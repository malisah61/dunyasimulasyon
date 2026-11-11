extends Node2D
## Dünyanın görüntüsü: arazi + yapılar bir resimde (her karo 4x4 piksel),
## canlılar ve efektler _draw ile çizilir.

const KARO := 4
const SimS = preload("res://betikler/sim.gd")

var sim
var resim: Image
var doku: ImageTexture
var sprite: Sprite2D
var alfa := 1.0            # tick arası ara değer (akıcı hareket)
var ara_deger := true
var secili := -1
var piks := PackedByteArray()      # arazi resmi (RGB8), doğrudan yazılır
var su_mes := PackedByteArray()    # su karosunun karaya uzaklığı (0-7)
var son_biyom := PackedByteArray() # son çizilen biyom (kıyı değişimini anlamak için)
var pal := PackedByteArray()       # karo paleti (6 renk × rgb)
var gurultu := PackedInt32Array()  # önceden hesaplanmış piksel gürültüsü (karo başına hash yerine)
var karo_onbellek: Dictionary = {}  # basit karo görünümü → 4x4 resim
var gorunur := Rect2()
var son_guncelleme := 0
var krallik_harita := false   # krallık toprakları renkli gösterilsin mi
var huzur_harita := false     # köylerin huzuru (yeşil → kırmızı) gösterilsin mi
var toprak_doku: ImageTexture
var toprak_zaman := -100000
var imlec := Vector2(-1, -1)  # fırça önizlemesi (dünya karosu), -1 = yok
var imlec_r := 0.0
var imlec_renk := Color(1, 1, 1, 0.7)
# tür başına önbellek (her karede sözlük aramasını önler)
var tur_renk := PackedColorArray()
var tur_ten := PackedColorArray()
var tur_boy := PackedFloat32Array()
var tur_yet := PackedInt32Array()
var tur_kod := PackedByteArray()   # 0 diğer, 1 elf, 2 ork, 3 cüce, 4 dev, 5 goblin, 6 kertenkele, 7 uzaylı
const SAKAL := Color("8a6a4a")
const GOLGE := Color(0, 0, 0, 0.28)
const TAC := Color("ffd23a")

const SU_SHADER := """
shader_type canvas_item;
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float su = step(0.12, c.b - c.r) * step(c.g, c.b + 0.02);
	vec2 px = floor(UV * vec2(textureSize(TEXTURE, 0)));
	vec2 karo = floor(px / 4.0);
	float d = sin(TIME * 1.7 + karo.x * 0.9 + karo.y * 0.55) * sin(TIME * 1.1 - karo.y * 0.8 + karo.x * 0.3);
	float isik = step(0.82, d) * step(0.5, fract(sin(dot(px, vec2(12.9898, 78.233))) * 43758.5453));
	c.rgb += su * isik * 0.10;
	COLOR = c;
}
"""

var B_RENK := [
	Color("1b3f75"), Color("2e6fb0"), Color("e3d39a"), Color("6fb24a"), Color("3f8a35"),
	Color("a9b85a"), Color("e0bf6e"), Color("4f6a3a"), Color("7d8f62"), Color("8a8580"),
	Color("eef3f7"), Color("e2531c"), Color("5c5246"),
]


func _ready() -> void:
	_tablo_kur()
	sprite = Sprite2D.new()
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.show_behind_parent = true
	# suya hafif, piksel piksel kıpırdayan parıltı (yalnızca mavimsi piksellerde)
	var sh := Shader.new()
	sh.code = SU_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	sprite.material = mat
	add_child(sprite)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func baglan(s) -> void:
	sim = s
	tur_renk.clear(); tur_ten.clear(); tur_boy.clear(); tur_yet.clear(); tur_kod.clear()
	var kodlar := {"elf": 1, "ork": 2, "cuce": 3, "dev": 4, "goblin": 5, "kertenkele": 6, "uzayli": 7}
	for t in sim.turler:
		tur_renk.append(t["renk_c"])
		tur_ten.append(t["ten_c"])
		tur_boy.append(float(t["boy"]))
		tur_yet.append(int(t["yetiskin"]) * 12)
		tur_kod.append(int(kodlar.get(t["id"], 0)))
	resim = Image.create(sim.gen * KARO, sim.yuk * KARO, false, Image.FORMAT_RGB8)
	_hepsini_ciz()
	doku = ImageTexture.create_from_image(resim)
	sprite.texture = doku
	sim.hepsi_degisti = false
	sim.degisen.clear()


func guncelle() -> void:
	if sim == null:
		return
	if sim.hepsi_degisti:
		if resim.get_width() != sim.gen * KARO or resim.get_height() != sim.yuk * KARO:
			baglan(sim)
			return
		_hepsini_ciz()
		doku.update(resim)
		sim.hepsi_degisti = false
		sim.degisen.clear()
	elif sim.degisen.size() > 0:
		var simdi := Time.get_ticks_msec()
		# sık değişen karolar (yangın) her karede değil, en çok 60 ms'de bir çizilir
		if simdi - son_guncelleme > 60:
			var n := mini(sim.degisen.size(), 6000)
			var arazi := false
			for m in n:
				var k: int = sim.degisen[m]
				if not arazi and sim.biyom[k] != son_biyom[k]:
					arazi = true
				_karo_ciz(k)
			if arazi:
				# kıyı değişti: bölgedeki su derinliği ve köpük yeniden hesaplanır
				var x0: int = sim.gen
				var y0: int = sim.yuk
				var x1 := -1
				var y1 := -1
				for m in n:
					var k: int = sim.degisen[m]
					if sim.biyom[k] != son_biyom[k]:
						son_biyom[k] = sim.biyom[k]
						x0 = mini(x0, k % sim.gen); x1 = maxi(x1, k % sim.gen)
						y0 = mini(y0, k / sim.gen); y1 = maxi(y1, k / sim.gen)
				_bolge_yenile(x0, y0, x1, y1)
			if n >= sim.degisen.size():
				sim.degisen.clear()
			else:
				sim.degisen = sim.degisen.slice(n)
			resim.set_data(sim.gen * KARO, sim.yuk * KARO, false, Image.FORMAT_RGB8, piks)
			doku.update(resim)
			son_guncelleme = simdi
	queue_redraw()


func _hash(k: int, s: int) -> int:
	var h := (k * 374761393 + s * 668265263) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return h ^ (h >> 16)


func _tablo_kur() -> void:
	if gurultu.size() == 8192:
		return
	pal.resize(18)
	gurultu.resize(8192)
	for n in 8192:
		gurultu[n] = _hash(n, 7)


## Tüm haritayı bayt dizisine çizer (set_pixel yerine doğrudan bellek: ~6 kat hızlı).
func _hepsini_ciz() -> void:
	var gen: int = sim.gen
	var yuk: int = sim.yuk
	var n := gen * yuk
	_tablo_kur()
	piks.resize(n * KARO * KARO * 3)
	son_biyom = sim.biyom.duplicate()
	_su_mesafe_hesapla()
	# basit karolar (açık deniz, iç kara; yapısız) önbellekteki 4x4 resimlerden C++ ile kopyalanır
	var hizli := PackedInt32Array()
	var anahtar := PackedInt32Array()
	var biyom: PackedByteArray = sim.biyom
	var yapi: PackedByteArray = sim.yapi
	var maden: PackedByteArray = sim.maden
	var ates: PackedByteArray = sim.ates
	var sel: PackedByteArray = sim.sel
	for k in n:
		var b: int = biyom[k]
		var x := k % gen
		var y := k / gen
		var a := -1
		if ates[k] == 0 and sel[k] == 0 and x > 0 and y > 0 and x < gen - 1 and y < yuk - 1:
			var h := _hash(k, 1)
			if b <= SimS.B_SIG:
				if su_mes[k] >= 2:
					a = ((b * 8 + su_mes[k]) * 9 + h % 9) * 64 + (h & 63)
			elif biyom[k - 1] > SimS.B_SIG and biyom[k + 1] > SimS.B_SIG and biyom[k - gen] > SimS.B_SIG and biyom[k + gen] > SimS.B_SIG:
				var dg := 1 if (b == SimS.B_DAG and biyom[k - 1] != SimS.B_DAG) else 0
				a = (((b * 8 + dg) * 9 + h % 9) * 64 + (h & 63)) + 1000000
		if a < 0:
			_karo_ciz(k)
		else:
			hizli.append(k)
			anahtar.append(a)
	resim.set_data(gen * KARO, yuk * KARO, false, Image.FORMAT_RGB8, piks)
	var gecici := PackedByteArray()
	gecici.resize(48)
	var r := Rect2i(0, 0, KARO, KARO)
	for m in hizli.size():
		var a := anahtar[m]
		var k := hizli[m]
		var img = karo_onbellek.get(a)
		if img == null:
			_karo_yaz(k, gecici, 0, 0, KARO)
			img = Image.create_from_data(KARO, KARO, false, Image.FORMAT_RGB8, gecici)
			karo_onbellek[a] = img
		resim.blit_rect(img, r, Vector2i((k % gen) * KARO, (k / gen) * KARO))
	piks = resim.get_data()
	# önbellekten gelen karoların üstüne yapı ve maden
	var ek := false
	for k in hizli:
		if yapi[k] != 0 or maden[k] != 0:
			_karo_ek(k)
			ek = true
	if ek:
		resim.set_data(gen * KARO, yuk * KARO, false, Image.FORMAT_RGB8, piks)


## Her su karosunun en yakın karaya uzaklığı (0-7). Çoklu kaynaklı genişlik araması: O(n).
func _su_mesafe_hesapla() -> void:
	var gen: int = sim.gen
	var yuk: int = sim.yuk
	var n := gen * yuk
	var biyom: PackedByteArray = sim.biyom
	su_mes.resize(n)
	su_mes.fill(7)
	var kuyruk := PackedInt32Array()
	for k in n:
		if biyom[k] > SimS.B_SIG:
			su_mes[k] = 0
			kuyruk.append(k)
	var bas := 0
	while bas < kuyruk.size():
		var k := kuyruk[bas]
		bas += 1
		var d := su_mes[k] + 1
		if d >= 7:
			continue
		var x := k % gen
		if x > 0 and su_mes[k - 1] > d:
			su_mes[k - 1] = d; kuyruk.append(k - 1)
		if x < gen - 1 and su_mes[k + 1] > d:
			su_mes[k + 1] = d; kuyruk.append(k + 1)
		if k >= gen and su_mes[k - gen] > d:
			su_mes[k - gen] = d; kuyruk.append(k - gen)
		if k < n - gen and su_mes[k + gen] > d:
			su_mes[k + gen] = d; kuyruk.append(k + gen)


## Arazi değişince yalnızca değişen bölgenin (7 karo payla) su derinliği yeniden hesaplanır ve çizilir.
func _bolge_yenile(x0: int, y0: int, x1: int, y1: int) -> void:
	var gen: int = sim.gen
	var yuk: int = sim.yuk
	var biyom: PackedByteArray = sim.biyom
	var ax0 := maxi(0, x0 - 14); var ay0 := maxi(0, y0 - 14)
	var ax1 := mini(gen - 1, x1 + 14); var ay1 := mini(yuk - 1, y1 + 14)
	var kuyruk := PackedInt32Array()
	for y in range(ay0, ay1 + 1):
		for x in range(ax0, ax1 + 1):
			var k := y * gen + x
			if biyom[k] > SimS.B_SIG:
				su_mes[k] = 0
				kuyruk.append(k)
			else:
				su_mes[k] = 7
	var bas := 0
	while bas < kuyruk.size():
		var k := kuyruk[bas]
		bas += 1
		var d := su_mes[k] + 1
		if d >= 7:
			continue
		var x := k % gen
		var y := k / gen
		if x > ax0 and su_mes[k - 1] > d:
			su_mes[k - 1] = d; kuyruk.append(k - 1)
		if x < ax1 and su_mes[k + 1] > d:
			su_mes[k + 1] = d; kuyruk.append(k + 1)
		if y > ay0 and su_mes[k - gen] > d:
			su_mes[k - gen] = d; kuyruk.append(k - gen)
		if y < ay1 and su_mes[k + gen] > d:
			su_mes[k + gen] = d; kuyruk.append(k + gen)
	for y in range(maxi(0, y0 - 7), mini(yuk - 1, y1 + 7) + 1):
		for x in range(maxi(0, x0 - 7), mini(gen - 1, x1 + 7) + 1):
			_karo_ciz(y * gen + x)


func _px(x: int, y: int, c: Color) -> void:
	var o: int = (y * sim.gen * KARO + x) * 3
	piks[o] = int(clampf(c.r, 0.0, 1.0) * 255.0)
	piks[o + 1] = int(clampf(c.g, 0.0, 1.0) * 255.0)
	piks[o + 2] = int(clampf(c.b, 0.0, 1.0) * 255.0)


## Palete renk yazar (r,g,b bayt).
func _pal(n: int, c: Color) -> void:
	pal[n * 3] = int(clampf(c.r, 0.0, 1.0) * 255.0)
	pal[n * 3 + 1] = int(clampf(c.g, 0.0, 1.0) * 255.0)
	pal[n * 3 + 2] = int(clampf(c.b, 0.0, 1.0) * 255.0)


## Bir karoyu (4x4 piksel) bayt dizisine çizer. Karo başına 6 renklik palet kurulur, pikseller paletten seçilir.
func _karo_ciz(k: int) -> void:
	_karo_yaz(k, piks, (k % sim.gen) * KARO, (k / sim.gen) * KARO, sim.gen * KARO)
	_karo_ek(k)


## Karonun zemin pikselleri. Görünüş yalnızca biyom, komşular, h%9 ve h&63'e bağlıdır (önbelleklenebilir).
func _karo_yaz(k: int, hedef: PackedByteArray, x0: int, y0: int, satir: int) -> void:
	var gen: int = sim.gen
	var tx := k % gen
	var ty := k / gen
	var biyom: PackedByteArray = sim.biyom
	var b: int = biyom[k]
	var temel: Color = B_RENK[b]
	var h := _hash(k, 1)
	var hv := h & 63
	var oyn := float(h % 9 - 4) * 0.012
	temel = Color(temel.r + oyn, temel.g + oyn, temel.b + oyn)
	var su := b <= SimS.B_SIG
	# komşular (kıyı köpüğü, ıslak kum, dağ gölgesi için)
	var ks: int = biyom[k - gen] if ty > 0 else b
	var ka: int = biyom[k + gen] if ty < sim.yuk - 1 else b
	var kb: int = biyom[k - 1] if tx > 0 else b
	var kd: int = biyom[k + 1] if tx < gen - 1 else b
	var ks_k := ks > SimS.B_SIG
	var ka_k := ka > SimS.B_SIG
	var kb_k := kb > SimS.B_SIG
	var kd_k := kd > SimS.B_SIG
	# palet: 0 temel, 1-3 desen, 4 kıyı (köpük ya da ıslak şerit), 5 köpük karışımı
	if su:
		var d: int = su_mes[k] if k < su_mes.size() else 7
		temel = temel.lerp(Color("4fa3c8"), clampf((7 - d) * 0.07, 0.0, 0.42))
		_pal(0, temel); _pal(1, temel.lightened(0.15)); _pal(4, Color("e8f4f4")); _pal(5, temel.lerp(Color("e8f4f4"), 0.45))
	else:
		_pal(0, temel)
		match b:
			SimS.B_ORMAN:
				_pal(1, temel.darkened(0.25)); _pal(2, temel.darkened(0.15)); _pal(3, Color("5a3a20")); _pal(5, temel.darkened(0.3))
			SimS.B_DAG:
				_pal(1, Color("f2f2f2") if hv % 2 == 0 else temel.lightened(0.2)); _pal(2, temel.darkened(0.18)); _pal(3, temel.lightened(0.08))
			SimS.B_TEPE:
				_pal(1, temel.darkened(0.12)); _pal(2, temel.lightened(0.08))
			SimS.B_BATAK:
				_pal(1, Color("3d6b78")); _pal(2, Color("6a8a4a"))
			SimS.B_LAV:
				_pal(1, Color("ffb020")); _pal(2, Color("ff7a10"))
			SimS.B_OVA, SimS.B_BOZKIR:
				_pal(1, temel.lightened(0.12)); _pal(2, temel.darkened(0.08)); _pal(3, Color("e8d870") if b == SimS.B_OVA else Color("c8b878"))
			SimS.B_KAR:
				_pal(1, Color("d8e4f0")); _pal(2, Color("ffffff"))
			SimS.B_YANIK:
				_pal(1, Color("3a3630")); _pal(2, Color("6f9a3c"))   # kül ve yeni filizler
			_:
				_pal(1, temel.darkened(0.06)); _pal(2, temel.lightened(0.06))
		_pal(4, temel.lerp(Color("b8c8a0") if b != SimS.B_KUM else Color("c8b880"), 0.5))
	var agac := hv % 3
	for py in KARO:
		var o: int = ((y0 + py) * satir + x0) * 3
		for px in KARO:
			var hh: int = gurultu[hv * 16 + py * 4 + px]
			var n := 0
			if su:
				# köpük: karaya bakan kenar pikselleri
				if (py == 0 and ks_k) or (py == 3 and ka_k) or (px == 0 and kb_k) or (px == 3 and kd_k):
					n = 4 if hh % 3 != 0 else 5
				elif hh % 23 == 0:
					n = 1
			else:
				match b:
					SimS.B_ORMAN:
						# ağaç: koyu taç, gövde, sağda gölge
						if py <= 2 and px >= agac % 2 and px <= 1 + agac % 2 + 1:
							n = 1 if (px + py) % 2 == 0 else 2
						if py == 3 and px == 1 + agac % 2:
							n = 3
						elif py == 3 and px == 2 + agac % 2:
							n = 5
					SimS.B_DAG:
						if py == 0 or (py == 1 and px >= 1 and px <= 2):
							n = 1
						elif px + py >= 5:
							n = 2
						elif px == 0 and kb != SimS.B_DAG:
							n = 3
					SimS.B_TEPE:
						if px + py >= 5:
							n = 1
						elif px + py <= 1:
							n = 2
					SimS.B_BATAK, SimS.B_LAV, SimS.B_KAR:
						if hh % 5 == 0:
							n = 1
						elif hh % 7 == 0:
							n = 2
					SimS.B_OVA, SimS.B_BOZKIR:
						if hh % 11 == 0:
							n = 1
						elif hh % 17 == 0:
							n = 2
						elif hh % 61 == 0:
							n = 3   # çiçek / kuru ot
					_:
						if hh % 13 == 0:
							n = 1
						elif hh % 19 == 0:
							n = 2
				# ıslak kıyı şeridi
				if (py == 0 and not ks_k) or (py == 3 and not ka_k) or (px == 0 and not kb_k) or (px == 3 and not kd_k):
					n = 4
			hedef[o] = pal[n * 3]
			hedef[o + 1] = pal[n * 3 + 1]
			hedef[o + 2] = pal[n * 3 + 2]
			o += 3


## Karonun üstündekiler: maden, yapı, ateş, sel.
func _karo_ek(k: int) -> void:
	var x0: int = (k % sim.gen) * KARO
	var y0: int = (k / sim.gen) * KARO
	var h := _hash(k, 1)
	if sim.maden[k] > 0 and sim.yapi[k] == 0:
		_px(x0 + 2, y0 + 2, Color("ffd23a") if sim.maden[k] == 1 else Color("b5653a"))
		_px(x0 + 1, y0 + 2, Color("6a6460"))
	var y: int = sim.yapi[k]
	if y != 0:
		_yapi_ciz(k, y, x0, y0)
	if sim.ates[k] > 0:
		for n in 6:
			var hh := _hash(k, n + 31)
			_px(x0 + hh % 4, y0 + (hh >> 3) % 4, Color("ff7a1a") if n % 2 == 0 else Color("ffd84a"))
	if k < sim.sel.size() and sim.sel[k] > 0:
		# sel: bulanık su
		for py in KARO:
			for px in KARO:
				var hh: int = gurultu[(h + py * 4 + px + 7) & 8191]
				if hh % 4 != 0:
					_px(x0 + px, y0 + py, Color("5a86a8") if hh % 5 != 0 else Color("8aa8b8"))


func _yapi_ciz(k: int, tip: int, x0: int, y0: int) -> void:
	var kr_renk := Color("c8c8c8")
	var duvar := Color("c9a46a")
	var v = sim.koyler.get(sim.yapi_koy[k])
	if v != null:
		var kr = sim.kralliklar.get(v["krallik"])
		if kr != null:
			kr_renk = Color(kr["renk"])
		var irk: String = sim.turler[v["irk"]]["id"]
		match irk:
			"elf": duvar = Color("9a7a4a")
			"cuce": duvar = Color("9a9a9a")
			"ork": duvar = Color("6a5030")
			"goblin": duvar = Color("6a6a40")
			"kertenkele": duvar = Color("8aa070")
			"dev": duvar = Color("8a8070")
			"uzayli": duvar = Color("b0c0d0")
	var cati := kr_renk.darkened(0.15)
	var desen := []
	match tip:
		SimS.Y_MERKEZ:
			desen = ["..F.", "..FF", "..|.", ".ww."]
		SimS.Y_EV:
			desen = [".cc.", "cccc", "wwww", "wdww"]
		SimS.Y_TARLA:
			desen = ["gtgt", "tgtg", "gtgt", "tgtg"]
		SimS.Y_AMBAR:
			desen = ["cccc", "wwww", "wddw", "wddw"]
		SimS.Y_MADEN:
			desen = ["ssss", "s..s", "s..s", "tttt"]
		SimS.Y_DEMIRHANE:
			desen = ["s.o.", "ssss", "wwww", "wdow"]
		SimS.Y_KISLA:
			desen = ["cFcc", "cccc", "wwww", "wddw"]
		SimS.Y_TAPINAK:
			desen = [".Y..", ".cc.", "cccc", "wdww"]
		SimS.Y_KUTUPHANE:
			desen = ["cccc", "wBwB", "wwww", "wddw"]
		SimS.Y_PAZAR:
			desen = ["cYcY", "....", "o..o", "tttt"]
		SimS.Y_SARAY:
			desen = ["F..F", "cccc", "wYYw", "wddw"]
		SimS.Y_KULE:
			desen = [".cc.", ".ww.", ".ww.", ".wd."]
		SimS.Y_HARABE:
			desen = ["....", ".s..", "s.s.", ".ss."]
		SimS.Y_KALE:
			desen = ["sFs.", "ssss", "sdds", "sdds"]
	for py in desen.size():
		var satir: String = desen[py]
		for px in 4:
			var ch := satir[px]
			var c := Color.TRANSPARENT
			match ch:
				"c": c = cati
				"w": c = duvar
				"d": c = duvar.darkened(0.55)
				"F": c = kr_renk.lightened(0.15)
				"|": c = Color("5a3a20")
				"g": c = Color("c9b840")
				"t": c = Color("8a6030")
				"s": c = Color("6a6460")
				"o": c = Color("ff8a2a")
				"Y": c = Color("ffd23a")
				"B": c = Color("3060c0")
			if c.a > 0.0:
				_px(x0 + px, y0 + py, c)


# ------------------------------------------------------------ canlılar
func _draw() -> void:
	if sim == null:
		return
	var tr := get_canvas_transform()
	var ters := tr.affine_inverse()
	var ekran := get_viewport_rect().size
	var ust_sol: Vector2 = ters * Vector2.ZERO
	var alt_sag: Vector2 = ters * ekran
	gorunur = Rect2(ust_sol / KARO, (alt_sag - ust_sol) / KARO).grow(2)
	var olcek: float = tr.get_scale().x
	var detay := olcek >= 1.6
	if krallik_harita:
		_krallik_toprak()
	if huzur_harita:
		_huzur_ciz()
	_mevsim_ortu()
	var a := alfa if ara_deger else 1.0
	var gx := gorunur.position.x
	var gy := gorunur.position.y
	var gx2 := gorunur.end.x
	var gy2 := gorunur.end.y
	var c_var: PackedByteArray = sim.c_var
	var c_x: PackedFloat32Array = sim.c_x
	var c_y: PackedFloat32Array = sim.c_y
	var c_tur: PackedByteArray = sim.c_tur
	var t_irk: PackedByteArray = sim.t_irk
	var t_ucan: PackedByteArray = sim.t_ucan
	if not detay:
		# uzak görünüm: her canlı tek nokta; tek çizim çağrısı (draw_multiline_colors) ile toplu çizilir
		var noktalar := PackedVector2Array()
		var renkler := PackedColorArray()
		for i in sim.ust:
			if c_var[i] == 0:
				continue
			var x: float = c_x[i]
			var y: float = c_y[i]
			if x < gx or x > gx2 or y < gy or y > gy2:
				continue
			var px := x * KARO
			var py := y * KARO
			noktalar.append(Vector2(px - 1.5, py))
			noktalar.append(Vector2(px + 1.5, py))
			renkler.append(tur_renk[c_tur[i]])
		if noktalar.size() > 0:
			draw_multiline_colors(noktalar, renkler, 3.0)
		_secili_ciz()
		_efektleri_ciz()
		return
	var zaman := Time.get_ticks_msec()
	var kral := {}
	var cag_kr := {}
	for id in sim.kralliklar:
		var kr: Dictionary = sim.kralliklar[id]
		if kr["kral"] >= 0 and kr["kral_uid"] != 0:
			kral[kr["kral"]] = true
	for i in sim.ust:
		if c_var[i] == 0:
			continue
		var x: float = c_x[i]
		var y: float = c_y[i]
		if x < gx or x > gx2 or y < gy or y > gy2:
			continue
		var hareketli: bool = x != sim.c_ox[i] or y != sim.c_oy[i]
		if a < 1.0:
			x = lerpf(sim.c_ox[i], x, a)
			y = lerpf(sim.c_oy[i], y, a)
		var tur: int = c_tur[i]
		var px := x * KARO
		var py := y * KARO
		var boy: float = tur_boy[tur]
		var renk: Color = tur_renk[tur]
		var ten: Color = tur_ten[tur]
		if t_irk[tur] == 1:
			var yt: bool = sim.c_yas[i] >= tur_yet[tur]
			var s := boy * (1.0 if yt else 0.65)
			var durum: int = sim.c_durum[i]
			var asker := durum == SimS.D_ASKER
			var gov := renk.darkened(0.35) if asker else renk
			# gölge
			draw_rect(Rect2(px - 1.2 * s, py + 1.6 * s, 2.4 * s, 0.7 * s), GOLGE)
			# yürürken bacaklar sırayla
			var adim_f := 0.0
			if hareketli:
				adim_f = 0.5 * s if ((zaman / 140 + i) % 2 == 0) else -0.5 * s
			draw_rect(Rect2(px - 0.9 * s, py + 1.0 * s, 0.7 * s, 0.9 * s + adim_f), gov.darkened(0.3))
			draw_rect(Rect2(px + 0.2 * s, py + 1.0 * s, 0.7 * s, 0.9 * s - adim_f), gov.darkened(0.3))
			draw_rect(Rect2(px - 1.0 * s, py - 1.0 * s, 2.0 * s, 2.2 * s), gov)
			draw_rect(Rect2(px - 0.8 * s, py - 2.8 * s, 1.6 * s, 1.8 * s), ten)
			match tur_kod[tur]:
				1:  # elf: sivri kulak
					draw_rect(Rect2(px - 1.2 * s, py - 2.5 * s, 0.4 * s, 0.6 * s), ten)
					draw_rect(Rect2(px + 0.8 * s, py - 2.5 * s, 0.4 * s, 0.6 * s), ten)
				2:  # ork: diş
					draw_rect(Rect2(px - 0.5 * s, py - 1.3 * s, 0.3 * s, 0.4 * s), Color.WHITE)
					draw_rect(Rect2(px + 0.2 * s, py - 1.3 * s, 0.3 * s, 0.4 * s), Color.WHITE)
				3:  # cüce: sakal
					draw_rect(Rect2(px - 0.8 * s, py - 1.6 * s, 1.6 * s, 1.2 * s), SAKAL)
				5:  # goblin: büyük kulak
					draw_rect(Rect2(px - 1.5 * s, py - 2.6 * s, 0.7 * s, 0.5 * s), ten)
					draw_rect(Rect2(px + 0.8 * s, py - 2.6 * s, 0.7 * s, 0.5 * s), ten)
				6:  # kertenkele: kuyruk
					draw_line(Vector2(px + 0.8 * s, py + 1.2 * s), Vector2(px + 2.2 * s, py + 1.8 * s), renk, 0.6 * s)
				7:  # uzaylı: anten
					draw_line(Vector2(px - 0.4 * s, py - 2.8 * s), Vector2(px - 0.8 * s, py - 3.8 * s), ten, 0.3 * s)
					draw_line(Vector2(px + 0.4 * s, py - 2.8 * s), Vector2(px + 0.8 * s, py - 3.8 * s), ten, 0.3 * s)
			if kral.has(i):
				draw_rect(Rect2(px - 0.8 * s, py - 3.4 * s, 1.6 * s, 0.6 * s), TAC)
				draw_rect(Rect2(px - 0.8 * s, py - 3.8 * s, 0.4 * s, 0.4 * s), TAC)
				draw_rect(Rect2(px + 0.4 * s, py - 3.8 * s, 0.4 * s, 0.4 * s), TAC)
			if asker:
				# silah çağa göre: mızrak → kılıç → tüfek → lazer
				var cag: int = 0
				var kid: int = sim.c_koy[i]
				if cag_kr.has(kid):
					cag = cag_kr[kid]
				else:
					var v = sim.koyler.get(kid)
					cag = v["cag"] if v != null else 0
					cag_kr[kid] = cag
				var el := Vector2(px + 1.2 * s, py)
				if cag <= 1:
					draw_line(el + Vector2(0, -2.8 * s), el + Vector2(0, 1.5 * s), Color("8a6030"), 0.4 * s)
					draw_rect(Rect2(el.x - 0.3 * s, el.y - 3.4 * s, 0.6 * s, 0.7 * s), Color("b0b0b8"))
				elif cag <= 3:
					draw_line(el + Vector2(0, -2.4 * s), el + Vector2(0, 0.6 * s), Color("dfe4ea"), 0.5 * s)
					draw_line(el + Vector2(-0.6 * s, 0.2 * s), el + Vector2(0.6 * s, 0.2 * s), Color("8a6030"), 0.4 * s)
				elif cag <= 5:
					draw_line(el + Vector2(-0.4 * s, -1.6 * s), el + Vector2(0.8 * s, 0.8 * s), Color("303038"), 0.5 * s)
				else:
					draw_line(el + Vector2(-0.4 * s, -1.6 * s), el + Vector2(0.8 * s, 0.8 * s), Color("80ffb0"), 0.5 * s)
		elif t_ucan[tur] == 1:
			var kanat := sin(zaman * 0.008 + i) * 2.0 * boy
			draw_rect(Rect2(px - 1.5 * boy, py + 3.0 * boy, 3.0 * boy, 0.8 * boy), GOLGE)
			draw_rect(Rect2(px - 2.0 * boy, py - 1.0 * boy, 4.0 * boy, 2.0 * boy), renk)
			draw_line(Vector2(px - 1.5 * boy, py - 0.5 * boy), Vector2(px - 4.0 * boy, py - 1.0 * boy - kanat), renk.lightened(0.2), 1.2)
			draw_line(Vector2(px + 1.5 * boy, py - 0.5 * boy), Vector2(px + 4.0 * boy, py - 1.0 * boy - kanat), renk.lightened(0.2), 1.2)
			draw_rect(Rect2(px + 1.6 * boy, py - 1.6 * boy, 1.4 * boy, 1.2 * boy), ten)
		else:
			draw_rect(Rect2(px - 1.6 * boy, py + 1.0 * boy, 3.2 * boy, 0.6 * boy), GOLGE)
			var bacak := 0.0
			if hareketli:
				bacak = 0.4 * boy if ((zaman / 160 + i) % 2 == 0) else 0.0
			draw_rect(Rect2(px - 1.3 * boy, py + 0.8 * boy, 0.6 * boy, 0.7 * boy - bacak), renk.darkened(0.3))
			draw_rect(Rect2(px + 0.7 * boy, py + 0.8 * boy, 0.6 * boy, 0.3 * boy + bacak), renk.darkened(0.3))
			draw_rect(Rect2(px - 1.6 * boy, py - 1.0 * boy, 3.2 * boy, 2.0 * boy), renk)
			draw_rect(Rect2(px + 1.0 * boy, py - 1.6 * boy, 1.2 * boy, 1.2 * boy), ten)
	_secili_ciz()
	_efektleri_ciz()


func _secili_ciz() -> void:
	if secili >= 0 and sim.c_var[secili] == 1:
		var p := Vector2(sim.c_x[secili], sim.c_y[secili]) * KARO
		draw_arc(p + Vector2(0, -1), 5.0, 0, TAU, 20, Color(1, 1, 0.3), 0.8)
	if imlec.x >= 0.0 and imlec_r > 0.0:
		draw_arc(imlec * KARO, imlec_r * KARO, 0, TAU, 40, imlec_renk, 1.0 / maxf(0.2, get_canvas_transform().get_scale().x) * 2.0)


## Krallık haritası: her kara karosu en yakın köyün krallığına boyanır, sınırlar koyu çizilir.
## Doku saniyede bir yeniden hesaplanır (her karede değil).
func _krallik_toprak() -> void:
	var simdi := Time.get_ticks_msec()
	if toprak_doku == null or simdi - toprak_zaman > 1000:
		toprak_zaman = simdi
		_toprak_hesapla()
	draw_texture_rect(toprak_doku, Rect2(0, 0, sim.gen * KARO, sim.yuk * KARO), false)


func _toprak_hesapla() -> void:
	var gen: int = sim.gen
	var yuk: int = sim.yuk
	var n := gen * yuk
	var sahip := PackedInt32Array()
	sahip.resize(n)
	sahip.fill(-1)
	var mesafe := PackedInt32Array()
	mesafe.resize(n)
	mesafe.fill(1 << 30)
	var dokunulan := PackedInt32Array()
	var biyom: PackedByteArray = sim.biyom
	var renkler := {}
	for id in sim.koyler:
		var v: Dictionary = sim.koyler[id]
		var kid: int = v["krallik"]
		var kr = sim.kralliklar.get(kid)
		if kr == null:
			continue
		if not renkler.has(kid):
			renkler[kid] = Color(kr["renk"])
		var r: int = int(v["yaricap"]) + 3
		var vx: int = v["x"]
		var vy: int = v["y"]
		for oy in range(-r, r + 1):
			var yy := vy + oy
			if yy < 0 or yy >= yuk:
				continue
			for ox in range(-r, r + 1):
				var xx := vx + ox
				var d2 := ox * ox + oy * oy
				if xx < 0 or xx >= gen or d2 > r * r:
					continue
				var k := yy * gen + xx
				if biyom[k] <= SimS.B_SIG or d2 >= mesafe[k]:
					continue
				if sahip[k] < 0:
					dokunulan.append(k)
				mesafe[k] = d2
				sahip[k] = kid
	var veri := PackedByteArray()
	veri.resize(n * 4)
	for k in dokunulan:
		var kid := sahip[k]
		var c: Color = renkler[kid]
		var x := k % gen
		var sinir := (x == 0 or sahip[k - 1] != kid) or (x == gen - 1 or sahip[k + 1] != kid) or (k < gen or sahip[k - gen] != kid) or (k >= n - gen or sahip[k + gen] != kid)
		veri[k * 4] = int(c.r * 255)
		veri[k * 4 + 1] = int(c.g * 255)
		veri[k * 4 + 2] = int(c.b * 255)
		veri[k * 4 + 3] = 210 if sinir else 85
	var img := Image.create_from_data(gen, yuk, false, Image.FORMAT_RGBA8, veri)
	if toprak_doku == null or toprak_doku.get_width() != gen or toprak_doku.get_height() != yuk:
		toprak_doku = ImageTexture.create_from_image(img)
	else:
		toprak_doku.update(img)


## Mevsim örtüsü: kışın kuzey kuşağı karla örtülür (yumuşak geçişli), kara kışta tüm dünya soğur.
func _mevsim_ortu() -> void:
	var ay: int = sim.ay % 12
	var kis := ay == 11 or ay <= 1
	var gen_px: float = sim.gen * KARO
	var yuk_px: float = sim.yuk * KARO
	if kis or sim.kis_ay > 0:
		var bant: float = yuk_px * (0.28 if sim.kis_ay == 0 else 0.42)
		var ust := Color(0.95, 0.97, 1.0, 0.38)
		var alt := Color(0.95, 0.97, 1.0, 0.0)
		draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(gen_px, 0), Vector2(gen_px, bant), Vector2(0, bant)]),
			PackedColorArray([ust, ust, alt, alt]))
	if sim.kis_ay > 0:
		draw_rect(Rect2(0, 0, gen_px, yuk_px), Color(0.6, 0.75, 1.0, 0.10))
	if sim.kuraklik_ay > 0:
		draw_rect(Rect2(0, 0, gen_px, yuk_px), Color(1.0, 0.75, 0.3, 0.08))


## Huzur haritası: her köy huzuruna göre yeşil (huzurlu) → kırmızı (isyana yakın) halka.
func _huzur_ciz() -> void:
	for id in sim.koyler:
		var v: Dictionary = sim.koyler[id]
		var h: float = float(v.get("huzur", 70.0)) / 100.0
		var c := Color(1.0, 0.15, 0.1).lerp(Color(0.25, 1.0, 0.3), clampf((h - 0.15) / 0.7, 0.0, 1.0))
		var p := Vector2(v["x"] + 0.5, v["y"] + 0.5) * KARO
		var r: float = (float(v["yaricap"]) + 1.0) * KARO
		draw_circle(p, r, Color(c, 0.22))
		draw_arc(p, r, 0, TAU, 32, Color(c, 0.85), 2.0)


func _efektleri_ciz() -> void:
	var zaman := Time.get_ticks_msec() * 0.001
	for e in sim.efektler:
		var p := Vector2(e[1], e[2]) * KARO
		match int(e[0]):
			0:
				draw_rect(Rect2(p - Vector2(1, 3), Vector2(2, 2)), Color(1, 0.2, 0.2, 0.9))
			1:
				var ust := p - Vector2(0, 60)
				var onceki := ust
				for n in 6:
					var nk := ust.lerp(p, (n + 1) / 6.0) + Vector2(randf_range(-4, 4), 0)
					draw_line(onceki, nk, Color(1, 1, 0.6), 1.5)
					onceki = nk
			2:
				for n in 3:
					draw_arc(p, 8.0 + n * 9.0 + fmod(zaman * 30.0, 9.0), 0, TAU, 32, Color(0.6, 0.4, 0.2, 0.6), 1.5)
			3:
				draw_circle(p, 6.0 + fmod(zaman * 10.0, 4.0), Color(1, 0.4, 0.1, 0.6))
			4:
				draw_circle(p, 12.0, Color(1, 0.8, 0.3, 0.5))
				draw_circle(p, 6.0, Color(1, 1, 0.8, 0.8))
			5:
				draw_arc(p, 20.0 + fmod(zaman * 40.0, 40.0), 0, TAU, 40, Color(0.5, 0.8, 1, 0.8), 3.0)
			6:
				for n in 30:
					var q := p + Vector2(randf_range(-24, 24), randf_range(-24, 24))
					draw_line(q, q + Vector2(-1, 3), Color(0.6, 0.8, 1, 0.8), 0.6)
			7:
				draw_line(p - Vector2(0, 30), p, Color(0.5, 1, 0.6, 0.7), 4.0)
			8:
				# tanrı silgisi: kırmızı halka söner
				draw_arc(p, float(e[4]) * KARO, 0, TAU, 40, Color(1, 0.3, 0.25, 0.25 * e[3]), 2.0)
			9:
				# ticaret kervanı: yol çizgisi ve yürüyen araba
				var q := Vector2(e[4], e[5]) * KARO
				var t := clampf(1.0 - float(e[3]) / 8.0 + fmod(zaman * 0.15, 0.125), 0.0, 1.0)
				draw_dashed_line(p, q, Color(1.0, 0.85, 0.45, 0.45), 1.0, 4.0)
				var a := p.lerp(q, t)
				draw_rect(Rect2(a - Vector2(2.5, 2.0), Vector2(5, 3)), Color("8a5a2a"))
				draw_rect(Rect2(a - Vector2(2.0, 3.5), Vector2(4, 1.6)), Color("f0e0c0"))
				draw_circle(a + Vector2(-1.5, 1.2), 0.9, Color("3a2a1a"))
				draw_circle(a + Vector2(1.5, 1.2), 0.9, Color("3a2a1a"))
			10:
				# isyan: kırmızı bayrak ve öfke halkası
				var nab := 1.0 + 0.25 * sin(zaman * 8.0)
				draw_arc(p, 14.0 * nab, 0, TAU, 32, Color(1, 0.2, 0.15, 0.8), 2.0)
				draw_line(p + Vector2(0, 2), p - Vector2(0, 14), Color("5a3a20"), 1.2)
				draw_colored_polygon(PackedVector2Array([p - Vector2(0, 14), p - Vector2(-8, 11.5 + sin(zaman * 6.0)), p - Vector2(0, 9)]), Color(0.9, 0.1, 0.1))
			11:
				# sel: genişleyen su halkaları
				for n in 3:
					draw_arc(p, 6.0 + n * 10.0 + fmod(zaman * 16.0, 10.0), 0, TAU, 32, Color(0.35, 0.6, 0.85, 0.55), 2.0)
	for h in sim.hortumlar:
		var p := Vector2(h[0], h[1]) * KARO
		for n in 5:
			var r := 2.0 + n * 1.6
			draw_arc(p - Vector2(0, n * 3.0), r, zaman * 8.0, zaman * 8.0 + 4.5, 10, Color(0.75, 0.75, 0.8, 0.8), 1.0)
	for u in sim.ufolar:
		var p := Vector2(u["x"], u["y"]) * KARO - Vector2(0, 16)
		draw_circle(p, 6.0, Color(0.7, 0.75, 0.8))
		draw_rect(Rect2(p - Vector2(9, 1), Vector2(18, 3)), Color(0.5, 0.55, 0.6))
		draw_circle(p - Vector2(0, 2), 3.0, Color(0.4, 1, 0.6))
