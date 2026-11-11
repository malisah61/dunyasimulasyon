extends Node
## Oyunun ana sahnesi: dünya, kamera, arayüz, tanrı araçları, kaydet/yükle.

const SimS = preload("res://betikler/sim.gd")
const HaritaS = preload("res://betikler/harita.gd")
const SesS = preload("res://betikler/ses.gd")
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
	["Salgın", "salgin"], ["Çekirge", "cekirge"], ["Kuraklık", "kuraklik"], ["Kara kış", "karakis"], ["Sel", "sel"], ["UFO", "ufo"],
]
const GUCLER := [["Canlı sil", "sil"], ["Bereket", "bereket"], ["Gazap", "olum"], ["Savaş çıkar", "savas"], ["Barış yaptır", "baris"], ["İttifak kur", "ittifak"], ["İsyan çıkar", "isyan"], ["Darbe yaptır", "darbe"]]
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
	"sel": "Kıyıya ya da göl kenarına dokun: sular taşar, tarlalar boğulur; çekilince toprak bereketlenir.",
	"isyan": "Bir krallığın başkent olmayan köyüne dokun: halk ayaklanır, yeni krallık kurulur ve iç savaş başlar.",
	"darbe": "Bir krallığın köyüne dokun: sarayda darbe olur, hükümdar devrilir ve yerine başkası geçer.",
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
var bilgi_git: HFlowContainer      # bilgi kartında "git" düğmeleri (anne, baba, hükümdar, başkent)
var bilgi_git_anahtar := ""
var takip_btn: Button
var ses                            # ses üreteci (önizleme/ölçümde yok)
var ses_acik := true
var muzik_acik := true             # çağa göre kodla üretilen müzik
var toprak_ozet := true            # uzaktan krallık sınırları görünsün mü (ayar)
var alt_panel: PanelContainer      # alt araç çubuğu (büyük paneller bunun üstünde biter)
var olay_btn: Button               # önemli olay bildirimi: dokununca olay yerine gider
var olay_yer := Vector2i(-1, -1)
var olay_sure := 0.0
var son_kronik := 0
var grafik: Control                # istatistik: nüfus / altın / teknoloji / toprak grafiği
var graf_mod := 0                  # 0 nüfus (ırklar), 1 hazine, 2 teknoloji, 3 köy sayısı (krallıklar)
var kronik_mod := 0                # 0 son olaylar, 1 tarih kitabı (tüm önemli olaylar)
var mod_satir: HBoxContainer       # büyük panelde sekme düğmeleri (grafik türü / kronik görünümü)
var son_sim_ms := 0.0              # önceki karede simülasyona giden süre (kare bütçesi için)
var hiz_ay := 0                    # son saniyede işlenen ay sayısı
var hiz_sure := 0.0
var gercek_hiz := 0.0              # ulaşılan gerçek hız (ay/sn)
var etiket_liste: Array = []       # köy adları önbelleği
var etiket_zaman := 0
var etiket_dunya := -1
var olc_tick_us := 0               # ölçüm: karelerde simülasyona harcanan süre (µs, birikimli)


func _ready() -> void:
	platform_mobil = OS.has_feature("mobile")
	_simge_yazi_tipi()
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
	if OS.get_cmdline_user_args().has("olcum"):
		onizleme_modu = true
		_olcum.call_deferred()
		return
	_ayar_oku()
	ses = SesS.new()
	ses.acik = ses_acik
	ses.muzik_acik = muzik_acik
	add_child(ses)
	harita.toprak_ozet = toprak_ozet
	if not _yukle(0):
		yeni_dunya(1, randi())


## Kalıcı ayarlar (ses, krallık sınırları): user://ayar.cfg
func _ayar_oku() -> void:
	var c := ConfigFile.new()
	if c.load("user://ayar.cfg") == OK:
		ses_acik = bool(c.get_value("ayar", "ses", true))
		muzik_acik = bool(c.get_value("ayar", "muzik", true))
		toprak_ozet = bool(c.get_value("ayar", "sinirlar", true))


func _ayar_yaz() -> void:
	var c := ConfigFile.new()
	c.set_value("ayar", "ses", ses_acik)
	c.set_value("ayar", "muzik", muzik_acik)
	c.set_value("ayar", "sinirlar", toprak_ozet)
	c.save("user://ayar.cfg")


func _ses(ad: String, db := -8.0, aralik := 250) -> void:
	if ses != null:
		ses.cal(ad, db, aralik)


func yeni_dunya(boyut: int, tohum: int, bos := false) -> void:
	var b: Array = BOYUTLAR[boyut]
	var sinir: int = sim.nufus_siniri
	sim.dunya_uret(b[0], b[1], tohum)
	sim.nufus_siniri = sinir
	if not bos:
		sim.baslangic_canlilari()
	harita.baglan(sim)
	harita.secili = -1
	son_kronik = sim.kronik.size()
	# eski dünyanın olay bildirimi yeni dünyada kalmasın
	if olay_btn != null:
		olay_btn.visible = false
		olay_sure = 0.0
		olay_yer = Vector2i(-1, -1)
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
	# toplu hareket: hız arttıkça canlılar daha seyrek ama daha uzun adım atar (aynı yol, daha az iş)
	sim.hareket_adim = 1 if hiz <= 5 else (2 if hiz <= 20 else (6 if hiz <= 100 else 12))
	harita.ara_deger = hiz <= 5
	# 1x–5x: hareket ayın içine yayılır (her karede canlıların sekizde biri yürür; tick anında takılma olmaz)
	if hiz > 0:
		sim.yayik = hiz <= 5
	if hiz > 0:
		birikim += delta * hiz
		var bas_us := Time.get_ticks_usec()
		# kare bütçesi: karenin simülasyon dışındaki süresi (çizim, arayüz) ölçülür; simülasyona kalan süre verilir.
		# Düşük hızda hedef akıcılık (60 FPS), yüksek hızda hedef hız (en az ~30 FPS).
		var diger_ms := clampf(delta * 1000.0 - son_sim_ms, 2.0, 30.0)
		var butce_us := int(clampf((17.0 if hiz <= 20 else 31.0) - diger_ms, 5.0 if hiz <= 20 else 10.0, 12.0 if platform_mobil and hiz <= 20 else 22.0) * 1000.0)
		var yapilan := 0
		while birikim >= 1.0:
			sim.tick()
			birikim -= 1.0
			yapilan += 1
			if Time.get_ticks_usec() - bas_us > butce_us:
				# yetişemiyoruz: birikmiş ayları at (oyun donmaz, gerçek hız üst çubukta görünür)
				birikim = minf(birikim, 1.0)
				break
		var gecen_us := Time.get_ticks_usec() - bas_us
		olc_tick_us += gecen_us
		son_sim_ms = gecen_us / 1000.0
		hiz_ay += yapilan
		harita.alfa = clampf(birikim, 0.0, 1.0)
		if sim.yayik:
			var d_us := Time.get_ticks_usec()
			sim.dilim_ilerlet(int(clampf(birikim, 0.0, 1.0) * SimS.DILIM) + 1)
			olc_tick_us += Time.get_ticks_usec() - d_us
	else:
		son_sim_ms = 0.0
	hiz_sure += delta
	if hiz_sure >= 1.0:
		gercek_hiz = hiz_ay / hiz_sure
		hiz_ay = 0
		hiz_sure = 0.0
	harita.guncelle()
	if ses != null and Engine.get_process_frames() % 60 == 0:
		ses.cag_ayarla(sim.muzik_cag)
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
	_olaylari_izle(delta)
	if takip_btn != null and takip_btn.button_pressed != takip:
		takip_btn.button_pressed = takip
	if boyuyor and dokunmalar.size() == 1 and _surekli_arac():
		son_boya += delta
		if son_boya > 0.06:
			son_boya = 0.0
			var p: Vector2 = dokunmalar.values()[0]
			_arac_uygula(p, true)


## Kroniğe yeni düşen önemli olayları (savaş, isyan, din, krallık yıkılışı...) ekranda gösterir.
func _olaylari_izle(delta: float) -> void:
	if son_kronik > sim.kronik.size():
		son_kronik = sim.kronik.size()
	while son_kronik < sim.kronik.size():
		var k: Array = sim.kronik[son_kronik]
		son_kronik += 1
		if int(k[2]) >= 3:
			var metin: String = k[1]
			if metin.length() > 72:
				metin = metin.substr(0, 70) + "…"
			olay_btn.text = "⚑ Yıl %d: %s%s" % [int(k[0]) / 12 + 1, metin, "   → Git" if k.size() >= 5 else ""]
			olay_yer = Vector2i(int(k[3]), int(k[4])) if k.size() >= 5 else Vector2i(-1, -1)
			olay_btn.visible = true
			olay_btn.reset_size()
			olay_sure = 7.0
			# olayın sesi (hızlı oyunda seyrek)
			var ara := 1500 if HIZLAR[hiz_no] <= 20 else 5000
			if metin.begins_with("SAVAŞ"):
				_ses("boru", -6.0, ara)
			elif metin.begins_with("İSYAN") or metin.begins_with("DARBE") or metin.begins_with("İÇ SAVAŞ"):
				_ses("davul", -6.0, ara)
			else:
				_ses("can", -10.0, ara)
		elif int(k[2]) == 2 and HIZLAR[hiz_no] <= 20:
			var m2: String = k[1]
			if m2.contains("volkan") or m2.contains("Deprem") or m2.contains("deprem") or m2.contains("meteor") or m2.contains("Meteor"):
				_ses("sarsinti", -8.0, 3000)
			elif m2.contains("tsunami") or m2.contains("Tsunami") or m2.contains("SEL") or m2.contains("sel bas"):
				_ses("su", -9.0, 3000)
	if olay_sure > 0.0:
		olay_sure -= delta
		olay_btn.modulate.a = clampf(olay_sure, 0.0, 1.0)
		olay_btn.visible = not buyuk_panel.visible and not menu_panel.visible and not secici.visible
		if olay_sure <= 0.0:
			olay_btn.visible = false


## Kamerayı bir karoya götürür.
func _git(x: int, y: int) -> void:
	takip = false
	kamera.position = Vector2(x + 0.5, y + 0.5) * KARO
	if kamera.zoom.x < 3.0:
		kamera.zoom = Vector2(4, 4)
	_kamera_sinirla()


func _kronik_tik(meta) -> void:
	var p := str(meta).split(",")
	if p.size() == 2:
		buyuk_panel.visible = false
		_git(int(p[0]), int(p[1]))


func _canliya_git(i: int) -> void:
	if i < 0 or sim.c_var[i] == 0:
		_bildir("Bu canlı artık yaşamıyor.")
		return
	harita.secili = i
	kamera.position = Vector2(sim.c_x[i], sim.c_y[i]) * KARO
	_bilgi_ac()


const MEVSIM_RENK := [Color("cfe6ff"), Color("b8f0a0"), Color("ffe08a"), Color("ffb070")]


func _ust_bar() -> void:
	tarih_lbl.text = sim.tarih_yazi()
	# sayım ve çağ taraması her karede değil, saniyede birkaç kez yapılır
	if Engine.get_process_frames() % 12 != 0 and nufus_lbl.text != "":
		return
	var cag := ""
	var en_cag := -1
	for id in sim.koyler:
		en_cag = maxi(en_cag, sim.koyler[id]["cag"])
	if en_cag >= 0:
		cag = "  ·  En ileri: " + SimS.CAG_AD[en_cag]
	var savas: int = sim.savas_sayisi()
	var sv := ("  ·  ⚔ %d savaş" % savas) if savas > 0 else ""
	# istenen hıza yetişilemiyorsa oyuncu bunu görsün
	var hiz: int = HIZLAR[hiz_no]
	var hz := ""
	if hiz >= 20 and gercek_hiz > 0.0 and gercek_hiz < hiz * 0.85:
		hz = "  ·  hız ~%dx" % int(gercek_hiz)
	nufus_lbl.text = "Nüfus %d  ·  Köy %d  ·  Krallık %d%s%s%s" % [sim.irk_nufus, sim.koyler.size(), sim.kralliklar.size(), sv, cag, hz]
	tarih_lbl.add_theme_color_override("font_color", MEVSIM_RENK[SimS.MEVSIM[sim.ay % 12]])


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
			if i >= 0:
				_ses("pit", -12.0, 70)
			if i < 0 and not surukleme:
				_bildir("Buraya konamaz (su ya da lav).")
		"afet":
			if surukleme and arac_veri == "yildirim" and randf() < 0.6:
				return
			if surukleme and arac_veri == "yagmur" and randf() < 0.7:
				return
			sim.afet(arac_veri, x, y, true)
			match str(arac_veri):
				"yildirim": _ses("gok", -7.0, 500)
				"deprem", "volkan", "meteor": _ses("sarsinti", -5.0, 600)
				"tsunami", "sel", "yagmur": _ses("su", -8.0, 900)
				"hortum", "karakis", "kuraklik": _ses("gok", -12.0, 900)
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
		"isyan":
			if v == null:
				_bildir("Bir köye dokun.")
			elif not sim.isyan(v, true):
				_bildir("Bu köy ayaklanamaz (başkent ya da krallığın tek köyü).")
			else:
				_bildir("%s ayaklandı! İç savaş başladı." % v["ad"])
		"darbe":
			var dkr = sim.kralliklar.get(v["krallik"]) if v != null else null
			if dkr == null:
				_bildir("Bir krallığın köyüne dokun.")
			else:
				var yeni_kral: String = sim.darbe_yaptir(dkr)
				if yeni_kral == "":
					_bildir("Başkentte tahta geçecek kimse yok.")
				else:
					_bildir("%s tahtında artık %s oturuyor." % [dkr["ad"], yeni_kral])
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
## Simge yazı tipi (DejaVu Sans alt kümesi, özgür lisans): ♛ ⚔ → ■ ★ gibi işaretler tarayıcıda da görünsün.
## Tarayıcı sürümünde sistem yazı tipine düşülemediği için bu işaretler kutu olarak çıkıyordu.
func _simge_yazi_tipi() -> void:
	var veri := FileAccess.get_file_as_bytes("res://veri/yazi/simgeler.yazi")
	if veri.is_empty():
		return
	var sf := FontFile.new()
	sf.data = veri
	var ana: Font = ThemeDB.fallback_font
	var liste: Array[Font] = ana.fallbacks
	liste.append(sf)
	ana.fallbacks = liste
	if OS.get_cmdline_user_args().has("sistemsiz") and ana is FontFile:
		(ana as FontFile).allow_system_fallback = false   # sınama: tarayıcıdaki gibi sistem yazı tipi olmadan


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
	b.pressed.connect(_ses.bind("tik", -14.0, 40))
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
	alt_panel = alt
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
	bilgi_git = HFlowContainer.new()
	bv.add_child(bilgi_git)
	var bh := HBoxContainer.new()
	bv.add_child(bh)
	_dugme("+ Özellik", _secici_ac.bind("ekle"), bh)
	takip_btn = _dugme("Takip", func(): takip = not takip, bh, true)
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
	mod_satir = HBoxContainer.new()
	mod_satir.add_theme_constant_override("separation", 6)
	yv.add_child(mod_satir)
	grafik = Control.new()
	grafik.custom_minimum_size = Vector2(0, 200 if platform_mobil else 170)
	grafik.draw.connect(_grafik_ciz)
	grafik.visible = false
	yv.add_child(grafik)
	buyuk_lbl = RichTextLabel.new()
	buyuk_lbl.meta_clicked.connect(_kronik_tik)
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
	# ---- önemli olay bildirimi (dokun: oraya git)
	olay_btn = Button.new()
	olay_btn.set_anchors_preset(Control.PRESET_TOP_LEFT)
	olay_btn.offset_left = 8
	olay_btn.offset_top = 92 if platform_mobil else 80
	olay_btn.focus_mode = Control.FOCUS_NONE
	olay_btn.add_theme_font_size_override("font_size", 18 if platform_mobil else 15)
	olay_btn.add_theme_color_override("font_color", Color("ffd23a"))
	olay_btn.visible = false
	olay_btn.pressed.connect(func():
		if olay_yer.x >= 0:
			_git(olay_yer.x, olay_yer.y)
		olay_btn.visible = false)
	kok.add_child(olay_btn)


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
			_dugme("⚔ Savaşlar", _buyuk_ac.bind("savaslar"), arac_kutu)
			var kb := _dugme("Krallık haritası", func():
				harita.krallik_harita = not harita.krallik_harita
				if harita.krallik_harita:
					harita.irk_harita = false
				_sekme_sec("Gözlem"), arac_kutu, true)
			kb.button_pressed = harita.krallik_harita
			var ib := _dugme("Irk haritası", func():
				harita.irk_harita = not harita.irk_harita
				if harita.irk_harita:
					harita.krallik_harita = false
					_bildir("Her bölge orada yaşayan ırkın rengiyle boyanır")
				_sekme_sec("Gözlem"), arac_kutu, true)
			ib.button_pressed = harita.irk_harita
			var hb := _dugme("Huzur haritası", func():
				harita.huzur_harita = not harita.huzur_harita
				if harita.huzur_harita:
					_bildir("Yeşil: huzurlu · Sarı: tedirgin · Kırmızı: isyana hazır"), arac_kutu, true)
			hb.button_pressed = harita.huzur_harita
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
	bilgi_git_anahtar = ""
	for c in bilgi_git.get_children():
		c.queue_free()
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
			if sim.c_bit[i] & 8:
				s += "[color=#ffd23a]★ General[/color] — ordunun komutanı (komuta ×%.2f)\n" % float(kr.get("komuta", 1.0))
			var din = sim.dinler.get(int(kr.get("din", -1)))
			if din != null:
				s += "Din: [color=#%s]%s[/color]\n" % [din["renk"], din["ad"]]
		s += "Silah: %s · Zırh: %s (%%%d)\n" % [SimS.SILAH_AD[v["cag"]], SimS.ZIRH_AD[v["cag"]], int(sim.kv_zirh[v["id"]] * 100.0) if v["id"] < sim.kv_zirh.size() else 0]
	elif t["irk"]:
		s += "Köyü yok (gezgin)\n"
	var durum := ["Geziyor", "Asker", "Göç ediyor", "Kaçıyor"]
	if sim.c_durum[i] == SimS.D_ASKER:
		s += "Durum: Asker — [color=#ffb060]%s[/color]\n" % SimS.BIRIM_AD[sim.birim(i)]
	else:
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
	# aile ve hükümdar düğmeleri (soy ağacında gezinme)
	var hukumdar := -1
	var kr0 = sim.kralliklar.get(sim.koyler[sim.c_koy[i]]["krallik"]) if sim.koyler.has(sim.c_koy[i]) else null
	if kr0 != null and kr0["kral_uid"] != sim.c_uid[i]:
		hukumdar = sim.uid_bul(kr0["kral_uid"])
	var anahtar := "%d-%d-%d-%d" % [i, anne, baba, hukumdar]
	if anahtar != bilgi_git_anahtar:
		bilgi_git_anahtar = anahtar
		for c in bilgi_git.get_children():
			c.queue_free()
		if anne >= 0:
			_dugme("↑ Anne: " + sim.c_ad[anne], _canliya_git.bind(anne), bilgi_git)
		if baba >= 0:
			_dugme("↑ Baba: " + sim.c_ad[baba], _canliya_git.bind(baba), bilgi_git)
		if hukumdar >= 0:
			_dugme("♛ Hükümdar", _canliya_git.bind(hukumdar), bilgi_git)
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
	s += "Ordu: %s · %s (%%%d)\n" % [SimS.SILAH_AD[v["cag"]], SimS.ZIRH_AD[v["cag"]], int(sim.kv_zirh[v["id"]] * 100.0) if v["id"] < sim.kv_zirh.size() else 0]
	s += "Yiyecek: %d  ·  Malzeme: %d\nAltın: %d  ·  Demir: %d\n" % [int(v["yemek"]), int(v["malzeme"]), int(v["altin"]), int(v["demir"])]
	s += "Bina: %d%s\n" % [v["yapilar"].size(), ("  ·  Kale: %d" % v["b"][SimS.Y_KALE]) if v["b"][SimS.Y_KALE] > 0 else ""]
	var hz: float = float(v.get("huzur", 70.0))
	var hz_renk := "7be07b" if hz >= 55.0 else ("ffd36a" if hz >= 30.0 else "ff6a5a")
	s += "Huzur: [color=#%s]%d / 100%s[/color]\n" % [hz_renk, int(hz), "  (isyan tehlikesi!)" if hz < 20.0 else ""]
	if kr != null:
		s += "Vergi: %s  ·  Hazine: %d altın\n" % [SimS.VERGI_AD[int(kr.get("vergi", 1))], int(kr.get("hazine", 0.0))]
		for kid in kr.get("harac", {}):
			if sim.kralliklar.has(kid):
				s += "[color=#ffb060]%s haraç: yılda %d altın (%d yıl kaldı)[/color]\n" % [SimS.yonelme(sim.kralliklar[kid]["ad"]), int(kr["harac"][kid][0]), maxi(0, (int(kr["harac"][kid][1]) - sim.ay) / 12)]
		var ortak := []
		for kid in kr.get("ortak", {}):
			if sim.kralliklar.has(kid):
				ortak.append(sim.kralliklar[kid]["ad"])
		if ortak.size() > 0:
			s += "Ticaret ortakları: %s\n" % ", ".join(ortak.slice(0, 3))
	if int(v.get("aluvyon", 0)) > 0: s += "[color=#7be07b]Alüvyonlu toprak: verim +%%25 (%d yıl)[/color]\n" % int(v["aluvyon"])
	if v["aclik"]: s += "[color=#ff7a7a]Kıtlık var![/color]\n"
	if v["salgin"] > 0: s += "[color=#ff7a7a]Salgın var![/color]\n"
	if v["savasta"]: s += "[color=#ffb060]Savaşta[/color]\n"
	if int(v.get("ofke", -1)) > sim.ay: s += "[color=#ff9a6a]Tanrıların öfkesinden korkuyorlar (afet)[/color]\n"
	if kr != null and int(kr.get("haydut", 0)) > 0: s += "[color=#ffb060]Yollarda haydutlar var (%d soygun)[/color]\n" % int(kr["haydut"])
	s += "Kuruluş: Yıl %d" % (v["kurulus"] / 12 + 1)
	bilgi_lbl.text = s
	bilgi_git_anahtar = ""
	for c in bilgi_git.get_children():
		c.queue_free()
	if kr != null:
		var h: int = sim.uid_bul(kr["kral_uid"]) if kr["kral_uid"] != 0 else -1
		if h >= 0:
			_dugme("♛ Hükümdar: " + sim.c_ad[h], _canliya_git.bind(h), bilgi_git)
		var bk: Vector2i = sim.baskent_yeri(kr)
		if bk.x >= 0 and kr["baskent"] != v["id"]:
			_dugme("Başkente git", _git.bind(bk.x, bk.y), bilgi_git)
		var g: int = int(kr.get("general", -1))
		if g >= 0 and g < sim.ust and sim.c_var[g] == 1:
			_dugme("★ General: " + sim.c_ad[g], _canliya_git.bind(g), bilgi_git)


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
	buyuk_panel.offset_bottom = -(alt_panel.size.y + 6.0)   # alt çubuğun üstüne taşmasın
	buyuk_panel.visible = true
	menu_panel.visible = false
	_mod_satiri_kur()
	_buyuk_yaz()


## Büyük panelin sekme satırı: istatistikte grafik türü, kronikte "son olaylar / tarih kitabı".
func _mod_satiri_kur() -> void:
	for c in mod_satir.get_children():
		c.queue_free()
	var secenek: Array = []
	var secili := 0
	if buyuk_tur == "istatistik":
		secenek = ["Nüfus", "Altın (hazine)", "Teknoloji", "Toprak (köy)"]
		secili = graf_mod
	elif buyuk_tur == "kronik":
		secenek = ["Son olaylar", "Tarih kitabı"]
		secili = kronik_mod
	mod_satir.visible = not secenek.is_empty()
	for n in secenek.size():
		var b := _dugme(secenek[n], _mod_sec.bind(n), mod_satir, true)
		b.button_pressed = n == secili
		b.custom_minimum_size = Vector2(0, 48 if platform_mobil else 32)


func _mod_sec(n: int) -> void:
	if buyuk_tur == "istatistik":
		graf_mod = n
	else:
		kronik_mod = n
	_mod_satiri_kur()
	_buyuk_yaz()


func _buyuk_yaz() -> void:
	var s := ""
	grafik.visible = buyuk_tur == "istatistik"
	if grafik.visible:
		grafik.queue_redraw()
	if buyuk_tur == "kronik":
		var liste: Array = sim.kronik
		if kronik_mod == 1:
			liste = sim.tarih
			buyuk_baslik.text = "Tarih Kitabı: dünyanın tüm önemli olayları (%d)  ·  ➤ dokun: oraya git" % liste.size()
		else:
			buyuk_baslik.text = "Dünya Kroniği  (➤ olan satıra dokun: oraya git)"
		var n := 0
		var son_yuzyil := -1
		for m in range(liste.size() - 1, -1, -1):
			var k: Array = liste[m]
			if kronik_mod == 1:
				# tarih kitabı yüzyıllara bölünür
				var yz: int = (int(k[0]) / 12) / 100
				if yz != son_yuzyil:
					son_yuzyil = yz
					s += "\n[b][color=#ffd23a]— %d. yüzyıl (Yıl %d–%d) —[/color][/b]\n" % [yz + 1, yz * 100 + 1, yz * 100 + 100]
			var renk := "#c8d0d8"
			if k[2] >= 3: renk = "#ffd23a"
			elif k[2] == 2: renk = "#ffffff"
			if k.size() >= 5:
				s += "[color=#89a]Yıl %d:[/color] [url=%d,%d][color=%s]➤ %s[/color][/url]\n" % [k[0] / 12 + 1, int(k[3]), int(k[4]), renk, k[1]]
			else:
				s += "[color=#89a]Yıl %d:[/color] [color=%s]%s[/color]\n" % [k[0] / 12 + 1, renk, k[1]]
			n += 1
			if n >= (600 if kronik_mod == 1 else 300):
				break
	elif buyuk_tur == "savaslar":
		buyuk_baslik.text = "Süren savaşlar  (➤ olan satıra dokun: cepheye git)"
		var say := 0
		for id in sim.kralliklar:
			var ka: Dictionary = sim.kralliklar[id]
			for did in ka["savas"]:
				if did < id or not sim.kralliklar.has(did):
					continue
				var kb: Dictionary = sim.kralliklar[did]
				say += 1
				var sure: int = (sim.ay - int(ka["savas"][did])) / 12
				var sa: int = int(ka.get("skor", {}).get(did, 0))
				var sb: int = int(kb.get("skor", {}).get(id, 0))
				var sebep: String = str(ka.get("sebep", {}).get(did, kb.get("sebep", {}).get(id, "")))
				# cephe: kuşatma altındaki köy, yoksa savunanın başkenti
				var yer: Vector2i = sim.baskent_yeri(kb)
				var kusatilan := []
				for v in sim.krallik_koyleri(id) + sim.krallik_koyleri(did):
					if int(v.get("kusatma", -100000)) > sim.ay - 12:
						if kusatilan.is_empty():
							yer = Vector2i(v["x"], v["y"])
						kusatilan.append(v["ad"])
				var ga: int = sim.krallik_koyleri(id).size()
				var gb: int = sim.krallik_koyleri(did).size()
				s += "[url=%d,%d]➤ [color=#%s]■ %s[/color] (%d köy)  ⚔  [color=#%s]■ %s[/color] (%d köy)[/url]\n" % [yer.x, yer.y, ka["renk"], ka["ad"], ga, kb["renk"], kb["ad"], gb]
				s += "      [color=#9ab]%s · skor %d – %d%s[/color]\n" % [("%d yıldır" % sure) if sure > 0 else "yeni başladı", sa, sb, (" · sebep: " + sebep) if sebep != "" else ""]
				if kusatilan.size() > 0:
					s += "      [color=#ff8a6a]Kuşatma altında: %s[/color]\n" % ", ".join(kusatilan.slice(0, 6))
				# generaller: adına dokununca generale gidilir
				var gs := []
				for kk in [ka, kb]:
					var g: int = int(kk.get("general", -1))
					if g >= 0 and g < sim.ust and sim.c_var[g] == 1:
						var kt: float = float(kk.get("komuta", 1.0))
						gs.append("[url=%d,%d][color=#%s]★ General %s[/color][/url] [color=#9ab](komuta ×%.2f)[/color]" % [int(sim.c_x[g]), int(sim.c_y[g]), kk["renk"], sim.c_ad[g], kt])
					else:
						gs.append("[color=#789]generalsiz[/color]")
				s += "      %s  –  %s\n" % [gs[0], gs[1]]
		if say == 0:
			s += "[color=#7be07b]Şu an dünyada savaş yok.[/color]\n"
		s += "\n[b]Son savaş olayları[/b]\n"
		var n2 := 0
		for m in range(sim.kronik.size() - 1, -1, -1):
			var k: Array = sim.kronik[m]
			var mt: String = k[1]
			if not (mt.contains("SAVAŞ") or mt.contains("General") or mt.contains("GENERAL") or mt.contains("BARIŞ") or mt.contains("fethetti") or mt.contains("yağmala") or mt.contains("surları") or mt.contains("savaşa katıldı") or mt.contains("DARBE") or mt.contains("İSYAN")):
				continue
			if k.size() >= 5:
				s += "[color=#89a]Yıl %d:[/color] [url=%d,%d]➤ %s[/url]\n" % [k[0] / 12 + 1, int(k[3]), int(k[4]), mt]
			else:
				s += "[color=#89a]Yıl %d:[/color] %s\n" % [k[0] / 12 + 1, mt]
			n2 += 1
			if n2 >= 25:
				break
	else:
		buyuk_baslik.text = "Dünya İstatistikleri — " + sim.tarih_yazi()
		s += "[color=#9ab]Yukarıdaki grafik: %s (5 yılda bir ölçülür).[/color]\n" % ["ırkların nüfusu", "en zengin krallıkların hazinesi", "krallıkların teknolojisi (kesik çizgiler: çağ eşikleri)", "krallıkların köy sayısı"][graf_mod]
		s += "Altının değeri: [color=%s]%%%d[/color]%s\n\n" % ["#7be07b" if sim.altin_deger >= 0.75 else "#ffb060", int(sim.altin_deger * 100.0), "  (enflasyon: fiyatlar yüksek)" if sim.altin_deger < 0.6 else ""]
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
			var huz := 0.0
			for v in koyler:
				huz += float(v.get("huzur", 70.0))
			s += "      Hazine: %d altın  ·  Vergi: %s  ·  Ortalama huzur: %d%s\n" % [int(kr.get("hazine", 0.0)), SimS.VERGI_AD[int(kr.get("vergi", 1))], int(huz / maxi(1, koyler.size())), ("  ·  [color=#ffb060]haraç ödüyor[/color]" if not kr.get("harac", {}).is_empty() else "")]
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
		var eko: Dictionary = sim.ekosistem_durumu()
		s += "\n[b]Ekosistem (besin zinciri)[/b]\n"
		s += "  Otobur: %d (otlak kapasitesi %d)  ·  Avcı: %d (av kapasitesi %d)\n" % [eko["otobur"], eko["otobur_kap"], eko["avci"], eko["avci_kap"]]
		if eko["avci"] == 0 and eko["otobur"] > eko["otobur_kap"]:
			s += "  [color=#ff8a6a]Avcı kalmadı: sürüler otlakları tüketiyor, ovalar bozkıra dönüyor![/color]\n"
		elif eko["otobur"] < eko["otobur_kap"] / 3:
			s += "  [color=#ffd36a]Av hayvanları azaldı: avcılar aç kalıyor.[/color]\n"
		else:
			s += "  [color=#7be07b]Denge sağlıklı.[/color]\n"
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
## Nüfus grafiği: her ırkın nüfusu zamanla (5 yılda bir örnek).
func _grafik_ciz() -> void:
	if graf_mod > 0:
		_krallik_grafik_ciz()
		return
	var g: Array = sim.nufus_gecmis
	var w := grafik.size.x
	var h := grafik.size.y
	grafik.draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 0.3))
	var font := ThemeDB.fallback_font
	if g.size() < 2:
		grafik.draw_string(font, Vector2(12, h * 0.5), "Grafik için biraz zaman geçmeli (5 yılda bir ölçülür).", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.8, 0.85, 0.9))
		return
	var en_cok := 10
	for o in g:
		var say: PackedInt32Array = o[1]
		for t in sim.turler:
			if t["irk"] and t["no"] < say.size():
				en_cok = maxi(en_cok, say[t["no"]])
	var sol := 52.0
	var alt := h - 20.0
	var ust := 8.0
	var y0: int = int(g[0][0])
	var y1: int = maxi(y0 + 1, int(g[g.size() - 1][0]))
	for n in 5:
		var yy := alt - (alt - ust) * n / 4.0
		grafik.draw_line(Vector2(sol, yy), Vector2(w - 8, yy), Color(1, 1, 1, 0.08))
		grafik.draw_string(font, Vector2(4, yy + 5), str(en_cok * n / 4), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.7, 0.75, 0.8))
	grafik.draw_string(font, Vector2(sol, h - 4), "Yıl %d" % y0, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.7, 0.75, 0.8))
	grafik.draw_string(font, Vector2(w - 90, h - 4), "Yıl %d" % y1, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.7, 0.75, 0.8))
	var lx := sol + 8.0
	for t in sim.turler:
		if not t["irk"]:
			continue
		var no: int = t["no"]
		var renk: Color = (t["renk_c"] as Color).lightened(0.25)
		var pts := PackedVector2Array()
		var var_mi := false
		for o in g:
			var say: PackedInt32Array = o[1]
			var deger: int = say[no] if no < say.size() else 0
			if deger > 0:
				var_mi = true
			var x := sol + (w - 8.0 - sol) * float(int(o[0]) - y0) / (y1 - y0)
			pts.append(Vector2(x, alt - (alt - ust) * float(deger) / en_cok))
		if not var_mi:
			continue
		grafik.draw_polyline(pts, renk, 2.0, true)
		# açıklama
		grafik.draw_rect(Rect2(lx, ust + 2, 10, 10), renk)
		grafik.draw_string(font, Vector2(lx + 13, ust + 12), t["ad"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, renk)
		lx += 20.0 + font.get_string_size(t["ad"], HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x


## Krallık grafikleri: hazine, teknoloji ya da köy sayısı; en büyük 8 krallık kendi renginde (yıkılanlar da görünür).
func _krallik_grafik_ciz() -> void:
	var g: Array = sim.gecmis_kr
	var w := grafik.size.x
	var h := grafik.size.y
	grafik.draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 0.3))
	var font := ThemeDB.fallback_font
	if g.size() < 2:
		grafik.draw_string(font, Vector2(12, h * 0.5), "Grafik için biraz zaman geçmeli (5 yılda bir ölçülür).", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.8, 0.85, 0.9))
		return
	var alan: int = [0, 0, 1, 3][graf_mod]
	# en yüksek değere ulaşmış 8 krallık
	var tepe := {}
	var en_cok := 1.0
	for o in g:
		var kd: Dictionary = o[1]
		for kid in kd:
			var dg: float = (kd[kid] as PackedFloat32Array)[alan]
			tepe[kid] = maxf(float(tepe.get(kid, 0.0)), dg)
			en_cok = maxf(en_cok, dg)
	var sirali := tepe.keys()
	sirali.sort_custom(func(a, b): return tepe[a] > tepe[b])
	sirali = sirali.slice(0, 8)
	var tek := graf_mod == 2
	var olc := func(dg: float) -> float:
		return sqrt(dg / en_cok) if tek else dg / en_cok
	var sol := 52.0
	var alt := h - 20.0
	var ust := 22.0
	var y0: int = int(g[0][0])
	var y1: int = maxi(y0 + 1, int(g[g.size() - 1][0]))
	var gri := Color(0.7, 0.75, 0.8)
	if tek:
		# çağ eşikleri (karekök ölçek: erken çağlar da okunur)
		for c in range(1, SimS.CAG_ESIK.size()):
			var e: float = SimS.CAG_ESIK[c]
			if e > en_cok * 1.05:
				break
			var yy: float = alt - (alt - ust) * olc.call(e)
			grafik.draw_dashed_line(Vector2(sol, yy), Vector2(w - 8, yy), Color(1, 0.85, 0.4, 0.25), 1.0, 5.0)
			grafik.draw_string(font, Vector2(4, yy + 4), SimS.CAG_AD[c].split(" ")[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 0.85, 0.4, 0.8))
	else:
		for n in 5:
			var yy := alt - (alt - ust) * n / 4.0
			grafik.draw_line(Vector2(sol, yy), Vector2(w - 8, yy), Color(1, 1, 1, 0.08))
			grafik.draw_string(font, Vector2(4, yy + 5), str(int(en_cok * n / 4.0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, gri)
	grafik.draw_string(font, Vector2(sol, h - 4), "Yıl %d" % y0, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, gri)
	grafik.draw_string(font, Vector2(w - 90, h - 4), "Yıl %d" % y1, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, gri)
	var lx := sol + 4.0
	for kid in sirali:
		var bilgi = sim.kr_renk_gecmis.get(kid)
		var renk := Color(bilgi[0]).lightened(0.2) if bilgi != null else Color.WHITE
		var pts := PackedVector2Array()
		for o in g:
			var kd: Dictionary = o[1]
			var x := sol + (w - 8.0 - sol) * float(int(o[0]) - y0) / (y1 - y0)
			if kd.has(kid):
				pts.append(Vector2(x, alt - (alt - ust) * olc.call((kd[kid] as PackedFloat32Array)[alan])))
			elif pts.size() > 0:
				break     # krallık yıkıldı: çizgi biter
		if pts.size() >= 2:
			grafik.draw_polyline(pts, renk, 2.0, true)
		if pts.size() > 0 and not sim.kralliklar.has(kid):
			_carpi(pts[pts.size() - 1], renk)
		var ad: String = bilgi[1] if bilgi != null else "?"
		var parca := ad.split(" ")
		ad = parca[1] if parca.size() > 1 and parca[0] == "Özgür" else parca[0]
		if lx + font.get_string_size(ad, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x < w - 10:
			grafik.draw_rect(Rect2(lx, 5, 9, 9), renk)
			grafik.draw_string(font, Vector2(lx + 12, 14), ad, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, renk)
			lx += 20.0 + font.get_string_size(ad, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x


func _carpi(p: Vector2, c: Color) -> void:
	grafik.draw_line(p + Vector2(-4, -4), p + Vector2(4, 4), c, 2.0)
	grafik.draw_line(p + Vector2(4, -4), p + Vector2(-4, 4), c, 2.0)


func _menu_ac() -> void:
	for c in menu_panel.get_children():
		c.queue_free()
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	menu_panel.add_child(v)
	var bas := Label.new()
	bas.text = "Dünya Kutusu"
	bas.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bas.add_theme_font_size_override("font_size", 26)
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
	var nh := HBoxContainer.new()
	v.add_child(nh)
	var ns := _dugme("Nüfus sınırı: " + _sinir_yazi(sim.nufus_siniri), func():
		var l: Array = SimS.NUFUS_SECENEK
		sim.nufus_siniri = l[(l.find(sim.nufus_siniri) + 1) % l.size()]
		_menu_ac(), nh)
	ns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var af := _dugme("Doğal afetler: " + ("AÇIK" if sim.dogal_afet else "KAPALI"), func():
		sim.dogal_afet = not sim.dogal_afet
		_menu_ac(), nh)
	af.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sh2 := HBoxContainer.new()
	v.add_child(sh2)
	var sb := _dugme("Ses: " + ("AÇIK" if ses_acik else "KAPALI"), func():
		ses_acik = not ses_acik
		if ses != null:
			ses.ayarla(ses_acik)
		_ayar_yaz()
		_menu_ac(), sh2)
	sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var tb := _dugme("Uzaktan sınırlar: " + ("AÇIK" if toprak_ozet else "KAPALI"), func():
		toprak_ozet = not toprak_ozet
		harita.toprak_ozet = toprak_ozet
		_ayar_yaz()
		_menu_ac(), sh2)
	tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sh3 := HBoxContainer.new()
	v.add_child(sh3)
	var mb := _dugme("Müzik (çağa göre): " + ("AÇIK" if muzik_acik else "KAPALI"), func():
		muzik_acik = not muzik_acik
		if ses != null:
			ses.muzik_ayarla(muzik_acik)
		_ayar_yaz()
		_menu_ac(), sh3)
	mb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var yard := Label.new()
	yard.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	yard.custom_minimum_size = Vector2(520, 0)
	yard.add_theme_font_size_override("font_size", 15)
	yard.modulate = Color(0.75, 0.8, 0.85)
	yard.text = "Kaydırma: tek parmak (İncele aracında) ya da iki parmak. Yakınlaştırma: iki parmak / fare tekerleği. PC: WASD gez, Boşluk duraklat, 1-5 hız, F5 kaydet, F9 yükle, sağ tık sürükle. Dünya her dakika kendiliğinden kaydedilir."
	if platform_mobil:
		yard.text = "Kaydırma: tek parmak (İncele aracında) ya da iki parmak. Yakınlaştırma: iki parmak. Dünya her dakika kendiliğinden kaydedilir."
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
	son_kronik = sim.kronik.size()
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
	# köy listesi (önem sırası, yazı, renk, yazı genişliği) yarım saniyede bir kurulur; her karede yalnızca yerleştirilir
	var simdi := Time.get_ticks_msec()
	if simdi - etiket_zaman > 500 or etiket_dunya != sim.tohum * 1000 + sim.koyler.size():
		etiket_zaman = simdi
		etiket_dunya = sim.tohum * 1000 + sim.koyler.size()
		etiket_liste.clear()
		var onemli: Array = []
		for id in sim.koyler:
			var v: Dictionary = sim.koyler[id]
			onemli.append([_etiket_onem(v), v])
		onemli.sort_custom(func(p: Array, q: Array) -> bool: return p[0] > q[0])
		for o in onemli:
			var v: Dictionary = o[1]
			var kr = sim.kralliklar.get(v["krallik"])
			var baskent: bool = kr != null and kr["baskent"] == v["id"]
			var yazi := "%s%s (%d)" % ["♛ " if baskent else "", v["ad"], v["nufus"]]
			var renk := (Color(kr["renk"]) if kr != null else Color.WHITE).lightened(0.6)
			var savasta: bool = kr != null and not kr["savas"].is_empty() and int(v.get("hedef", -1)) >= 0
			etiket_liste.append([float(v["x"]) + 0.5, float(v["y"]) - 1.5, yazi, renk, sim.kademe(v), baskent, int(v["nufus"]), font.get_string_size(yazi, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x, savasta])
	var ekran := get_viewport().get_visible_rect().size
	var dolu: Array[Rect2] = []
	for e in etiket_liste:
		var kd: int = e[4]
		var baskent: bool = e[5]
		if e[6] < 3 and olcek < 2.5:
			continue
		# uzaktan yalnızca şehirler ve başkentler yazılır (kalabalık olmasın)
		if olcek < 1.6 and kd < 2 and not baskent:
			continue
		var p: Vector2 = tr * (Vector2(e[0], e[1]) * KARO)
		if p.x < -80.0 or p.y < -10.0 or p.x > ekran.x + 80.0 or p.y > ekran.y + 30.0:
			continue
		var b2: int = boy + (4 if kd >= 2 else 0) + (2 if baskent else 0)
		var gen: float = float(e[7]) * b2 / 16.0
		var kutu := Rect2(p.x - gen * 0.5, p.y - b2, gen, b2 + 2)
		var cakisma := false
		for r in dolu:
			if r.intersects(kutu):
				cakisma = true
				break
		if cakisma:
			continue
		dolu.append(kutu)
		etiket_katmani.draw_string_outline(font, p - Vector2(gen * 0.5, 0), e[2], HORIZONTAL_ALIGNMENT_LEFT, -1, b2, 4, Color(0, 0, 0, 0.8))
		etiket_katmani.draw_string(font, p - Vector2(gen * 0.5, 0), e[2], HORIZONTAL_ALIGNMENT_LEFT, -1, b2, e[3])


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
	harita.huzur_harita = true
	_sekme_sec("Gözlem")
	await _kare(klasor + "/02c_huzur_haritasi.png")
	harita.huzur_harita = false
	harita.irk_harita = true
	_sekme_sec("Gözlem")
	await _kare(klasor + "/02d_irk_haritasi.png")
	harita.irk_harita = false
	_sekme_sec("Gözlem")
	# mevsimler: aynı dünya dört mevsimde (bahar çiçekleri, sararan yaz, kızıl güz, kuzeyde kar)
	var asil_ay: int = sim.ay
	hiz_ayarla(0)
	for ms in [[3, "20_mevsim_ilkbahar"], [6, "21_mevsim_yaz"], [9, "22_mevsim_sonbahar"], [0, "23_mevsim_kis"]]:
		sim.ay = (asil_ay / 12) * 12 + int(ms[0])
		harita.alfa = 0.5
		_kamera_sigdir()
		await _kare(klasor + "/" + ms[1] + ".png")
	var orman_koy = null
	for id in sim.koyler:
		var kv: Dictionary = sim.koyler[id]
		if orman_koy == null or float(kv["orman"]) > float(orman_koy["orman"]):
			orman_koy = kv
	if orman_koy != null:
		kamera.position = Vector2(orman_koy["x"], orman_koy["y"]) * KARO
		kamera.zoom = Vector2(2.5, 2.5)
		sim.ay = (asil_ay / 12) * 12 + 9
		await _kare(klasor + "/22b_sonbahar_yakin.png")
	sim.ay = asil_ay
	hiz_ayarla(1)
	await _savas_kareleri(klasor)
	var en = null
	for id in sim.koyler:
		if en == null or sim.koyler[id]["nufus"] > en["nufus"]:
			en = sim.koyler[id]
	if en != null:
		kamera.position = Vector2(en["x"], en["y"]) * KARO
		kamera.zoom = Vector2(5, 5)
		await _kare(klasor + "/03_koy_yakin.png")
		await _fps_olc("yakin")
		kamera.zoom = Vector2(2, 2)
		await _kare(klasor + "/03b_orta_uzaklik.png")
		kamera.zoom = Vector2(9, 9)
		await _kare(klasor + "/03c_binalar_yakin.png")
		kamera.zoom = Vector2(5, 5)
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
		# sel: kıyıdaki bir köyü sular basar
		var kiyi = null
		for id in sim.koyler:
			var kv: Dictionary = sim.koyler[id]
			if sim._kiyiya_yakin(kv["x"], kv["y"], 6) and (kiyi == null or kv["nufus"] > kiyi["nufus"]):
				kiyi = kv
		if kiyi != null:
			sim.afet("sel", kiyi["x"], kiyi["y"], true)
			sim.tick()
			kamera.position = Vector2(kiyi["x"], kiyi["y"]) * KARO
			kamera.zoom = Vector2(4, 4)
			_sekme_sec("Afetler")
			arac_sec("afet", "sel")
			await _kare(klasor + "/14_sel.png")
			arac_sec("incele", null)
		# isyan: büyük bir krallığın başkent olmayan köyü ayaklanır
		var asi = null
		for id in sim.koyler:
			var kv: Dictionary = sim.koyler[id]
			var kr = sim.kralliklar.get(kv["krallik"])
			if kr != null and kr["baskent"] != kv["id"] and sim.krallik_koyleri(kr["id"]).size() >= 3 and (asi == null or kv["nufus"] > asi["nufus"]):
				asi = kv
		if asi != null:
			sim.isyan(asi, true)
			# bir ticaret kervanı örneği (komşu köye)
			var komsu = sim.koy_yakin(asi["x"] + 12, asi["y"] + 6, 40)
			if komsu != null and komsu["id"] != asi["id"]:
				sim.efektler.append([9, asi["x"] + 0.5, asi["y"] + 0.5, 4, komsu["x"] + 0.5, komsu["y"] + 0.5])
			kamera.position = Vector2(asi["x"], asi["y"]) * KARO
			kamera.zoom = Vector2(3, 3)
			_sekme_sec("Güçler")
			arac_sec("guc", "isyan")
			_koy_goster(asi)
			await _kare(klasor + "/15_isyan.png")
			arac_sec("incele", null)
			_bilgi_kapat()
	_buyuk_ac("kronik")
	await _kare(klasor + "/09_kronik.png")
	_mod_sec(1)
	await _kare(klasor + "/09b_tarih_kitabi.png")
	_mod_sec(0)
	_buyuk_ac("istatistik")
	await _kare(klasor + "/10_istatistik.png")
	_mod_sec(1)
	await _kare(klasor + "/10b_altin_grafigi.png")
	_mod_sec(2)
	await _kare(klasor + "/10c_teknoloji_grafigi.png")
	_mod_sec(0)
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


## Savaş kareleri: iki komşu krallık savaşa sokulur; uzak özet, kuşatma ve asker yakın planı çekilir.
func _savas_kareleri(klasor: String) -> void:
	# en kalabalık iki komşu krallık (aynı kıtada)
	var en_a = null
	var en_b = null
	var en_puan := -1
	for id in sim.koyler:
		var v: Dictionary = sim.koyler[id]
		var o = sim.koy_yakin(v["x"] + 10, v["y"] + 4, 26)
		if o == null or o["krallik"] == v["krallik"] or sim.kita[o["y"] * sim.gen + o["x"]] != sim.kita[v["y"] * sim.gen + v["x"]]:
			continue
		var puan: int = mini(v["nufus"], o["nufus"])
		if puan > en_puan:
			en_puan = puan; en_a = v; en_b = o
	if en_a == null:
		return
	if not sim.kralliklar[en_a["krallik"]]["savas"].has(en_b["krallik"]):
		sim.savas_ilan(en_a["krallik"], en_b["krallik"])
	hiz_ayarla(0)
	for n in 40:
		sim.tick()
	_sekme_sec("Gözlem")
	_kamera_sigdir()
	await _kare(klasor + "/16_savas_uzak.png")
	# kuşatma altındaki köy (yoksa hedef köy)
	var cephe = en_b
	for id in sim.koyler:
		var v: Dictionary = sim.koyler[id]
		if int(v.get("kusatma", -100000)) > sim.ay - 6:
			cephe = v
			break
	# çarpışma anı: birkaç ay daha, efektler taze kalsın
	for n in 3:
		sim.tick()
	kamera.position = Vector2(cephe["x"], cephe["y"]) * KARO
	kamera.zoom = Vector2(5, 5)
	await _kare(klasor + "/17_kusatma.png")
	# bir askerin yakın planı (silah, zırh, sancak)
	# savaş bu arada barışla bittiyse (rastgele) görüntü için yeniden başlatılır
	if sim.kralliklar.has(en_a["krallik"]) and sim.kralliklar.has(en_b["krallik"]) and not sim.kralliklar[en_a["krallik"]]["savas"].has(en_b["krallik"]):
		sim.savas_ilan(en_a["krallik"], en_b["krallik"])
		for n in 14:
			sim.tick()
	var asker := -1
	var en_d := 1.0e9
	for i in sim.ust:
		if sim.c_var[i] == 1 and sim.c_durum[i] == SimS.D_ASKER:
			var d: float = Vector2(sim.c_x[i] - cephe["x"], sim.c_y[i] - cephe["y"]).length()
			if d < en_d:
				en_d = d; asker = i
	if asker >= 0:
		kamera.position = Vector2(sim.c_x[asker], sim.c_y[asker]) * KARO
		kamera.zoom = Vector2(11, 11)
		await _kare(klasor + "/18_asker_yakin.png")
		# general: pelerin, tüylü miğfer, altın kuşak; uzaktan yıldız işareti
		var g := -1
		for kk in [sim.kralliklar.get(en_a["krallik"]), sim.kralliklar.get(en_b["krallik"])]:
			if kk != null and int(kk.get("general", -1)) >= 0 and sim.c_var[int(kk["general"])] == 1 and sim.c_durum[int(kk["general"])] == SimS.D_ASKER:
				g = int(kk["general"])
				break
		if g >= 0:
			kamera.position = Vector2(sim.c_x[g], sim.c_y[g]) * KARO
			kamera.zoom = Vector2(11, 11)
			await _kare(klasor + "/18e_general_yakin.png")
			kamera.zoom = Vector2(2.5, 2.5)
			harita.ozet_ay = -1
			await _kare(klasor + "/18f_general_isareti.png")
			harita.secili = g
			_bilgi_ac()
			await _kare(klasor + "/18g_general_karti.png")
			harita.secili = -1
			bilgi_panel.visible = false
		# sonraki çağların silahları: savaşan köyler geçici olarak Barut ve Uzay Çağı'na alınır (yalnızca görüntü için)
		var eski_cag := {}
		for id in sim.koyler:
			var v: Dictionary = sim.koyler[id]
			if v["savasta"]:
				eski_cag[id] = v["cag"]
		for cag in [3, 4, 6]:
			for id in eski_cag:
				if sim.koyler.has(id):
					sim.koyler[id]["cag"] = cag
					sim._bayrak(sim.koyler[id])
			for n in 2:
				sim.tick()
			var odak := asker
			if cag < 6:
				# kuşatma makinesi (mancınık / top) ya da atlı olan bir asker varsa ona yaklaş
				var en_m := 1.0e9
				for i in sim.ust:
					if sim.c_var[i] == 1 and sim.c_durum[i] == SimS.D_ASKER and sim.birim(i) >= 4:
						var d2: float = Vector2(sim.c_x[i] - cephe["x"], sim.c_y[i] - cephe["y"]).length() - (20.0 if sim.birim(i) >= 5 else 0.0)
						if d2 < en_m:
							en_m = d2; odak = i
			if sim.c_var[odak] == 1:
				kamera.position = Vector2(sim.c_x[odak], sim.c_y[odak]) * KARO
			kamera.zoom = Vector2(9, 9)
			await _kare(klasor + ["/18d_mancinik_atli.png", "/18b_tufekli_askerler.png", "/18c_lazerli_askerler.png"][[3, 4, 6].find(cag)])
		for id in eski_cag:
			if sim.koyler.has(id):
				sim.koyler[id]["cag"] = eski_cag[id]
				sim._bayrak(sim.koyler[id])
	_buyuk_ac("savaslar")
	await _kare(klasor + "/19_savaslar_paneli.png")
	buyuk_panel.visible = false
	# haydut baskını: bir kervan yolunda soygun (efekt) ve kronik satırı
	var pz = null
	for id in sim.koyler:
		if sim.koyler[id]["b"][SimS.Y_PAZAR] > 0:
			pz = sim.koyler[id]
			break
	if pz == null:
		pz = en_a
	var hx: float = pz["x"] + 7.5
	var hy: float = pz["y"] + 3.5
	sim.efektler.append([9, pz["x"] + 0.5, pz["y"] + 0.5, 8, pz["x"] + 14.5, pz["y"] + 7.5])
	sim.efektler.append([21, hx, hy, 9])
	kamera.position = Vector2(hx, hy) * KARO
	kamera.zoom = Vector2(7, 7)
	await _kare(klasor + "/24_haydut_baskini.png")
	# afet sonrası: tanrıların öfkesi (köy kartında)
	sim.afet("deprem", en_b["x"] + 2, en_b["y"] + 2)
	_koy_goster(en_b)
	kamera.position = Vector2(en_b["x"], en_b["y"]) * KARO
	kamera.zoom = Vector2(3, 3)
	await _kare(klasor + "/25_afet_sonrasi_ofke.png")
	bilgi_panel.visible = false
	hiz_ayarla(1)


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


## Kasma ölçümü: az/orta/çok nüfus × uzak/yakın görünüm × 1x/20x/100x/500x hız.
## Her satır: ortalama ve en yavaş kare, karede simülasyona / canlı çizimine / harita dokusuna giden süre, ulaşılan hız.
## Kullanım: xvfb-run godot --rendering-driver opengl3 --resolution 1280x720 -- olcum
func _olcum() -> void:
	var senaryo := [["az", 1, 12345, 40], ["orta", 1, 12345, 160], ["cok", 3, 5, 170]]
	var kisa := OS.get_cmdline_user_args().has("kisa")
	# süzgeç (hızlı deneme için): -- olcum sadece=orta gorunum=yakin
	var sadece := ""
	var yalniz_gor := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("sadece="): sadece = a.substr(7)
		if a.begins_with("gorunum="): yalniz_gor = a.substr(8)
	print("OLCUM basladi (kare süreleri ms; yazılım çizimi, yalnızca gece gece karşılaştırma için)")
	print("OLCUM | nufus | gorunum | hiz | canli | ort kare | en yavas | sim | cizim | doku | ay/sn")
	for sn in senaryo:
		if (kisa and sn[0] == "cok") or (sadece != "" and sn[0] != sadece):
			continue
		yeni_dunya(sn[1], sn[2])
		sim.hareket_adim = 12
		for n in int(sn[3]) * 12:
			sim.tick()
		sim.hareket_adim = 1
		sim.kaydet("user://olcum.kayit")
		for gorunum in ["uzak", "yakin", "cokyakin"]:
			for h in [1, 3, 4, 5]:
				if (gorunum == "cokyakin" and h != 1 and h != 4) or (yalniz_gor != "" and gorunum != yalniz_gor):
					continue
				# her satır aynı dünyadan başlar (nüfus satırlar arasında kaymasın)
				sim.yukle("user://olcum.kayit")
				harita.baglan(sim)
				var en = null
				for id in sim.koyler:
					if en == null or sim.koyler[id]["nufus"] > en["nufus"]:
						en = sim.koyler[id]
				if gorunum == "uzak":
					_kamera_sigdir()
				elif en != null:
					kamera.position = Vector2(en["x"], en["y"]) * KARO
					kamera.zoom = Vector2(4, 4) if gorunum == "yakin" else Vector2(7, 7)
				hiz_ayarla(h)
				birikim = 0.0
				for n in 12:
					await get_tree().process_frame
				var kare := 70
				var top := 0
				var azami := 0
				olc_tick_us = 0
				harita.olc_cizim_us = 0
				harita.olc_doku_us = 0
				var ay0: int = sim.ay
				var onceki := Time.get_ticks_usec()
				for n in kare:
					await get_tree().process_frame
					var simdi := Time.get_ticks_usec()
					var d := simdi - onceki
					onceki = simdi
					top += d
					azami = maxi(azami, d)
				print("OLCUM | %s | %s | %s | %d | %.1f | %.1f | %.1f | %.1f | %.1f | %.0f" % [sn[0], gorunum, HIZ_AD[h], sim.ust - sim.bos.size(), top / 1000.0 / kare, azami / 1000.0, olc_tick_us / 1000.0 / kare, harita.olc_cizim_us / 1000.0 / kare, harita.olc_doku_us / 1000.0 / kare, (sim.ay - ay0) * 1000000.0 / maxf(1.0, top)])
	print("OLCUM bitti")
	get_tree().quit()
