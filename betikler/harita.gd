extends Node2D
## Dünyanın görüntüsü: arazi + yapılar bir resimde (her karo 4x4 piksel),
## canlılar ve efektler _draw ile çizilir.

const KARO := 4
const SimS = preload("res://betikler/sim.gd")

var sim
var resim: Image
var doku: ImageTexture
var su_mat: ShaderMaterial
const PARCA := 32                  # harita dokusu parça boyu (karo)
var parca_gen := 0
var parca_yuk := 0
var parca_sprite: Array = []
var parca_doku: Array = []
var parca_kirli := PackedByteArray()
var damga := PackedByteArray()     # bir güncellemede aynı karo iki kez çizilmesin
var damga_no := 0
var kirli_parca := 0
var nokta_ay := -1                 # uzak görünüm nokta listesinin kurulduğu ay
var nokta_zaman := 0
var noktalar := PackedVector2Array()
var nokta_renk := PackedColorArray()
var gorunen_ay := -1               # yakın görünümde ekrandaki canlı listesinin kurulduğu ay
var gorunen_zaman := 0
var gorunen_kutu := Rect2()
var gorunen := PackedInt32Array()
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
var irk_harita := false       # ırkların yayılışı (ırk renkleriyle) gösterilsin mi
var toprak_ozet := true       # uzaktan krallık sınırları hafifçe gösterilsin mi
var tp_mod := 0               # 0 krallık, 1 ırk
var tp_dunya := -1
var tp_asama := 0             # 0 bekliyor, 1 köyler işleniyor, 2 pikseller yazılıyor
var tp_i := 0
var tp_koyler: Array = []
var tp_sahip := PackedInt32Array()
var tp_mesafe := PackedInt32Array()
var tp_dokunulan := PackedInt32Array()
var tp_veri := PackedByteArray()
var tp_renk := {}
var imlec := Vector2(-1, -1)  # fırça önizlemesi (dünya karosu), -1 = yok
var imlec_r := 0.0
var imlec_renk := Color(1, 1, 1, 0.7)
var olc_cizim_us := 0     # ölçüm: _draw süresi (µs, birikimli)
var olc_doku_us := 0      # ölçüm: harita dokusu güncelleme süresi (µs, birikimli)
# tür başına önbellek (her karede sözlük aramasını önler)
var tur_renk := PackedColorArray()
var tur_ten := PackedColorArray()
var tur_boy := PackedFloat32Array()
var tur_yet := PackedInt32Array()
var tur_kod := PackedByteArray()   # 0 diğer, 1 elf, 2 ork, 3 cüce, 4 dev, 5 goblin, 6 kertenkele, 7 uzaylı
const SAKAL := Color("8a6a4a")
const GOLGE := Color(0, 0, 0, 0.28)
const TAC := Color("ffd23a")
const GOZ := Color("1a1410")
const GIYSI := [Color("8a5a3a"), Color("b8a070"), Color("5a7a9a"), Color("9a4a3a"), Color("6a8a5a"), Color("c8b8a0")]
const SAC := [Color("3a2a1a"), Color("5a3a20"), Color("1a1a1a"), Color("8a6a3a"), Color("6a2a1a")]
const SAC_ELF := [Color("e8d890"), Color("d8e0e8"), Color("b89050")]
const SILAH_RENK := [Color("7a5028"), Color("d8a860"), Color("dfe4ea"), Color("f4f8ff"), Color("2a2a30"), Color("2a2a30"), Color("60ffb0")]
const MIGFER := [Color("8a6a4a"), Color("b08a50"), Color("9aa0aa"), Color("d0d6e0"), Color("5a6048"), Color("4a5040"), Color("80e8ff")]
var bina_katman: Node2D        # yakın görünümde ayrıntılı binalar (çizim komutları saklanır)
var bina_atlas: ImageTexture
var bina_kutu := Rect2()       # komutların kurulduğu bölge (karo)
var bina_kirli := false
var bina_zaman := 0
var ozet_zaman := 0
var ozet_ay := -1
var koy_halka: Array = []      # [x, y, yarıçap, renk]
var kusatmalar: Array = []     # [x, y, kuşatan rengi]
var yuruyusler: Array = []     # [x1, y1, x2, y2, renk] sefere çıkan köy → hedef

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
	# suya hafif, piksel piksel kıpırdayan parıltı (yalnızca mavimsi piksellerde)
	var sh := Shader.new()
	sh.code = SU_SHADER
	su_mat = ShaderMaterial.new()
	su_mat.shader = sh
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func baglan(s) -> void:
	sim = s
	if bina_katman == null:
		_bina_atlas_kur()
		bina_katman = Node2D.new()
		bina_katman.show_behind_parent = true
		bina_katman.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bina_katman.draw.connect(_binalari_ciz)
		add_child(bina_katman)
	tur_renk.clear(); tur_ten.clear(); tur_boy.clear(); tur_yet.clear(); tur_kod.clear()
	var kodlar := {"elf": 1, "ork": 2, "cuce": 3, "dev": 4, "goblin": 5, "kertenkele": 6, "uzayli": 7}
	for t in sim.turler:
		tur_renk.append(t["renk_c"])
		tur_ten.append(t["ten_c"])
		tur_boy.append(float(t["boy"]))
		tur_yet.append(int(t["yetiskin"]) * 12)
		tur_kod.append(int(kodlar.get(t["id"], 0)))
	resim = Image.create(sim.gen * KARO, sim.yuk * KARO, false, Image.FORMAT_RGB8)
	_parcalari_kur()
	_hepsini_ciz()
	_parcalari_yukle(true)
	sim.hepsi_degisti = false
	sim.degisen.clear()
	nokta_ay = -1
	gorunen_ay = -1
	ozet_ay = -1


## Harita PARCA×PARCA karoluk dokulara bölünür: bir karo değişince yalnızca o parçanın dokusu
## ekran kartına yeniden yüklenir (önce her değişiklikte tüm harita, Dev haritada ~8 MB yükleniyordu).
func _parcalari_kur() -> void:
	for sp in parca_sprite:
		sp.queue_free()
	parca_sprite.clear()
	parca_doku.clear()
	parca_gen = (sim.gen + PARCA - 1) / PARCA
	parca_yuk = (sim.yuk + PARCA - 1) / PARCA
	parca_kirli.resize(parca_gen * parca_yuk)
	parca_kirli.fill(0)
	kirli_parca = 0
	damga.resize(sim.gen * sim.yuk)
	damga.fill(0)
	for py in parca_yuk:
		for px in parca_gen:
			var sp := Sprite2D.new()
			sp.centered = false
			sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sp.show_behind_parent = true
			sp.material = su_mat
			sp.position = Vector2(px * PARCA * KARO, py * PARCA * KARO)
			add_child(sp)
			parca_sprite.append(sp)
			parca_doku.append(null)
	# bina katmanı arazi parçalarının üstünde (canlıların altında) kalsın
	if bina_katman != null:
		move_child(bina_katman, -1)
	bina_kutu = Rect2()


## Kirli parçaların dokusunu `piks` dizisinden kurar. `hepsi` değilse karede en çok 4 parça yüklenir
## (kalanlar sonraki karelere yayılır; ekrandaki parçalar önce).
func _parcalari_yukle(hepsi: bool) -> void:
	var satir: int = sim.gen * KARO * 3
	var kalan := 4
	if hepsi:
		kirli_parca = 0
	for gecis in 2:
		for p in parca_kirli.size():
			if not hepsi and parca_kirli[p] == 0:
				continue
			var px := p % parca_gen
			var py := p / parca_gen
			if not hepsi and gecis == 0 and not gorunur.intersects(Rect2(px * PARCA, py * PARCA, PARCA, PARCA)):
				continue
			if not hepsi:
				if kalan <= 0:
					return
				kalan -= 1
				kirli_parca -= 1
			parca_kirli[p] = 0
			var g: int = mini(PARCA, sim.gen - px * PARCA) * KARO
			var y: int = mini(PARCA, sim.yuk - py * PARCA) * KARO
			var veri := PackedByteArray()
			var bas: int = py * PARCA * KARO * satir + px * PARCA * KARO * 3
			if g * 3 == satir:
				veri = piks.slice(bas, bas + y * satir)
			else:
				for r in y:
					veri.append_array(piks.slice(bas + r * satir, bas + r * satir + g * 3))
			var img := Image.create_from_data(g, y, false, Image.FORMAT_RGB8, veri)
			var dk = parca_doku[p]
			if dk == null or dk.get_width() != g or dk.get_height() != y:
				dk = ImageTexture.create_from_image(img)
				parca_doku[p] = dk
				parca_sprite[p].texture = dk
			else:
				dk.update(img)
		if hepsi:
			return


func guncelle() -> void:
	if sim == null:
		return
	var olc_bas := Time.get_ticks_usec()
	_guncelle_ic()
	olc_doku_us += Time.get_ticks_usec() - olc_bas
	queue_redraw()


func _guncelle_ic() -> void:
	if sim.hepsi_degisti:
		if resim.get_width() != sim.gen * KARO or resim.get_height() != sim.yuk * KARO:
			baglan(sim)
			return
		_hepsini_ciz()
		_parcalari_yukle(true)
		sim.hepsi_degisti = false
		sim.degisen.clear()
		return
	var bekleyen: int = sim.degisen.size()
	if bekleyen == 0:
		if kirli_parca > 0:
			_parcalari_yukle(false)
		return
	if bekleyen > sim.gen * sim.yuk:
		# çok büyük birikim (dev afet): tek seferde hepsini çizmek daha ucuz
		sim.hepsi_degisti = true
		return
	var gen: int = sim.gen
	var biyom: PackedByteArray = sim.biyom
	var degisen: PackedInt32Array = sim.degisen
	damga_no += 1
	if damga_no > 250:
		damga_no = 1
		damga.fill(0)
	var bas_us := Time.get_ticks_usec()
	var su_degisen := PackedInt32Array()
	var m := 0
	# kare bütçesi: bir karede en çok ~2,5 ms karo çizilir, kalanı sonraki kareye kalır (takılma olmaz)
	while m < bekleyen:
		var k: int = degisen[m]
		m += 1
		if damga[k] == damga_no:
			continue
		damga[k] = damga_no
		var eski: int = son_biyom[k]
		var yeni: int = biyom[k]
		if eski != yeni:
			son_biyom[k] = yeni
			if (eski <= SimS.B_SIG) != (yeni <= SimS.B_SIG):
				su_degisen.append(k)
			else:
				# komşuların kenar ayrıntısı (dağ ışığı vb.) bu karoya bakar
				_karo_ciz_i(k)
				if k % gen > 0: _karo_ciz_i(k - 1)
				if k % gen < gen - 1: _karo_ciz_i(k + 1)
				continue
		_karo_ciz_i(k)
		if (m & 15) == 0 and Time.get_ticks_usec() - bas_us > 2500:
			break
	if su_degisen.size() > 0:
		_su_bolgeleri(su_degisen)
	if m >= bekleyen:
		sim.degisen.clear()
	else:
		sim.degisen = degisen.slice(m)
	_parcalari_yukle(false)


## Karoyu çizer ve parçasını kirli işaretler.
func _karo_ciz_i(k: int) -> void:
	_karo_ciz(k)
	bina_kirli = true
	var p: int = (k / sim.gen / PARCA) * parca_gen + (k % sim.gen) / PARCA
	if parca_kirli[p] == 0:
		parca_kirli[p] = 1
		kirli_parca += 1


## Kıyı değişti (su ↔ kara): değişen karoları yakın kümelere ayırıp her kümenin çevresinde
## su derinliğini ve köpüğü yeniden hesaplar (uzak iki karo yüzünden tüm harita yeniden çizilmez).
func _su_bolgeleri(karolar: PackedInt32Array) -> void:
	var gen: int = sim.gen
	var kutular: Array = []   # [x0, y0, x1, y1]
	for k in karolar:
		var x := k % gen
		var y := k / gen
		var bulundu := false
		for kt in kutular:
			if x >= kt[0] - 16 and x <= kt[2] + 16 and y >= kt[1] - 16 and y <= kt[3] + 16:
				kt[0] = mini(kt[0], x); kt[1] = mini(kt[1], y)
				kt[2] = maxi(kt[2], x); kt[3] = maxi(kt[3], y)
				bulundu = true
				break
		if not bulundu:
			kutular.append([x, y, x, y])
	for kt in kutular:
		_bolge_yenile(kt[0], kt[1], kt[2], kt[3])


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
			_karo_ciz_i(y * gen + x)


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
	var olc_bas := Time.get_ticks_usec()
	_ciz()
	olc_cizim_us += Time.get_ticks_usec() - olc_bas


func _ciz() -> void:
	var tr := get_canvas_transform()
	var ters := tr.affine_inverse()
	var ekran := get_viewport_rect().size
	var ust_sol: Vector2 = ters * Vector2.ZERO
	var alt_sag: Vector2 = ters * ekran
	gorunur = Rect2(ust_sol / KARO, (alt_sag - ust_sol) / KARO).grow(2)
	var olcek: float = tr.get_scale().x
	var detay := olcek >= 1.6
	# yakından bakınca binalar ayrıntılı (8x8) çizilir; komutlar saklanır, yalnızca görüş alanı ya da binalar değişince yenilenir
	var bina_goster := olcek >= 3.0
	if bina_katman.visible != bina_goster:
		bina_katman.visible = bina_goster
	if bina_goster:
		var simdi0 := Time.get_ticks_msec()
		if not bina_kutu.encloses(gorunur) or (bina_kirli and simdi0 - bina_zaman > 350) or simdi0 - bina_zaman > 4000:
			bina_kutu = gorunur.grow(10)
			bina_kirli = false
			bina_zaman = simdi0
			bina_katman.queue_redraw()
	# krallık toprakları: uzaktan her zaman hafifçe görünür (sınırlar okunur); katman açıksa güçlü
	if krallik_harita or irk_harita:
		_krallik_toprak(true)
	elif olcek < 3.0 and toprak_ozet:
		_krallik_toprak(false)
	if huzur_harita:
		_huzur_ciz()
	_mevsim_ortu()
	var a := alfa if ara_deger else 1.0
	var yayik: bool = sim.yayik
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
	var simdi_ms := Time.get_ticks_msec()
	if not detay:
		# uzak görünüm: her canlı tek nokta; tek çizim çağrısı (draw_multiline_colors) ile toplu çizilir.
		# Nokta listesi her karede değil, yalnızca simülasyon ilerleyince (en çok saniyede ~8 kez) yeniden kurulur.
		var imza: int = sim.ay * 31 + sim.son_uid * 7 + sim.bos.size()
		if nokta_ay != imza and (simdi_ms - nokta_zaman >= 120 or nokta_ay < 0):
			nokta_ay = imza
			nokta_zaman = simdi_ms
			var ust: int = sim.ust
			noktalar.resize(ust * 2)
			nokta_renk.resize(ust)
			var m := 0
			for i in ust:
				if c_var[i] == 0:
					continue
				var px := c_x[i] * KARO
				var py := c_y[i] * KARO
				noktalar[m * 2] = Vector2(px - 1.5, py)
				noktalar[m * 2 + 1] = Vector2(px + 1.5, py)
				nokta_renk[m] = tur_renk[c_tur[i]]
				m += 1
			noktalar.resize(m * 2)
			nokta_renk.resize(m)
		if noktalar.size() > 0:
			draw_multiline_colors(noktalar, nokta_renk, 3.0)
		_ozet_ciz(olcek)
		_secili_ciz()
		_efektleri_ciz()
		return
	# yakın görünüm: ekrandaki canlıların listesi yalnızca simülasyon ilerleyince ya da kamera kayınca yenilenir
	var imza2: int = sim.ay * 31 + sim.son_uid * 7 + sim.bos.size()
	if gorunen_ay != imza2 or not gorunen_kutu.encloses(gorunur):
		if gorunen_ay < 0 or not gorunen_kutu.encloses(gorunur) or simdi_ms - gorunen_zaman >= 100 or ara_deger:
			gorunen_ay = imza2
			gorunen_zaman = simdi_ms
			gorunen_kutu = gorunur.grow(6)
			var kx := gorunen_kutu.position.x
			var ky := gorunen_kutu.position.y
			var kx2 := gorunen_kutu.end.x
			var ky2 := gorunen_kutu.end.y
			gorunen.clear()
			for i in sim.ust:
				if c_var[i] == 0:
					continue
				var x: float = c_x[i]
				if x < kx or x > kx2:
					continue
				var y: float = c_y[i]
				if y < ky or y > ky2:
					continue
				gorunen.append(i)
	var zaman := Time.get_ticks_msec()
	var orta := olcek < 3.0        # orta uzaklık: sade figürler (az çizim çağrısı)
	var ince := olcek >= 4.5       # çok yakın: gölge, kuşak, kulak/diş, tam donanım
	var kral := {}
	var koy_onb := {}             # köy id → [çağ, krallık rengi]
	for id in sim.kralliklar:
		var kr: Dictionary = sim.kralliklar[id]
		if kr["kral"] >= 0 and kr["kral_uid"] != 0:
			kral[kr["kral"]] = true
	_koy_halkalari(olcek)
	for i in gorunen:
		if c_var[i] == 0:
			continue
		var x: float = c_x[i]
		var y: float = c_y[i]
		if x < gx or x > gx2 or y < gy or y > gy2:
			continue
		var hareketli: bool = x != sim.c_ox[i] or y != sim.c_oy[i]
		if a < 1.0:
			var af := a
			if yayik:
				# yayık hareket: her canlının adımı kendi diliminde başlar
				af = a - float(i % SimS.DILIM) / SimS.DILIM
				if af < 0.0:
					af += 1.0
			x = lerpf(sim.c_ox[i], x, af)
			y = lerpf(sim.c_oy[i], y, af)
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
			var gov := renk
			var cag := 0
			var kr_renk := renk
			if asker:
				# asker krallığının rengini giyer: ordular uzaktan da ayırt edilir
				var kid: int = sim.c_koy[i]
				var kb = koy_onb.get(kid)
				if kb == null:
					var v = sim.koyler.get(kid)
					var c := renk
					var cg := 0
					if v != null:
						cg = v["cag"]
						var kr2 = sim.kralliklar.get(v["krallik"])
						if kr2 != null:
							c = Color(kr2["renk"])
					kb = [cg, c]
					koy_onb[kid] = kb
				cag = kb[0]
				kr_renk = kb[1]
				gov = kr_renk.darkened(0.15)
			if orta:
				draw_rect(Rect2(px - 1.0 * s, py - 1.0 * s, 2.0 * s, 2.9 * s), gov)
				draw_rect(Rect2(px - 0.8 * s, py - 2.8 * s, 1.6 * s, 1.8 * s), ten)
				if asker:
					draw_line(Vector2(px + 1.3 * s, py - 2.6 * s), Vector2(px + 1.3 * s, py + 1.4 * s), SILAH_RENK[mini(cag, 6)], 0.5 * s)
				if kral.has(i):
					draw_rect(Rect2(px - 0.8 * s, py - 3.5 * s, 1.6 * s, 0.7 * s), TAC)
				continue
			# gölge
			if ince:
				draw_rect(Rect2(px - 1.2 * s, py + 1.6 * s, 2.4 * s, 0.7 * s), GOLGE)
			# yürürken bacaklar sırayla
			var adim_f := 0.0
			if hareketli:
				adim_f = 0.5 * s if ((zaman / 140 + i) % 2 == 0) else -0.5 * s
			# giysi: sivillerde ırk rengi kişiye göre tonlanır (herkes aynı görünmesin), askerde krallık rengi
			var uid: int = sim.c_uid[i]
			if not asker:
				gov = renk.lerp(GIYSI[uid % 6], 0.5)
			if hareketli or ince:
				draw_rect(Rect2(px - 0.9 * s, py + 1.0 * s, 0.7 * s, 0.9 * s + adim_f), gov.darkened(0.4))
				draw_rect(Rect2(px + 0.2 * s, py + 1.0 * s, 0.7 * s, 0.9 * s - adim_f), gov.darkened(0.4))
			else:
				draw_rect(Rect2(px - 0.9 * s, py + 1.0 * s, 1.8 * s, 0.9 * s), gov.darkened(0.4))
			draw_rect(Rect2(px - 1.0 * s, py - 1.0 * s, 2.0 * s, 2.2 * s), gov)
			if ince:
				draw_rect(Rect2(px - 1.0 * s, py + 0.35 * s, 2.0 * s, 0.3 * s), gov.darkened(0.3))   # kuşak
			draw_rect(Rect2(px - 0.8 * s, py - 2.8 * s, 1.6 * s, 1.8 * s), ten)
			var kod: int = tur_kod[tur]
			if kod != 5 and kod != 6 and kod != 7:
				# saç: yaşlılarda ağarır; kadınlarda omuza iner
				var sac: Color = SAC[uid % 5] if sim.c_yas[i] < sim.s_omur[i] * 0.7 else Color("d8d8d8")
				if kod == 1:
					sac = SAC_ELF[uid % 3]
				draw_rect(Rect2(px - 0.9 * s, py - 3.0 * s, 1.8 * s, 0.6 * s), sac)
				if ince and sim.c_cins[i] == 0:
					draw_rect(Rect2(px - 1.0 * s, py - 2.9 * s, 0.35 * s, 1.7 * s), sac)
					draw_rect(Rect2(px + 0.65 * s, py - 2.9 * s, 0.35 * s, 1.7 * s), sac)
			if olcek >= 6.0:
				# gözler
				draw_rect(Rect2(px - 0.5 * s, py - 2.1 * s, 0.3 * s, 0.3 * s), GOZ)
				draw_rect(Rect2(px + 0.2 * s, py - 2.1 * s, 0.3 * s, 0.3 * s), GOZ)
			match kod if (ince or kod == 3 or kod == 6) else 0:
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
				if ince:
					_asker_ciz(i, px, py, s, cag, kr_renk, zaman)
				else:
					# sade donanım: silah çizgisi (çağın rengi) ve kalkan
					draw_line(Vector2(px + 1.3 * s, py - 2.8 * s), Vector2(px + 1.3 * s, py + 1.2 * s), SILAH_RENK[mini(cag, 6)], 0.5 * s)
					if cag >= 1:
						draw_rect(Rect2(px - 1.9 * s, py - 0.8 * s, 1.0 * s, 1.6 * s), kr_renk.lightened(0.25))
		elif t_ucan[tur] == 1:
			var kanat := sin(zaman * 0.008 + i) * 2.0 * boy
			draw_rect(Rect2(px - 1.5 * boy, py + 3.0 * boy, 3.0 * boy, 0.8 * boy), GOLGE)
			draw_rect(Rect2(px - 2.0 * boy, py - 1.0 * boy, 4.0 * boy, 2.0 * boy), renk)
			draw_line(Vector2(px - 1.5 * boy, py - 0.5 * boy), Vector2(px - 4.0 * boy, py - 1.0 * boy - kanat), renk.lightened(0.2), 1.2)
			draw_line(Vector2(px + 1.5 * boy, py - 0.5 * boy), Vector2(px + 4.0 * boy, py - 1.0 * boy - kanat), renk.lightened(0.2), 1.2)
			draw_rect(Rect2(px + 1.6 * boy, py - 1.6 * boy, 1.4 * boy, 1.2 * boy), ten)
		elif orta:
			draw_rect(Rect2(px - 1.6 * boy, py - 1.0 * boy, 3.2 * boy, 2.4 * boy), renk)
			draw_rect(Rect2(px + 1.0 * boy, py - 1.6 * boy, 1.2 * boy, 1.2 * boy), ten)
		else:
			draw_rect(Rect2(px - 1.6 * boy, py + 1.0 * boy, 3.2 * boy, 0.6 * boy), GOLGE)
			var bacak := 0.0
			if hareketli:
				bacak = 0.4 * boy if ((zaman / 160 + i) % 2 == 0) else 0.0
			draw_rect(Rect2(px - 1.3 * boy, py + 0.8 * boy, 0.6 * boy, 0.7 * boy - bacak), renk.darkened(0.3))
			draw_rect(Rect2(px + 0.7 * boy, py + 0.8 * boy, 0.6 * boy, 0.3 * boy + bacak), renk.darkened(0.3))
			draw_rect(Rect2(px - 1.6 * boy, py - 1.0 * boy, 3.2 * boy, 2.0 * boy), renk)
			draw_rect(Rect2(px + 1.0 * boy, py - 1.6 * boy, 1.2 * boy, 1.2 * boy), ten)
	_ozet_ciz(olcek)
	_secili_ciz()
	_efektleri_ciz()


## Askerin donanımı: çağa göre silah (sopa → mızrak → kılıç/yay → çelik kılıç/arbalet → tüfek → lazer),
## kalkan ve miğfer; her dokuz askerden biri krallık sancağı taşır.
func _asker_ciz(i: int, px: float, py: float, s: float, cag: int, kr_renk: Color, zaman: int) -> void:
	var br: int = sim.birim(i)
	var el := Vector2(px + 1.3 * s, py)
	# miğfer (Demir Çağı'ndan itibaren), Orta Çağ'da tepelikli
	if cag >= 2:
		draw_rect(Rect2(px - 0.9 * s, py - 3.1 * s, 1.8 * s, 0.8 * s), MIGFER[mini(cag, 6)])
		if cag == 3:
			draw_rect(Rect2(px - 0.2 * s, py - 3.6 * s, 0.4 * s, 0.5 * s), kr_renk.lightened(0.3))
	# zırh: Tunç'tan itibaren göğüslük şeridi
	if cag >= 1:
		draw_rect(Rect2(px - 1.0 * s, py - 0.6 * s, 2.0 * s, 0.5 * s), MIGFER[mini(maxi(cag, 2), 6)].darkened(0.15))
	match br:
		0:
			# piyade: kalkan solda (Tunç Çağı'ndan itibaren)
			if cag >= 1:
				draw_rect(Rect2(px - 1.9 * s, py - 0.8 * s, 1.0 * s, 1.6 * s), kr_renk.lightened(0.25))
				draw_rect(Rect2(px - 1.6 * s, py - 0.2 * s, 0.4 * s, 0.4 * s), TAC)
			if cag == 0:
				# sopa
				draw_line(el + Vector2(0, 1.2 * s), el + Vector2(0.3 * s, -1.8 * s), Color("7a5028"), 0.5 * s)
				draw_rect(Rect2(el.x - 0.2 * s, el.y - 2.6 * s, 0.9 * s, 0.9 * s), Color("5a3a18"))
			elif cag == 1:
				# mızrak
				draw_line(el + Vector2(0, 1.6 * s), el + Vector2(0, -3.2 * s), Color("8a6030"), 0.35 * s)
				draw_colored_polygon(PackedVector2Array([el + Vector2(-0.4 * s, -3.2 * s), el + Vector2(0.4 * s, -3.2 * s), el + Vector2(0, -4.2 * s)]), Color("d8a860"))
			else:
				# kılıç (Orta Çağ'da daha uzun, parlak çelik)
				var uz := 2.4 if cag == 2 else 3.0
				draw_line(el + Vector2(0, 0.4 * s), el + Vector2(0, -uz * s), Color("dfe4ea") if cag == 2 else Color("f4f8ff"), 0.5 * s)
				draw_line(el + Vector2(-0.6 * s, 0.2 * s), el + Vector2(0.6 * s, 0.2 * s), Color("8a6030") if cag == 2 else TAC, 0.4 * s)
		1:
			if cag >= 3:
				# arbalet
				draw_line(el + Vector2(-0.9 * s, -0.6 * s), el + Vector2(0.9 * s, -0.6 * s), Color("6a4a28"), 0.4 * s)
				draw_line(el + Vector2(0, -1.4 * s), el + Vector2(0, 0.6 * s), Color("8a6030"), 0.4 * s)
			else:
				# yay ve kiriş
				draw_arc(el + Vector2(-0.4 * s, -0.6 * s), 1.5 * s, -1.2, 1.2, 6, Color("8a6030"), 0.35 * s)
				draw_line(el + Vector2(0.15 * s, -2.0 * s), el + Vector2(0.15 * s, 0.8 * s), Color("e8e0c8"), 0.15 * s)
			# sadak
			draw_rect(Rect2(px - 1.5 * s, py - 1.6 * s, 0.5 * s, 1.6 * s), Color("6a4a28"))
		2:
			# tüfek (süngülü)
			draw_line(el + Vector2(-0.5 * s, 0.9 * s), el + Vector2(0.9 * s, -2.4 * s), Color("2a2a30"), 0.45 * s)
			draw_line(el + Vector2(-0.7 * s, 1.3 * s), el + Vector2(-0.2 * s, 0.2 * s), Color("7a5028"), 0.6 * s)
			draw_line(el + Vector2(0.9 * s, -2.4 * s), el + Vector2(1.1 * s, -3.0 * s), Color("d8dce4"), 0.2 * s)
		3:
			# lazer silahı
			draw_line(el + Vector2(-0.5 * s, 0.4 * s), el + Vector2(1.0 * s, -1.4 * s), Color("b8c0d0"), 0.5 * s)
			draw_circle(el + Vector2(1.0 * s, -1.4 * s), 0.35 * s, Color("60ffb0"))
	if sim.c_uid[i] % 9 == 0:
		# sancaktar
		var dip := Vector2(px - 1.3 * s, py + 1.2 * s)
		var tepe := dip + Vector2(0, -5.2 * s)
		var dalga := sin(zaman * 0.006 + i) * 0.3 * s
		draw_line(dip, tepe, Color("5a3a20"), 0.3 * s)
		draw_colored_polygon(PackedVector2Array([tepe, tepe + Vector2(2.2 * s, 0.5 * s + dalga), tepe + Vector2(0, 1.4 * s)]), kr_renk.lightened(0.15))


## Yakın görünümde köy sınırı: krallık renginde ince halka.
func _koy_halkalari(olcek: float) -> void:
	if olcek < 3.0:
		return   # orta uzaklıkta sınırları toprak katmanı gösterir (halkalar kalabalık yapar)
	_ozet_onbellek()
	var kal := 1.5 / olcek
	for h in koy_halka:
		var r: float = h[2]
		if h[0] + r < gorunur.position.x or h[0] - r > gorunur.end.x or h[1] + r < gorunur.position.y or h[1] - r > gorunur.end.y:
			continue
		draw_arc(Vector2(h[0], h[1]) * KARO, r * KARO, 0, TAU, 40, h[3], kal)


## Köy halkaları ve savaş işaretleri listesi yarım saniyede bir kurulur.
func _ozet_onbellek() -> void:
	var simdi := Time.get_ticks_msec()
	if simdi - ozet_zaman < 500 and ozet_ay >= 0:
		return
	ozet_zaman = simdi
	ozet_ay = sim.ay
	koy_halka.clear()
	kusatmalar.clear()
	yuruyusler.clear()
	for id in sim.koyler:
		var v: Dictionary = sim.koyler[id]
		var kr = sim.kralliklar.get(v["krallik"])
		var c := Color(kr["renk"]) if kr != null else Color.WHITE
		koy_halka.append([float(v["x"]) + 0.5, float(v["y"]) + 0.5, float(v["yaricap"]) + 1.5, Color(c, 0.42)])
		if int(v.get("kusatma", -100000)) > sim.ay - 10:
			var kk = sim.kralliklar.get(int(v.get("kusatan", -1)))
			kusatmalar.append([float(v["x"]) + 0.5, float(v["y"]) + 0.5, Color(kk["renk"]) if kk != null else Color.RED])
		var hid: int = v["hedef"]
		if hid >= 0 and v["savasta"]:
			var hv = sim.koyler.get(hid)
			if hv != null:
				yuruyusler.append([float(v["x"]) + 0.5, float(v["y"]) + 0.5, float(hv["x"]) + 0.5, float(hv["y"]) + 0.5, c])


## Savaşın haritadaki özeti (her uzaklıkta): sefere çıkan köyden hedefe kesik ok, kuşatılan köyde çapraz kılıç.
## Simgeler ekranda sabit boydadır; uzaktan bakınca da seçilir.
func _ozet_ciz(olcek: float) -> void:
	_ozet_onbellek()
	var zaman := Time.get_ticks_msec() * 0.001
	var b := 1.0 / olcek            # ekranda 1 piksel
	for y in yuruyusler:
		var p := Vector2(y[0], y[1]) * KARO
		var q := Vector2(y[2], y[3]) * KARO
		var c: Color = y[4]
		draw_dashed_line(p, q, Color(c.lightened(0.2), 0.85), 2.0 * b, 7.0 * b)
		var yon := (q - p).normalized()
		var uc := q - yon * 10.0 * b
		var dik := Vector2(-yon.y, yon.x)
		draw_colored_polygon(PackedVector2Array([uc + yon * 9.0 * b, uc + dik * 5.0 * b, uc - dik * 5.0 * b]), Color(c.lightened(0.2), 0.95))
	for k in kusatmalar:
		var p := Vector2(k[0], k[1]) * KARO - Vector2(0, 9.0 * b)
		var nab := 1.0 + 0.18 * sin(zaman * 6.0)
		draw_circle(p, 11.0 * b * nab, Color(0.75, 0.08, 0.05, 0.75))
		draw_arc(p, 11.0 * b * nab, 0, TAU, 24, Color(1, 0.9, 0.5), 1.5 * b)
		_kilic_ciz(p, 7.0 * b, 2.0 * b)


## Çapraz iki kılıç simgesi.
func _kilic_ciz(p: Vector2, r: float, kal: float) -> void:
	draw_line(p + Vector2(-r, r), p + Vector2(r, -r), Color("f4f8ff"), kal)
	draw_line(p + Vector2(r, r), p + Vector2(-r, -r), Color("f4f8ff"), kal)
	draw_line(p + Vector2(-r * 0.9, r * 0.3), p + Vector2(-r * 0.3, r * 0.9), TAC, kal)
	draw_line(p + Vector2(r * 0.9, r * 0.3), p + Vector2(r * 0.3, r * 0.9), TAC, kal)


func _secili_ciz() -> void:
	if secili >= 0 and sim.c_var[secili] == 1:
		var p := Vector2(sim.c_x[secili], sim.c_y[secili]) * KARO
		draw_arc(p + Vector2(0, -1), 5.0, 0, TAU, 20, Color(1, 1, 0.3), 0.8)
	if imlec.x >= 0.0 and imlec_r > 0.0:
		draw_arc(imlec * KARO, imlec_r * KARO, 0, TAU, 40, imlec_renk, 1.0 / maxf(0.2, get_canvas_transform().get_scale().x) * 2.0)


## Krallık haritası: her kara karosu en yakın köyün krallığına boyanır, sınırlar koyu çizilir.
## Doku saniyede bir yeniden hesaplanır (her karede değil).
func _krallik_toprak(guclu: bool) -> void:
	var mod := 1 if irk_harita else 0
	if toprak_doku == null or mod != tp_mod or tp_dunya != sim.tohum * 7 + sim.gen:
		# ilk gösterim ya da katman değişti: hemen hesapla
		tp_mod = mod
		tp_dunya = sim.tohum * 7 + sim.gen
		tp_asama = 0
		toprak_zaman = -100000
		_toprak_adim(10000000)
	else:
		_toprak_adim(1200)
	if toprak_doku != null:
		var sav := 1.0
		if not guclu:
			# uzaktan belirgin, yaklaştıkça silikleşir (arazi ve binalar görünsün)
			sav = 0.6 if get_canvas_transform().get_scale().x < 1.6 else 0.38
		draw_texture_rect(toprak_doku, Rect2(0, 0, sim.gen * KARO, sim.yuk * KARO), false, Color(1, 1, 1, sav))


## Toprak katmanını (krallık ya da ırk renkleri, sınırlar koyu) birkaç kareye yayarak hesaplar.
## Her kara karosu en yakın köyün sahibine boyanır. Önce her saniye tek karede ~40–80 ms sürüyordu.
func _toprak_adim(butce_us: int) -> void:
	var gen: int = sim.gen
	var yuk: int = sim.yuk
	var n := gen * yuk
	var bas := Time.get_ticks_usec()
	if tp_asama == 0:
		if Time.get_ticks_msec() - toprak_zaman < 1500:
			return
		tp_sahip.resize(n)
		tp_sahip.fill(-1)
		tp_mesafe.resize(n)
		tp_mesafe.fill(1 << 30)
		tp_dokunulan.clear()
		tp_renk.clear()
		tp_koyler = sim.koyler.values()
		tp_i = 0
		tp_asama = 1
	if tp_asama == 1:
		var biyom: PackedByteArray = sim.biyom
		if biyom.size() != n:
			tp_asama = 0
			return
		while tp_i < tp_koyler.size():
			var v: Dictionary = tp_koyler[tp_i]
			tp_i += 1
			var kid: int = v["krallik"]
			if tp_mod == 1:
				kid = 100000 + int(v["irk"])
				if not tp_renk.has(kid):
					tp_renk[kid] = tur_renk[v["irk"]]
			else:
				var kr = sim.kralliklar.get(kid)
				if kr == null:
					continue
				if not tp_renk.has(kid):
					tp_renk[kid] = Color(kr["renk"])
			var r: int = int(v["yaricap"]) + 3
			var vx: int = v["x"]
			var vy: int = v["y"]
			var r2 := r * r
			for oy in range(-r, r + 1):
				var yy := vy + oy
				if yy < 0 or yy >= yuk:
					continue
				for ox in range(-r, r + 1):
					var xx := vx + ox
					var d2 := ox * ox + oy * oy
					if xx < 0 or xx >= gen or d2 > r2:
						continue
					var k := yy * gen + xx
					if biyom[k] <= SimS.B_SIG or d2 >= tp_mesafe[k]:
						continue
					if tp_sahip[k] < 0:
						tp_dokunulan.append(k)
					tp_mesafe[k] = d2
					tp_sahip[k] = kid
			if Time.get_ticks_usec() - bas > butce_us:
				return
		tp_veri = PackedByteArray()
		tp_veri.resize(n * 4)
		tp_i = 0
		tp_asama = 2
	if tp_asama == 2:
		var say := tp_dokunulan.size()
		while tp_i < say:
			var k := tp_dokunulan[tp_i]
			tp_i += 1
			var kid := tp_sahip[k]
			var c: Color = tp_renk[kid]
			var x := k % gen
			var sinir := (x == 0 or tp_sahip[k - 1] != kid) or (x == gen - 1 or tp_sahip[k + 1] != kid) or (k < gen or tp_sahip[k - gen] != kid) or (k >= n - gen or tp_sahip[k + gen] != kid)
			tp_veri[k * 4] = int(c.r * 255)
			tp_veri[k * 4 + 1] = int(c.g * 255)
			tp_veri[k * 4 + 2] = int(c.b * 255)
			tp_veri[k * 4 + 3] = 225 if sinir else 80
			if (tp_i & 63) == 0 and Time.get_ticks_usec() - bas > butce_us:
				return
		var img := Image.create_from_data(gen, yuk, false, Image.FORMAT_RGBA8, tp_veri)
		if toprak_doku == null or toprak_doku.get_width() != gen or toprak_doku.get_height() != yuk:
			toprak_doku = ImageTexture.create_from_image(img)
		else:
			toprak_doku.update(img)
		tp_asama = 0
		toprak_zaman = Time.get_ticks_msec()


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
			12:
				# ok: yaydan hedefe uçar
				var q := Vector2(e[4], e[5]) * KARO
				var t := fmod(zaman * 2.2 + e[1] * 0.37, 1.0)
				var yon := (q - p).normalized()
				var a := p.lerp(q, t) - Vector2(0, sin(t * PI) * 5.0)
				draw_line(a - yon * 3.0, a, Color("e8dcc0"), 0.6)
				draw_line(a, a + yon * 1.0, Color("b0b0b8"), 0.9)
			13:
				# tüfek atışı: namlu alevi, duman ve mermi izi
				var q := Vector2(e[4], e[5]) * KARO
				var t := fmod(zaman * 3.0 + e[1] * 0.37, 1.0)
				if t < 0.35:
					draw_circle(p - Vector2(0, 2), 1.6, Color(1, 0.9, 0.4, 0.95))
					draw_line(p - Vector2(0, 2), q - Vector2(0, 1), Color(1, 1, 0.8, 0.5), 0.4)
				draw_circle(p - Vector2(0, 3.0 + t * 4.0), 1.2 + t * 2.0, Color(0.8, 0.8, 0.8, 0.5 * (1.0 - t)))
			14:
				# lazer ışını
				var q := Vector2(e[4], e[5]) * KARO
				draw_line(p - Vector2(0, 2), q - Vector2(0, 1), Color(0.4, 1.0, 0.7, 0.45), 2.2)
				draw_line(p - Vector2(0, 2), q - Vector2(0, 1), Color(0.9, 1.0, 0.95), 0.7)
				draw_circle(q - Vector2(0, 1), 1.6 + sin(zaman * 30.0) * 0.5, Color(0.6, 1.0, 0.8, 0.8))
			16:
				# kılıç çarpışması: kıvılcım
				var faz := int(zaman * 12.0 + e[1] * 7.0)
				for n in 4:
					var ac := float((faz * 37 + n * 97) % 360) * 0.01745
					var d := Vector2(cos(ac), sin(ac))
					draw_line(p - Vector2(0, 1.5) + d * 0.8, p - Vector2(0, 1.5) + d * (2.2 + (faz + n) % 2), Color(1, 0.95, 0.5) if n % 2 == 0 else Color(1, 1, 1), 0.5)
			17:
				# ölüm: kan lekesi ve yükselen ruh
				var sn := clampf(float(e[3]) / 4.0, 0.0, 1.0)
				draw_circle(p + Vector2(0, 1), 1.8, Color(0.6, 0.05, 0.05, 0.75 * sn))
				draw_circle(p + Vector2(1.5, 1.6), 0.9, Color(0.6, 0.05, 0.05, 0.6 * sn))
				var ry := p - Vector2(0, 4.0 + fmod(zaman * 5.0, 6.0))
				draw_line(ry - Vector2(0, 1.6), ry + Vector2(0, 1.8), Color(1, 1, 1, 0.75 * sn), 0.6)
				draw_line(ry - Vector2(1.2, 0.4), ry + Vector2(1.2, -0.4), Color(1, 1, 1, 0.75 * sn), 0.6)
			18:
				# kuşatma ateşi ve duman
				var tit := sin(zaman * 14.0 + e[1]) * 0.8
				draw_colored_polygon(PackedVector2Array([p + Vector2(-2.5, 1), p + Vector2(2.5, 1), p + Vector2(tit, -5.0)]), Color(1, 0.45, 0.1, 0.9))
				draw_colored_polygon(PackedVector2Array([p + Vector2(-1.3, 1), p + Vector2(1.3, 1), p + Vector2(-tit * 0.5, -2.8)]), Color(1, 0.9, 0.3, 0.95))
				for n in 3:
					var dy := fmod(zaman * 6.0 + n * 3.0, 9.0)
					draw_circle(p + Vector2(sin(dy + n) * 1.5, -5.0 - dy), 1.2 + dy * 0.25, Color(0.25, 0.25, 0.25, 0.45 * (1.0 - dy / 9.0)))
			19:
				# savaş ilanı: atan kırmızı halka ve çapraz kılıçlar (ekranda sabit boy)
				var bb := 1.0 / maxf(0.2, get_canvas_transform().get_scale().x)
				var nab2 := fmod(zaman * 1.2, 1.0)
				draw_arc(p, (14.0 + nab2 * 30.0) * bb, 0, TAU, 40, Color(1, 0.2, 0.15, 1.0 - nab2), 3.0 * bb)
				draw_circle(p - Vector2(0, 16.0 * bb), 13.0 * bb, Color(0.8, 0.1, 0.05, 0.9))
				_kilic_ciz(p - Vector2(0, 16.0 * bb), 8.0 * bb, 2.2 * bb)
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



# ------------------------------------------------------------ ayrıntılı binalar (yakın görünüm)
## 8x8 bina resimleri. Harfler: r/R çatı (krallık rengi, açık/koyu), f bayrak (krallık rengi), w/W duvar (ırka göre),
## d kapı, p pencere, k ahşap, s/S taş, y altın, o ateş, g/G ekin, t toprak, b mavi, c camgöbeği, h saman, E yaprak, x koyu, . boş.
const BINA_DESEN := [
	[],
	["...kff..", "...kfff.", "...kff..", "...k....", "..ssss..", ".sbbbbs.", ".sbbbbs.", "..ssss.."],  # 1 köy meydanı (kuyu ve bayrak)
	["...rr...", "..rrrr..", ".rrRRrr.", "rrRRRRrr", ".wwwwww.", ".wpwwpw.", ".wwddww.", ".WWddWW."],  # 2 ev
	["gggggggg", "tttttttt", "gGggGggG", "tttttttt", "gggggggg", "tttttttt", "GggGggGg", "tttttttt"],  # 3 tarla
	["..rrrr..", ".rrrrrr.", "rrRRRRrr", "kkkkkkkk", "kwwkkwwk", "kwwddwwk", "kwwddwwk", "kkkddkkk"],  # 4 ambar
	["..SSSS..", ".SssssS.", "SsxxxxsS", "SsxxxxsS", "kkxxxxkk", "k.yxxy.k", "..tyyt..", ".tttttt."],  # 5 maden
	[".....ss.", "..o..ss.", ".rrrrss.", "rrrrrrss", "wwwwwwss", "wpwwdwss", "wwwodwss", "WWWWdWSS"],  # 6 demirhane
	[".f......", ".ff.....", ".k......", "rrrrrrrr", "rRRRRRRr", "wywwwwyw", "wwwddwww", "WWWddWWW"],  # 7 kışla
	["...yy...", "..yyyy..", ".rrrrrr.", "ssssssss", ".s.ss.s.", ".s.ss.s.", ".s.dd.s.", "ssssssss"],  # 8 tapınak
	[".rrrrrr.", "rrRRRRrr", "wwwwwwww", "wbbwwbbw", "wbbwwbbw", "wwwwwwww", "wwwddwww", "WWWddWWW"],  # 9 kütüphane
	["........", "ryryryry", "rrrrrrrr", "k......k", "kooghgbk", "kkkkkkkk", ".k....k.", "........"],  # 10 pazar
	["f..yy..f", "k.yyyy.k", "rryyyyrr", "rrrrrrrr", "wwpwwpww", "wwwwwwww", "wpwddwpw", "WWWddWWW"],  # 11 saray
	["..f.....", "..k.....", ".s.ss.s.", ".ssssss.", "..wwww..", "..wpww..", "..wwww..", "..wdww.."],  # 12 gözetleme kulesi
	["........", ".s....s.", ".s......", ".ss..s..", "..s..ss.", ".Ss..sS.", "SSsS.SSs", "........"],  # 13 harabe
	["s.s..s.s", "ssssssss", "sSSSSSSs", "sS.ff.Ss", "sS.ff.Ss", "sSSddSSs", "sSSddSSs", "ssssssss"],  # 14 kale
	["........", "...hh...", "..hhhh..", ".hhhhhh.", "hhhhhhhh", ".kwwwwk.", ".kwddwk.", ".kwddwk."],  # 15 kulübe (Taş Çağı)
	["..rr..s.", ".rrrr.s.", "rrRRrrs.", "rRRRRRr.", "wwwwwww.", "wpwwwpw.", "wwwddww.", "WWWddWW."],  # 16 taş ev (Orta Çağ+)
	["..EEEE..", ".EEGEEE.", "EEGGEEGE", "EGEEEEEE", ".EEkkEE.", "..ykky..", "...kk...", "..kddk.."],  # 17 elf ağaç evi
	["...kk...", "...kk...", "..khhk..", "..hrrh..", ".khhhhk.", ".hhddhh.", "khhddhhk", "kkkddkkk"],  # 18 ork deri çadırı
	["......s.", ".SSSSSs.", "SSSSSSSS", "ssssssss", "sysssdds", "sssssdds", "sSsSsdds", "SSSSSSSS"],  # 19 cüce taş evi
	["...r....", "..tttt..", ".thhhht.", "tthtthtt", "tttttttt", "ttxddxtt", "tttddttt", ".tttttt."],  # 20 goblin çamur kulübesi
	["..hhhh..", ".hhhhhh.", "hhhhhhhh", ".GGGGGG.", ".GdGGpG.", ".GdGGGG.", ".k....k.", ".k....k."],  # 21 kertenkele kamış evi
	["ssssssss", "sSSSSSSs", ".ss..ss.", ".sS..Ss.", ".ss..ss.", ".sS..Ss.", ".ss..ss.", "SSS..SSS"],  # 22 dev taş halkası
	["..bbbb..", ".bccccb.", "bccccccb", "bcbccbcb", "ssssssss", "sspddpss", "ssSddSss", ".S....S."],  # 23 uzaylı kubbesi
]
const BINA_SABIT := {"d": "3a2616", "p": "2a3550", "k": "7a5230", "s": "8a8680", "S": "5e5a56", "y": "ffd23a", "o": "ff8a2a",
	"g": "d8c448", "G": "8aa838", "t": "7a5a34", "b": "3a70c8", "c": "8ae8f0", "h": "c8a860", "E": "4a9a48", "x": "1c1814"}
const IRK_EV := {"elf": 17, "ork": 18, "cuce": 19, "goblin": 20, "kertenkele": 21, "dev": 22, "uzayli": 23}
const IRK_DUVAR := {"elf": "9a7a4a", "cuce": "9a9a9a", "ork": "6a5030", "goblin": "6a6a40", "kertenkele": "8aa070", "dev": "8a8070", "uzayli": "b0c0d0"}
var bina_cati := PackedByteArray()    # desenin çatı / duvar katmanı var mı
var bina_duvar := PackedByteArray()


## Atlas: sütun = desen, satır 0 sabit renkler, satır 1 çatı maskesi (krallık rengiyle boyanır), satır 2 duvar maskesi.
func _bina_atlas_kur() -> void:
	var n := BINA_DESEN.size()
	var img := Image.create(n * 8, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	bina_cati.resize(n); bina_cati.fill(0)
	bina_duvar.resize(n); bina_duvar.fill(0)
	for m in n:
		var desen: Array = BINA_DESEN[m]
		for y in desen.size():
			var satir: String = desen[y]
			for x in 8:
				var ch := satir[x]
				match ch:
					".":
						pass
					"r":
						img.set_pixel(m * 8 + x, 8 + y, Color(1, 1, 1)); bina_cati[m] = 1
					"R":
						img.set_pixel(m * 8 + x, 8 + y, Color(0.72, 0.72, 0.72)); bina_cati[m] = 1
					"f":
						img.set_pixel(m * 8 + x, 8 + y, Color(1, 1, 1)); bina_cati[m] = 1
					"w":
						img.set_pixel(m * 8 + x, 16 + y, Color(1, 1, 1)); bina_duvar[m] = 1
					"W":
						img.set_pixel(m * 8 + x, 16 + y, Color(0.78, 0.78, 0.78)); bina_duvar[m] = 1
					_:
						img.set_pixel(m * 8 + x, y, Color(BINA_SABIT[ch]))
	bina_atlas = ImageTexture.create_from_image(img)


## Görüş alanındaki binaları ayrıntılı çizer (zemin, sabit renkler, krallık renkli çatı, ırk renkli duvar).
## Bu çizim saklanır: kamera aynı bölgede kaldıkça ve bina değişmedikçe yeniden çalışmaz.
func _binalari_ciz() -> void:
	if sim == null or sim.gen == 0:
		return
	var gen: int = sim.gen
	var x0 := maxi(0, int(bina_kutu.position.x))
	var y0 := maxi(0, int(bina_kutu.position.y))
	var x1 := mini(gen - 1, int(bina_kutu.end.x))
	var y1 := mini(sim.yuk - 1, int(bina_kutu.end.y))
	var yapi: PackedByteArray = sim.yapi
	var yapi_koy: PackedInt32Array = sim.yapi_koy
	var biyom: PackedByteArray = sim.biyom
	var koy_onb := {}        # köy id → [çatı rengi, duvar rengi, ev deseni]
	var cati: Array = []     # [rect, desen, renk]
	var duvar: Array = []
	var taban: Array = []    # [rect, desen]
	var ates: PackedByteArray = sim.ates
	for y in range(y0, y1 + 1):
		var k := y * gen + x0
		for x in range(x0, x1 + 1):
			var tip: int = yapi[k]
			if tip == 0 or ates[k] > 0:
				k += 1
				continue
			var r := Rect2(x * KARO, y * KARO, KARO, KARO)
			var desen := tip
			var kid: int = yapi_koy[k]
			var kb = koy_onb.get(kid)
			if kb == null:
				var c_cati := Color("a8a8a8")
				var c_duvar := Color("c9a46a")
				var ev := 2
				var v = sim.koyler.get(kid)
				if v != null:
					var kr = sim.kralliklar.get(v["krallik"])
					if kr != null:
						c_cati = Color(kr["renk"]).darkened(0.12)
					var irk: String = sim.turler[v["irk"]]["id"]
					if IRK_DUVAR.has(irk):
						c_duvar = Color(IRK_DUVAR[irk])
					if IRK_EV.has(irk):
						ev = IRK_EV[irk]
					elif int(v["cag"]) == 0:
						ev = 15
					elif int(v["cag"]) >= 3:
						ev = 16
				kb = [c_cati, c_duvar, ev]
				koy_onb[kid] = kb
			if tip == SimS.Y_EV:
				desen = kb[2]
			if desen >= BINA_DESEN.size():
				k += 1
				continue
			if tip != SimS.Y_TARLA:
				# zemin: biyomun düz rengi (alttaki 4x4 bina çizimini örter)
				bina_katman.draw_rect(r, B_RENK[biyom[k]])
			taban.append([r, desen])
			if bina_cati[desen] == 1:
				cati.append([r, desen, kb[0]])
			if bina_duvar[desen] == 1:
				duvar.append([r, desen, kb[1]])
			k += 1
	for t in taban:
		bina_katman.draw_texture_rect_region(bina_atlas, t[0], Rect2(int(t[1]) * 8, 0, 8, 8))
	for t in duvar:
		bina_katman.draw_texture_rect_region(bina_atlas, t[0], Rect2(int(t[1]) * 8, 16, 8, 8), t[2])
	for t in cati:
		bina_katman.draw_texture_rect_region(bina_atlas, t[0], Rect2(int(t[1]) * 8, 8, 8, 8), t[2])
