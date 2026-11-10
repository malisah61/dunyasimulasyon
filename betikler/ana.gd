extends Node
## Oyunun ana sahnesi: dünya, kamera, arayüz, tanrı araçları, kaydet/yükle.

const SimS = preload("res://betikler/sim.gd")
const HaritaS = preload("res://betikler/harita.gd")
const KARO := 4
const HIZLAR := [0, 1, 5, 20, 100, 500]
const HIZ_AD := ["II", "1x", "5x", "20x", "100x", "500x"]
const BOYUTLAR := [[192, 120, "Küçük"], [256, 160, "Orta"], [384, 240, "Büyük"], [512, 320, "Dev"]]
const ARAZI := [
	["Derin su", 0], ["Sığ su", 1], ["Kum", 2], ["Ova", 3], ["Orman", 4], ["Bozkır", 5],
	["Çöl", 6], ["Bataklık", 7], ["Tepe", 8], ["Dağ", 9], ["Kar", 10], ["Lav", 11],
]
const AFETLER := [
	["Yıldırım", "yildirim"], ["Yangın", "yangin"], ["Yağmur", "yagmur"], ["Deprem", "deprem"],
	["Volkan", "volkan"], ["Meteor", "meteor"], ["Tsunami", "tsunami"], ["Hortum", "hortum"],
	["Salgın", "salgin"], ["Çekirge", "cekirge"], ["Kuraklık", "kuraklik"], ["Kara kış", "karakis"], ["UFO", "ufo"],
]
const GUCLER := [["Canlı sil", "sil"], ["Bereket", "bereket"], ["Gazap", "olum"], ["Savaş çıkar", "savas"], ["Barış yaptır", "baris"], ["İttifak kur", "ittifak"]]
const FIRCALAR := [1, 2, 4, 7, 12]
## Seçili araç için kısa ipucu (oyuncu ne yapacağını anlasın)
const IPUCU := {
	"incele": "Bir canlıya dokun: bilgi kartı açılır. Köye dokun: köy bilgisi. Sürükle: haritayı kaydır.",
	"arazi": "Sürükleyerek araziyi boya. Fırça boyutunu sağdaki düğmeden değiştir.",
	"canli": "Dokun ya da sürükle: seçili türden canlı koy. Özellik fırçasıyla doğuştan özellik ver.",
	"yildirim": "Dokun ya da sürükle: yıldırım düşer, yangın çıkabilir.", "yangin": "Sürükleyerek ateş yak.",
	"yagmur": "Sürükle: yağmur yangını söndürür, çölü ve yanık toprağı yeşertir.", "deprem": "Dokun: deprem binaları yıkar.",
	"volkan": "Dokun: volkan patlar, lav akar.", "meteor": "Dokun: meteor düşer, bazen maden bırakır.",
	"tsunami": "Kıyıya dokun: dev dalga kıyı köylerini vurur.", "hortum": "Dokun: hortum çıkar ve dolaşır.",
	"salgin": "Bir köye dokun: salgın başlar ve yayılabilir.", "cekirge": "Bir köye dokun: çekirgeler ekinleri yer.",
	"kuraklik": "Dokun: tüm dünyada 3 yıllık kuraklık.", "karakis": "Dokun: kara kış; kuzeyde soğuk öldürür.",
	"ufo": "Dokun: UFO gelir, sonra uzaylılar üs kurar.",
	"sil": "Sürükleyerek fırça alanındaki canlıları sil. Fırça boyutunu sağdaki düğmeden değiştir.",
	"bereket": "Bir köye dokun: yiyecek ve malzeme yağar.", "olum": "Dokun: küçük alandaki canlılar ölür.",
	"savas": "Önce bir krallığın köyüne, sonra diğerinin köyüne dokun: savaş başlar.",
	"baris": "İki savaşan krallığın köylerine sırayla dokun: barış yapılır.",
	"ittifak": "İki krallığın köylerine sırayla dokun: ittifak kurulur, birbirlerini savunurlar.",
}
const ETKI_AD := {
	"zeka": "zekâ", "ogrenme": "öğrenme", "calisma": "çalışma", "guc": "güç", "hiz": "hız", "can": "can",
	"omur": "ömür", "dogurganlik": "doğurganlık", "cesaret": "cesaret", "moral": "moral", "diplomasi": "diplomasi",
	"liderlik": "liderlik", "teknoloji": "teknoloji", "saldiri": "saldırı", "savas_istegi": "savaş isteği",
	"uretim": "üretim", "tarim": "tarım", "avcilik": "avcılık", "madencilik": "madencilik", "insaat": "inşaat",
	"ticaret": "ticaret", "hastalik_direnci": "hastalık direnci", "kesif": "keşif", "sadakat": "sadakat",
	"ihanet": "ihanet", "okculuk": "okçuluk", "yakin_dovus": "kılıç", "kacis": "kaçış", "yemek": "yemek ihtiyacı",
	"altin_toplama": "altın", "baris_yapma": "barışçılık", "ikiz_sansi": "ikiz", "mutasyon": "mutasyon",
	"sans": "şans", "kultur": "kültür", "aldatilma": "kandırılma", "casusluk": "casusluk", "silah_yapim": "silah yapımı", "zirh_yapim": "zırh yapımı", "savas_taktik": "taktik", "karar": "karar", "kacinma": "kaçınma", "zanaat": "zanaat", "gorus": "görüş", "es_bulma": "eş bulma", "darbe": "darbe", "kavga": "kavga", "denizcilik": "denizcilik", "binicilik": "binicilik", "iksir": "iksir", "din_yayma": "din yayma", "kaza": "kaza", "buyu": "büyü", "sifa": "şifa", "iyilesme": "iyileşme", "gizlilik": "gizlilik",
}

var sim
var harita
var kamera: Camera2D
var hiz_no := 1
var birikim := 0.0
var arac := "incele"
var arac_veri = null
var firca := 2
var firca_ozl: Array = []
var savas_ilk := -1
var kayit_yuva := 1
var takip := false
var son_boya := 0.0
var platform_mobil := false
var baslangic_bos := false   # yeni dünya boş mu başlasın
var ipucu_lbl: Label

# dokunma
var dokunmalar := {}
var surukle_mesafe := 0.0
var pinch_bas := 0.0
var pinch_zoom := 1.0
var boyuyor := false

# arayüz
var ui: CanvasLayer
var tarih_lbl: Label
var nufus_lbl: Label
var hiz_btnlar: Array = []
var sekme_kutu: HBoxContainer
var arac_kutu: HBoxContainer
var arac_btnlar: Array = []
var bilgi_panel: PanelContainer
var bilgi_lbl: RichTextLabel
var bilgi_ozl: HFlowContainer
var secici: PanelContainer
var secici_grid: GridContainer
var secici_baslik: Label
var secici_bilgi: Label
var secici_mod := "ekle"
var secici_kat := "Tümü"
var buyuk_panel: PanelContainer
var buyuk_lbl: RichTextLabel
var buyuk_baslik: Label
var buyuk_tur := ""
var menu_panel: PanelContainer
var bildirim: Label
var bildirim_sure := 0.0
var etiket_katmani: Control
var firca_btn: Button
var sekme := "Gözlem"
var onizleme_modu := false


func _ready() -> void:
	platform_mobil = OS.has_feature("mobile")
	sim = SimS.new()
	sim.nufus_siniri = 0   # varsayılan: sınırsız (menüden ayarlanabilir)
	harita = HaritaS.new()
	add_child(harita)
	kamera = Camera2D.new()
	add_child(kamera)
	kamera.make_current()
	_arayuz_kur()
	if OS.get_cmdline_user_args().has("onizleme"):
		onizleme_modu = true
		_onizleme.call_deferred()
		return
	if not _yukle(0):
		yeni_dunya(1, randi())


func yeni_dunya(boyut: int, tohum: int, bos := false) -> void:
	var b: Array = BOYUTLAR[boyut]
	var sinir: int = sim.nufus_siniri
	sim.dunya_uret(b[0], b[1], tohum)
	sim.nufus_siniri = sinir
	if not bos:
		sim.baslangic_canlilari()
	harita.baglan(sim)
	harita.secili = -1
	_kamera_sigdir()
	_bilgi_kapat()


func _kamera_sigdir() -> void:
	var ekran := get_viewport().get_visible_rect().size
	var z := minf(ekran.x / (sim.gen * KARO), (ekran.y - 150) / (sim.yuk * KARO))
	kamera.zoom = Vector2(z, z)
	kamera.position = Vector2(sim.gen, sim.yuk) * KARO * 0.5 + Vector2(0, 10 / z)


# ============================================================ DÖNGÜ
func _process(delta: float) -> void:
	if sim.gen == 0:
		return
	var hiz: int = HIZLAR[hiz_no]
	sim.hareket_adim = 1 if hiz <= 20 else (4 if hiz <= 100 else 12)
	harita.ara_deger = hiz <= 5
	if hiz > 0:
		birikim += delta * hiz
		var bas := Time.get_ticks_msec()
		var butce := 12 if platform_mobil else 16
		while birikim >= 1.0:
			sim.tick()
			birikim -= 1.0
			if Time.get_ticks_msec() - bas > butce:
				birikim = minf(birikim, 1.0)
				break
		harita.alfa = clampf(birikim, 0.0, 1.0)
	harita.guncelle()
	_kamera_klavye(delta)
	if takip and harita.secili >= 0 and sim.c_var[harita.secili] == 1:
		kamera.position = kamera.position.lerp(Vector2(sim.c_x[harita.secili], sim.c_y[harita.secili]) * KARO, minf(1.0, delta * 6.0))
	etiket_katmani.queue_redraw()
	_ust_bar()
	if bilgi_panel.visible and Engine.get_process_frames() % 15 == 0:
		_bilgi_yaz()
	if buyuk_panel.visible and Engine.get_process_frames() % 30 == 0:
		_buyuk_yaz()
	if bildirim_sure > 0.0:
		bildirim_sure -= delta
		bildirim.modulate.a = clampf(bildirim_sure, 0.0, 1.0)
	if boyuyor and dokunmalar.size() == 1 and _surekli_arac():
		son_boya += delta
		if son_boya > 0.06:
			son_boya = 0.0
			var p: Vector2 = dokunmalar.values()[0]
			_arac_uygula(p, true)


func _ust_bar() -> void:
	tarih_lbl.text = sim.tarih_yazi()
	var cag := ""
	var en_cag := -1
	for id in sim.koyler:
		en_cag = maxi(en_cag, sim.koyler[id]["cag"])
	if en_cag >= 0:
		cag = "  ·  En ileri: " + SimS.CAG_AD[en_cag]
	nufus_lbl.text = "Nüfus %d  ·  Köy %d  ·  Krallık %d%s" % [sim.irk_nufus, sim.koyler.size(), sim.kralliklar.size(), cag]


func _kamera_klavye(delta: float) -> void:
	var v := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): v.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): v.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): v.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): v.y += 1
	if v != Vector2.ZERO:
		kamera.position += v * 600.0 * delta / kamera.zoom.x
		_kamera_sinirla()


func _kamera_sinirla() -> void:
	kamera.position = kamera.position.clamp(Vector2.ZERO, Vector2(sim.gen, sim.yuk) * KARO)


func _zoom(carpan: float, odak: Vector2) -> void:
	var once := _dunya(odak)
	var z := clampf(kamera.zoom.x * carpan, 0.15, 14.0)
	kamera.zoom = Vector2(z, z)
	var sonra := _dunya(odak)
	kamera.position += once - sonra
	_kamera_sinirla()


func _dunya(ekran: Vector2) -> Vector2:
	return harita.get_canvas_transform().affine_inverse() * ekran


# ============================================================ GİRDİ
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.pressed and e.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(1.15, e.position)
		elif e.pressed and e.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(1.0 / 1.15, e.position)
	elif e is InputEventMouseMotion:
		_imlec_guncelle(e.position)
		if e.button_mask & (MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE):
			kamera.position -= e.relative / kamera.zoom.x
			_kamera_sinirla()
	elif e is InputEventScreenTouch:
		if e.pressed:
			dokunmalar[e.index] = e.position
			if dokunmalar.size() == 1:
				surukle_mesafe = 0.0
				boyuyor = arac != "incele"
				son_boya = 1.0
				if boyuyor and _surekli_arac():
					_arac_uygula(e.position, true)
			elif dokunmalar.size() == 2:
				boyuyor = false
				var p: Array = dokunmalar.values()
				pinch_bas = (p[0] as Vector2).distance_to(p[1])
				pinch_zoom = kamera.zoom.x
		else:
			if dokunmalar.size() == 1 and surukle_mesafe < 12.0:
				if arac == "incele" or not _surekli_arac():
					_arac_uygula(e.position, false)
			dokunmalar.erase(e.index)
			if dokunmalar.is_empty():
				boyuyor = false
	elif e is InputEventScreenDrag:
		var once: Vector2 = dokunmalar.get(e.index, e.position)
		dokunmalar[e.index] = e.position
		if dokunmalar.size() == 1:
			_imlec_guncelle(e.position)
			surukle_mesafe += e.relative.length()
			if not boyuyor:
				kamera.position -= e.relative / kamera.zoom.x
				_kamera_sinirla()
				if surukle_mesafe > 12.0:
					takip = false
		elif dokunmalar.size() == 2:
			var p: Array = dokunmalar.values()
			var d := (p[0] as Vector2).distance_to(p[1])
			var orta: Vector2 = ((p[0] as Vector2) + (p[1] as Vector2)) * 0.5
			if pinch_bas > 10.0:
				var hedef := clampf(pinch_zoom * d / pinch_bas, 0.15, 14.0)
				_zoom(hedef / kamera.zoom.x, orta)
			kamera.position -= (e.position - once) * 0.5 / kamera.zoom.x
			_kamera_sinirla()
	elif e is InputEventKey and e.pressed and not e.echo:
		match e.keycode:
			KEY_SPACE: hiz_ayarla(0 if hiz_no != 0 else 1)
			KEY_1: hiz_ayarla(1)
			KEY_2: hiz_ayarla(2)
			KEY_3: hiz_ayarla(3)
			KEY_4: hiz_ayarla(4)
			KEY_5: hiz_ayarla(5)
			KEY_ESCAPE:
				arac_sec("incele", null)
				_bilgi_kapat()
			KEY_F5: _kaydet(kayit_yuva)
			KEY_F9: _yukle(kayit_yuva)


func _surekli_arac() -> bool:
	return arac == "arazi" or arac == "canli" or (arac == "guc" and arac_veri == "sil") or (arac == "afet" and (arac_veri == "yangin" or arac_veri == "yildirim" or arac_veri == "yagmur"))


func _fircali_arac() -> bool:
	return arac == "arazi" or (arac == "guc" and arac_veri == "sil")


## Fare/parmak altında fırça çemberi gösterir.
func _imlec_guncelle(ekran: Vector2) -> void:
	if _fircali_arac():
		harita.imlec = _dunya(ekran) / KARO
		harita.imlec_r = firca + 0.5
		harita.imlec_renk = Color(1, 0.35, 0.3, 0.85) if arac == "guc" else Color(1, 1, 1, 0.7)
	else:
		harita.imlec = Vector2(-1, -1)


func _arac_uygula(ekran: Vector2, surukleme: bool) -> void:
	var w := _dunya(ekran) / KARO
	var x := int(w.x)
	var y := int(w.y)
	if not sim.icinde(x, y):
		return
	match arac:
		"incele":
			var i: int = sim.canli_bul(w.x, w.y, maxf(1.5, 6.0 / kamera.zoom.x))
			if i >= 0:
				harita.secili = i
				_bilgi_ac()
			else:
				var v = sim.koy_yakin(x, y, 4)
				if v != null:
					_koy_goster(v)
				else:
					_bilgi_kapat()
		"arazi":
			sim.arazi_boya(x, y, firca, int(arac_veri))
		"canli":
			if surukleme and not (sim.rng.randf() < 0.5):
				return
			var ids := []
			for o in firca_ozl:
				ids.append(o)
			var i: int = sim.canli_koy(int(arac_veri), w.x + randf_range(-0.4, 0.4), w.y + randf_range(-0.4, 0.4), ids)
			if i < 0 and not surukleme:
				_bildir("Buraya konamaz (su ya da lav).")
		"afet":
			if surukleme and arac_veri == "yildirim" and randf() < 0.6:
				return
			if surukleme and arac_veri == "yagmur" and randf() < 0.7:
				return
			sim.afet(arac_veri, x, y, true)
			if not surukleme and (arac_veri == "salgin" or arac_veri == "cekirge") and sim.koy_yakin(x, y, 12) == null:
				_bildir("Yakında köy yok.")
		"guc":
			_guc_uygula(arac_veri, x, y)


func _guc_uygula(ad: String, x: int, y: int) -> void:
	var v = sim.koy_yakin(x, y, 10)
	match ad:
		"bereket":
			if v != null:
				sim.afet("bereket", x, y, true)
				_bildir("%s köyü kutsandı: yiyecek ve malzeme bol." % v["ad"])
			else:
				_bildir("Bir köye dokun.")
		"olum":
			sim.afet("olum", x, y, true)
		"sil":
			sim.canli_sil(x + 0.5, y + 0.5, firca + 0.5)
			sim.efektler.append([8, x + 0.5, y + 0.5, 2, firca + 0.5])
		"savas", "baris", "ittifak":
			if v == null:
				_bildir("Bir köye dokun.")
				return
			if savas_ilk < 0 or not sim.kralliklar.has(savas_ilk):
				savas_ilk = v["krallik"]
				_bildir("%s seçildi. Şimdi diğer krallığın köyüne dokun." % sim.kralliklar[savas_ilk]["ad"])
				return
			var b: int = v["krallik"]
			if b == savas_ilk:
				_bildir("Aynı krallık. Başka bir krallığın köyüne dokun.")
				return
			if ad == "savas":
				sim.savas_ilan(savas_ilk, b, "tanrının kışkırtması")
				_bildir("Savaş başladı!")
			elif ad == "ittifak":
				if sim.ittifak_kur(savas_ilk, b):
					_bildir("İttifak kuruldu.")
				else:
					_bildir("Bu iki krallık zaten müttefik.")
			else:
				if sim.kralliklar[savas_ilk]["savas"].has(b):
					sim.baris_yap(savas_ilk, b)
					_bildir("Barış yapıldı.")
				else:
					_bildir("Bu iki krallık zaten savaşmıyor.")
			savas_ilk = -1


func hiz_ayarla(n: int) -> void:
	hiz_no = n
	for i in hiz_btnlar.size():
		hiz_btnlar[i].button_pressed = i == n


func arac_sec(ad: String, veri) -> void:
	arac = ad
	arac_veri = veri
	savas_ilk = -1
	for b in arac_btnlar:
		b.button_pressed = b.get_meta("arac") == ad and (b.get_meta("veri") if b.has_meta("veri") else null) == veri
	if ipucu_lbl != null:
		var anahtar: String = ad if ad in ["incele", "arazi", "canli"] else str(veri)
		ipucu_lbl.text = IPUCU.get(anahtar, "")
	if not _fircali_arac() and harita != null:
		harita.imlec = Vector2(-1, -1)


# ============================================================ ARAYÜZ
func _tema() -> Theme:
	var t := Theme.new()
	t.default_font_size = 22 if platform_mobil else 18
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.08, 0.1, 0.14, 0.92)
	panel.set_corner_radius_all(10)
	panel.set_content_margin_all(10)
	panel.border_color = Color(0.3, 0.38, 0.5)
	panel.set_border_width_all(1)
	t.set_stylebox("panel", "PanelContainer", panel)
	var btn := StyleBoxFlat.new()
	btn.bg_color = Color(0.17, 0.21, 0.28)
	btn.set_corner_radius_all(8)
	btn.content_margin_left = 10
	btn.content_margin_right = 10
	btn.content_margin_top = 6
	btn.content_margin_bottom = 6
	var btn_h := btn.duplicate()
	btn_h.bg_color = Color(0.24, 0.3, 0.4)
	var btn_p := btn.duplicate()
	btn_p.bg_color = Color(0.85, 0.6, 0.18)
	t.set_stylebox("normal", "Button", btn)
	t.set_stylebox("hover", "Button", btn_h)
	t.set_stylebox("pressed", "Button", btn_p)
	t.set_stylebox("hover_pressed", "Button", btn_p)
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_pressed_color", "Button", Color(0.1, 0.08, 0.05))
	t.set_color("font_hover_pressed_color", "Button", Color(0.1, 0.08, 0.05))
	return t


func _dugme(yazi: String, eylem: Callable, kutu: Node, gecis := false) -> Button:
	var b := Button.new()
	b.text = yazi
	b.toggle_mode = gecis
	b.custom_minimum_size = Vector2(0, 56 if platform_mobil else 40)
	b.pressed.connect(eylem)
	b.focus_mode = Control.FOCUS_NONE
	kutu.add_child(b)
	return b


func _arayuz_kur() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var kok := Control.new()
	kok.set_anchors_preset(Control.PRESET_FULL_RECT)
	kok.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kok.theme = _tema()
	ui.add_child(kok)
	etiket_katmani = Control.new()
	etiket_katmani.set_anchors_preset(Control.PRESET_FULL_RECT)
	etiket_katmani.mouse_filter = Control.MOUSE_FILTER_IGNORE
	etiket_katmani.draw.connect(_etiketleri_ciz)
	kok.add_child(etiket_katmani)
	# ---- üst çubuk
	var ust := PanelContainer.new()
	ust.set_anchors_preset(Control.PRESET_TOP_WIDE)
	kok.add_child(ust)
	var uh := HBoxContainer.new()
	uh.add_theme_constant_override("separation", 6)
	ust.add_child(uh)
	var yazilar := VBoxContainer.new()
	yazilar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yazilar.add_theme_constant_override("separation", 0)
	uh.add_child(yazilar)
	tarih_lbl = Label.new()
	tarih_lbl.add_theme_font_size_override("font_size", 24 if platform_mobil else 20)
	yazilar.add_child(tarih_lbl)
	nufus_lbl = Label.new()
	nufus_lbl.add_theme_font_size_override("font_size", 17 if platform_mobil else 15)
	nufus_lbl.modulate = Color(0.8, 0.85, 0.9)
	yazilar.add_child(nufus_lbl)
	for n in HIZLAR.size():
		var b := _dugme(HIZ_AD[n], hiz_ayarla.bind(n), uh, true)
		b.custom_minimum_size.x = 58 if platform_mobil else 50
		hiz_btnlar.append(b)
	_dugme("Kronik", _buyuk_ac.bind("kronik"), uh)
	_dugme("İstatistik", _buyuk_ac.bind("istatistik"), uh)
	_dugme("Menü", _menu_ac, uh)
	hiz_ayarla(1)
	# ---- alt araç çubuğu
	var alt := PanelContainer.new()
	alt.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	alt.grow_vertical = Control.GROW_DIRECTION_BEGIN
	kok.add_child(alt)
	var av := VBoxContainer.new()
	alt.add_child(av)
	ipucu_lbl = Label.new()
	ipucu_lbl.add_theme_font_size_override("font_size", 16 if platform_mobil else 14)
	ipucu_lbl.modulate = Color(1, 0.88, 0.6)
	ipucu_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	av.add_child(ipucu_lbl)
	sekme_kutu = HBoxContainer.new()
	av.add_child(sekme_kutu)
	for s in ["Gözlem", "Arazi", "Canlılar", "Afetler", "Güçler"]:
		var b := _dugme(s, _sekme_sec.bind(s), sekme_kutu, true)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.set_meta("sekme", s)
	var kay := ScrollContainer.new()
	kay.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	kay.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	kay.custom_minimum_size = Vector2(0, 66 if platform_mobil else 48)
	av.add_child(kay)
	arac_kutu = HBoxContainer.new()
	kay.add_child(arac_kutu)
	_sekme_sec("Gözlem")
	# ---- bilgi paneli (sağ)
	bilgi_panel = PanelContainer.new()
	bilgi_panel.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	bilgi_panel.offset_left = -420 if platform_mobil else -380
	bilgi_panel.offset_top = 80
	bilgi_panel.offset_bottom = -150
	bilgi_panel.visible = false
	kok.add_child(bilgi_panel)
	var bv := VBoxContainer.new()
	bilgi_panel.add_child(bv)
	bilgi_lbl = RichTextLabel.new()
	bilgi_lbl.bbcode_enabled = true
	bilgi_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bilgi_lbl.add_theme_font_size_override("normal_font_size", 19 if platform_mobil else 16)
	bilgi_lbl.add_theme_font_size_override("bold_font_size", 22 if platform_mobil else 18)
	bv.add_child(bilgi_lbl)
	bilgi_ozl = HFlowContainer.new()
	bv.add_child(bilgi_ozl)
	var bh := HBoxContainer.new()
	bv.add_child(bh)
	_dugme("+ Özellik", _secici_ac.bind("ekle"), bh)
	_dugme("Takip", func(): takip = not takip, bh)
	_dugme("Kapat", _bilgi_kapat, bh)
	# ---- özellik seçici
	secici = PanelContainer.new()
	secici.set_anchors_preset(Control.PRESET_FULL_RECT)
	secici.offset_left = 40; secici.offset_right = -40; secici.offset_top = 40; secici.offset_bottom = -40
	secici.visible = false
	kok.add_child(secici)
	var sv := VBoxContainer.new()
	secici.add_child(sv)
	var sh := HBoxContainer.new()
	sv.add_child(sh)
	secici_baslik = Label.new()
	secici_baslik.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sh.add_child(secici_baslik)
	_dugme("Temizle", func():
		firca_ozl.clear()
		_secici_doldur()
		_firca_yazi(), sh)
	_dugme("Kapat", func(): secici.visible = false, sh)
	var kat := HFlowContainer.new()
	sv.add_child(kat)
	for k in ["Tümü", "Olumlu", "Olumsuz", "Zihin", "Beden", "Karakter", "Sosyal", "Üreme", "Yetenek", "Doğa", "Özel"]:
		_dugme(k, func():
			secici_kat = k
			_secici_doldur(), kat)
	secici_bilgi = Label.new()
	secici_bilgi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	secici_bilgi.modulate = Color(1, 0.85, 0.5)
	sv.add_child(secici_bilgi)
	var sk := ScrollContainer.new()
	sk.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sk.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sv.add_child(sk)
	secici_grid = GridContainer.new()
	secici_grid.columns = 3
	secici_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sk.add_child(secici_grid)
	# ---- büyük panel (kronik / istatistik)
	buyuk_panel = PanelContainer.new()
	buyuk_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	buyuk_panel.offset_left = 60; buyuk_panel.offset_right = -60; buyuk_panel.offset_top = 70; buyuk_panel.offset_bottom = -40
	buyuk_panel.visible = false
	kok.add_child(buyuk_panel)
	var yv := VBoxContainer.new()
	buyuk_panel.add_child(yv)
	var yh := HBoxContainer.new()
	yv.add_child(yh)
	buyuk_baslik = Label.new()
	buyuk_baslik.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	yh.add_child(buyuk_baslik)
	_dugme("Kapat", func(): buyuk_panel.visible = false, yh)
	buyuk_lbl = RichTextLabel.new()
	buyuk_lbl.bbcode_enabled = true
	buyuk_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	buyuk_lbl.add_theme_font_size_override("normal_font_size", 19 if platform_mobil else 16)
	buyuk_lbl.add_theme_font_size_override("bold_font_size", 22 if platform_mobil else 18)
	yv.add_child(buyuk_lbl)
	# ---- menü
	menu_panel = PanelContainer.new()
	menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	menu_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	menu_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	menu_panel.custom_minimum_size = Vector2(560, 0)
	menu_panel.visible = false
	kok.add_child(menu_panel)
	# ---- bildirim
	bildirim = Label.new()
	bildirim.set_anchors_preset(Control.PRESET_CENTER_TOP)
	bildirim.grow_horizontal = Control.GROW_DIRECTION_BOTH
	bildirim.offset_top = 90
	bildirim.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bildirim.add_theme_color_override("font_outline_color", Color.BLACK)
	bildirim.add_theme_constant_override("outline_size", 6)
	bildirim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kok.add_child(bildirim)


func _bildir(s: String) -> void:
	bildirim.text = s
	bildirim_sure = 3.0
	bildirim.modulate.a = 1.0


func _sekme_sec(s: String) -> void:
	sekme = s
	for b in sekme_kutu.get_children():
		b.button_pressed = b.get_meta("sekme") == s
	for c in arac_kutu.get_children():
		c.queue_free()
	arac_btnlar.clear()
	match s:
		"Gözlem":
			_arac_dugme("İncele", "incele", null)
			_dugme("Haritayı sığdır", _kamera_sigdir, arac_kutu)
			var kb := _dugme("Krallık haritası", func(): harita.krallik_harita = not harita.krallik_harita, arac_kutu, true)
			kb.button_pressed = harita.krallik_harita
			_dugme("Rastgele canlı", func():
				var adaylar := []
				for i in sim.ust:
					if sim.c_var[i] == 1 and sim.t_irk[sim.c_tur[i]] == 1:
						adaylar.append(i)
				if adaylar.size() > 0:
					harita.secili = adaylar[randi() % adaylar.size()]
					takip = true
					kamera.zoom = Vector2(6, 6)
					_bilgi_ac(), arac_kutu)
			arac_sec("incele", null)
		"Arazi":
			for a in ARAZI:
				var b := _arac_dugme(a[0], "arazi", a[1])
				b.add_theme_color_override("font_color", harita.B_RENK[a[1]].lightened(0.3))
			_firca_dugme("Arazi")
		"Canlılar":
			for t in sim.turler:
				var b := _arac_dugme(t["ad"], "canli", t["no"])
				b.add_theme_color_override("font_color", (t["renk_c"] as Color).lightened(0.35))
			firca_btn = _dugme("", _secici_ac.bind("firca"), arac_kutu)
			_firca_yazi()
		"Afetler":
			for a in AFETLER:
				_arac_dugme(a[0], "afet", a[1])
		"Güçler":
			for a in GUCLER:
				var b := _arac_dugme(a[0], "guc", a[1])
				if a[1] == "sil":
					b.add_theme_color_override("font_color", Color("ff8a7a"))
			_firca_dugme("Güçler")


func _firca_dugme(sekme_adi: String) -> void:
	_dugme("Fırça: %d" % firca, func():
		firca = FIRCALAR[(FIRCALAR.find(firca) + 1) % FIRCALAR.size()]
		_imlec_guncelle(get_viewport().get_mouse_position())
		_sekme_sec(sekme_adi), arac_kutu)


func _arac_dugme(yazi: String, ad: String, veri) -> Button:
	var b := _dugme(yazi, arac_sec.bind(ad, veri), arac_kutu, true)
	b.set_meta("arac", ad)
	b.set_meta("veri", veri)
	b.button_pressed = arac == ad and arac_veri == veri
	arac_btnlar.append(b)
	return b


func _firca_yazi() -> void:
	if firca_btn != null and is_instance_valid(firca_btn):
		firca_btn.text = "Özellik fırçası (%d)" % firca_ozl.size()


# ------------------------------------------------------------ bilgi kartı
func _bilgi_ac() -> void:
	bilgi_panel.visible = true
	_bilgi_yaz()


func _bilgi_kapat() -> void:
	bilgi_panel.visible = false
	harita.secili = -1
	takip = false


func _bilgi_yaz() -> void:
	var i: int = harita.secili
	if i < 0 or sim.c_var[i] == 0:
		if i >= 0:
			bilgi_lbl.text = "[b]Bu canlı öldü.[/b]"
			for c in bilgi_ozl.get_children():
				c.queue_free()
			harita.secili = -1
		return
	var t: Dictionary = sim.turler[sim.c_tur[i]]
	var s := ""
	var ad: String = sim.c_ad[i] if sim.c_ad[i] != "" else t["ad"]
	s += "[b]%s[/b]  [color=#9ab]%s, %s[/color]\n" % [ad, t["ad"], "dişi" if sim.c_cins[i] == 0 else "erkek"]
	s += "Yaş: %d  ·  Can: %d/%d\n" % [sim.c_yas[i] / 12, int(sim.c_can[i]), int(sim.s_canmax[i])]
	s += "Güç %d · Hız %.1f · Zekâ %d\n" % [int(sim.s_guc[i]), sim.s_hiz[i], int(sim.s_zeka[i])]
	s += "Çalışkanlık %d%% · Doğurganlık %d%%\n" % [int(sim.s_is[i] * 100), int(sim.s_dogur[i] * 100)]
	s += "Beklenen ömür: %d yıl\n" % int(sim.s_omur[i] / 12)
	var v = sim.koyler.get(sim.c_koy[i])
	if v != null:
		var kr = sim.kralliklar.get(v["krallik"])
		s += "%s: %s\n" % [SimS.KADEME_AD[sim.kademe(v)], v["ad"]]
		if kr != null:
			s += "Krallık: [color=#%s]%s[/color]\n" % [kr["renk"], kr["ad"]]
			if kr["kral_uid"] == sim.c_uid[i]:
				s += "[color=#ffd23a]♛ Hükümdar[/color]\n"
			var din = sim.dinler.get(int(kr.get("din", -1)))
			if din != null:
				s += "Din: [color=#%s]%s[/color]\n" % [din["renk"], din["ad"]]
		s += "Silah: %s\n" % SimS.SILAH_AD[v["cag"]]
	elif t["irk"]:
		s += "Köyü yok (gezgin)\n"
	var durum := ["Geziyor", "Asker", "Göç ediyor", "Kaçıyor"]
	s += "Durum: %s\n" % durum[sim.c_durum[i]]
	if sim.c_oldurme[i] > 0:
		s += "Öldürdüğü: %d\n" % sim.c_oldurme[i]
	if sim.c_cocuk[i] > 0:
		s += "Çocuk: %d\n" % sim.c_cocuk[i]
	var anne: int = sim.uid_bul(sim.c_anne[i]) if sim.c_anne[i] > 0 else -1
	var baba: int = sim.uid_bul(sim.c_baba[i]) if sim.c_baba[i] > 0 else -1
	if anne >= 0 or baba >= 0:
		s += "Anne/baba: %s / %s\n" % [sim.c_ad[anne] if anne >= 0 else "?", sim.c_ad[baba] if baba >= 0 else "?"]
	s += "\n[b]Özellikler[/b] (dokun = sil):"
	bilgi_lbl.text = s
	var idler: PackedInt32Array = sim.ozellik_idleri(i)
	var mevcut := []
	for c in bilgi_ozl.get_children():
		mevcut.append(c.get_meta("id"))
	if mevcut != Array(idler):
		for c in bilgi_ozl.get_children():
			c.queue_free()
		for id in idler:
			var o: Dictionary = sim.ozellikler[id]
			var b := _dugme(o["ad"] + " ✕", func():
				sim.ozellik_sil(harita.secili, id)
				_bilgi_yaz(), bilgi_ozl)
			b.set_meta("id", id)
			b.add_theme_color_override("font_color", _tur_renk(o["tur"]))


func _tur_renk(tur: String) -> Color:
	if tur == "olumlu":
		return Color("7be07b")
	if tur == "olumsuz":
		return Color("ff7a7a")
	return Color("ffd36a")


## Krallığın dini, müttefikleri ve savaşları (bilgi kartı için).
func _krallik_diplomasi(kr: Dictionary) -> String:
	var s := ""
	var din = sim.dinler.get(int(kr.get("din", -1)))
	s += "Din: %s\n" % (("[color=#%s]%s[/color]" % [din["renk"], din["ad"]]) if din != null else "yok")
	var mt := []
	for mid in kr.get("muttefik", {}):
		if sim.kralliklar.has(mid):
			mt.append("[color=#%s]%s[/color]" % [sim.kralliklar[mid]["renk"], sim.kralliklar[mid]["ad"]])
	if mt.size() > 0:
		s += "Müttefik: %s\n" % ", ".join(mt)
	var sv := []
	for did in kr["savas"]:
		if sim.kralliklar.has(did):
			sv.append(sim.kralliklar[did]["ad"])
	if sv.size() > 0:
		s += "[color=#ff8a6a]Savaşta: %s[/color]\n" % ", ".join(sv)
	return s


func _koy_goster(v: Dictionary) -> void:
	harita.secili = -1
	bilgi_panel.visible = true
	for c in bilgi_ozl.get_children():
		c.queue_free()
	var kr = sim.kralliklar.get(v["krallik"])
	var s := "[b]%s[/b]  [color=#9ab]%s%s[/color]\n" % [v["ad"], SimS.KADEME_AD[sim.kademe(v)], " · Başkent" if kr != null and kr["baskent"] == v["id"] else ""]
	if kr != null:
		s += "[color=#%s]%s[/color]\n" % [kr["renk"], kr["ad"]]
		s += _krallik_diplomasi(kr)
	s += "Irk: %s\nNüfus: %d / %d (tavan %d)\n" % [sim.turler[v["irk"]]["ad"], v["nufus"], v["kapasite"], int(v.get("tavan", 0))]
	s += "Çağ: %s\n" % SimS.CAG_AD[v["cag"]]
	s += "Yiyecek: %d  ·  Malzeme: %d\nAltın: %d  ·  Demir: %d\n" % [int(v["yemek"]), int(v["malzeme"]), int(v["altin"]), int(v["demir"])]
	s += "Bina: %d\n" % v["yapilar"].size()
	if v["aclik"]: s += "[color=#ff7a7a]Kıtlık var![/color]\n"
	if v["salgin"] > 0: s += "[color=#ff7a7a]Salgın var![/color]\n"
	if v["savasta"]: s += "[color=#ffb060]Savaşta[/color]\n"
	s += "Kuruluş: Yıl %d" % (v["kurulus"] / 12 + 1)
	bilgi_lbl.text = s


# ------------------------------------------------------------ özellik seçici
func _secici_ac(mod: String) -> void:
	secici_mod = mod
	if mod == "ekle" and (harita.secili < 0 or sim.t_irk[sim.c_tur[harita.secili]] == 0):
		if harita.secili >= 0 and sim.t_irk[sim.c_tur[harita.secili]] == 0:
			pass
		elif harita.secili < 0:
			_bildir("Önce bir canlı seç.")
			return
	secici.visible = true
	secici_bilgi.text = ""
	_secici_doldur()


func _secici_doldur() -> void:
	for c in secici_grid.get_children():
		c.queue_free()
	if secici_mod == "ekle":
		secici_baslik.text = "Özellik ver: %s" % sim.c_ad[harita.secili]
	else:
		secici_baslik.text = "Özellik fırçası: yeni konan canlılara verilir (%d/5)" % firca_ozl.size()
	var var_olan: PackedInt32Array = sim.ozellik_idleri(harita.secili) if secici_mod == "ekle" and harita.secili >= 0 else PackedInt32Array(firca_ozl)
	for o in sim.ozellikler:
		if o == null:
			continue
		if secici_kat == "Olumlu" and o["tur"] != "olumlu": continue
		if secici_kat == "Olumsuz" and o["tur"] != "olumsuz": continue
		if secici_kat not in ["Tümü", "Olumlu", "Olumsuz"] and o["kategori"] != secici_kat: continue
		var etk := []
		for k in o["etkiler"]:
			var deger: int = int(o["etkiler"][k])
			if absi(deger) >= 1000:
				etk.append("%s ∞" % ETKI_AD.get(k, k.replace("_", " ")))
			else:
				etk.append("%s %+d%%" % [ETKI_AD.get(k, k.replace("_", " ")), deger])
			if etk.size() >= 3:
				break
		var b := Button.new()
		b.text = "%s %s\n%s" % [o["ad"], "★".repeat(o["nadirlik"]), ", ".join(etk)]
		b.custom_minimum_size = Vector2(0, 72 if platform_mobil else 58)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.clip_text = true
		b.custom_minimum_size.x = 100
		b.add_theme_font_size_override("font_size", 17 if platform_mobil else 14)
		b.add_theme_color_override("font_color", _tur_renk(o["tur"]))
		b.focus_mode = Control.FOCUS_NONE
		b.toggle_mode = true
		b.button_pressed = var_olan.has(o["id"])
		b.pressed.connect(_ozellik_tik.bind(o["id"], b))
		secici_grid.add_child(b)


func _ozellik_tik(id: int, b: Button) -> void:
	var o: Dictionary = sim.ozellikler[id]
	if secici_mod == "ekle":
		var i: int = harita.secili
		if i < 0 or sim.c_var[i] == 0:
			secici.visible = false
			return
		if sim.ozl_var(i, id):
			sim.ozellik_sil(i, id)
			secici_bilgi.text = "%s silindi." % o["ad"]
		else:
			var hata: String = sim.ozellik_ekle(i, id)
			secici_bilgi.text = hata if hata != "" else "%s verildi." % o["ad"]
			b.button_pressed = hata == ""
		_bilgi_yaz()
	else:
		if firca_ozl.has(id):
			firca_ozl.erase(id)
		else:
			var engel := ""
			for f in firca_ozl:
				if (o["zit_id"] as PackedInt32Array).has(f):
					engel = sim.ozellikler[f]["ad"]
			if engel != "":
				secici_bilgi.text = "%s ile %s birlikte olamaz." % [o["ad"], engel]
				b.button_pressed = false
				return
			if firca_ozl.size() >= SimS.MAX_OZL:
				secici_bilgi.text = "En fazla 5 özellik."
				b.button_pressed = false
				return
			firca_ozl.append(id)
		secici_baslik.text = "Özellik fırçası: yeni konan canlılara verilir (%d/5)" % firca_ozl.size()
		secici_bilgi.text = "Seçili: " + ", ".join(firca_ozl.map(func(x): return sim.ozellikler[x]["ad"]))
		_firca_yazi()


# ------------------------------------------------------------ kronik / istatistik
func _buyuk_ac(tur: String) -> void:
	buyuk_tur = tur
	buyuk_panel.visible = true
	menu_panel.visible = false
	_buyuk_yaz()


func _buyuk_yaz() -> void:
	var s := ""
	if buyuk_tur == "kronik":
		buyuk_baslik.text = "Dünya Kroniği"
		var n := 0
		for m in range(sim.kronik.size() - 1, -1, -1):
			var k: Array = sim.kronik[m]
			var renk := "#c8d0d8"
			if k[2] >= 3: renk = "#ffd23a"
			elif k[2] == 2: renk = "#ffffff"
			s += "[color=#89a]Yıl %d:[/color] [color=%s]%s[/color]\n" % [k[0] / 12 + 1, renk, k[1]]
			n += 1
			if n >= 300:
				break
	else:
		buyuk_baslik.text = "Dünya İstatistikleri — " + sim.tarih_yazi()
		s += "[b]Canlılar[/b]\n"
		var d: Dictionary = sim.irk_sayilari()
		for ad in d:
			s += "  %s: %d\n" % [ad, d[ad]]
		s += "\n[b]Krallıklar[/b]\n"
		for id in sim.kralliklar:
			var kr: Dictionary = sim.kralliklar[id]
			var koyler: Array = sim.krallik_koyleri(id)
			var nuf := 0
			var cag := 0
			var altin := 0.0
			for v in koyler:
				nuf += v["nufus"]
				cag = maxi(cag, v["cag"])
				altin += v["altin"]
			var savas := []
			for did in kr["savas"]:
				if sim.kralliklar.has(did):
					savas.append(sim.kralliklar[did]["ad"])
			s += "  [color=#%s]■ %s[/color] (%s) — %d köy, %d nüfus, %s, altın %d\n" % [kr["renk"], kr["ad"], sim.turler[kr["irk"]]["ad"], koyler.size(), nuf, SimS.CAG_AD[cag], int(altin)]
			var din = sim.dinler.get(int(kr.get("din", -1)))
			s += "      Hükümdar: %s  ·  Din: %s%s\n" % [kr["kral_ad"] if kr["kral_uid"] != 0 else "yok", din["ad"] if din != null else "yok", ("  ·  [color=#ff8a6a]Savaşta: " + ", ".join(savas) + "[/color]") if savas.size() > 0 else ""]
		s += "\n[b]Dinler[/b]\n"
		var dn: Dictionary = sim.din_nufuslari()
		if dn.is_empty():
			s += "  Henüz din yok (tapınaklı köyler din kurar).\n"
		for did in dn:
			var din: Dictionary = sim.dinler[did]
			s += "  [color=#%s]✦ %s[/color] — %d inanan (kuran: %s, Yıl %d)\n" % [din["renk"], din["ad"], dn[did], din["kurucu"], int(din["kurulus"]) / 12 + 1]
		s += "\n[b]İttifaklar[/b]\n"
		var yazildi := {}
		for id in sim.kralliklar:
			for mid in sim.kralliklar[id].get("muttefik", {}):
				var anahtar := "%d-%d" % [mini(id, mid), maxi(id, mid)]
				if yazildi.has(anahtar) or not sim.kralliklar.has(mid):
					continue
				yazildi[anahtar] = true
				s += "  %s ⇄ %s\n" % [sim.kralliklar[id]["ad"], sim.kralliklar[mid]["ad"]]
		if yazildi.is_empty():
			s += "  Yok.\n"
		s += "\n[b]Ölüm nedenleri[/b]\n"
		for k in sim.olumler:
			s += "  %s: %d\n" % [k, sim.olumler[k]]
		s += "\n[b]Irklara göre ölümler[/b] (bu oturum)\n"
		for tur in sim.irk_olum:
			if sim.t_irk[tur] == 1:
				var l := []
				var d2: Dictionary = sim.irk_olum[tur]
				for k in d2:
					l.append("%s %d" % [k, d2[k]])
				s += "  %s: %s\n" % [sim.turler[tur]["ad"], ", ".join(l)]
		s += "\nToplam doğum: %d\n" % sim.dogum_sayisi
	buyuk_lbl.text = s


# ------------------------------------------------------------ menü
func _menu_ac() -> void:
	for c in menu_panel.get_children():
		c.queue_free()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	menu_panel.add_child(v)
	var bas := Label.new()
	bas.text = "Dünya Kutusu"
	bas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bas.add_theme_font_size_override("font_size", 30)
	v.add_child(bas)
	var yh := HBoxContainer.new()
	v.add_child(yh)
	var yl := Label.new()
	yl.text = "Kayıt yuvası:"
	yh.add_child(yl)
	for n in [1, 2, 3]:
		var b := _dugme(str(n), func():
			kayit_yuva = n
			_menu_ac(), yh, true)
		b.button_pressed = kayit_yuva == n
		b.custom_minimum_size.x = 60
	var kh := HBoxContainer.new()
	v.add_child(kh)
	var kb := _dugme("Kaydet", func(): _kaydet(kayit_yuva), kh)
	kb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var lb := _dugme("Yükle", func():
		if _yukle(kayit_yuva):
			menu_panel.visible = false
		else:
			_bildir("Bu yuvada kayıt yok."), kh)
	lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var yeni := Label.new()
	yeni.text = "Yeni dünya (boyuta dokun):"
	v.add_child(yeni)
	var bsh := HBoxContainer.new()
	v.add_child(bsh)
	var bsl := Label.new()
	bsl.text = "Başlangıç:"
	bsh.add_child(bsl)
	for secenek in [[false, "Rastgele canlılar"], [true, "Boş dünya"]]:
		var bb := _dugme(secenek[1], func():
			baslangic_bos = secenek[0]
			_menu_ac(), bsh, true)
		bb.button_pressed = baslangic_bos == secenek[0]
		bb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bh := HBoxContainer.new()
	v.add_child(bh)
	for n in BOYUTLAR.size():
		if n == 3 and platform_mobil:
			continue
		var b := _dugme("%s\n%dx%d" % [BOYUTLAR[n][2], BOYUTLAR[n][0], BOYUTLAR[n][1]], func():
			yeni_dunya(n, randi(), baslangic_bos)
			if baslangic_bos:
				_sekme_sec("Canlılar")
				_bildir("Boş dünya: Canlılar sekmesinden ırk seçip haritaya dokun.")
			menu_panel.visible = false, bh)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var ns := _dugme("Nüfus sınırı: " + _sinir_yazi(sim.nufus_siniri), func():
		var l: Array = SimS.NUFUS_SECENEK
		sim.nufus_siniri = l[(l.find(sim.nufus_siniri) + 1) % l.size()]
		_menu_ac(), v)
	ns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var af := _dugme("Doğal afetler: " + ("AÇIK" if sim.dogal_afet else "KAPALI"), func():
		sim.dogal_afet = not sim.dogal_afet
		_menu_ac(), v)
	af.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var yard := Label.new()
	yard.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	yard.custom_minimum_size = Vector2(520, 0)
	yard.add_theme_font_size_override("font_size", 15)
	yard.modulate = Color(0.75, 0.8, 0.85)
	yard.text = "Kaydırma: tek parmak (İncele aracında) ya da iki parmak. Yakınlaştırma: iki parmak / fare tekerleği. PC: WASD ile gez, Boşluk duraklat, 1-5 hız, F5 kaydet, F9 yükle, sağ tık ile sürükle. Dünya her dakika kendiliğinden kaydedilir."
	v.add_child(yard)
	_dugme("Kapat", func(): menu_panel.visible = false, v)
	menu_panel.visible = true
	buyuk_panel.visible = false


func _sinir_yazi(n: int) -> String:
	return "Sınırsız" if n <= 0 else str(n)


func _kaydet(yuva: int) -> void:
	if sim.kaydet("user://dunya_%d.kayit" % yuva):
		_bildir("Kaydedildi (yuva %d)." % yuva)
	else:
		_bildir("Kayıt başarısız!")


func _yukle(yuva: int) -> bool:
	if not sim.yukle("user://dunya_%d.kayit" % yuva):
		return false
	harita.baglan(sim)
	harita.secili = -1
	_kamera_sigdir()
	if yuva > 0:
		_bildir("Yüklendi (yuva %d): %s" % [yuva, sim.tarih_yazi()])
	return true


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		if sim != null and sim.gen > 0 and not onizleme_modu:
			sim.kaydet("user://dunya_0.kayit")


var _oto_sayac := 0.0
func _physics_process(delta: float) -> void:
	_oto_sayac += delta
	if _oto_sayac > 60.0 and not onizleme_modu:
		_oto_sayac = 0.0
		sim.kaydet("user://dunya_0.kayit")


# ------------------------------------------------------------ köy adları
func _etiketleri_ciz() -> void:
	if sim == null or sim.gen == 0:
		return
	var tr: Transform2D = harita.get_canvas_transform()
	var olcek: float = tr.get_scale().x
	if olcek < 0.6:
		return
	var font := ThemeDB.fallback_font
	var boy := 16 if olcek < 3.0 else 20
	# önce başkentler ve büyük şehirler yazılır; üst üste binen küçük adlar atlanır
	var sirali: Array = sim.koyler.values()
	sirali.sort_custom(func(p: Dictionary, q: Dictionary) -> bool: return _etiket_onem(p) > _etiket_onem(q))
	var dolu: Array[Rect2] = []
	for v in sirali:
		var id: int = v["id"]
		var kd: int = sim.kademe(v)
		if v["nufus"] < 3 and olcek < 2.5:
			continue
		# uzaktan yalnızca şehirler ve başkentler yazılır (kalabalık olmasın)
		var kr = sim.kralliklar.get(v["krallik"])
		var baskent: bool = kr != null and kr["baskent"] == id
		if olcek < 1.6 and kd < 2 and not baskent:
			continue
		var p: Vector2 = tr * (Vector2(v["x"] + 0.5, v["y"] - 1.5) * KARO)
		var renk := Color(kr["renk"]) if kr != null else Color.WHITE
		var b2: int = boy + (4 if kd >= 2 else 0) + (2 if baskent else 0)
		var yazi := "%s%s (%d)" % ["♛ " if baskent else "", v["ad"], v["nufus"]]
		var gen := font.get_string_size(yazi, HORIZONTAL_ALIGNMENT_LEFT, -1, b2).x
		var kutu := Rect2(p.x - gen * 0.5, p.y - b2, gen, b2 + 2)
		var cakisma := false
		for r in dolu:
			if r.intersects(kutu):
				cakisma = true
				break
		if cakisma:
			continue
		dolu.append(kutu)
		etiket_katmani.draw_string_outline(font, p - Vector2(gen * 0.5, 0), yazi, HORIZONTAL_ALIGNMENT_LEFT, -1, b2, 4, Color(0, 0, 0, 0.8))
		etiket_katmani.draw_string(font, p - Vector2(gen * 0.5, 0), yazi, HORIZONTAL_ALIGNMENT_LEFT, -1, b2, renk.lightened(0.6))


func _etiket_onem(v: Dictionary) -> int:
	var kr = sim.kralliklar.get(v["krallik"])
	var b := 100000 if kr != null and kr["baskent"] == v["id"] else 0
	return b + sim.kademe(v) * 10000 + int(v["nufus"])


# ------------------------------------------------------------ önizleme (CI ekran görüntüsü)
func _onizleme() -> void:
	var klasor := "user://onizleme"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("klasor="):
			klasor = a.substr(7)
	DirAccess.make_dir_recursive_absolute(klasor)
	yeni_dunya(1, 12345)
	print("ONIZLEME basladi")
	await _kare(klasor + "/01_baslangic.png")
	sim.hareket_adim = 12
	var t0 := Time.get_ticks_msec()
	for n in 150 * 12:
		sim.tick()
	print("ONIZLEME 150 yil: %d ms, nufus=%d koy=%d krallik=%d" % [Time.get_ticks_msec() - t0, sim.irk_nufus, sim.koyler.size(), sim.kralliklar.size()])
	sim.hareket_adim = 1
	hiz_ayarla(1)
	await _kare(klasor + "/02_150_yil.png")
	# kare hızı ölçümü (tüm harita, sonra yakın görünüm)
	await _fps_olc("uzak")
	harita.krallik_harita = true
	_sekme_sec("Gözlem")
	await _kare(klasor + "/02b_krallik_haritasi.png")
	harita.krallik_harita = false
	_sekme_sec("Gözlem")
	var en = null
	for id in sim.koyler:
		if en == null or sim.koyler[id]["nufus"] > en["nufus"]:
			en = sim.koyler[id]
	if en != null:
		kamera.position = Vector2(en["x"], en["y"]) * KARO
		kamera.zoom = Vector2(5, 5)
		await _kare(klasor + "/03_koy_yakin.png")
		await _fps_olc("yakin")
		for i in sim.ust:
			if sim.c_var[i] == 1 and sim.c_koy[i] == en["id"]:
				harita.secili = i
				_bilgi_ac()
				break
		await _kare(klasor + "/04_canli_karti.png")
		_secici_ac("ekle")
		await _kare(klasor + "/05_ozellikler.png")
		secici.visible = false
		_bilgi_kapat()
		# canlı sil aracı: fırça 4 ile köyün ortasında bir delik aç
		_sekme_sec("Güçler")
		arac_sec("guc", "sil")
		firca = 4
		_sekme_sec("Güçler")
		var ekran_orta := get_viewport().get_visible_rect().size * 0.5
		_imlec_guncelle(ekran_orta)
		_arac_uygula(ekran_orta, true)
		await _kare(klasor + "/06_canli_sil.png")
		harita.imlec = Vector2(-1, -1)
		arac_sec("incele", null)
		sim.afet("volkan", en["x"] + 8, en["y"] + 4)
		sim.afet("yildirim", en["x"] - 3, en["y"])
		sim.afet("hortum", en["x"], en["y"] + 6)
		for n in 3:
			sim.tick()
		_sekme_sec("Afetler")
		await _kare(klasor + "/07_afetler.png")
		_koy_goster(en)
		await _kare(klasor + "/08_sehir_bilgisi.png")
		_bilgi_kapat()
	_buyuk_ac("kronik")
	await _kare(klasor + "/09_kronik.png")
	_buyuk_ac("istatistik")
	await _kare(klasor + "/10_istatistik.png")
	buyuk_panel.visible = false
	_menu_ac()
	await _kare(klasor + "/11_menu.png")
	menu_panel.visible = false
	# boş dünya: oyuncu kendisi canlı koyar
	yeni_dunya(0, 4242, true)
	_sekme_sec("Canlılar")
	arac_sec("canli", sim.tur_id["elf"])
	var konan := 0
	for n in 400:
		var x := randi_range(10, sim.gen - 10)
		var y := randi_range(10, sim.yuk - 10)
		if sim.canli_koy(sim.tur_id["insan"] if n % 2 == 0 else sim.tur_id["elf"], x + 0.5, y + 0.5, []) >= 0:
			konan += 1
		if konan >= 12:
			break
	await _kare(klasor + "/12_bos_dunya.png")
	var ilk := -1
	for i in sim.ust:
		if sim.c_var[i] == 1:
			ilk = i
			break
	if ilk >= 0:
		for n in 6:
			sim.canli_koy(sim.c_tur[ilk], sim.c_x[ilk] + randf_range(-2, 2), sim.c_y[ilk] + randf_range(-2, 2), [])
		kamera.position = Vector2(sim.c_x[ilk], sim.c_y[ilk]) * KARO
		kamera.zoom = Vector2(9, 9)
		await _kare(klasor + "/13_bos_dunya_yakin.png")
	print("ONIZLEME bitti")
	get_tree().quit()


## Önizleme sırasında kare hızını ölçer (CI'da yazılım çizimi; yalnızca göreli karşılaştırma için).
func _fps_olc(ad: String) -> void:
	var t0 := Time.get_ticks_usec()
	for n in 60:
		await get_tree().process_frame
	var ms := (Time.get_ticks_usec() - t0) / 60000.0
	print("ONIZLEME FPS %s: %.1f ms/kare (%.0f FPS), canli=%d" % [ad, ms, 1000.0 / maxf(0.1, ms), sim.ust - sim.bos.size()])


func _kare(yol: String) -> void:
	for n in 4:
		await get_tree().process_frame
	var img := get_viewport().get_texture().get_image()
	img.save_png(yol)
	print("kare: ", yol)
