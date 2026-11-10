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
var gorunur := Rect2()
var son_guncelleme := 0

var B_RENK := [
	Color("1b3f75"), Color("2e6fb0"), Color("e3d39a"), Color("6fb24a"), Color("3f8a35"),
	Color("a9b85a"), Color("e0bf6e"), Color("4f6a3a"), Color("7d8f62"), Color("8a8580"),
	Color("eef3f7"), Color("e2531c"), Color("4a4037"),
]


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.show_behind_parent = true
	add_child(sprite)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func baglan(s) -> void:
	sim = s
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
		var n := mini(sim.degisen.size(), 4000)
		for m in n:
			_karo_ciz(sim.degisen[m])
		if n >= sim.degisen.size():
			sim.degisen.clear()
		else:
			sim.degisen = sim.degisen.slice(n)
		var simdi := Time.get_ticks_msec()
		if simdi - son_guncelleme > 60:
			doku.update(resim)
			son_guncelleme = simdi
		else:
			sim.degisen.append(0)  # bir sonraki karede tekrar dene
	queue_redraw()


func _hash(k: int, s: int) -> int:
	var h := (k * 374761393 + s * 668265263) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return h ^ (h >> 16)


func _hepsini_ciz() -> void:
	for k in sim.gen * sim.yuk:
		_karo_ciz(k)


func _karo_ciz(k: int) -> void:
	var x0: int = (k % sim.gen) * KARO
	var y0: int = (k / sim.gen) * KARO
	var b: int = sim.biyom[k]
	var temel: Color = B_RENK[b]
	var h := _hash(k, 1)
	var oyn := float(h % 9 - 4) * 0.012
	temel = Color(temel.r + oyn, temel.g + oyn, temel.b + oyn)
	for py in KARO:
		for px in KARO:
			var c := temel
			var hh := _hash(k * 16 + py * 4 + px, 7)
			match b:
				SimS.B_DERIN, SimS.B_SIG:
					if hh % 23 == 0:
						c = temel.lightened(0.15)
				SimS.B_ORMAN:
					# küçük ağaç: koyu taç, alt orta gövde
					var agac := (h % 3)
					if py <= 2 and px >= agac % 2 and px <= 1 + agac % 2 + 1:
						c = temel.darkened(0.25 if (px + py) % 2 == 0 else 0.15)
					if py == 3 and px == 1 + agac % 2:
						c = Color("5a3a20")
				SimS.B_DAG:
					if py == 0 or (py == 1 and px >= 1 and px <= 2):
						c = Color("f2f2f2") if h % 2 == 0 else temel.lightened(0.2)
					elif px + py >= 5:
						c = temel.darkened(0.15)
				SimS.B_TEPE:
					if px + py >= 5:
						c = temel.darkened(0.1)
				SimS.B_BATAK:
					if hh % 5 == 0:
						c = Color("3d6b78")
				SimS.B_LAV:
					if hh % 3 == 0:
						c = Color("ffb020")
				SimS.B_OVA, SimS.B_BOZKIR:
					if hh % 11 == 0:
						c = temel.lightened(0.12)
				_:
					if hh % 13 == 0:
						c = temel.darkened(0.06)
			resim.set_pixel(x0 + px, y0 + py, c)
	if sim.maden[k] > 0 and sim.yapi[k] == 0:
		resim.set_pixel(x0 + 2, y0 + 2, Color("ffd23a") if sim.maden[k] == 1 else Color("b5653a"))
	var y: int = sim.yapi[k]
	if y != 0:
		_yapi_ciz(k, y, x0, y0)
	if sim.ates[k] > 0:
		for n in 6:
			var hh := _hash(k, n + 31)
			resim.set_pixel(x0 + hh % 4, y0 + (hh >> 3) % 4, Color("ff7a1a") if n % 2 == 0 else Color("ffd84a"))


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
				resim.set_pixel(x0 + px, y0 + py, c)


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
	var a := alfa if ara_deger else 1.0
	var gx := gorunur.position.x
	var gy := gorunur.position.y
	var gx2 := gorunur.end.x
	var gy2 := gorunur.end.y
	for i in sim.ust:
		if sim.c_var[i] == 0:
			continue
		var x: float = sim.c_x[i]
		var y: float = sim.c_y[i]
		if x < gx or x > gx2 or y < gy or y > gy2:
			continue
		if a < 1.0:
			x = lerpf(sim.c_ox[i], x, a)
			y = lerpf(sim.c_oy[i], y, a)
		var t: Dictionary = sim.turler[sim.c_tur[i]]
		var px := x * KARO
		var py := y * KARO
		var boy: float = t["boy"]
		var renk: Color = t["renk_c"]
		if not detay:
			draw_rect(Rect2(px - 1.5, py - 1.5, 3, 3), renk)
			continue
		var ten: Color = t["ten_c"]
		if sim.t_irk[sim.c_tur[i]] == 1:
			var yt: bool = sim.c_yas[i] >= int(t["yetiskin"]) * 12
			var s := boy * (1.0 if yt else 0.65)
			var gov := renk
			if sim.c_durum[i] == SimS.D_ASKER:
				gov = renk.darkened(0.35)
			draw_rect(Rect2(px - 1.0 * s, py - 1.0 * s, 2.0 * s, 3.0 * s), gov)
			draw_rect(Rect2(px - 0.8 * s, py - 2.8 * s, 1.6 * s, 1.8 * s), ten)
			if sim.c_durum[i] == SimS.D_ASKER and detay:
				draw_line(Vector2(px + 1.2 * s, py - 2.5 * s), Vector2(px + 1.2 * s, py + 1.5 * s), Color("d0d0d8"), 0.5)
		elif sim.t_ucan[sim.c_tur[i]] == 1:
			var kanat := sin(Time.get_ticks_msec() * 0.008 + i) * 2.0 * boy
			draw_rect(Rect2(px - 2.0 * boy, py - 1.0 * boy, 4.0 * boy, 2.0 * boy), renk)
			draw_line(Vector2(px - 1.5 * boy, py - 0.5 * boy), Vector2(px - 4.0 * boy, py - 1.0 * boy - kanat), renk.lightened(0.2), 1.2)
			draw_line(Vector2(px + 1.5 * boy, py - 0.5 * boy), Vector2(px + 4.0 * boy, py - 1.0 * boy - kanat), renk.lightened(0.2), 1.2)
			draw_rect(Rect2(px + 1.6 * boy, py - 1.6 * boy, 1.4 * boy, 1.2 * boy), ten)
		else:
			draw_rect(Rect2(px - 1.6 * boy, py - 1.0 * boy, 3.2 * boy, 2.0 * boy), renk)
			draw_rect(Rect2(px + 1.0 * boy, py - 1.6 * boy, 1.2 * boy, 1.2 * boy), ten)
	if secili >= 0 and sim.c_var[secili] == 1:
		var p := Vector2(sim.c_x[secili], sim.c_y[secili]) * KARO
		draw_arc(p + Vector2(0, -1), 5.0, 0, TAU, 20, Color(1, 1, 0.3), 0.8)
	_efektleri_ciz()


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
