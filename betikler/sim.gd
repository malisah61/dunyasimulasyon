extends RefCounted
## Dünya simülasyonunun çekirdeği. Ekrandan bağımsızdır (headless çalışır).
## 1 adım (tick) = 1 ay. Canlılar "dizi yapısı" (struct-of-arrays) olarak tutulur: hız için.

enum { B_DERIN, B_SIG, B_KUM, B_OVA, B_ORMAN, B_BOZKIR, B_COL, B_BATAK, B_TEPE, B_DAG, B_KAR, B_LAV, B_YANIK }
enum { Y_YOK, Y_MERKEZ, Y_EV, Y_TARLA, Y_AMBAR, Y_MADEN, Y_DEMIRHANE, Y_KISLA, Y_TAPINAK, Y_KUTUPHANE, Y_PAZAR, Y_SARAY, Y_KULE, Y_HARABE, Y_KALE }
enum { D_GEZ, D_ASKER, D_GOC, D_KAC }

const BIYOM_AD := ["Derin deniz", "Sığ deniz", "Kumsal", "Ova", "Orman", "Bozkır", "Çöl", "Bataklık", "Tepe", "Dağ", "Kar", "Lav", "Yanık toprak"]
const YAPI_AD := ["", "Köy meydanı", "Ev", "Tarla", "Ambar", "Maden", "Demirhane", "Kışla", "Tapınak", "Kütüphane", "Pazar", "Saray", "Gözetleme kulesi", "Harabe", "Kale"]
const CAG_AD := ["Taş Çağı", "Tunç Çağı", "Demir Çağı", "Orta Çağ", "Barut Çağı", "Sanayi Çağı", "Uzay Çağı"]
const CAG_ESIK := [0.0, 120.0, 400.0, 1000.0, 2200.0, 4500.0, 9000.0]
const CAG_VERIM := [1.0, 1.15, 1.3, 1.5, 1.7, 2.0, 2.4]
const CAG_SILAH := [1.0, 1.3, 1.7, 2.2, 3.2, 4.5, 7.0]
const SILAH_AD := ["Sopa ve taş balta", "Tunç mızrak", "Demir kılıç ve yay", "Çelik kılıç ve arbalet", "Tüfek ve top", "Makineli tüfek", "Lazer silahı"]
const MEVSIM_AD := ["Kış", "Kış", "İlkbahar", "İlkbahar", "İlkbahar", "Yaz", "Yaz", "Yaz", "Sonbahar", "Sonbahar", "Sonbahar", "Kış"]
const MAX_OZL := 5
const KAYIT_SURUMU := 4
const YAGMACI := ["ork", "goblin", "dev", "uzayli"]
const KADEME_AD := ["Köy", "Kasaba", "Şehir", "Büyük şehir"]
const KADEME_ESIK := [0, 40, 100, 180]
const DIN_TIP := ["Doğa", "Ateş", "Ata", "Güneş", "Ay", "Deniz", "Dağ", "Yıldız"]
const DIN_EK := ["Yolu", "İnancı", "Öğretisi", "Ocağı", "Tarikatı"]
const NUFUS_SECENEK := [0, 1000, 2500, 5000, 10000, 20000, 50000]
const VERGI_AD := ["Düşük", "Orta", "Yüksek"]
const VERGI_ORAN := [0.12, 0.25, 0.45]
const HARAC_YIL := 10

# ---- veri ----
var ozellikler: Array = [null]        # id -> sözlük
var ozl_id: Dictionary = {}           # ad -> id
var ozl_stat: Array = [null]          # id -> PackedFloat32Array [guc,can,hiz,zeka,is,dogur,omur,cesaret]
var havuz: PackedInt32Array = []      # rastgele özellik havuzu (nadirliğe göre ağırlıklı)
var turler: Array = []
var tur_id: Dictionary = {}
var t_irk := PackedByteArray()
var t_avci := PackedByteArray()
var t_otobur := PackedByteArray()
var t_ucan := PackedByteArray()
var t_uretim := PackedFloat32Array()   # bir yetişkinin iş gücü çarpanı (Dev = 3 kişi)
var t_yetiskin := PackedInt32Array()   # yetişkinlik yaşı (ay)
var t_dogur := PackedFloat32Array()
var t_soguga := PackedByteArray()      # soğuktan ölmez (Dev)
var t_zirh := PackedFloat32Array()     # ok ve mermiye karşı doğal zırh çarpanı (Cüce zırhı, Dev derisi; 1 = yok)
# sık kullanılan özellik id'leri (sözlük aramasını azaltmak için)
var oz_soguk := 0
var oz_mutant := 0
var oz_guclu_kal := 0
var oz_cesur := 0
var oz_bilge := 0
var oz_kahraman := 0
var oz_dahi := 0
var oz_uzayli := 0
var oz_efsane := PackedInt32Array()

# ---- dünya ----
var gen := 0
var yuk := 0
var tohum := 0
var biyom := PackedByteArray()
var yapi := PackedByteArray()
var yapi_koy := PackedInt32Array()
var ates := PackedByteArray()
var maden := PackedByteArray()        # 0 yok, 1 altın, 2 demir
var kita := PackedInt32Array()
var yer := PackedInt32Array()         # karodaki son canlı (yuva+1)
var kita_kirli := true
var _kita_is := PackedInt32Array()    # kıta etiketleri: aylara yayılan yeniden hesap (çalışma dizisi)
var _kita_yigin := PackedInt32Array()
var _kita_k0 := -1                    # -1 = hesap sürmüyor
var _kita_etiket := 0
var ay := 0
var rng := RandomNumberGenerator.new()

# ---- canlılar ----
var kap := 0
var ust := 0
var bos := PackedInt32Array()
var son_uid := 0
var c_var := PackedByteArray()
var c_tur := PackedByteArray()
var c_cins := PackedByteArray()
var c_durum := PackedByteArray()
var c_x := PackedFloat32Array()
var c_y := PackedFloat32Array()
var c_ox := PackedFloat32Array()
var c_oy := PackedFloat32Array()
var c_hx := PackedInt32Array()
var c_hy := PackedInt32Array()
var c_yas := PackedInt32Array()
var c_can := PackedFloat32Array()
var c_sans := PackedFloat32Array()
var c_koy := PackedInt32Array()
var c_uid := PackedInt32Array()
var c_anne := PackedInt32Array()
var c_baba := PackedInt32Array()
var c_oldurme := PackedInt32Array()
var c_cocuk := PackedInt32Array()
var c_ozl := PackedByteArray()
var c_ad := PackedStringArray()
var c_tok := PackedByteArray()        # avcı hayvanların tokluğu (av yedikçe artar, aç kalan ölür)
var s_guc := PackedFloat32Array()
var s_hiz := PackedFloat32Array()
var s_zeka := PackedFloat32Array()
var s_is := PackedFloat32Array()
var s_dogur := PackedFloat32Array()
var s_omur := PackedFloat32Array()
var s_cesaret := PackedFloat32Array()
var s_canmax := PackedFloat32Array()
var s_lider := PackedFloat32Array()    # liderlik + kral olma (yıllık aday seçimi için önbellek)
var s_vurus := PackedFloat32Array()    # yakın dövüş hasar çarpanı (Saldırgan, Kılıç Ustası...)
var s_okcu := PackedFloat32Array()     # okçuluk (0.25 ve üstü: doğuştan okçu; menzilli hasarı artırır)
var s_kacin := PackedFloat32Array()    # darbeden sıyrılma olasılığı (Çevik...)
var c_bit := PackedByteArray()         # 1 kâhin (afet önsezisi), 2 hain/darbeci, 4 şifacı
var sayim := PackedInt32Array()       # tür başına canlı sayısı
var irk_nufus := 0

# ---- toplum ----
var koyler: Dictionary = {}
var kralliklar: Dictionary = {}
var son_koy := 0
const HUCRE := 16                      # köy ızgarası hücre boyu (karo)
var koy_hucre: Dictionary = {}        # hücre anahtarı -> köy id listesi (yakın köy aramasını hızlandırır)
var son_krallik := 0
# köy başına hızlı diziler (köy id ile): yıllık canlı döngüsü sözlük yerine bunları okur/yazar
var kv_bayrak := PackedByteArray()    # 128 köy var, 1 kıtlık, 2 salgın, 4 savaş, 8 göç, 16 avlanma gerek, 32 kışla
var kv_bolluk := PackedFloat32Array()
var kv_is := PackedFloat32Array()
var kv_zeka := PackedFloat32Array()
var kv_yet := PackedInt32Array()
var kv_aday := PackedInt32Array()
var kv_puan := PackedFloat32Array()
var kv_erkek := PackedInt32Array()
var kv_cag := PackedByteArray()       # köyün çağı (askerin silahı için hızlı okuma)
var kv_kahin := PackedInt32Array()    # köyde en son kâhin görülen ay (afet önsezisi)
var kv_hain := PackedInt32Array()     # köydeki darbeci/hain yetişkin (canlı yuvası, -1 yok)
var kv_sifa := PackedInt32Array()     # köyde en son şifacı görülen ay (salgını hafifletir)
var _onsezi := false                  # süren afette halk önceden uyarıldı mı
var _kk_ay := -1                      # krallık → köy listesi önbelleğinin ayı (-1 = bayat)
var _kk: Dictionary = {}
var kronik: Array = []                # [ay, metin, önem]
var olumler: Dictionary = {}
var irk_olum: Dictionary = {}          # tür adı -> {sebep: sayı} (kaydedilmez, istatistik için)
var dogum_sayisi := 0
var dinler: Dictionary = {}           # id -> {ad, tip, renk, kurucu, kurulus}
var son_din := 0
var nufus_gecmis: Array = []          # [yıl, PackedInt32Array(tür sayıları)] — 5 yılda bir
var t_kap := PackedInt32Array()       # türün taşıma kapasitesi (otlak ve av miktarına göre, yıllık)
var otobur_kap := 0

# ---- afetler ----
var yanan := PackedInt32Array()
var hortumlar: Array = []
var ufolar: Array = []
var kuraklik_ay := 0
var kis_ay := 0
var dogal_afet := true
var sel := PackedByteArray()          # sel altındaki karolar (kalan ay)
var seller := PackedInt32Array()
var ufo_geldi := false

# ---- ayarlar / çizim için ----
var nufus_siniri := 0                # 0 = sınırsız
var hareket_adim := 1
const DILIM := 8                     # yayık harekette bir ay kaç dilime bölünür
var yayik := false                   # hareket karelere yayılsın mı (ekran, 1x–5x hızda açar)
var dilim_no := 8                    # bu ay işlenen dilim sayısı (DILIM = hepsi bitti)
var degisen := PackedInt32Array()     # çizimde yenilenecek karolar
var hepsi_degisti := true
var efektler: Array = []              # [tip, x, y, süre]
var olc_us := PackedInt64Array([0, 0, 0, 0, 0, 0])   # ölçüm (µs): yıllık, hareket, köy, krallık, afet+diğer, en yavaş tick


func _init() -> void:
	_veri_yukle()


# ============================================================ VERİ
func _veri_yukle() -> void:
	var j: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://veri/ozellikler.json"))
	var agirlik := [0, 10, 6, 3, 1, 0]
	for o in j["ozellikler"]:
		var id: int = int(o["id"])
		while ozellikler.size() <= id:
			ozellikler.append(null)
			ozl_stat.append(null)
		o["id"] = id
		o["nadirlik"] = int(o["nadirlik"])
		ozellikler[id] = o
		ozl_id[o["ad"]] = id
		var e: Dictionary = o["etkiler"]
		var st := PackedFloat32Array()
		st.resize(8)
		st[0] = e.get("guc", 0) + e.get("saldiri", 0) * 0.5 + e.get("yakin_dovus", 0) * 0.5 + e.get("okculuk", 0) * 0.3
		st[1] = e.get("can", 0)
		st[2] = e.get("hiz", 0)
		st[3] = e.get("zeka", 0) + e.get("ogrenme", 0) * 0.3
		st[4] = e.get("calisma", 0) + e.get("uretim", 0) * 0.5 + e.get("tarim", 0) * 0.4 + e.get("insaat", 0) * 0.2 + e.get("madencilik", 0) * 0.2 + e.get("avcilik", 0) * 0.2
		st[5] = e.get("dogurganlik", 0)
		st[6] = e.get("omur", 0)
		st[7] = e.get("cesaret", 0)
		ozl_stat[id] = st
		for _n in agirlik[o["nadirlik"]]:
			havuz.append(id)
	for o in ozellikler:
		if o == null:
			continue
		var z := PackedInt32Array()
		for ad in o["zit"]:
			z.append(ozl_id[ad])
		o["zit_id"] = z
	oz_soguk = ozl_id["Soğuğa Dayanıklı"]; oz_mutant = ozl_id["Mutant"]; oz_guclu_kal = ozl_id["Güçlü Kalıtım"]
	oz_cesur = ozl_id["Cesur"]; oz_bilge = ozl_id["Bilge"]; oz_kahraman = ozl_id["Kahraman"]; oz_dahi = ozl_id["Dahi"]
	oz_uzayli = ozl_id["Uzaylı Geni"]
	oz_efsane = PackedInt32Array([oz_dahi, oz_kahraman, ozl_id["Kâhin"], ozl_id["Kutsanmış"], ozl_id["Büyü Yetenekli"]])
	var jt: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://veri/turler.json"))
	for t in jt["turler"]:
		tur_id[t["id"]] = turler.size()
		t["no"] = turler.size()
		t["renk_c"] = Color(t["renk"])
		t["ten_c"] = Color(t["ten"])
		var by := PackedInt32Array()
		for b in t["biyom"]:
			by.append(int(b))
		t["biyom"] = by
		turler.append(t)
		t_irk.append(1 if t.get("irk", false) else 0)
		t_avci.append(1 if t.get("avci", false) else 0)
		t_otobur.append(1 if t.get("otobur", false) else 0)
		t_ucan.append(1 if t.get("ucan", false) else 0)
		t_uretim.append(float(t.get("uretim", 1.0)))
		t_yetiskin.append(int(t["yetiskin"]) * 12)
		t_dogur.append(float(t["dogur"]))
		t_soguga.append(1 if t["id"] == "dev" else 0)
		t_zirh.append(float(t.get("zirh", 1.0)))
	sayim.resize(turler.size())
	t_kap.resize(turler.size())


# ============================================================ DÜNYA ÜRETİMİ
func dunya_uret(g: int, y: int, th: int) -> void:
	gen = g
	yuk = y
	tohum = th
	rng.seed = th
	var n := g * y
	biyom.resize(n); yapi.resize(n); yapi_koy.resize(n); ates.resize(n); maden.resize(n); kita.resize(n); yer.resize(n); sel.resize(n)
	yapi.fill(0); yapi_koy.fill(-1); ates.fill(0); maden.fill(0); yer.fill(0); sel.fill(0); seller.clear(); nufus_gecmis.clear()
	ay = 0
	koyler.clear(); kralliklar.clear(); kronik.clear(); olumler.clear(); dinler.clear(); son_din = 0; koy_hucre.clear()
	yanan.clear(); hortumlar.clear(); ufolar.clear(); efektler.clear()
	kuraklik_ay = 0; kis_ay = 0; ufo_geldi = false; dogum_sayisi = 0
	son_koy = 0; son_krallik = 0; son_uid = 0
	_kv_kur()
	_canli_sifirla(1024)
	var yukseklik := FastNoiseLite.new()
	yukseklik.seed = th
	yukseklik.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	yukseklik.fractal_octaves = 5
	yukseklik.frequency = 2.2 / g
	var nem := FastNoiseLite.new()
	nem.seed = th + 77
	nem.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	nem.fractal_octaves = 3
	nem.frequency = 3.5 / g
	var isi := FastNoiseLite.new()
	isi.seed = th + 191
	isi.frequency = 2.0 / g
	for yy in y:
		var ky := float(yy) / y
		for xx in g:
			var kx := float(xx) / g
			var kenar: float = maxf(absf(kx - 0.5), absf(ky - 0.5)) * 2.0
			var h: float = yukseklik.get_noise_2d(xx, yy * float(g) / y * 0.62) * 0.5 + 0.5
			h = h * 1.25 - 0.12 - pow(kenar, 3.5) * 0.55
			var m: float = nem.get_noise_2d(xx, yy) * 0.5 + 0.5
			var s: float = 1.0 - absf(ky - 0.5) * 2.0 + isi.get_noise_2d(xx, yy) * 0.18 - maxf(0.0, h - 0.6) * 0.8
			var b := B_OVA
			if h < 0.36:
				b = B_DERIN
			elif h < 0.43:
				b = B_SIG
			elif h < 0.455:
				b = B_KUM
			elif h > 0.80:
				b = B_DAG
			elif s < 0.16:
				b = B_KAR
			elif h > 0.70:
				b = B_TEPE
			elif s > 0.72 and m < 0.40:
				b = B_COL
			elif m > 0.68 and h < 0.52 and s > 0.4:
				b = B_BATAK
			elif m > 0.56:
				b = B_ORMAN
			elif m < 0.38:
				b = B_BOZKIR
			var k := yy * g + xx
			biyom[k] = b
			if b == B_DAG or b == B_TEPE:
				var r := rng.randf()
				if r < 0.012:
					maden[k] = 1
				elif r < 0.045:
					maden[k] = 2
	kita_kirli = true
	_kita_hesapla()
	hepsi_degisti = true
	_kronik("Dünya yaratıldı. (Tohum: %d)" % th, 2)


func _kita_hesapla() -> void:
	_kita_k0 = -1
	kita.fill(0)
	var etiket := 0
	var yigin := PackedInt32Array()
	var n := gen * yuk
	for k0 in n:
		if kita[k0] != 0 or not _kara(biyom[k0]):
			continue
		etiket += 1
		kita[k0] = etiket
		yigin.append(k0)
		while yigin.size() > 0:
			var k := yigin[yigin.size() - 1]
			yigin.resize(yigin.size() - 1)
			var x := k % gen
			if x > 0 and kita[k - 1] == 0 and _kara(biyom[k - 1]):
				kita[k - 1] = etiket; yigin.append(k - 1)
			if x < gen - 1 and kita[k + 1] == 0 and _kara(biyom[k + 1]):
				kita[k + 1] = etiket; yigin.append(k + 1)
			if k >= gen and kita[k - gen] == 0 and _kara(biyom[k - gen]):
				kita[k - gen] = etiket; yigin.append(k - gen)
			if k < n - gen and kita[k + gen] == 0 and _kara(biyom[k + gen]):
				kita[k + gen] = etiket; yigin.append(k + gen)
	kita_kirli = false


## Kıta etiketlerini birkaç aya yayarak yeniden hesaplar (tek seferde ~15–60 ms'lik takılma yapıyordu).
## Bitene kadar eski etiketler kullanılır.
func _kita_adim(butce: int) -> void:
	var n := gen * yuk
	if _kita_k0 < 0:
		_kita_is.resize(n)
		_kita_is.fill(0)
		_kita_yigin.clear()
		_kita_k0 = 0
		_kita_etiket = 0
		kita_kirli = false
	var islem := 0
	while true:
		while _kita_yigin.size() > 0:
			var k := _kita_yigin[_kita_yigin.size() - 1]
			_kita_yigin.resize(_kita_yigin.size() - 1)
			var x := k % gen
			var b := 0
			if x > 0 and _kita_is[k - 1] == 0:
				b = biyom[k - 1]
				if b >= B_KUM and b != B_LAV:
					_kita_is[k - 1] = _kita_etiket; _kita_yigin.append(k - 1)
			if x < gen - 1 and _kita_is[k + 1] == 0:
				b = biyom[k + 1]
				if b >= B_KUM and b != B_LAV:
					_kita_is[k + 1] = _kita_etiket; _kita_yigin.append(k + 1)
			if k >= gen and _kita_is[k - gen] == 0:
				b = biyom[k - gen]
				if b >= B_KUM and b != B_LAV:
					_kita_is[k - gen] = _kita_etiket; _kita_yigin.append(k - gen)
			if k < n - gen and _kita_is[k + gen] == 0:
				b = biyom[k + gen]
				if b >= B_KUM and b != B_LAV:
					_kita_is[k + gen] = _kita_etiket; _kita_yigin.append(k + gen)
			islem += 1
			if islem >= butce:
				return
		while _kita_k0 < n and (_kita_is[_kita_k0] != 0 or biyom[_kita_k0] < B_KUM or biyom[_kita_k0] == B_LAV):
			_kita_k0 += 1
			islem += 1
			if islem >= butce * 3:
				return
		if _kita_k0 >= n:
			kita = _kita_is.duplicate()
			_kita_k0 = -1
			return
		_kita_etiket += 1
		_kita_is[_kita_k0] = _kita_etiket
		_kita_yigin.append(_kita_k0)


## Tek bir karo karaya dönüştü (lav soğudu): komşusunun kıta etiketini alır; tüm haritayı yeniden etiketlemek gerekmez.
## İki ayrı kıtayı birleştiriyorsa tam hesap istenir.
func _kita_kara_oldu(k: int) -> void:
	var etk := 0
	var x := k % gen
	for kom in [k - 1 if x > 0 else -1, k + 1 if x < gen - 1 else -1, k - gen, k + gen]:
		if kom < 0 or kom >= gen * yuk:
			continue
		var e := kita[kom]
		if e == 0:
			continue
		if etk == 0:
			etk = e
		elif etk != e:
			kita_kirli = true
			return
	kita[k] = etk if etk != 0 else 1000000 + k


func _kara(b: int) -> bool:
	return b >= B_KUM and b != B_LAV


func icinde(x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < gen and y < yuk


## Başlangıç kabileleri ve hayvanlar.
func baslangic_canlilari() -> void:
	for ad in ["insan", "insan", "elf", "ork", "cuce", "dev", "goblin", "kertenkele"]:
		var t: Dictionary = turler[tur_id[ad]]
		var k := _yer_bul(-1, -1, 0, 0, t)
		if k < 0:
			continue
		var sayi: int = {"dev": 14, "elf": 22, "cuce": 18}.get(ad, 14)
		for n in sayi:
			var x := k % gen + rng.randi_range(-2, 2)
			var y := k / gen + rng.randi_range(-2, 2)
			if icinde(x, y) and _kara(biyom[y * gen + x]):
				var ci := canli_ekle(t["no"], x + 0.5, y + 0.5, int(t["yetiskin"]) * 12 + rng.randi_range(0, int(t["yetiskin"]) * 6), -1)
				c_cins[ci] = n % 2   # kabilede kadın/erkek dengesi
	var kara_sayisi := 0
	for b in biyom:
		if b >= B_KUM and b != B_LAV:
			kara_sayisi += 1
	for t in turler:
		if t["irk"] or int(t.get("sinir", 0)) == 0:
			continue
		var hedef: int = kara_sayisi * int(t["sinir"]) / 12000
		for n in hedef:
			var k := _rastgele_kara(t)
			if k >= 0:
				canli_ekle(t["no"], k % gen + 0.5, k / gen + 0.5, rng.randi_range(12, int(t["omur"]) * 8), -1)


func _rastgele_kara(t: Dictionary) -> int:
	var by: PackedInt32Array = t["biyom"]
	for deneme in 30:
		var k := rng.randi_range(0, gen * yuk - 1)
		if by.has(biyom[k]) and yapi[k] == 0:
			return k
	return -1


# ============================================================ CANLI DİZİLERİ
func _canli_sifirla(n: int) -> void:
	kap = 0; ust = 0
	bos.clear()
	sayim.fill(0)
	irk_nufus = 0
	_boyutla(n)


func _boyutla(n: int) -> void:
	kap = n
	for a in [c_var, c_tur, c_cins, c_durum, c_x, c_y, c_ox, c_oy, c_hx, c_hy, c_yas, c_can, c_sans, c_koy, c_uid, c_anne, c_baba, c_oldurme, c_cocuk, c_ad, s_guc, s_hiz, s_zeka, s_is, s_dogur, s_omur, s_cesaret, s_canmax, s_lider, s_vurus, s_okcu, s_kacin, c_bit]:
		a.resize(n)
	c_ozl.resize(n * MAX_OZL)
	c_tok.resize(n)


func _yuva_ac() -> int:
	if bos.size() > 0:
		var i := bos[bos.size() - 1]
		bos.resize(bos.size() - 1)
		return i
	if ust >= kap:
		_boyutla(kap * 2)
	ust += 1
	return ust - 1


## Yeni canlı ekler. secili: verilecek özellik id'leri (tanrı fırçası).
func canli_ekle(tur: int, x: float, y: float, yas_ay: int, koy_id: int, anne := -1, baba := -1, secili: Array = []) -> int:
	var t: Dictionary = turler[tur]
	var i := _yuva_ac()
	son_uid += 1
	c_var[i] = 1
	c_tur[i] = tur
	c_cins[i] = rng.randi_range(0, 1)
	c_durum[i] = D_GEZ
	c_x[i] = x; c_y[i] = y; c_ox[i] = x; c_oy[i] = y
	c_hx[i] = int(x); c_hy[i] = int(y)
	c_yas[i] = yas_ay
	c_sans[i] = rng.randf_range(0.85, 1.15)
	c_koy[i] = koy_id
	c_uid[i] = son_uid
	c_anne[i] = c_uid[anne] if anne >= 0 else 0
	c_baba[i] = c_uid[baba] if baba >= 0 else 0
	c_oldurme[i] = 0
	c_cocuk[i] = 0
	c_tok[i] = 3
	c_ad[i] = _isim(t) if t["irk"] else ""
	for n in MAX_OZL:
		c_ozl[i * MAX_OZL + n] = 0
	# kalıtım
	if anne >= 0:
		_kalitim(i, anne)
	if baba >= 0:
		_kalitim(i, baba)
	if t["irk"]:
		var eg: Dictionary = t["egilim"]
		var carp := 0.5 if anne >= 0 else 1.0
		for ad in eg:
			if rng.randf() < float(eg[ad]) * carp:
				_ozl_yaz(i, ozl_id[ad])
		if anne < 0:
			for n in rng.randi_range(0, 2):
				_ozl_yaz(i, havuz[rng.randi_range(0, havuz.size() - 1)])
		else:
			var mut := 0.03
			if ozl_var(anne, oz_mutant) or (baba >= 0 and ozl_var(baba, oz_mutant)):
				mut = 0.25
			if rng.randf() < mut:
				_ozl_yaz(i, havuz[rng.randi_range(0, havuz.size() - 1)])
			if rng.randf() < 0.0015:
				_ozl_yaz(i, oz_efsane[rng.randi_range(0, oz_efsane.size() - 1)])
	for id in secili:
		_ozl_yaz(i, int(id))
	stat_hesapla(i)
	c_can[i] = s_canmax[i]
	sayim[tur] += 1
	if t["irk"]:
		irk_nufus += 1
		if koy_id >= 0 and koyler.has(koy_id):
			koyler[koy_id]["nufus"] += 1
	if icinde(int(x), int(y)):
		yer[int(y) * gen + int(x)] = i + 1
	return i


func _kalitim(i: int, ebeveyn: int) -> void:
	var olasilik := 0.30
	if ozl_var(ebeveyn, oz_guclu_kal):
		olasilik = 0.60
	for n in MAX_OZL:
		var id := c_ozl[ebeveyn * MAX_OZL + n]
		if id != 0 and rng.randf() < olasilik:
			_ozl_yaz(i, id)


func ozl_var(i: int, id: int) -> bool:
	var b := i * MAX_OZL
	return c_ozl[b] == id or c_ozl[b + 1] == id or c_ozl[b + 2] == id or c_ozl[b + 3] == id or c_ozl[b + 4] == id


func _ozl_yaz(i: int, id: int) -> bool:
	var b := i * MAX_OZL
	var bosluk := -1
	var zit: PackedInt32Array = ozellikler[id]["zit_id"]
	for n in MAX_OZL:
		var m := c_ozl[b + n]
		if m == id:
			return false
		if m == 0:
			if bosluk < 0:
				bosluk = n
		elif zit.has(m):
			return false
	if bosluk < 0:
		return false
	c_ozl[b + bosluk] = id
	return true


## Tanrı paneli: özellik ekle. Başarısızsa nedenini döndürür ("" = oldu).
func ozellik_ekle(i: int, id: int) -> String:
	if ozl_var(i, id):
		return "Bu özellik zaten var."
	var zit: PackedInt32Array = ozellikler[id]["zit_id"]
	var dolu := 0
	for n in MAX_OZL:
		var m := c_ozl[i * MAX_OZL + n]
		if m != 0:
			dolu += 1
			if zit.has(m):
				return "%s ile birlikte olamaz." % ozellikler[m]["ad"]
	if dolu >= MAX_OZL:
		return "En fazla %d özellik olabilir." % MAX_OZL
	_ozl_yaz(i, id)
	stat_hesapla(i)
	return ""


func ozellik_sil(i: int, id: int) -> void:
	for n in MAX_OZL:
		if c_ozl[i * MAX_OZL + n] == id:
			c_ozl[i * MAX_OZL + n] = 0
	stat_hesapla(i)


func stat_hesapla(i: int) -> void:
	var t: Dictionary = turler[c_tur[i]]
	var g := 0.0; var cn := 0.0; var hz := 0.0; var zk := 0.0; var isg := 0.0; var dg := 0.0; var om := 0.0; var cs := 0.0
	for n in MAX_OZL:
		var id := c_ozl[i * MAX_OZL + n]
		if id == 0:
			continue
		var st: PackedFloat32Array = ozl_stat[id]
		g += st[0]; cn += st[1]; hz += st[2]; zk += st[3]; isg += st[4]; dg += st[5]; om += st[6]; cs += st[7]
	s_guc[i] = float(t["guc"]) * maxf(0.2, 1.0 + g / 100.0)
	s_canmax[i] = float(t["can"]) * maxf(0.3, 1.0 + cn / 100.0)
	s_hiz[i] = float(t["hiz"]) * maxf(0.3, 1.0 + hz / 100.0)
	s_zeka[i] = float(t["zeka"]) * maxf(0.2, 1.0 + zk / 100.0)
	s_is[i] = maxf(0.2, 1.0 + isg / 100.0)
	s_dogur[i] = maxf(0.0, 1.0 + dg / 100.0)
	s_omur[i] = float(t["omur"]) * 12.0 * maxf(0.3, 1.0 + om / 100.0) * c_sans[i]
	s_cesaret[i] = cs / 100.0
	# özellik etkileri tek geçişte toplanır (savaş, önsezi, ihanet, şifa)
	var lider := 0.0; var vurus := 0.0; var okcu := 0.0; var kacin := 0.0
	var bit := 0
	for n in MAX_OZL:
		var id2 := c_ozl[i * MAX_OZL + n]
		if id2 == 0:
			continue
		var e: Dictionary = ozellikler[id2]["etkiler"]
		lider += float(e.get("liderlik", 0)) + float(e.get("kral_olma", 0))
		vurus += float(e.get("saldiri", 0)) + float(e.get("yakin_dovus", 0))
		okcu += float(e.get("okculuk", 0))
		kacin += float(e.get("kacinma", 0))
		if e.has("afet_onsezi"):
			bit |= 1
		if float(e.get("darbe", 0)) > 0.0 or float(e.get("ihanet", 0)) >= 40.0:
			bit |= 2
		if float(e.get("sifa", 0)) > 0.0:
			bit |= 4
	s_lider[i] = lider
	s_vurus[i] = maxf(0.4, 1.0 + vurus / 100.0)
	s_okcu[i] = okcu / 100.0
	s_kacin[i] = clampf(kacin / 100.0, 0.0, 0.6)
	c_bit[i] = bit
	if c_can[i] > s_canmax[i]:
		c_can[i] = s_canmax[i]


## Bir canlının özelliklerinden gelen toplam etki (ör. "savas_istegi").
func etki(i: int, anahtar: String) -> float:
	var top := 0.0
	for n in MAX_OZL:
		var id := c_ozl[i * MAX_OZL + n]
		if id != 0:
			top += float(ozellikler[id]["etkiler"].get(anahtar, 0))
	return top


func _isim(t: Dictionary) -> String:
	var h: Array = t["hece"]
	var s := ""
	for n in rng.randi_range(2, 3):
		s += h[rng.randi_range(0, h.size() - 1)]
	return s.capitalize()


func oldur(i: int, sebep: String) -> void:
	if c_var[i] == 0:
		return
	c_var[i] = 0
	bos.append(i)
	var tur := c_tur[i]
	sayim[tur] -= 1
	olumler[sebep] = int(olumler.get(sebep, 0)) + 1
	var to: Dictionary = irk_olum.get(tur, {})
	if to.is_empty():
		irk_olum[tur] = to
	to[sebep] = int(to.get(sebep, 0)) + 1
	if t_irk[tur]:
		irk_nufus -= 1
		var v = koyler.get(c_koy[i])
		if v != null:
			v["nufus"] -= 1
			var kr = kralliklar.get(v["krallik"])
			if kr != null and sebep == "savaş":
				kr["kayip"] = int(kr.get("kayip", 0)) + 1
			if kr != null and kr["kral_uid"] == c_uid[i]:
				_kronik("%s hükümdarı %s öldü (%s, %d yaşında)." % [kr["ad"], c_ad[i], sebep, c_yas[i] / 12], 2)
				kr["kral_uid"] = 0
				return
		if c_oldurme[i] >= 8 or ozl_var(i, oz_kahraman) or ozl_var(i, oz_dahi):
			_kronik("Ünlü %s %s öldü (%s, %d yaşında)." % [turler[tur]["ad"], c_ad[i], sebep, c_yas[i] / 12], 1)


# ============================================================ ANA DÖNGÜ
func tick() -> void:
	if dilim_no < DILIM:
		dilim_ilerlet(DILIM)
	ay += 1
	var adim := hareket_adim
	var a := ay
	var t0 := Time.get_ticks_usec()
	# Her canlı yılda bir "yıllık" işlenir: (i + ay) % 12 == 0 olanlar. Adımlı döngü, tüm diziyi taramaktan çok daha hızlı.
	for i in range((12 - a % 12) % 12, ust, 12):
		if c_var[i] == 1:
			_yillik(i)
	var t1 := Time.get_ticks_usec()
	# Hızlı modda (adim > 1) her canlı adim ayda bir, adim kat yol alır (toplu hareket).
	# Yavaş hızda (yayik) hareket bu ayın içine dilim dilim yayılır: ekran her karede `dilim_ilerlet` çağırır.
	if yayik and adim == 1:
		dilim_no = 0
	else:
		for i in range((adim - a % adim) % adim, ust, adim):
			if c_var[i] == 1:
				_hareket(i, adim)
	var t2 := Time.get_ticks_usec()
	for id in koyler.keys():
		if (id + a) % 12 == 0 and koyler.has(id):
			_koy_yillik(koyler[id])
	var t3 := Time.get_ticks_usec()
	for id in kralliklar.keys():
		if (id * 5 + a) % 12 == 0 and kralliklar.has(id):
			_krallik_yillik(kralliklar[id])
	var t4 := Time.get_ticks_usec()
	_afet_tick()
	_rastgele_karolar()
	if _kita_k0 >= 0 or (kita_kirli and a % 12 == 0):
		_kita_adim(maxi(3000, gen * yuk / 14))
	if a % 12 == 0:
		_ekosistem_yillik()
	if a % 60 == 0:
		_gecmis_kaydet()
		if kronik.size() > 3000:
			kronik = kronik.slice(kronik.size() - 2500)
	for n in range(efektler.size() - 1, -1, -1):
		efektler[n][3] -= 1
		if efektler[n][3] <= 0:
			efektler.remove_at(n)
	var t5 := Time.get_ticks_usec()
	olc_us[0] += t1 - t0; olc_us[1] += t2 - t1; olc_us[2] += t3 - t2; olc_us[3] += t4 - t3; olc_us[4] += t5 - t4
	if t5 - t0 > olc_us[5]:
		olc_us[5] = t5 - t0


## Yayık hareket: bu ayın hareketinden `hedef`. dilime kadar olanları işler (her canlı ayda bir kez, i % DILIM sırasıyla).
## Böylece 10 bin canlının hareketi tek karede (takılma) değil, ay boyunca karelere bölünerek yapılır.
func dilim_ilerlet(hedef: int) -> void:
	if hedef > DILIM:
		hedef = DILIM
	var t0 := Time.get_ticks_usec()
	while dilim_no < hedef:
		for i in range(dilim_no, ust, DILIM):
			if c_var[i] == 1:
				_hareket(i, 1)
		dilim_no += 1
	olc_us[1] += Time.get_ticks_usec() - t0


## 5 yılda bir tür sayılarını saklar (nüfus grafiği). Çok uzarsa seyreltilir.
func _gecmis_kaydet() -> void:
	nufus_gecmis.append([yil(), sayim.duplicate()])
	if nufus_gecmis.size() > 400:
		var yeni: Array = []
		for n in nufus_gecmis.size():
			if n % 2 == 0 or n == nufus_gecmis.size() - 1:
				yeni.append(nufus_gecmis[n])
		nufus_gecmis = yeni


## Taşıma kapasitesi: otoburlar için boş otlak/orman, avcılar için av miktarı belirler (besin zinciri).
func _kapasite_guncelle() -> void:
	var ot := 0
	var ornek := 1500
	var n := gen * yuk
	for m in ornek:
		var k := rng.randi_range(0, n - 1)
		var b := biyom[k]
		if yapi[k] == 0 and (b == B_OVA or b == B_BOZKIR or b == B_ORMAN or b == B_TEPE):
			ot += 1
	otobur_kap = int(float(ot) / ornek * n / 16.0)
	var top_sinir := 0
	for t in turler:
		if t.get("otobur", false):
			top_sinir += int(t.get("sinir", 0))
	var otobur := 0
	for t in turler:
		if t.get("otobur", false):
			t_kap[t["no"]] = maxi(4, otobur_kap * int(t.get("sinir", 0)) / maxi(1, top_sinir))
			otobur += sayim[t["no"]]
	for t in turler:
		if t.get("avci", false) and float(t["dogur"]) > 0.0 and not t["irk"]:
			# bir kurt ~18 otoburla, bir ayı ~45 otoburla geçinir
			var bolen := 18.0 if int(t.get("sinir", 0)) >= 8 else 45.0
			t_kap[t["no"]] = maxi(2, int(otobur / bolen))


## Ekosistem raporu (istatistik paneli): otobur/avcı sayıları ve kapasiteler.
func ekosistem_durumu() -> Dictionary:
	var otobur := 0
	var avci := 0
	var avci_kap := 0
	for t in turler:
		if t["irk"]:
			continue
		if t.get("otobur", false):
			otobur += sayim[t["no"]]
		elif t.get("avci", false) and float(t["dogur"]) > 0.0:
			avci += sayim[t["no"]]
			avci_kap += t_kap[t["no"]]
	return {"otobur": otobur, "otobur_kap": otobur_kap, "avci": avci, "avci_kap": avci_kap}


## Yok olmaya yüz tutan yabani hayvan türlerine dışarıdan küçük sürüler göç eder (ekosistem kendini toparlar).
func _ekosistem_yillik() -> void:
	_kapasite_guncelle()
	for t in turler:
		if t["irk"] or int(t.get("sinir", 0)) == 0 or float(t["dogur"]) <= 0.0:
			continue
		var tur: int = t["no"]
		var sinir := _hayvan_siniri(tur)
		if sayim[tur] < maxi(2, sinir / 10) and rng.randf() < (0.15 if t_avci[tur] == 1 else 0.08):
			var k := _rastgele_kara(t)
			if k >= 0:
				for n in 4:
					var ci := canli_ekle(tur, k % gen + rng.randf_range(0.2, 0.8), k / gen + rng.randf_range(0.2, 0.8), int(t["yetiskin"]) * 12 + 12, -1)
					c_cins[ci] = n % 2


func yil() -> int:
	return ay / 12 + 1


## Kuzey kuşağı ile kar/dağ karoları soğuk bölgedir (kara kış burada öldürür).
func soguk_bolge(x: int, y: int) -> bool:
	if y < yuk * 0.28:
		return true
	if not icinde(x, y):
		return false
	var b := biyom[y * gen + x]
	return b == B_KAR or b == B_DAG


## 0 köy, 1 kasaba, 2 şehir, 3 büyük şehir
func kademe(v: Dictionary) -> int:
	return int(v.get("kademe", 0))


## Türkçe ünlü uyumu: iyelik ekli ada yönelme eki ("Krallığı'na", "Çetesi'ne", "Sürüsü'ne").
static func yonelme(ad: String) -> String:
	for n in range(ad.length() - 1, -1, -1):
		var ch := ad[n]
		if ch in "aıouAIOU":
			return ad + "'na"
		if ch in "eiöüEİÖÜ":
			return ad + "'ne"
	return ad + "'na"


## Belirtme eki, özel ad için ("Permar'ı", "Glimvex'i", "Zog'u", "Mür'ü").
static func belirtme(ad: String) -> String:
	var ek := "i"
	var son_unlu := ""
	for n in range(ad.length() - 1, -1, -1):
		var ch := ad[n].to_lower()
		if ch in "aıoueiöü":
			son_unlu = ch
			break
	if son_unlu in "aı" and son_unlu != "":
		ek = "ı"
	elif son_unlu in "ou" and son_unlu != "":
		ek = "u"
	elif son_unlu in "öü" and son_unlu != "":
		ek = "ü"
	var sonu := ad[ad.length() - 1].to_lower() if ad.length() > 0 else ""
	return ad + "'" + ("y" if sonu != "" and sonu in "aıoueiöü" else "") + ek


func tarih_yazi() -> String:
	return "Yıl %d, %d. ay (%s)" % [yil(), ay % 12 + 1, MEVSIM_AD[ay % 12]]


## Kroniğe olay yazar. x,y verilirse oyuncu olaya "git" diyebilir.
func _kronik(metin: String, onem := 1, x := -1, y := -1) -> void:
	if x >= 0:
		kronik.append([ay, metin, onem, x, y])
	else:
		kronik.append([ay, metin, onem])


# ============================================================ CANLI: YILLIK
func _yillik(i: int) -> void:
	c_yas[i] += 12
	var tur := c_tur[i]
	var yas := c_yas[i]
	if yas > s_omur[i] and rng.randf() < 0.3:
		oldur(i, "yaşlılık")
		return
	var cm := s_canmax[i]
	if c_can[i] < cm:
		c_can[i] = minf(cm, c_can[i] + cm * 0.25)
	# kara kış yalnızca soğuk bölgelerde (kuzey kuşağı, kar ve dağ) öldürür; ılık güney yalnızca kıtlık çeker
	if kis_ay > 0 and t_soguga[tur] == 0 and soguk_bolge(int(c_x[i]), int(c_y[i])) and rng.randf() < 0.08 and not ozl_var(i, oz_soguk):
		oldur(i, "soğuk")
		return
	var yetiskin: bool = yas >= t_yetiskin[tur]
	if t_irk[tur] == 0:
		_hayvan_yillik(i, turler[tur], yetiskin)
		return
	var vid := c_koy[i]
	var bay: int = kv_bayrak[vid] if vid >= 0 and vid < kv_bayrak.size() else 0
	if bay == 0:
		c_koy[i] = -1
		if yetiskin:
			_koy_bul_veya_kur(i, turler[tur])
		else:
			# köyü yıkılan çocuklar yakındaki soydaş bir köye sığınır
			var sv = koy_yakin(int(c_x[i]), int(c_y[i]), 20, tur)
			if sv != null:
				c_koy[i] = sv["id"]
				sv["nufus"] += 1
				c_hx[i] = sv["x"]; c_hy[i] = sv["y"]
				c_durum[i] = D_GOC
		return
	# kıtlık ve salgın
	if bay & 1 and rng.randf() < 0.22:
		oldur(i, "açlık")
		return
	if bay & 2:
		var direnc := clampf(etki(i, "hastalik_direnci") / 100.0, -0.5, 0.95)
		# köyde şifacı varsa salgın daha az öldürür
		if rng.randf() < (0.11 if kv_sifa[vid] > ay - 14 else 0.20) * (1.0 - direnc):
			oldur(i, "salgın")
			return
	if c_durum[i] == D_KAC:
		c_durum[i] = D_GEZ
	if not yetiskin:
		return
	# köye katkı (sözlük yerine dizilere)
	kv_is[vid] += s_is[i] * t_uretim[tur]
	kv_zeka[vid] += s_zeka[i]
	kv_yet[vid] += 1
	var puan := s_zeka[i] / 100.0 + s_lider[i] / 40.0 + rng.randf() * 0.5
	if puan > kv_puan[vid]:
		kv_puan[vid] = puan
		kv_aday[vid] = i
	if c_cins[i] == 1:
		kv_erkek[vid] = i
	var bit := c_bit[i]
	if bit != 0:
		if bit & 1:
			kv_kahin[vid] = ay
		if bit & 2:
			kv_hain[vid] = i
		if bit & 4:
			kv_sifa[vid] = ay
	# göç
	if bay & 8:
		var v: Dictionary = koyler[vid]
		if v["goc_kalan"] > 0 and koyler.has(v["goc_hedef"]):
			var hv: Dictionary = koyler[v["goc_hedef"]]
			v["goc_kalan"] -= 1
			v["nufus"] -= 1
			hv["nufus"] += 1
			c_koy[i] = hv["id"]
			c_durum[i] = D_GOC
			c_hx[i] = hv["x"]; c_hy[i] = hv["y"]
			if v["goc_kalan"] <= 0:
				kv_bayrak[vid] &= ~8
			return
		kv_bayrak[vid] &= ~8
	# askerlik
	if bay & 4 and yas < s_omur[i] * 0.75:
		var oran := 3 if bay & 32 else 2
		if c_uid[i] % 5 < oran and c_durum[i] != D_ASKER:
			c_durum[i] = D_ASKER
			_yeni_hedef(i)
	elif c_durum[i] == D_ASKER:
		c_durum[i] = D_GEZ
	# doğum
	if c_cins[i] == 0 and not (bay & 1) and yas < s_omur[i] * 0.65 and (nufus_siniri <= 0 or irk_nufus < nufus_siniri):
		var baba: int = kv_erkek[vid]
		if baba >= 0 and c_var[baba] == 1 and c_koy[baba] == vid:
			var p: float = t_dogur[tur] * s_dogur[i] * kv_bolluk[vid] * (0.5 + 0.5 * s_dogur[baba])
			if rng.randf() < p:
				var v: Dictionary = koyler[vid]
				if v["nufus"] < v["kapasite"]:
					_dogum(i, baba, v)
					if rng.randf() < etki(i, "ikiz_sansi") / 100.0:
						_dogum(i, baba, v)
	# hayatla kazanılan özellikler
	if c_oldurme[i] >= 3 and rng.randf() < 0.3:
		if _ozl_yaz(i, oz_cesur):
			stat_hesapla(i)
	if yas > s_omur[i] * 0.6 and s_zeka[i] > 110 and rng.randf() < 0.02:
		if _ozl_yaz(i, oz_bilge):
			stat_hesapla(i)
	# avcılık: ambarda bir yıllık yiyecek yoksa avlanılır
	if bay & 16 and rng.randf() < 0.6:
		var j := _yakin_av(i, 2)
		if j >= 0 and t_otobur[c_tur[j]] == 1 and sayim[c_tur[j]] > _hayvan_siniri(c_tur[j]) / 6:
			koyler[vid]["yemek"] += float(turler[c_tur[j]]["et"]) * (1.0 + etki(i, "avcilik") / 100.0)
			oldur(j, "avlandı")


func _dogum(anne: int, baba: int, v: Dictionary) -> void:
	canli_ekle(c_tur[anne], c_x[anne], c_y[anne], 0, v["id"], anne, baba)
	c_cocuk[anne] += 1
	c_cocuk[baba] += 1
	dogum_sayisi += 1


func _hayvan_siniri(tur: int) -> int:
	if t_kap[tur] > 0:
		return t_kap[tur]
	return gen * yuk * int(turler[tur].get("sinir", 0)) / 20000


func _hayvan_yillik(i: int, t: Dictionary, yetiskin: bool) -> void:
	var tur := c_tur[i]
	var kap := maxi(1, _hayvan_siniri(tur))
	var doluluk := float(sayim[tur]) / kap
	if t_otobur[tur] == 1:
		# kalabalık sürü otlağı tüketir: kapasitenin üstünde açlık ve aşırı otlatma (ova → bozkır → çöl)
		if doluluk > 1.15:
			if rng.randf() < 0.25:
				oldur(i, "açlık")
				return
			var k := int(c_y[i]) * gen + int(c_x[i])
			if yapi[k] == 0 and rng.randf() < 0.12:
				if biyom[k] == B_OVA:
					biyom[k] = B_BOZKIR; degisen.append(k)
				elif biyom[k] == B_BOZKIR and rng.randf() < 0.3:
					biyom[k] = B_COL; degisen.append(k)
		if yetiskin and c_cins[i] == 0 and rng.randf() < float(t["dogur"]) * clampf(1.35 - doluluk, 0.0, 1.0):
			canli_ekle(tur, c_x[i], c_y[i], 0, -1, i, -1)
	elif float(t["dogur"]) > 0.0:
		# avcı: av yedikçe tok; aç kalan ölür, tok olan yavrular
		if c_tok[i] == 0:
			if rng.randf() < 0.15:
				oldur(i, "açlık")
				return
		else:
			c_tok[i] -= 1
		if yetiskin and c_cins[i] == 0 and c_tok[i] >= 1 and rng.randf() < float(t["dogur"]) * clampf(1.2 - doluluk, 0.0, 1.0):
			canli_ekle(tur, c_x[i], c_y[i], 0, -1, i, -1)
	if t_avci[tur] == 1 and rng.randf() < 0.8:
		var j := _yakin_av(i, 5)
		if j >= 0 and _dusman(i, j):
			# av: birkaç ısırık (av kaçamazsa ölür)
			for n in 3:
				if c_var[j] == 0 or c_var[i] == 0:
					break
				_vur(i, j)
	if t.get("atesli", false) and rng.randf() < 0.5:
		# ejderha: en yakın köye uç ve yak
		var v = koy_yakin(int(c_x[i]), int(c_y[i]), 9999)
		if v != null:
			c_hx[i] = v["x"] + rng.randi_range(-3, 3)
			c_hy[i] = v["y"] + rng.randi_range(-3, 3)
			if absf(c_x[i] - v["x"]) < 8 and absf(c_y[i] - v["y"]) < 8:
				for n in 4:
					yangin_baslat(int(c_x[i]) + rng.randi_range(-3, 3), int(c_y[i]) + rng.randi_range(-3, 3))
				if rng.randf() < 0.3:
					_kronik("Bir ejderha %s köyünü ateşe verdi!" % v["ad"], 2, v["x"], v["y"])


## Avcı için yakındaki otobur (yoksa herhangi bir canlı).
func _yakin_av(i: int, r: int) -> int:
	var x0 := int(c_x[i])
	var y0 := int(c_y[i])
	var yedek := -1
	for oy in range(-r, r + 1):
		var yy := y0 + oy
		if yy < 0 or yy >= yuk:
			continue
		for ox in range(-r, r + 1):
			var xx := x0 + ox
			if xx < 0 or xx >= gen:
				continue
			var j := yer[yy * gen + xx] - 1
			if j >= 0 and j != i and c_var[j] == 1 and c_tur[j] != c_tur[i] and absf(c_x[j] - c_x[i]) <= r + 1 and absf(c_y[j] - c_y[i]) <= r + 1:
				if t_otobur[c_tur[j]] == 1:
					return j
				yedek = j
	return yedek


func _yakin_canli(i: int, r: int) -> int:
	var x0 := int(c_x[i])
	var y0 := int(c_y[i])
	for oy in range(-r, r + 1):
		var yy := y0 + oy
		if yy < 0 or yy >= yuk:
			continue
		for ox in range(-r, r + 1):
			var xx := x0 + ox
			if xx < 0 or xx >= gen:
				continue
			var j := yer[yy * gen + xx] - 1
			if j >= 0 and j != i and c_var[j] == 1 and absf(c_x[j] - c_x[i]) <= r + 1 and absf(c_y[j] - c_y[i]) <= r + 1:
				return j
	return -1


## Menzil içindeki ilk düşman ırk üyesi (okçu ve tüfekliler için).
func _yakin_dusman(i: int, r: int) -> int:
	var x0 := int(c_x[i])
	var y0 := int(c_y[i])
	var ki := _krallik_no(i)
	if ki < 0:
		return -1
	var kri = kralliklar.get(ki)
	if kri == null:
		return -1
	var savas: Dictionary = kri["savas"]
	if savas.is_empty():
		return -1
	# hız: karolar birer atlanarak taranır (kaydırma her çağrıda değişir); kalabalık cephede yine hedef bulunur
	var kay := (i + ay / 2) & 1
	for oy in range(-r + kay, r + 1, 2):
		var yy := y0 + oy
		if yy < 0 or yy >= yuk:
			continue
		for ox in range(-r + kay, r + 1, 2):
			var xx := x0 + ox
			if xx < 0 or xx >= gen:
				continue
			var j := yer[yy * gen + xx] - 1
			if j >= 0 and j != i and c_var[j] == 1 and t_irk[c_tur[j]] == 1 and absf(c_x[j] - c_x[i]) <= r + 1 and absf(c_y[j] - c_y[i]) <= r + 1:
				var kj := _krallik_no(j)
				if kj >= 0 and savas.has(kj):
					return j
	return -1


# ============================================================ CANLI: HAREKET
func _hareket(i: int, carp: int) -> void:
	var x := c_x[i]
	var y := c_y[i]
	c_ox[i] = x
	c_oy[i] = y
	var dx := c_hx[i] + 0.5 - x
	var dy := c_hy[i] + 0.5 - y
	var d2 := dx * dx + dy * dy
	if d2 < 0.36:
		_yeni_hedef(i)
		return
	var tur := c_tur[i]
	var adim := s_hiz[i] * 1.1 * carp
	var d := sqrt(d2)
	if adim > d:
		adim = d
	var nx := x + dx / d * adim
	var ny := y + dy / d * adim
	var k := int(ny) * gen + int(nx)
	var b := biyom[k]
	if t_ucan[tur] == 0:
		if b <= B_SIG or b == B_LAV:
			# kaymayı dene
			var k2 := int(y) * gen + int(nx)
			var k3 := int(ny) * gen + int(x)
			if biyom[k2] > B_SIG and biyom[k2] != B_LAV:
				ny = y; k = k2
			elif biyom[k3] > B_SIG and biyom[k3] != B_LAV:
				nx = x; k = k3
			else:
				_yeni_hedef(i)
				return
		elif b == B_DAG or b == B_BATAK or sel[k] > 0:
			nx = x + (nx - x) * 0.6
			ny = y + (ny - y) * 0.6
			k = int(ny) * gen + int(nx)
	c_x[i] = nx
	c_y[i] = ny
	yer[k] = i + 1
	if ates[k] > 0:
		c_can[i] -= 25.0 * (1.0 - clampf(etki(i, "ates_direnci") / 100.0, 0.0, 0.9))
		if c_can[i] <= 0.0 and not turler[tur].get("atesli", false):
			oldur(i, "yangın")
			return
	if (c_durum[i] == D_ASKER or t_avci[tur] == 1) and (i + ay) % 2 == 0:
		if t_irk[tur] == 0:
			var j := _yakin_av(i, 2)
			if j >= 0 and _dusman(i, j):
				_vur(i, j)
		else:
			var j := _yakin_canli(i, 2)
			if j >= 0 and _dusman(i, j):
				_vur(i, j)
			elif (i + ay) % 4 == 0 or hareket_adim > 2:
				# okçu, tüfekli ve lazerli askerler uzaktan vurur (yakın dövüşün yarı sıklığında)
				var br := birim(i)
				if br > 0:
					j = _yakin_dusman(i, 4 if br == 1 else 5)
					if j >= 0:
						_vur(i, j, br)


func _yeni_hedef(i: int) -> void:
	var x0 := int(c_x[i])
	var y0 := int(c_y[i])
	var tur := c_tur[i]
	var cx := x0
	var cy := y0
	var r := 5
	if t_avci[tur] == 1 and c_tok[i] <= 1 and t_irk[tur] == 0:
		# aç avcı sürü izi sürer: yakındaki bir otobura doğru yürür
		r = 10
		for deneme in 6:
			var j := rng.randi_range(0, ust - 1)
			if c_var[j] == 1 and t_otobur[c_tur[j]] == 1 and absf(c_x[j] - x0) < 40 and absf(c_y[j] - y0) < 40:
				cx = int(c_x[j]); cy = int(c_y[j]); r = 2
				break
	if t_irk[tur] == 1:
		var v = koyler.get(c_koy[i])
		if v != null:
			cx = v["x"]; cy = v["y"]; r = v["yaricap"]
			if c_durum[i] == D_ASKER:
				var hv = koyler.get(v["hedef"])
				if hv != null:
					cx = hv["x"]; cy = hv["y"]; r = 3
					if absi(x0 - cx) <= 3 and absi(y0 - cy) <= 3:
						_kusatma(i, v, hv)
			elif c_durum[i] == D_GOC:
				if absi(x0 - cx) <= 2 and absi(y0 - cy) <= 2:
					c_durum[i] = D_GEZ
				else:
					r = 1
	for deneme in 4:
		var hx := cx + rng.randi_range(-r, r)
		var hy := cy + rng.randi_range(-r, r)
		if hx < 0 or hy < 0 or hx >= gen or hy >= yuk:
			continue
		var b := biyom[hy * gen + hx]
		if t_ucan[tur] == 1 or (b > B_SIG and b != B_LAV):
			c_hx[i] = hx
			c_hy[i] = hy
			return
	c_hx[i] = cx
	c_hy[i] = cy


# ============================================================ SAVAŞ
func _krallik_no(i: int) -> int:
	var v = koyler.get(c_koy[i])
	return v["krallik"] if v != null else -1


func _dusman(i: int, j: int) -> bool:
	var ti := c_tur[i]
	var tj := c_tur[j]
	if t_irk[ti] == 0:
		if ti == tj:
			return false
		if turler[ti].get("atesli", false):
			return true
		return t_otobur[tj] == 1 or (t_irk[tj] == 1 and rng.randf() < 0.3)
	if t_irk[tj] == 0:
		return t_avci[tj] == 1
	var ki := _krallik_no(i)
	var kj := _krallik_no(j)
	if ki < 0 or kj < 0 or ki == kj:
		return false
	var kri = kralliklar.get(ki)
	return kri != null and kri["savas"].has(kj)


func _silah(i: int) -> float:
	var v = koyler.get(c_koy[i])
	if v == null:
		return 1.0
	return v["silah"]


func _vur(i: int, j: int, uzak := 0) -> void:
	var irk_i := t_irk[c_tur[i]] == 1
	var irk_j := t_irk[c_tur[j]] == 1
	# sıyrılma: çevik canlı darbeden kaçar
	if s_kacin[j] > 0.0 and rng.randf() < s_kacin[j]:
		return
	var hasar := s_guc[i] * _silah(i) * rng.randf_range(0.6, 1.4)
	if uzak > 0:
		# menzilli atış: okçuluk hasarı artırır; karşılık yok
		hasar *= 0.55 + s_okcu[i] + (0.25 if uzak >= 2 else 0.0)
		if uzak < 3:
			hasar *= t_zirh[c_tur[j]]   # cüce zırhı ve dev derisi oku/mermiyi keser (lazeri kesmez)
		_efekt([11 + uzak, c_x[i], c_y[i], 2, c_x[j], c_y[j]])
	else:
		hasar *= s_vurus[i]
		if irk_i and irk_j:
			_efekt([16, (c_x[i] + c_x[j]) * 0.5, (c_y[i] + c_y[j]) * 0.5, 2])
		else:
			_efekt([0, c_x[j], c_y[j], 2])
	# ev arazisi üstünlüğü: savunan, ırkının sevdiği arazideyse (elf ormanda, cüce dağda) daha az hasar alır
	if irk_j:
		var kj := int(c_y[j]) * gen + int(c_x[j])
		if kj >= 0 and kj < biyom.size() and (turler[c_tur[j]]["biyom"] as PackedInt32Array).has(biyom[kj]):
			hasar *= 0.75
	c_can[j] -= hasar
	if c_can[j] <= 0.0:
		var savasla: bool = irk_j and irk_i
		if savasla:
			_skor_ekle(i, j, 1)
			_efekt([17, c_x[j], c_y[j], 4])
		elif t_avci[c_tur[i]] == 1 and not irk_i:
			c_tok[i] = mini(8, c_tok[i] + 4)
		oldur(j, "savaş" if savasla else "saldırı")
		c_oldurme[i] += 1
		c_can[i] = minf(s_canmax[i], c_can[i] + s_canmax[i] * 0.1)
		return
	if uzak > 0:
		# vurulan asker saldırgana döner ya da (korkaksa) kaçar
		if irk_j and c_can[j] < s_canmax[j] * (0.30 - s_cesaret[j] * 0.5):
			c_durum[j] = D_KAC
			_yeni_hedef(j)
		return
	# karşılık
	c_can[i] -= s_guc[j] * _silah(j) * s_vurus[j] * rng.randf_range(0.3, 1.0)
	if c_can[i] <= 0.0:
		var savasla2: bool = irk_i and irk_j
		if savasla2:
			_efekt([17, c_x[i], c_y[i], 4])
		oldur(i, "savaş" if savasla2 else "saldırı")
		c_oldurme[j] += 1
		return
	if irk_i and c_can[i] < s_canmax[i] * (0.30 - s_cesaret[i] * 0.5):
		c_durum[i] = D_KAC
		_yeni_hedef(i)


## Efekt ekler (ekranda görünür; çok hızlı oyunda liste şişmesin diye sınırlı).
func _efekt(e: Array) -> void:
	if efektler.size() < 500:
		efektler.append(e)


## Askerin birimi: 0 piyade, 1 okçu (yay/arbalet), 2 tüfekli, 3 lazerli. Çağa ve canlının yeteneğine göre.
func birim(i: int) -> int:
	var vid := c_koy[i]
	var cag: int = kv_cag[vid] if vid >= 0 and vid < kv_cag.size() else 0
	if cag >= 6:
		return 3
	if cag >= 4:
		return 2
	if s_okcu[i] >= 0.25 or (cag >= 2 and c_uid[i] % 3 == 0):
		return 1
	return 0


func _skor_ekle(i: int, j: int, puan: int) -> void:
	var ki := _krallik_no(i)
	var kj := _krallik_no(j)
	if ki >= 0 and kj >= 0 and kralliklar.has(ki):
		var sk = kralliklar[ki].get("skor")
		if sk != null and kralliklar[ki]["savas"].has(kj):
			sk[kj] = int(sk.get(kj, 0)) + puan


func _kusatma(i: int, v: Dictionary, hv: Dictionary) -> void:
	if hv["krallik"] == v["krallik"]:
		v["hedef"] = -1
		return
	hv["kusatma"] = ay            # haritada "kuşatma altında" işareti
	hv["kusatan"] = v["krallik"]
	if rng.randf() < 0.3:
		_efekt([18, hv["x"] + rng.randf_range(-2.0, 2.0), hv["y"] + rng.randf_range(-2.0, 2.0), 3])
	var yp: Array = hv["yapilar"]
	if yp.size() > 1 and rng.randf() < 0.25:
		var k: int = yp[rng.randi_range(1, yp.size() - 1)]
		if YAGMACI.has(turler[c_tur[i]]["id"]):
			yangin_baslat(k % gen, k / gen)
		else:
			_yapi_yik(k)
	var p := clampf(0.22 - hv["nufus"] * 0.004, 0.015, 0.22)
	if s_vurus[i] > 1.2:
		p *= 1.25   # usta savaşçılar kuşatmayı hızlandırır
	var kale: int = hv["b"][Y_KALE] if hv["b"].size() > Y_KALE else 0
	if kale > 0:
		p *= 0.35
		# kuşatma makineleri ve ateş önce surları döver
		if rng.randf() < 0.06 * v["silah"] / 2.0:
			for k in hv["yapilar"]:
				if yapi[k] == Y_KALE:
					_yapi_yik(k)
					_kronik("%s surları yıkıldı!" % hv["ad"], 1, hv["x"], hv["y"])
					break
	if rng.randf() < p:
		var kkr = kralliklar.get(v["krallik"])
		if kkr == null:
			return
		var sk = kkr.get("skor")
		if sk != null:
			sk[hv["krallik"]] = int(sk.get(hv["krallik"], 0)) + 15
		_fethet(v["krallik"], hv)


func _fethet(kid: int, hv: Dictionary) -> void:
	var kr: Dictionary = kralliklar[kid]
	var eski = kralliklar.get(hv["krallik"])
	var eski_ad: String = eski["ad"] if eski != null else "?"
	if turler[hv["irk"]]["id"] == "uzayli":
		for id in koyler:
			if koyler[id]["krallik"] == kid:
				koyler[id]["tek"] += 1500.0
		_kronik("%s uzaylı üssünü ele geçirdi ve uzaylı teknolojisini öğrendi!" % kr["ad"], 3, hv["x"], hv["y"])
		_koy_yik(hv, "ele geçirildi")
	elif YAGMACI.has(turler[kr["irk"]]["id"]) and kr["irk"] != hv["irk"]:
		_kronik("%s, %s köyünü yağmalayıp yıktı (%s)." % [kr["ad"], hv["ad"], eski_ad], 2, hv["x"], hv["y"])
		_koy_yik(hv, "yağma")
	else:
		_kronik("%s, %s köyünü fethetti (%s)." % [kr["ad"], hv["ad"], eski_ad], 2, hv["x"], hv["y"])
		hv["krallik"] = kid
		hv["hedef"] = -1
		hv["savasta"] = true
		_bayrak(hv)
		for k in hv["yapilar"]:
			degisen.append(k)   # çatılar yeni krallığın rengine boyanır
	_kk_ay = -1
	for id in koyler:
		if koyler[id]["hedef"] == hv["id"]:
			koyler[id]["hedef"] = -1


func _koy_yik(v: Dictionary, sebep: String) -> void:
	for k in v["yapilar"]:
		if yapi_koy[k] == v["id"]:
			yapi[k] = Y_HARABE
			yapi_koy[k] = -1
			degisen.append(k)
	var id: int = v["id"]
	koyler.erase(id)
	_izgara_sil(v)
	kv_bayrak[id] = 0
	_kk_ay = -1
	# kalan halk: yarısı ölür, yarısı başıboş kalır
	for i in ust:
		if c_var[i] == 1 and c_koy[i] == id and t_irk[c_tur[i]] == 1:
			if sebep == "yağma" and rng.randf() < 0.5:
				oldur(i, "savaş")
			else:
				c_koy[i] = -1
				c_durum[i] = D_GEZ


# ============================================================ KÖYLER
func _hucre_anahtar(x: int, y: int) -> int:
	return (y / HUCRE) * 4096 + x / HUCRE


func _izgara_ekle(v: Dictionary) -> void:
	var a := _hucre_anahtar(v["x"], v["y"])
	if not koy_hucre.has(a):
		koy_hucre[a] = PackedInt32Array()
	var l: PackedInt32Array = koy_hucre[a]
	l.append(v["id"])
	koy_hucre[a] = l


func _izgara_sil(v: Dictionary) -> void:
	var a := _hucre_anahtar(v["x"], v["y"])
	if koy_hucre.has(a):
		var l: PackedInt32Array = koy_hucre[a]
		var n := l.find(v["id"])
		if n >= 0:
			l.remove_at(n)
		koy_hucre[a] = l


func _izgara_kur() -> void:
	koy_hucre.clear()
	for id in koyler:
		_izgara_ekle(koyler[id])


## En yakın köy (azami karo uzaklıkta). Yakın aramalarda ızgara kullanılır, uzaklarda tüm liste.
func koy_yakin(x: int, y: int, azami: int, irk := -1):
	var en = null
	var en_d := azami * azami + 1
	if azami <= 48:
		var hx0 := maxi(0, x - azami) / HUCRE
		var hx1 := maxi(0, x + azami) / HUCRE
		var hy0 := maxi(0, y - azami) / HUCRE
		var hy1 := maxi(0, y + azami) / HUCRE
		for hy in range(hy0, hy1 + 1):
			for hx in range(hx0, hx1 + 1):
				var l = koy_hucre.get(hy * 4096 + hx)
				if l == null:
					continue
				for id in l:
					var v: Dictionary = koyler[id]
					if irk >= 0 and v["irk"] != irk:
						continue
					var d: int = (v["x"] - x) * (v["x"] - x) + (v["y"] - y) * (v["y"] - y)
					if d < en_d:
						en_d = d
						en = v
		return en
	for id in koyler:
		var v: Dictionary = koyler[id]
		if irk >= 0 and v["irk"] != irk:
			continue
		var d: int = (v["x"] - x) * (v["x"] - x) + (v["y"] - y) * (v["y"] - y)
		if d < en_d:
			en_d = d
			en = v
	return en


func _koy_bul_veya_kur(i: int, t: Dictionary) -> void:
	var x := int(c_x[i])
	var y := int(c_y[i])
	var v = koy_yakin(x, y, 14, t["no"])
	if v != null:
		c_koy[i] = v["id"]
		v["nufus"] += 1
		return
	if koy_yakin(x, y, 7) != null:
		# başka ırkın köyünün dibinde: uzaklaş
		c_hx[i] = clampi(x + rng.randi_range(-12, 12), 0, gen - 1)
		c_hy[i] = clampi(y + rng.randi_range(-12, 12), 0, yuk - 1)
		return
	var k := y * gen + x
	if not _kara(biyom[k]) or yapi[k] != 0:
		return
	var nv := _koy_olustur(x, y, t["no"], -1)
	c_koy[i] = nv["id"]
	nv["nufus"] += 1
	var kr: Dictionary = kralliklar[nv["krallik"]]
	kr["kral"] = i
	kr["kral_uid"] = c_uid[i]
	kr["kral_ad"] = c_ad[i]
	_kronik("%s, %s köyünü kurdu. %s doğdu." % [c_ad[i], nv["ad"], kr["ad"]], 2, nv["x"], nv["y"])


func _koy_olustur(x: int, y: int, irk: int, krallik: int) -> Dictionary:
	son_koy += 1
	var t: Dictionary = turler[irk]
	var b := []
	b.resize(Y_KALE + 1)
	b.fill(0)
	var v := {
		"id": son_koy, "ad": _isim(t), "irk": irk, "x": x, "y": y, "krallik": krallik,
		"nufus": 0, "yemek": 40.0, "malzeme": 20.0, "altin": 0.0, "demir": 0.0,
		"tek": 0.0, "cag": 0, "kurulus": ay, "b": b, "yapilar": [], "yaricap": 4, "kapasite": 12,
		"aclik": false, "bolluk": 1.0, "salgin": 0, "cekirge": 0, "savasta": false, "hedef": -1,
		"t_is": 0.0, "t_zeka": 0.0, "t_yetiskin": 0, "aday": -1, "aday_puan": -1.0, "son_erkek": -1,
		"goc_hedef": -1, "goc_kalan": 0, "bos_yil": 0, "verim": 1.0, "orman": 0.0, "tas": 0.0, "cevher": [],
		"kademe": 0, "tavan": 40, "huzur": 70.0, "silah": 1.0, "aluvyon": 0,
	}
	koyler[v["id"]] = v
	_izgara_ekle(v)
	_bayrak(v)
	_kk_ay = -1
	if krallik < 0:
		var kr := _krallik_kur(v, irk)
		v["krallik"] = kr["id"]
	var k := y * gen + x
	_yapi_koy(v, Y_MERKEZ, k)
	_koy_cevre(v)
	return v


## Yeni krallık: v başkent olur.
func _krallik_kur(v: Dictionary, irk: int, ad := "") -> Dictionary:
	var t: Dictionary = turler[irk]
	son_krallik += 1
	var renk := Color.from_hsv(rng.randf(), rng.randf_range(0.55, 0.9), rng.randf_range(0.75, 1.0))
	var kr := {
		"id": son_krallik, "ad": ad if ad != "" else "%s %s" % [_isim(t), t["krallik_eki"]], "irk": irk, "renk": renk.to_html(false),
		"baskent": v["id"], "kral": -1, "kral_uid": 0, "kral_ad": "", "savas": {}, "kurulus": ay,
		"din": -1, "muttefik": {}, "kayip": 0,
	}
	_krallik_tamamla(kr)
	kralliklar[kr["id"]] = kr
	return kr


## Eksik krallık alanlarını tamamlar (yeni krallıklar ve eski kayıtlar için).
func _krallik_tamamla(kr: Dictionary) -> void:
	for a in [["hazine", 0.0], ["vergi", 1], ["harac", {}], ["skor", {}], ["ortak", {}], ["ordu", 1.0], ["muttefik", {}], ["din", -1], ["kayip", 0]]:
		if not kr.has(a[0]):
			kr[a[0]] = a[1].duplicate() if a[1] is Dictionary else a[1]


func _koy_tamamla(v: Dictionary) -> void:
	for a in [["huzur", 70.0], ["silah", 1.0], ["aluvyon", 0], ["kademe", 0], ["tavan", 40]]:
		if not v.has(a[0]):
			v[a[0]] = a[1]
	var b: Array = v["b"]
	while b.size() < Y_KALE + 1:
		b.append(0)


func baskent_yeri(kr: Dictionary) -> Vector2i:
	var v = koyler.get(kr["baskent"])
	if v == null:
		return Vector2i(-1, -1)
	return Vector2i(v["x"], v["y"])


## Köyün çevresini tarar: verim, orman, taş, cevher.
func _koy_cevre(v: Dictionary) -> void:
	var t: Dictionary = turler[v["irk"]]
	var sever: PackedInt32Array = t["biyom"]
	var verimli := 0.0
	var orman := 0
	var tas := 0
	var top := 0
	var cevher := []
	for oy in range(-8, 9):
		for ox in range(-8, 9):
			var x: int = v["x"] + ox
			var y: int = v["y"] + oy
			if not icinde(x, y):
				continue
			top += 1
			var k := y * gen + x
			var b := biyom[k]
			if sever.has(b) or b == B_OVA:
				verimli += 1.0
			elif b == B_SIG:
				verimli += 0.6
			elif b == B_ORMAN or b == B_BOZKIR or b == B_TEPE:
				verimli += 0.5
			elif b >= B_KUM and b != B_LAV:
				verimli += 0.2
			if b == B_ORMAN:
				orman += 1
			if b == B_TEPE or b == B_DAG:
				tas += 1
			if maden[k] > 0 and cevher.size() < 6:
				cevher.append(k)
	v["verim"] = 0.45 + 1.0 * verimli / maxi(1, top)
	v["orman"] = float(orman) / maxi(1, top)
	v["tas"] = float(tas) / maxi(1, top)
	v["cevher"] = cevher


func _yapi_koy(v: Dictionary, tip: int, k: int) -> void:
	if yapi[k] != 0 and yapi[k] != Y_HARABE:
		return
	yapi[k] = tip
	yapi_koy[k] = v["id"]
	v["yapilar"].append(k)
	v["b"][tip] += 1
	if biyom[k] == B_ORMAN:
		biyom[k] = B_OVA
	degisen.append(k)
	v["yaricap"] = 3 + int(sqrt(v["yapilar"].size()) * 1.3)
	_kapasite_hesapla(v)


## Kapasite evlerden gelir ama çağ, saray ve başkentlik bir tavan koyar (taşan halk göç edip yeni köy kurar).
func _kapasite_hesapla(v: Dictionary) -> void:
	var tavan: int = 40 + int(v["cag"]) * 25 + int(v["b"][Y_SARAY]) * 40
	var kr = kralliklar.get(v["krallik"])
	if kr != null and kr["baskent"] == v["id"]:
		tavan = tavan * 3 / 2
	v["tavan"] = tavan
	v["kapasite"] = mini(12 + int(v["b"][Y_EV]) * 5, tavan)


func _yapi_kur(v: Dictionary, tip: int) -> bool:
	var r: int = v["yaricap"] + (2 if tip == Y_TARLA else 0)
	for deneme in 24:
		var x: int = v["x"] + rng.randi_range(-r, r)
		var y: int = v["y"] + rng.randi_range(-r, r)
		if not icinde(x, y):
			continue
		var k := y * gen + x
		var b := biyom[k]
		if (yapi[k] == 0 or yapi[k] == Y_HARABE) and b >= B_KUM and b != B_LAV and b != B_DAG:
			_yapi_koy(v, tip, k)
			return true
	return false


func _yapi_yik(k: int) -> void:
	var tip := yapi[k]
	if tip == Y_YOK or tip == Y_HARABE:
		return
	var v = koyler.get(yapi_koy[k])
	if v != null:
		v["b"][tip] -= 1
		v["yapilar"].erase(k)
		_kapasite_hesapla(v)
	yapi[k] = Y_HARABE
	yapi_koy[k] = -1
	degisen.append(k)


func _koy_yillik(v: Dictionary) -> void:
	var t: Dictionary = turler[v["irk"]]
	var nufus: int = v["nufus"]
	if nufus <= 0:
		v["bos_yil"] += 1
		if v["bos_yil"] >= 3:
			_kronik("%s köyü terk edildi." % v["ad"], 1)
			_koy_yik(v, "terk")
		return
	v["bos_yil"] = 0
	var vid: int = v["id"]
	var isg: float = kv_is[vid]
	var yet: int = kv_yet[vid]
	var zeka_ort: float = kv_zeka[vid] / maxi(1, yet)
	kv_is[vid] = 0.0; kv_zeka[vid] = 0.0; kv_yet[vid] = 0; kv_puan[vid] = -1.0
	v["aday"] = kv_aday[vid]
	var b: Array = v["b"]
	var kr = kralliklar.get(v["krallik"])
	var kral := -1
	if kr != null and kr["kral"] >= 0 and c_var[kr["kral"]] == 1 and c_uid[kr["kral"]] == kr["kral_uid"]:
		kral = kr["kral"]
	# --- yiyecek
	var verim: float = v["verim"] * CAG_VERIM[v["cag"]] * (1.0 + minf(b[Y_TARLA], nufus / 4.0) * 0.06)
	if kuraklik_ay > 0:
		verim *= 0.45
	if kis_ay > 0:
		verim *= 0.35 if soguk_bolge(v["x"], v["y"]) else 0.75
	if v["cekirge"] > 0:
		verim *= 0.3
		v["cekirge"] -= 12
	if int(v.get("aluvyon", 0)) > 0:
		# selin bıraktığı alüvyon toprağı birkaç yıl bereketli kılar
		verim *= 1.25
		v["aluvyon"] = int(v["aluvyon"]) - 1
	var uretim := isg * 2.1 * verim
	var tuketim := nufus * float(t["yemek"])
	var depo: float = 60.0 + nufus * 3.0 + b[Y_AMBAR] * 250.0
	v["yemek"] = minf(v["yemek"] + uretim - tuketim, depo)
	v["aclik"] = v["yemek"] < 0.0
	if v["aclik"]:
		v["yemek"] = 0.0
	v["bolluk"] = clampf(v["yemek"] / (tuketim + 1.0), 0.15, 1.0)
	# --- malzeme, maden, ticaret
	v["malzeme"] += isg * 0.25 * (0.35 + v["orman"] * 2.0 + v["tas"] * 2.0)
	if b[Y_MADEN] > 0:
		for k in v["cevher"]:
			if yapi[k] == Y_MADEN:
				if maden[k] == 1:
					v["altin"] += 3.0
				else:
					v["demir"] += 3.0
	# zanaat ve pazar geliri (hükümdarın altın hırsı ve ticaret yeteneği artırır)
	var gelir: float = nufus * 0.02 + b[Y_PAZAR] * nufus * 0.04
	if kral >= 0:
		gelir *= 1.0 + (etki(kral, "altin_toplama") + etki(kral, "ticaret")) / 100.0
	v["altin"] += gelir
	if kr != null:
		_ekonomi_yillik(v, kr, tuketim)
	# silah gücü önbelleği (çağ × demirhane × krallığın ordu harcaması)
	v["silah"] = CAG_SILAH[v["cag"]] * (1.0 + 0.15 * b[Y_DEMIRHANE]) * (float(kr.get("ordu", 1.0)) if kr != null else 1.0)
	# --- teknoloji
	var artis: float = pow(zeka_ort / 100.0, 2.0) * sqrt(float(yet)) * 0.55 * (1.0 + 0.5 * b[Y_KUTUPHANE])
	if kral >= 0:
		artis *= clampf(s_zeka[kral] / 100.0 + etki(kral, "teknoloji") / 100.0, 0.4, 2.5)
	v["tek"] += artis
	if v["cag"] < CAG_ESIK.size() - 1 and v["tek"] >= CAG_ESIK[v["cag"] + 1]:
		v["cag"] += 1
		if kr != null and kr["baskent"] == v["id"]:
			_kronik("%s %s girdi. Yeni silah: %s." % [kr["ad"], yonelme(CAG_AD[v["cag"]]), SILAH_AD[v["cag"]]], 2)
	# --- inşaat
	var cag: int = v["cag"]
	_kapasite_hesapla(v)
	if nufus >= v["kapasite"] - 4 and v["malzeme"] >= 8.0 and 12 + int(b[Y_EV]) * 5 < int(v.get("tavan", 999)):
		if _yapi_kur(v, Y_EV):
			v["malzeme"] -= 8.0
	if v["malzeme"] >= 5.0 and b[Y_TARLA] < nufus / 5:
		if _yapi_kur(v, Y_TARLA):
			v["malzeme"] -= 5.0
	if v["malzeme"] >= 25.0:
		var ister := Y_YOK
		if nufus > 25 and b[Y_AMBAR] < 1 + nufus / 120:
			ister = Y_AMBAR
		elif cag >= 1 and nufus > 35 and b[Y_KISLA] == 0:
			ister = Y_KISLA
		elif nufus > 45 and b[Y_TAPINAK] == 0:
			ister = Y_TAPINAK
		elif cag >= 2 and nufus > 40 and b[Y_PAZAR] == 0:
			ister = Y_PAZAR
		elif cag >= 2 and v["demir"] >= 3.0 and b[Y_DEMIRHANE] < 2:
			ister = Y_DEMIRHANE
		elif cag >= 3 and nufus > 50 and b[Y_KUTUPHANE] == 0:
			ister = Y_KUTUPHANE
		elif cag >= 3 and b[Y_KULE] < 2:
			ister = Y_KULE
		elif cag >= 3 and nufus > 70 and b[Y_SARAY] == 0 and kr != null and kr["baskent"] == v["id"] and float(kr.get("hazine", 0.0)) >= 60.0:
			ister = Y_SARAY
		elif cag >= 3 and kademe(v) >= 2 and b[Y_KALE] < 1 + int(kr != null and kr["baskent"] == v["id"]) and kr != null and float(kr.get("hazine", 0.0)) >= 30.0:
			ister = Y_KALE
		if ister != Y_YOK and _yapi_kur(v, ister):
			v["malzeme"] -= 25.0
			if ister == Y_SARAY:
				kr["hazine"] -= 60.0
				_kronik("%s, %s şehrine altın kubbeli bir saray yaptırdı." % [kr["ad"], v["ad"]], 1, v["x"], v["y"])
			elif ister == Y_KALE:
				kr["hazine"] -= 30.0
				_kronik("%s taş surlu bir kale ile çevrildi." % v["ad"], 1, v["x"], v["y"])
	if cag >= 1 and v["malzeme"] >= 15.0:
		for k in v["cevher"]:
			if yapi[k] == 0 and maden[k] > 0:
				_yapi_koy(v, Y_MADEN, k)
				v["malzeme"] -= 15.0
				break
	# --- göç: yeni köy
	if nufus > 30 and nufus >= v["kapasite"] * 0.7 and v["goc_kalan"] <= 0 and not v["savasta"]:
		var p := 0.12
		if kral >= 0:
			p *= 1.0 + etki(kral, "kesif") / 100.0
		if rng.randf() < p:
			var k := _yer_bul(v["x"], v["y"], 12, 45, t)
			if k >= 0:
				var nv := _koy_olustur(k % gen, k / gen, v["irk"], v["krallik"])
				nv["tek"] = v["tek"] * 0.8
				nv["cag"] = v["cag"]
				v["goc_hedef"] = nv["id"]
				v["goc_kalan"] = 8
				v["yemek"] *= 0.8
				_kronik("%s halkı yeni bir köy kurdu: %s." % [v["ad"], nv["ad"]], 1, nv["x"], nv["y"])
	# --- kademe: köy → kasaba → şehir → büyük şehir
	var kd := 0
	for n in range(KADEME_ESIK.size() - 1, 0, -1):
		if nufus >= KADEME_ESIK[n]:
			kd = n
			break
	var eski_kd := kademe(v)
	if kd > eski_kd or (kd < eski_kd and nufus < KADEME_ESIK[eski_kd] * 0.6):
		v["kademe"] = kd
		if kd > eski_kd:
			_kronik("%s artık bir %s." % [v["ad"], KADEME_AD[kd].to_lower()], 2 if kd >= 2 else 1, v["x"], v["y"])
	# --- din: tapınağı olan ve dini olmayan krallık bir inanç kurar
	if kr != null and b[Y_TAPINAK] > 0 and not dinler.has(int(kr.get("din", -1))) and rng.randf() < 0.15:
		_din_kur(kr, v)
	# --- huzur ve isyan
	if kr != null:
		_huzur_hesapla(v, kr, kral)
		if kr["baskent"] != v["id"] and nufus >= 15 and float(v["huzur"]) < 20.0 and rng.randf() < 0.03 + (20.0 - float(v["huzur"])) * 0.005:
			isyan(v)
	# --- salgın
	if v["salgin"] > 0:
		v["salgin"] -= 12
		if rng.randf() < 0.3:
			var kv = koy_yakin(v["x"] + rng.randi_range(-25, 25), v["y"] + rng.randi_range(-25, 25), 20)
			if kv != null and kv["salgin"] <= 0 and kv["id"] != v["id"]:
				kv["salgin"] = 36
				_bayrak(kv)
				_kronik("Salgın %s köyüne sıçradı." % kv["ad"], 1, kv["x"], kv["y"])
	_bayrak(v)


# ============================================================ KÖY HIZLI DİZİLERİ
func _kv_boyut(id: int) -> void:
	if id < kv_bayrak.size():
		return
	var n := maxi(id + 1, kv_bayrak.size() * 2)
	for a in [kv_bayrak, kv_bolluk, kv_is, kv_zeka, kv_yet, kv_aday, kv_puan, kv_erkek, kv_cag, kv_kahin, kv_hain, kv_sifa]:
		var eski: int = a.size()
		a.resize(n)
		for m in range(eski, n):
			a[m] = 0
	# yeni yuvalar için -1 başlangıçları
	for m in n:
		if kv_bayrak[m] == 0:
			kv_aday[m] = -1
			kv_erkek[m] = -1
			kv_puan[m] = -1.0
			kv_hain[m] = -1
			kv_kahin[m] = -100000
			kv_sifa[m] = -100000


## Köyün durum bayraklarını hızlı dizilere yazar (yıllık canlı döngüsü bunları okur).
func _bayrak(v: Dictionary) -> void:
	var id: int = v["id"]
	_kv_boyut(id)
	var f := 128
	if v["aclik"]:
		f |= 1
	if v["salgin"] > 0:
		f |= 2
	if v["savasta"]:
		f |= 4
	if v["goc_kalan"] > 0:
		f |= 8
	if v["bolluk"] < 1.0:
		f |= 16
	if v["b"][Y_KISLA] > 0:
		f |= 32
	kv_bayrak[id] = f
	kv_bolluk[id] = v["bolluk"]
	kv_cag[id] = v["cag"]


func _kv_kur() -> void:
	for a in [kv_bayrak, kv_bolluk, kv_is, kv_zeka, kv_yet, kv_aday, kv_puan, kv_erkek, kv_cag, kv_kahin, kv_hain, kv_sifa]:
		a.resize(0)
	_kv_boyut(son_koy + 1)
	for id in koyler:
		var v: Dictionary = koyler[id]
		_bayrak(v)
		kv_aday[id] = int(v.get("aday", -1))
	_kk_ay = -1


# ============================================================ EKONOMİ, HUZUR, İSYAN
## Vergi hazineye akar; hazine kıtlıkta tahıl alır; pazarlı köyler fazla yiyeceği komşulara satar.
func _ekonomi_yillik(v: Dictionary, kr: Dictionary, tuketim: float) -> void:
	var vergi: int = int(kr.get("vergi", 1))
	var pay: float = v["altin"] * VERGI_ORAN[vergi]
	v["altin"] -= pay
	kr["hazine"] = float(kr.get("hazine", 0.0)) + pay
	# kıtlık yardımı: hazine tahıl satın alır
	if v["aclik"] and float(kr["hazine"]) >= 10.0:
		var harca := minf(float(kr["hazine"]) * 0.5, tuketim * 0.12)
		kr["hazine"] -= harca
		v["yemek"] += harca * 8.0
		v["aclik"] = false
	# ticaret: pazarlı ve fazlası olan köy, yiyeceğe ihtiyacı olan bir köye kervan yollar
	if v["b"][Y_PAZAR] > 0 and v["yemek"] > tuketim * 1.5 + 40.0:
		var idler := koyler.keys()
		for deneme in 5:
			var o: Dictionary = koyler[idler[rng.randi_range(0, idler.size() - 1)]]
			if o["id"] == v["id"] or o["bolluk"] >= 0.9:
				continue
			var dx: int = o["x"] - v["x"]
			var dy: int = o["y"] - v["y"]
			if dx * dx + dy * dy > 50 * 50 or kita[o["y"] * gen + o["x"]] != kita[v["y"] * gen + v["x"]]:
				continue
			var ok = kralliklar.get(o["krallik"])
			if ok == null or kr["savas"].has(o["krallik"]):
				continue
			var miktar := minf((v["yemek"] - tuketim) * 0.5, 250.0)
			v["yemek"] -= miktar
			o["yemek"] += miktar
			var kazanc := miktar * 0.12
			v["altin"] += kazanc
			o["altin"] = maxf(0.0, o["altin"] - kazanc * 0.5)
			efektler.append([9, v["x"] + 0.5, v["y"] + 0.5, 8, o["x"] + 0.5, o["y"] + 0.5])
			if ok["id"] != kr["id"]:
				var ortak: Dictionary = kr["ortak"]
				var ilk: bool = not ortak.has(ok["id"])
				ortak[ok["id"]] = int(ortak.get(ok["id"], 0)) + 1
				ok["ortak"][kr["id"]] = int(ok["ortak"].get(kr["id"], 0)) + 1
				if ilk:
					_kronik("TİCARET: %s ile %s arasında kervan yolu açıldı (%s → %s)." % [kr["ad"], ok["ad"], v["ad"], o["ad"]], 1, v["x"], v["y"])
			break


## Huzur (0-100): vergi, kıtlık, savaş, başkente uzaklık, farklı ırk, tapınak ve hükümdarın liderliği belirler.
func _huzur_hesapla(v: Dictionary, kr: Dictionary, kral: int) -> void:
	var h := 72.0
	h -= [-8.0, 0.0, 18.0][int(kr.get("vergi", 1))]
	if v["aclik"]:
		h -= 25.0
	if v["salgin"] > 0:
		h -= 10.0
	if v["savasta"]:
		var en := 0.0
		for did in kr["savas"]:
			en = maxf(en, (ay - int(kr["savas"][did])) / 12.0)
		h -= 6.0 + minf(en * 1.5, 14.0)
	if v["irk"] != kr["irk"]:
		h -= 18.0
	# büyük krallıkları yönetmek zor (bürokrasi)
	h -= clampf((int(kr.get("_koy", 1)) - 5) * 1.2, 0.0, 20.0)
	if v["b"][Y_TAPINAK] > 0:
		h += 8.0
	if v["bolluk"] >= 1.0:
		h += 5.0
	if not (kr.get("harac", {}) as Dictionary).is_empty():
		h -= 10.0
	var bv = koyler.get(kr["baskent"])
	if bv != null and bv["id"] != v["id"]:
		var d := sqrt(float((bv["x"] - v["x"]) * (bv["x"] - v["x"]) + (bv["y"] - v["y"]) * (bv["y"] - v["y"])))
		h -= minf(d / 4.0, 22.0)
	if kral >= 0:
		h += clampf(s_lider[kral] / 3.0, -15.0, 25.0)
		if ozl_var(kral, ozl_id["Kana Susamış"]):
			h -= 8.0
	else:
		h -= 15.0
	v["huzur"] = clampf(lerpf(float(v.get("huzur", 70.0)), h, 0.5), 0.0, 100.0)


## İsyan: huzursuz köy (ve çevresindeki huzursuz köyler) ayrılıp yeni bir krallık kurar; iç savaş çıkar.
func isyan(v: Dictionary, tanri := false) -> bool:
	var eski = kralliklar.get(v["krallik"])
	if eski == null or krallik_koyleri(eski["id"]).size() < 2:
		return false
	if eski["baskent"] == v["id"]:
		return false
	var t: Dictionary = turler[v["irk"]]
	var kr := _krallik_kur(v, v["irk"], "Özgür %s %s" % [v["ad"], t["krallik_eki"]])
	kr["din"] = eski.get("din", -1)
	kr["asi"] = eski["id"]        # hangi krallıktan koptu (barışta yeniden birleşme ya da bağımsızlık)
	v["krallik"] = kr["id"]
	v["huzur"] = 65.0
	_kk_ay = -1
	var katilan := 0
	for id in koyler:
		var o: Dictionary = koyler[id]
		if o["krallik"] != eski["id"] or o["id"] == eski["baskent"]:
			continue
		var dx: int = o["x"] - v["x"]
		var dy: int = o["y"] - v["y"]
		if dx * dx + dy * dy <= 30 * 30 and float(o.get("huzur", 70.0)) < (55.0 if tanri else 42.0):
			o["krallik"] = kr["id"]
			o["huzur"] = 60.0
			katilan += 1
	# isyancı lider: köyün en iyi adayı
	var aday: int = kv_aday[v["id"]]
	if aday < 0 or c_var[aday] == 0 or c_koy[aday] != v["id"]:
		aday = -1
		for i in range(0, ust):
			if c_var[i] == 1 and c_koy[i] == v["id"] and c_yas[i] >= t_yetiskin[c_tur[i]]:
				aday = i
				break
	if aday >= 0:
		kr["kral"] = aday; kr["kral_uid"] = c_uid[aday]; kr["kral_ad"] = c_ad[aday]
	_kronik("İSYAN: %s halkı %s karşı ayaklandı%s! %s kuruldu." % [v["ad"], yonelme(eski["ad"]),
		(" (%d köy katıldı)" % katilan) if katilan > 0 else "", kr["ad"]], 3, v["x"], v["y"])
	efektler.append([10, v["x"] + 0.5, v["y"] + 0.5, 10])
	savas_ilan(eski["id"], kr["id"], "isyan (iç savaş)")
	return true


## Yeni köy yeri arar. cx<0 ise tüm haritada.
func _yer_bul(cx: int, cy: int, rmin: int, rmax: int, t: Dictionary) -> int:
	var sever: PackedInt32Array = t["biyom"]
	var en := -1
	var en_puan := -1.0
	var kaynak_kita := 0
	if cx >= 0:
		kaynak_kita = kita[cy * gen + cx]
	for deneme in 60:
		var x: int
		var y: int
		if cx < 0:
			x = rng.randi_range(6, gen - 7)
			y = rng.randi_range(6, yuk - 7)
		else:
			var aci := rng.randf() * TAU
			var u := rng.randf_range(rmin, rmax)
			x = cx + int(cos(aci) * u)
			y = cy + int(sin(aci) * u)
			if x < 4 or y < 4 or x >= gen - 4 or y >= yuk - 4:
				continue
		var k := y * gen + x
		var b := biyom[k]
		if not _kara(b) or b == B_DAG or yapi[k] != 0:
			continue
		if cx >= 0 and kita[k] != kaynak_kita:
			continue
		var puan := rng.randf() * 0.5
		for n in 8:
			var xx := x + rng.randi_range(-4, 4)
			var yy := y + rng.randi_range(-4, 4)
			if icinde(xx, yy):
				var bb := biyom[yy * gen + xx]
				if sever.has(bb):
					puan += 1.0
				elif bb == B_OVA or bb == B_SIG:
					puan += 0.4
		# pahalı "yakında köy var mı" denetimi yalnızca en iyi adaya yapılır
		if puan > en_puan and koy_yakin(x, y, 10) == null:
			en_puan = puan
			en = k
	return en


# ============================================================ KRALLIKLAR
## Krallığın köyleri. Ayda bir kez tüm köylerden krallık → liste önbelleği kurulur (köy/krallık değişince bayatlar).
func krallik_koyleri(kid: int) -> Array:
	if _kk_ay != ay:
		_kk.clear()
		for id in koyler:
			var v: Dictionary = koyler[id]
			var l = _kk.get(v["krallik"])
			if l == null:
				l = []
				_kk[v["krallik"]] = l
			l.append(v)
		_kk_ay = ay
	var r = _kk.get(kid)
	return (r as Array).duplicate() if r != null else []


func _iliski(a: Dictionary, b: Dictionary) -> float:
	var ia: String = turler[a["irk"]]["id"]
	var ib: String = turler[b["irk"]]["id"]
	if ia == "uzayli" or ib == "uzayli":
		return 8.0
	if ia == ib:
		return 0.6
	if ia == "ork" or ib == "ork":
		return 2.0
	if (ia == "elf" and ib == "cuce") or (ia == "cuce" and ib == "elf"):
		return 1.5
	if ia == "goblin" or ib == "goblin":
		return 1.5
	return 1.0


func _krallik_yillik(kr: Dictionary) -> void:
	var kid: int = kr["id"]
	var liste := krallik_koyleri(kid)
	if liste.is_empty():
		_kronik("%s yıkıldı. (%d yıl yaşadı)" % [kr["ad"], (ay - kr["kurulus"]) / 12], 3)
		kralliklar.erase(kid)
		for id in kralliklar:
			kralliklar[id]["savas"].erase(kid)
			kralliklar[id].get("muttefik", {}).erase(kid)
		return
	# başkent
	if not koyler.has(kr["baskent"]) or koyler[kr["baskent"]]["krallik"] != kid:
		var en: Dictionary = liste[0]
		for v in liste:
			if v["nufus"] > en["nufus"]:
				en = v
		kr["baskent"] = en["id"]
	# hükümdar
	var kral: int = kr["kral"]
	if kral < 0 or c_var[kral] == 0 or c_uid[kral] != kr["kral_uid"]:
		var bv: Dictionary = koyler[kr["baskent"]]
		var aday: int = kv_aday[bv["id"]]
		if aday >= 0 and c_var[aday] == 1 and c_koy[aday] == bv["id"]:
			kr["kral"] = aday
			kr["kral_uid"] = c_uid[aday]
			kr["kral_ad"] = c_ad[aday]
			kral = aday
			var ozl := ozellik_adlari(aday)
			_kronik("%s tahtına %s çıktı%s." % [kr["ad"], c_ad[aday], (" (" + ", ".join(ozl) + ")") if ozl.size() > 0 else ""], 2)
		else:
			kral = -1
	if kral >= 0:
		kral = _darbe_dene(kr, kral)
	# hazine: vergi kararı, haraç, ordu
	kr["_koy"] = liste.size()
	_hazine_yillik(kr, kral)
	# savaşlar
	var savas: Dictionary = kr["savas"]
	for did in savas.keys():
		if not kralliklar.has(did):
			savas.erase(did)
			continue
		# savaş yorgunluğu: uzun süren ve çok kayıp verdiren savaşlar barışa yaklaşır
		var sure_yil: float = (ay - int(savas[did])) / 12.0
		var p := 0.06 + minf(sure_yil * 0.012, 0.25) + minf(int(kr.get("kayip", 0)) * 0.002, 0.3)
		if kral >= 0:
			p *= clampf(1.0 + (etki(kral, "baris_yapma") + etki(kral, "diplomasi") - etki(kral, "savas_istegi")) / 60.0, 0.2, 4.0)
		if _iliski(kr, kralliklar[did]) > 4.0:
			p *= 0.1
		if rng.randf() < p:
			baris_yap(kid, did)
		elif sure_yil >= 2.0 and _baris_satin_al(kr, kralliklar[did], kral):
			pass
	var savasta := not savas.is_empty()
	if not savasta:
		kr["kayip"] = 0
	_diplomasi_yillik(kr, kral, liste)
	if not kralliklar.has(kid):
		return   # krallık başka birine katıldı
	# hız: savaş hedefi araması her yıl değil, ortalama 4 yılda bir yapılır (olasılık 4 katı: beklenen savaş sayısı aynı)
	if not savasta and kralliklar.size() > 1 and rng.randf() < 0.25:
		# en yakın yabancı köyü bul
		var bv: Dictionary = koyler[kr["baskent"]]
		var en = null
		var en_d := 70 * 70
		var mt: Dictionary = kr.get("muttefik", {})
		# hız: tüm köyler yerine başkent + en çok 5 rastgele köyden bakılır
		var ornek: Array = [bv]
		for n in mini(5, liste.size()):
			ornek.append(liste[rng.randi_range(0, liste.size() - 1)])
		var bk: int = kita[bv["y"] * gen + bv["x"]]
		for id in koyler:
			var v: Dictionary = koyler[id]
			if v["krallik"] == kid or mt.has(v["krallik"]) or kita[v["y"] * gen + v["x"]] != bk:
				continue
			for bizim in ornek:
				var d: int = (v["x"] - bizim["x"]) * (v["x"] - bizim["x"]) + (v["y"] - bizim["y"]) * (v["y"] - bizim["y"])
				if d < en_d:
					en_d = d
					en = v
		if en != null and kralliklar.has(en["krallik"]):
			var dk: Dictionary = kralliklar[en["krallik"]]
			var p: float = 0.048 * (0.3 + float(turler[kr["irk"]]["saldirgan"]) * 2.5) * _iliski(kr, dk)
			# ticaret ortakları birbirine daha zor savaş açar
			if kr.get("ortak", {}).has(dk["id"]):
				p *= 0.6
			if kral >= 0:
				p *= clampf(1.0 + (etki(kral, "savas_istegi") - etki(kral, "diplomasi") * 0.5) / 40.0, 0.1, 5.0)
				if s_zeka[kral] < 70:
					p *= 1.6
			p *= _din_carpani(kr, dk)
			if rng.randf() < p:
				savas_ilan(kid, dk["id"])
				savasta = true
	# hedefler (düşman köyler bir kez süzülür)
	var dusmanlar: Array = []
	if savasta:
		for id in koyler:
			var d: Dictionary = koyler[id]
			if savas.has(d["krallik"]):
				dusmanlar.append(d)
	for v in liste:
		if v["savasta"] != savasta:
			v["savasta"] = savasta
			_bayrak(v)
		if not savasta:
			v["hedef"] = -1
			continue
		var hv = koyler.get(v["hedef"])
		if hv != null and savas.has(hv["krallik"]):
			continue
		v["hedef"] = -1
		var en_d := 80 * 80
		var vk: int = kita[v["y"] * gen + v["x"]]
		for d in dusmanlar:
			if kita[d["y"] * gen + d["x"]] != vk:
				continue
			var uz: int = (d["x"] - v["x"]) * (d["x"] - v["x"]) + (d["y"] - v["y"]) * (d["y"] - v["y"])
			if uz < en_d:
				en_d = uz
				v["hedef"] = d["id"]


## Darbe: başkentteki hain/hırslı bir soylu, zayıf ya da sevilmeyen hükümdarı devirmeyi dener.
## Başarırsa tahta geçer (eski hükümdar öldürülür ya da sürülür); başaramazsa idam edilir.
func _darbe_dene(kr: Dictionary, kral: int) -> int:
	var bv = koyler.get(kr["baskent"])
	if bv == null:
		return kral
	var h: int = kv_hain[bv["id"]]
	if h < 0 or h == kral or c_var[h] == 0 or c_koy[h] != bv["id"] or (c_bit[h] & 2) == 0:
		return kral
	if ay - int(kr.get("darbe_ay", -100000)) < 15 * 12:
		return kral   # son girişimin üstünden 15 yıl geçmeden saray tetikte
	var p := 0.02 * (1.0 + (etki(h, "darbe") + etki(h, "ihanet")) / 60.0)
	var huzur: float = float(bv.get("huzur", 70.0))
	if huzur < 45.0:
		p *= 2.0
	if int(kr.get("vergi", 1)) == 2:
		p *= 1.4
	if not kr["savas"].is_empty() and int(kr.get("kayip", 0)) > 20:
		p *= 1.5
	p *= clampf(1.0 - s_lider[kral] / 80.0, 0.25, 1.5)
	if rng.randf() >= p:
		return kral
	kr["darbe_ay"] = ay
	# güç dengesi: darbecinin zekâsı ve liderliği, hükümdarın liderliği ve halkın huzuru
	var basari := clampf(0.45 + (s_zeka[h] - s_zeka[kral]) / 200.0 + (s_lider[h] - s_lider[kral]) / 100.0 + (50.0 - huzur) / 150.0, 0.15, 0.85)
	if rng.randf() < basari:
		_darbe_uygula(kr, kral, h, bv)
		return h
	_kronik("%s sarayında darbe girişimi bastırıldı; %s idam edildi." % [kr["ad"], c_ad[h]], 2, bv["x"], bv["y"])
	kv_hain[bv["id"]] = -1
	oldur(h, "idam")
	return kral


## Darbeyi gerçekleştirir: h tahta geçer, eski hükümdar öldürülür ya da sürülür, halkın huzuru sarsılır.
func _darbe_uygula(kr: Dictionary, kral: int, h: int, bv: Dictionary) -> void:
	var eski_var: bool = kral >= 0 and c_var[kral] == 1 and c_uid[kral] == kr["kral_uid"]
	var eski_ad: String = c_ad[kral] if eski_var else str(kr.get("kral_ad", "?"))
	var surgun := rng.randf() < 0.4
	kr["kral"] = h; kr["kral_uid"] = c_uid[h]; kr["kral_ad"] = c_ad[h]
	if eski_var:
		_kronik("DARBE: %s, %s hükümdarı %s devirip tahta geçti. Eski hükümdar %s." % [c_ad[h], kr["ad"], belirtme(eski_ad), "sürgüne gitti" if surgun else "öldürüldü"], 3, bv["x"], bv["y"])
	else:
		_kronik("DARBE: %s, boş kalan %s tahtını ele geçirdi." % [c_ad[h], kr["ad"]], 3, bv["x"], bv["y"])
	_efekt([10, bv["x"] + 0.5, bv["y"] + 0.5, 8])
	kr["darbe_sayisi"] = int(kr.get("darbe_sayisi", 0)) + 1
	kr["darbe_ay"] = ay
	if eski_var:
		if surgun:
			var ev = koyler.get(c_koy[kral])
			if ev != null:
				ev["nufus"] -= 1
			c_koy[kral] = -1
			c_durum[kral] = D_GEZ
		else:
			kr["kral_uid"] = 0            # ölüm kroniği ayrıca "hükümdar öldü" yazmasın
			oldur(kral, "darbe")
			kr["kral_uid"] = c_uid[h]
	# darbe halkı böler: köylerin huzuru sarsılır
	for v in krallik_koyleri(kr["id"]):
		v["huzur"] = maxf(5.0, float(v.get("huzur", 70.0)) - rng.randf_range(4.0, 14.0))
	kv_hain[bv["id"]] = -1


## Tanrı gücü: bir krallıkta darbe yaptırır (hükümdarı değiştirir). Yeni hükümdarın adını döndürür ("" = olmadı).
func darbe_yaptir(kr: Dictionary) -> String:
	var bv = koyler.get(kr["baskent"])
	if bv == null:
		return ""
	var kral: int = kr["kral"]
	var h := -1
	for aday in [kv_hain[bv["id"]], kv_aday[bv["id"]]]:
		if aday >= 0 and aday != kral and c_var[aday] == 1 and c_koy[aday] == bv["id"] and c_yas[aday] >= t_yetiskin[c_tur[aday]]:
			h = aday
			break
	if h < 0:
		for i in ust:
			if c_var[i] == 1 and i != kral and c_koy[i] == bv["id"] and c_yas[i] >= t_yetiskin[c_tur[i]]:
				h = i
				break
	if h < 0:
		return ""
	_darbe_uygula(kr, kral, h, bv)
	return c_ad[h]


## Savaşı kaybeden taraf, hazinesinde yeterli altın varsa barışı satın almayı dener (rüşvet / savaş tazminatı).
func _baris_satin_al(kr: Dictionary, dusman: Dictionary, kral: int) -> bool:
	var bizim: int = int(kr["skor"].get(dusman["id"], 0))
	var onlar: int = int(dusman["skor"].get(kr["id"], 0))
	if onlar < bizim + 12:
		return false
	var bedel: float = 25.0 + krallik_koyleri(dusman["id"]).size() * 4.0 + (onlar - bizim) * 0.8
	if float(kr["hazine"]) < bedel:
		return false
	var p := 0.25
	if kral >= 0:
		p *= clampf(1.0 + (etki(kral, "diplomasi") + etki(kral, "ticaret")) / 50.0, 0.3, 3.0)
	if rng.randf() >= p:
		return false
	kr["hazine"] = float(kr["hazine"]) - bedel
	dusman["hazine"] = float(dusman.get("hazine", 0.0)) + bedel
	var a: int = kr["id"]
	var b: int = dusman["id"]
	kr["savas"].erase(b); dusman["savas"].erase(a)
	kr["skor"].erase(b); dusman["skor"].erase(a)
	_kronik("BARIŞ: %s, %s %d altın ödeyerek barışı satın aldı." % [kr["ad"], yonelme(dusman["ad"]), int(bedel)], 2)
	return true


## Bir krallığın tüm köylerini başka bir krallığa katar (yeniden birleşme, gönüllü katılma).
func _krallik_kat(kucuk: Dictionary, buyuk: Dictionary) -> void:
	var kid: int = kucuk["id"]
	# önbellek yerine tüm köyler taranır: bu ay el değiştirmiş bir köy sahipsiz krallıkta kalmasın
	for id in koyler:
		var v: Dictionary = koyler[id]
		if v["krallik"] != kid:
			continue
		v["krallik"] = buyuk["id"]
		v["hedef"] = -1
		v["huzur"] = maxf(float(v.get("huzur", 70.0)), 55.0)
		for k in v["yapilar"]:
			degisen.append(k)
	buyuk["hazine"] = float(buyuk.get("hazine", 0.0)) + float(kucuk.get("hazine", 0.0))
	for did in kucuk["savas"].keys():
		if kralliklar.has(did):
			kralliklar[did]["savas"].erase(kid)
			kralliklar[did]["skor"].erase(kid)
	kralliklar.erase(kid)
	for id in kralliklar:
		kralliklar[id]["savas"].erase(kid)
		kralliklar[id].get("muttefik", {}).erase(kid)
		kralliklar[id].get("harac", {}).erase(kid)
	_kk_ay = -1


## Hükümdar vergiyi karakterine göre belirler; hazine haraç öder ve savaşta paralı asker/zırh alır.
func _hazine_yillik(kr: Dictionary, kral: int) -> void:
	_krallik_tamamla(kr)
	var savasta: bool = not kr["savas"].is_empty()
	var koy_say: int = maxi(1, int(kr.get("_koy", 1)))
	# bakım: memurlar, yollar, ordu (savaşta iki kat); hazine boşsa vergi artar
	var bakim := koy_say * (1.5 if not savasta else 4.0)
	kr["hazine"] = maxf(0.0, float(kr["hazine"]) - bakim) * 0.98   # %2 yolsuzluk ve israf
	var ihtiyac := koy_say * 30.0
	var vergi := 1
	if float(kr["hazine"]) < ihtiyac * 0.4:
		vergi = 2
	elif float(kr["hazine"]) > ihtiyac * 2.5:
		vergi = 0
	if kral >= 0:
		if ozl_var(kral, ozl_id["Açgözlü"]) or ozl_var(kral, ozl_id["Hırslı"]) or ozl_var(kral, ozl_id["Kana Susamış"]):
			vergi += 1
		elif ozl_var(kral, ozl_id["Cömert"]) or ozl_var(kral, ozl_id["Kanaatkâr"]) or ozl_var(kral, ozl_id["Bilge"]):
			vergi -= 1
	kr["vergi"] = clampi(vergi, 0, 2)
	# haraç
	var harac: Dictionary = kr["harac"]
	for kid in harac.keys():
		var h: Array = harac[kid]
		if not kralliklar.has(kid) or ay >= int(h[1]):
			harac.erase(kid)
			continue
		var odenen := minf(float(h[0]), float(kr["hazine"]))
		kr["hazine"] -= odenen
		kralliklar[kid]["hazine"] = float(kralliklar[kid].get("hazine", 0.0)) + odenen
	# ordu: savaşta hazinenin bir kısmı paralı asker ve zırha gider
	if savasta and float(kr["hazine"]) > 20.0:
		var harca: float = float(kr["hazine"]) * 0.25
		kr["hazine"] -= harca
		kr["ordu"] = minf(1.6, 1.0 + harca / 150.0)
	else:
		kr["ordu"] = lerpf(float(kr["ordu"]), 1.0, 0.5)


func savas_ilan(a: int, b: int, sebep := "") -> void:
	if a == b or not kralliklar.has(a) or not kralliklar.has(b):
		return
	var ka: Dictionary = kralliklar[a]
	var kb: Dictionary = kralliklar[b]
	if sebep == "":
		sebep = savas_sebebi(a, b)
	# müttefikler birbirine savaş açarsa ittifak bozulur
	if ka.get("muttefik", {}).has(b):
		ittifak_boz(a, b)
	_krallik_tamamla(ka)
	_krallik_tamamla(kb)
	ka["savas"][b] = ay
	kb["savas"][a] = ay
	ka["skor"][b] = 0
	kb["skor"][a] = 0
	if not ka.has("sebep"):
		ka["sebep"] = {}
	ka["sebep"][b] = sebep        # savaşı açan tarafta saklanır (Savaşlar panelinde gösterilir)
	# haraç ödeyen, efendisine savaş açarsa haracı keser
	ka["harac"].erase(b)
	for v in krallik_koyleri(a) + krallik_koyleri(b):
		v["savasta"] = true
		_bayrak(v)
	var yerb := baskent_yeri(kb)
	_kronik("SAVAŞ: %s, %s savaş ilan etti! (Sebep: %s)" % [ka["ad"], yonelme(kb["ad"]), sebep], 3, yerb.x, yerb.y)
	efektler.append([19, yerb.x + 0.5, yerb.y + 0.5, 24])
	# müttefikler savaşa katılır: savunanın müttefikleri daha istekli
	for taraf in [[b, a, 0.7], [a, b, 0.4]]:
		var dost: Dictionary = kralliklar[taraf[0]]
		var dusman: int = taraf[1]
		for mid in dost.get("muttefik", {}).keys():
			if not kralliklar.has(mid) or mid == dusman or kralliklar[mid]["savas"].has(dusman):
				continue
			if kralliklar[mid].get("muttefik", {}).has(dusman):
				continue
			if rng.randf() < float(taraf[2]):
				kralliklar[mid]["savas"][dusman] = ay
				kralliklar[dusman]["savas"][mid] = ay
				for v in krallik_koyleri(mid):
					v["savasta"] = true
					_bayrak(v)
				_kronik("%s, müttefiki %s için savaşa katıldı." % [kralliklar[mid]["ad"], dost["ad"]], 2)


## Süren savaş sayısı (krallık çifti).
func savas_sayisi() -> int:
	var n := 0
	for id in kralliklar:
		n += kralliklar[id]["savas"].size()
	return n / 2


## Savaşın nedeni: hükümdarın karakteri, din, ırk düşmanlığı, zenginlik ya da toprak.
func savas_sebebi(a: int, b: int) -> String:
	var ka: Dictionary = kralliklar[a]
	var kb: Dictionary = kralliklar[b]
	var kral: int = ka["kral"]
	if kral >= 0 and c_var[kral] == 1 and c_uid[kral] == ka["kral_uid"]:
		if ozl_var(kral, ozl_id["Kana Susamış"]):
			return "kana susamış hükümdar"
		if ozl_var(kral, ozl_id["Açgözlü"]):
			return "altın hırsı"
	if ka.get("harac", {}).has(b):
		return "haraçtan kurtulmak"
	var da: int = ka.get("din", -1)
	var db: int = kb.get("din", -1)
	if da >= 0 and db >= 0 and da != db:
		return "din"
	if _iliski(ka, kb) > 1.4:
		return "ırk düşmanlığı"
	for v in krallik_koyleri(b):
		if v["altin"] > 40.0:
			return "altın"
	return "toprak"


func _din_carpani(a: Dictionary, b: Dictionary) -> float:
	var da: int = a.get("din", -1)
	var db: int = b.get("din", -1)
	if da < 0 or db < 0:
		return 1.0
	return 0.5 if da == db else 1.6


func ittifak_kur(a: int, b: int) -> bool:
	if a == b or not kralliklar.has(a) or not kralliklar.has(b):
		return false
	var ka: Dictionary = kralliklar[a]
	var kb: Dictionary = kralliklar[b]
	if ka["savas"].has(b):
		baris_yap(a, b)
	if not ka.has("muttefik"):
		ka["muttefik"] = {}
	if not kb.has("muttefik"):
		kb["muttefik"] = {}
	if ka["muttefik"].has(b):
		return false
	ka["muttefik"][b] = ay
	kb["muttefik"][a] = ay
	_kronik("İTTİFAK: %s ile %s ittifak kurdu." % [ka["ad"], kb["ad"]], 2)
	return true


func ittifak_boz(a: int, b: int) -> void:
	if kralliklar.has(a):
		kralliklar[a].get("muttefik", {}).erase(b)
	if kralliklar.has(b):
		kralliklar[b].get("muttefik", {}).erase(a)
	if kralliklar.has(a) and kralliklar.has(b):
		_kronik("%s ile %s arasındaki ittifak bozuldu." % [kralliklar[a]["ad"], kralliklar[b]["ad"]], 1)


## Yıllık diplomasi: ittifaklar kurulur/bozulur, din komşulara yayılır.
func _diplomasi_yillik(kr: Dictionary, kral: int, liste: Array) -> void:
	var kid: int = kr["id"]
	if not kr.has("muttefik"):
		kr["muttefik"] = {}
	var mt: Dictionary = kr["muttefik"]
	for mid in mt.keys():
		if not kralliklar.has(mid):
			mt.erase(mid)
		elif _din_carpani(kr, kralliklar[mid]) > 1.0 and rng.randf() < 0.04:
			ittifak_boz(kid, mid)
	if kralliklar.size() < 2:
		return
	if liste.size() == 1 and kr["savas"].is_empty() and ay - int(kr["kurulus"]) > 240 and rng.randf() < 0.05:
		var tek: Dictionary = liste[0]
		if int(tek["nufus"]) < 60:
			var komsu = koy_yakin(tek["x"] + rng.randi_range(-14, 14), tek["y"] + rng.randi_range(-14, 14), 30, tek["irk"])
			if komsu != null and komsu["krallik"] != kid and kralliklar.has(komsu["krallik"]):
				var bk: Dictionary = kralliklar[komsu["krallik"]]
				var ayni_din: bool = dinler.has(int(kr.get("din", -1))) and int(kr.get("din", -1)) == int(bk.get("din", -2))
				if krallik_koyleri(bk["id"]).size() >= 3 and (mt.has(bk["id"]) or ayni_din) and kita[tek["y"] * gen + tek["x"]] == kita[komsu["y"] * gen + komsu["x"]]:
					_kronik("BİRLEŞME: %s, hanedan evliliğiyle %s katıldı." % [kr["ad"], yonelme(bk["ad"])], 2, tek["x"], tek["y"])
					_krallik_kat(kr, bk)
					return
	var idler := kralliklar.keys()
	var dip := 0.0
	if kral >= 0:
		dip = etki(kral, "diplomasi") + etki(kral, "ittifak")
	# ittifak arayışı
	if rng.randf() < 0.05 * clampf(1.0 + dip / 50.0, 0.3, 3.0):
		var o: Dictionary = kralliklar[idler[rng.randi_range(0, idler.size() - 1)]]
		if o["id"] != kid and not mt.has(o["id"]) and not kr["savas"].has(o["id"]) and _iliski(kr, o) <= 1.0:
			var p := 0.35 / _din_carpani(kr, o) * (0.5 if mt.size() >= 2 else 1.0)
			if YAGMACI.has(turler[kr["irk"]]["id"]) and turler[kr["irk"]]["id"] != turler[o["irk"]]["id"]:
				p *= 0.2
			if rng.randf() < p:
				ittifak_kur(kid, o["id"])
	# din yayma: en yakın yabancı krallığa misyoner
	var din: int = kr.get("din", -1)
	if dinler.has(din) and liste.size() > 0:
		var p := 0.05
		if kral >= 0:
			p *= clampf(1.0 + etki(kral, "din_yayma") / 40.0, 0.5, 3.0)
		if rng.randf() < p:
			var bv: Dictionary = liste[0]
			var en = null
			var en_d := 60 * 60
			for id in koyler:
				var v: Dictionary = koyler[id]
				if v["krallik"] == kid:
					continue
				var d: int = (v["x"] - bv["x"]) * (v["x"] - bv["x"]) + (v["y"] - bv["y"]) * (v["y"] - bv["y"])
				if d < en_d:
					en_d = d
					en = v
			if en != null and kralliklar.has(en["krallik"]):
				var hk: Dictionary = kralliklar[en["krallik"]]
				var hd: int = hk.get("din", -1)
				if hd != din and turler[hk["irk"]]["id"] != "uzayli":
					var direnc := 0.6 if dinler.has(hd) else 0.0
					if rng.randf() > direnc:
						hk["din"] = din
						_kronik("%s, %s dinini benimsedi." % [hk["ad"], dinler[din]["ad"]], 1 if direnc == 0.0 else 2)


func _din_kur(kr: Dictionary, v: Dictionary) -> void:
	var irk: String = turler[kr["irk"]]["id"]
	var tip: String = DIN_TIP[rng.randi_range(0, DIN_TIP.size() - 1)]
	var tercih := {"elf": "Doğa", "cuce": "Dağ", "ork": "Ateş", "kertenkele": "Güneş", "dev": "Ata", "goblin": "Ay", "uzayli": "Yıldız"}
	if tercih.has(irk) and rng.randf() < 0.6:
		tip = tercih[irk]
	son_din += 1
	var renk := Color.from_hsv(rng.randf(), 0.5, 1.0)
	var d := {"id": son_din, "ad": "%s %s %s" % [_isim(turler[kr["irk"]]), tip, DIN_EK[rng.randi_range(0, DIN_EK.size() - 1)]],
		"tip": tip, "renk": renk.to_html(false), "kurucu": kr["ad"], "kurulus": ay}
	dinler[son_din] = d
	kr["din"] = son_din
	_kronik("DİN: %s köyündeki tapınakta yeni bir inanç doğdu: %s." % [v["ad"], d["ad"]], 3, v["x"], v["y"])


## Bir dinin inananları (krallık nüfusları toplamı).
func din_nufuslari() -> Dictionary:
	var sonuc := {}
	for id in koyler:
		var v: Dictionary = koyler[id]
		var kr = kralliklar.get(v["krallik"])
		if kr == null:
			continue
		var din: int = kr.get("din", -1)
		if din >= 0:
			sonuc[din] = int(sonuc.get(din, 0)) + int(v["nufus"])
	return sonuc


func baris_yap(a: int, b: int) -> void:
	if not kralliklar.has(a) or not kralliklar.has(b):
		return
	if not kralliklar[a]["savas"].has(b):
		return
	var sure: int = (ay - int(kralliklar[a]["savas"][b])) / 12
	var ka: Dictionary = kralliklar[a]
	var kb: Dictionary = kralliklar[b]
	_krallik_tamamla(ka)
	_krallik_tamamla(kb)
	ka["savas"].erase(b)
	kb["savas"].erase(a)
	var sa: int = int(ka["skor"].get(b, 0))
	var sb: int = int(kb["skor"].get(a, 0))
	ka["skor"].erase(b)
	kb["skor"].erase(a)
	var sure_yazi: String = ("%d yıl sürdü" % sure) if sure > 0 else "bir yıldan kısa sürdü"
	# iç savaşın sonu: isyancılar yenildiyse eski krallığa döner, kazandıysa bağımsızlıkları tanınır
	for cift in [[ka, kb, sa, sb], [kb, ka, sb, sa]]:
		var asi: Dictionary = cift[0]
		var ana: Dictionary = cift[1]
		if int(asi.get("asi", -1)) != int(ana["id"]):
			continue
		var s_asi: int = cift[2]
		var s_ana: int = cift[3]
		if s_ana >= s_asi + 8 or (s_ana >= s_asi and krallik_koyleri(asi["id"]).size() * 3 <= krallik_koyleri(ana["id"]).size() and rng.randf() < 0.5):
			var by := baskent_yeri(asi)
			_kronik("İÇ SAVAŞ BİTTİ: %s yenildi; köyleri yeniden %s bağlandı. Savaş %s." % [asi["ad"], yonelme(ana["ad"]), sure_yazi], 3, by.x, by.y)
			_krallik_kat(asi, ana)
			return
		asi.erase("asi")
		if s_asi > s_ana + 5:
			_kronik("BAĞIMSIZLIK: %s, %s karşı iç savaşı kazandı ve bağımsızlığını kabul ettirdi. Savaş %s." % [asi["ad"], yonelme(ana["ad"]), sure_yazi], 2)
			return
	# antlaşma: açık farkla kazanan taraf 10 yıl haraç alır
	if absi(sa - sb) >= 10 and maxi(sa, sb) >= 2 * mini(sa, sb):
		var kazanan: Dictionary = ka if sa > sb else kb
		var kaybeden: Dictionary = kb if sa > sb else ka
		var miktar: float = maxf(4.0, float(kaybeden["hazine"]) * 0.08 + krallik_koyleri(kaybeden["id"]).size() * 1.5)
		kaybeden["harac"][kazanan["id"]] = [miktar, ay + HARAC_YIL * 12]
		_kronik("BARIŞ ANTLAŞMASI: %s savaşı kazandı (%d'e %d). %s %d yıl boyunca yılda %d altın haraç ödeyecek. Savaş %s." % [kazanan["ad"], maxi(sa, sb), mini(sa, sb), kaybeden["ad"], HARAC_YIL, int(miktar), sure_yazi], 2)
	else:
		_kronik("BARIŞ: %s ile %s barış yaptı. Savaş %s." % [ka["ad"], kb["ad"], sure_yazi], 2)


# ============================================================ AFETLER
func _afet_tick() -> void:
	# yangın yayılması
	if yanan.size() > 0:
		var eski := yanan
		yanan = PackedInt32Array()
		var kuru := 1.8 if kuraklik_ay > 0 else 1.0
		for k in eski:
			var a := ates[k] - 1
			if a > 0:
				ates[k] = a
				yanan.append(k)
				if yanan.size() < 2500:
					for kom in [k - 1, k + 1, k - gen, k + gen]:
						if kom < 0 or kom >= gen * yuk or ates[kom] > 0:
							continue
						var p := 0.0
						var b := biyom[kom]
						if yapi[kom] != 0 and yapi[kom] != Y_HARABE:
							p = 0.30
						elif b == B_ORMAN:
							p = 0.32
						elif b == B_BOZKIR:
							p = 0.12
						elif b == B_OVA:
							p = 0.07
						if p > 0.0 and rng.randf() < p * kuru:
							ates[kom] = rng.randi_range(2, 4)
							yanan.append(kom)
							degisen.append(kom)
			else:
				ates[k] = 0
				_yapi_yik(k)
				if biyom[k] == B_ORMAN or biyom[k] == B_OVA or biyom[k] == B_BOZKIR:
					biyom[k] = B_YANIK
				degisen.append(k)
	# sel suları çekilir
	if seller.size() > 0:
		var kalan := PackedInt32Array()
		for k in seller:
			if sel[k] > 1:
				sel[k] -= 1
				kalan.append(k)
			else:
				sel[k] = 0
				degisen.append(k)
		seller = kalan
	if kuraklik_ay > 0:
		kuraklik_ay -= 1
		if kuraklik_ay == 0:
			_kronik("Kuraklık sona erdi.", 1)
	if kis_ay > 0:
		kis_ay -= 1
		if kis_ay == 0:
			_kronik("Kara kış sona erdi.", 1)
	# hortumlar
	for n in range(hortumlar.size() - 1, -1, -1):
		var h: Array = hortumlar[n]
		h[0] = clampf(h[0] + h[2] + rng.randf_range(-0.6, 0.6), 1, gen - 2)
		h[1] = clampf(h[1] + h[3] + rng.randf_range(-0.6, 0.6), 1, yuk - 2)
		h[4] -= 1
		_alan_hasar(int(h[0]), int(h[1]), 2, 0.5, 60.0, "hortum")
		if h[4] <= 0:
			hortumlar.remove_at(n)
	# ufolar
	for n in range(ufolar.size() - 1, -1, -1):
		_ufo_tick(ufolar[n], n)
	if not dogal_afet:
		return
	# kendiliğinden afetler
	var olcek := gen * yuk / 40000.0
	var r := rng.randf()
	if r < 0.06 * olcek:
		var k := rng.randi_range(0, gen * yuk - 1)
		if _kara(biyom[k]) and (ay % 12 >= 5 and ay % 12 <= 8 or rng.randf() < 0.3):
			afet("yildirim", k % gen, k / gen, false)
	r = rng.randf()
	if r < 0.0035 * olcek:
		var k := _karo_ara(B_DAG)
		if k >= 0:
			afet("deprem", k % gen + rng.randi_range(-6, 6), k / gen + rng.randi_range(-6, 6), false)
	elif r < 0.0048 * olcek:
		var k := _karo_ara(B_DAG)
		if k >= 0:
			afet("volkan", k % gen, k / gen, false)
	elif r < 0.0055 * olcek:
		afet("meteor", rng.randi_range(5, gen - 6), rng.randi_range(5, yuk - 6), false)
	elif r < 0.0068 * olcek:
		var k := _karo_ara(B_KUM)
		if k >= 0:
			afet("tsunami", k % gen, k / gen, false)
	elif r < 0.0090 * olcek:
		var k := _karo_ara(B_OVA)
		if k >= 0:
			afet("hortum", k % gen, k / gen, false)
	elif r < 0.0105 * olcek and kuraklik_ay == 0:
		afet("kuraklik", 0, 0, false)
	elif r < 0.0115 * olcek and kis_ay == 0:
		afet("karakis", 0, 0, false)
	elif r < 0.0125 * olcek and yil() > 2000 and ufolar.is_empty():
		afet("ufo", rng.randi_range(5, gen - 6), rng.randi_range(5, yuk - 6), false)
	if ay % 12 >= 2 and ay % 12 <= 4 and koyler.size() > 0 and rng.randf() < 0.012 * olcek:
		# bahar selleri: kıyıdaki bir köyü sular basar (önce hiç olmuyordu: rastgele tek köy deneniyordu)
		var idler := koyler.keys()
		for deneme in 10:
			var sv: Dictionary = koyler[idler[rng.randi_range(0, idler.size() - 1)]]
			if _kiyiya_yakin(sv["x"], sv["y"], 6):
				afet("sel", sv["x"] + rng.randi_range(-3, 3), sv["y"] + rng.randi_range(-3, 3), false)
				break
	if koyler.size() > 0 and rng.randf() < 0.012:
		var idler := koyler.keys()
		var v: Dictionary = koyler[idler[rng.randi_range(0, idler.size() - 1)]]
		if rng.randf() < 0.5:
			if v["nufus"] > 40 and v["salgin"] <= 0 and rng.randf() < v["nufus"] / 200.0:
				afet("salgin", v["x"], v["y"], false)
		elif rng.randf() < 0.4:
			afet("cekirge", v["x"], v["y"], false)


func _karo_ara(b: int) -> int:
	for deneme in 40:
		var k := rng.randi_range(0, gen * yuk - 1)
		if biyom[k] == b:
			return k
	return -1


## Bir afeti tetikler. tanri=true ise oyuncu yapmıştır.
## Afet gönderir. Yakındaki köyde bir Kâhin yaşıyorsa halk felaketi önceden sezer ve çoğu kaçar.
func afet(ad: String, x: int, y: int, tanri := true) -> void:
	_onsezi = false
	if ad in ["deprem", "volkan", "meteor", "tsunami", "hortum", "sel"]:
		var kv = koy_yakin(clampi(x, 0, gen - 1), clampi(y, 0, yuk - 1), 14)
		if kv != null and kv_kahin[kv["id"]] > ay - 14:
			_onsezi = true
			_kronik("%s köyünün kâhini felaketi önceden sezdi; halk kaçtı." % kv["ad"], 2, kv["x"], kv["y"])
	_afet_ic(ad, x, y, tanri)
	_onsezi = false


func _afet_ic(ad: String, x: int, y: int, tanri := true) -> void:
	x = clampi(x, 0, gen - 1)
	y = clampi(y, 0, yuk - 1)
	var k := y * gen + x
	var v = koy_yakin(x, y, 12)
	var yer_adi: String = (" (" + v["ad"] + " yakınında)") if v != null else ""
	match ad:
		"yildirim":
			efektler.append([1, x + 0.5, y + 0.5, 3])
			var j := yer[k] - 1
			if j >= 0 and c_var[j] == 1 and int(c_x[j]) == x and int(c_y[j]) == y:
				oldur(j, "yıldırım")
			if rng.randf() < (0.8 if tanri else 0.25) or kuraklik_ay > 0:
				yangin_baslat(x, y)
		"yangin":
			yangin_baslat(x, y)
			if v != null and not tanri:
				_kronik("Yangın çıktı%s." % yer_adi, 1)
		"deprem":
			efektler.append([2, x + 0.5, y + 0.5, 6])
			_alan_hasar(x, y, 7, 0.55, 45.0, "deprem")
			if v != null:
				_kronik("Deprem oldu%s. Binalar yıkıldı." % yer_adi, 2, x, y)
		"volkan":
			efektler.append([3, x + 0.5, y + 0.5, 8])
			for oy in range(-4, 5):
				for ox in range(-4, 5):
					var d2 := ox * ox + oy * oy
					if d2 > 18 or not icinde(x + ox, y + oy):
						continue
					var kk := (y + oy) * gen + x + ox
					if d2 <= 2:
						biyom[kk] = B_DAG
						ates[kk] = 0
					elif rng.randf() < 0.6 - d2 * 0.02:
						_yapi_yik(kk)
						biyom[kk] = B_LAV
						_karodakini_oldur(kk, "lav")
					degisen.append(kk)
			for n in 6:
				yangin_baslat(x + rng.randi_range(-6, 6), y + rng.randi_range(-6, 6))
			kita_kirli = true
			_kronik("Bir volkan patladı%s!" % yer_adi, 2, x, y)
		"meteor":
			efektler.append([4, x + 0.5, y + 0.5, 6])
			for oy in range(-5, 6):
				for ox in range(-5, 6):
					var d2 := ox * ox + oy * oy
					if d2 > 25 or not icinde(x + ox, y + oy):
						continue
					var kk := (y + oy) * gen + x + ox
					_karodakini_oldur(kk, "meteor")
					if d2 <= 9:
						_yapi_yik(kk)
						if biyom[kk] > B_SIG:
							biyom[kk] = B_YANIK if d2 > 2 else B_TEPE
							if d2 <= 2 and rng.randf() < 0.5:
								maden[kk] = rng.randi_range(1, 2)
						degisen.append(kk)
					elif rng.randf() < 0.3:
						yangin_baslat(x + ox, y + oy)
			_kronik("Gökten bir meteor düştü%s!" % yer_adi, 2, x, y)
		"tsunami":
			efektler.append([5, x + 0.5, y + 0.5, 8])
			for oy in range(-14, 15):
				for ox in range(-14, 15):
					if ox * ox + oy * oy > 196 or not icinde(x + ox, y + oy):
						continue
					var kk := (y + oy) * gen + x + ox
					if not _kara(biyom[kk]) or not _kiyiya_yakin(x + ox, y + oy, 5):
						continue
					if ates[kk] > 0:
						ates[kk] = 1
					if rng.randf() < 0.7:
						_yapi_yik(kk)
					if rng.randf() < 0.6:
						_karodakini_oldur(kk, "tsunami")
					if biyom[kk] == B_ORMAN and rng.randf() < 0.4:
						biyom[kk] = B_KUM
						degisen.append(kk)
			if v != null:
				_kronik("Tsunami kıyıları vurdu%s." % yer_adi, 2, x, y)
		"hortum":
			hortumlar.append([float(x), float(y), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), 18])
			if v != null:
				_kronik("Bir hortum çıktı%s." % yer_adi, 1)
		"salgin":
			if v != null:
				v["salgin"] = 36
				_bayrak(v)
				_kronik("%s köyünde salgın başladı!" % v["ad"], 2, v["x"], v["y"])
		"cekirge":
			if v != null:
				v["cekirge"] = 24
				v["yemek"] = 0.0
				_kronik("Çekirgeler %s köyünün ekinlerini yedi." % v["ad"], 1)
		"sel":
			var su := 0
			for oy in range(-9, 10):
				for ox in range(-9, 10):
					if ox * ox + oy * oy > 81 or not icinde(x + ox, y + oy):
						continue
					var kk := (y + oy) * gen + x + ox
					var bb := biyom[kk]
					if bb < B_KUM or bb > B_BATAK or bb == B_COL or sel[kk] > 0:
						continue
					if ox * ox + oy * oy > 9 and not _kiyiya_yakin(x + ox, y + oy, 3):
						continue
					sel[kk] = rng.randi_range(5, 10)
					seller.append(kk)
					degisen.append(kk)
					su += 1
					if yapi[kk] == Y_TARLA:
						_yapi_yik(kk)
						yapi[kk] = Y_YOK
					elif yapi[kk] != 0 and yapi[kk] != Y_MERKEZ and rng.randf() < 0.25:
						_yapi_yik(kk)
					if rng.randf() < 0.3:
						_karodakini_oldur(kk, "sel")
			if su > 0:
				efektler.append([11, x + 0.5, y + 0.5, 6])
				var etkilenen := 0
				for id in koyler:
					var kv: Dictionary = koyler[id]
					if absi(kv["x"] - x) <= 12 and absi(kv["y"] - y) <= 12:
						kv["yemek"] *= 0.5
						kv["aluvyon"] = 5
						etkilenen += 1
				if etkilenen > 0 or tanri:
					_kronik("SEL: Sular taştı%s; tarlalar sular altında. (Çekilince toprak bereketlenecek)" % yer_adi, 2, x, y)
		"kuraklik":
			kuraklik_ay = 36
			_kronik("Büyük kuraklık başladı. Ekinler kuruyor.", 2)
		"karakis":
			kis_ay = 12
			_kronik("Kara kış bastırdı. Soğuk ve kıtlık var.", 2)
		"ufo":
			ufolar.append({"x": float(x), "y": float(y), "hx": x, "hy": y, "sure": 14})
			if not ufo_geldi:
				ufo_geldi = true
			_kronik("Gökyüzünde bir UFO belirdi! Uzaylılar geldi.", 3, x, y)
		"yagmur":
			efektler.append([6, x + 0.5, y + 0.5, 5])
			for oy in range(-6, 7):
				for ox in range(-6, 7):
					if ox * ox + oy * oy > 36 or not icinde(x + ox, y + oy):
						continue
					var kk := (y + oy) * gen + x + ox
					if ates[kk] > 0:
						ates[kk] = 1
					if biyom[kk] == B_YANIK or (biyom[kk] == B_COL and rng.randf() < 0.3):
						biyom[kk] = B_OVA
						degisen.append(kk)
					elif biyom[kk] == B_LAV:
						biyom[kk] = B_TEPE
						degisen.append(kk)
						_kita_kara_oldu(kk)
			if v != null:
				v["yemek"] += 30.0
		"bereket":
			if v != null:
				v["yemek"] += 300.0
				v["malzeme"] += 100.0
				efektler.append([6, v["x"] + 0.5, v["y"] + 0.5, 5])
		"olum":
			for oy in range(-2, 3):
				for ox in range(-2, 3):
					if icinde(x + ox, y + oy):
						_karodakini_oldur((y + oy) * gen + x + ox, "tanrının gazabı")
			# karo listesi bayat olabilir: yakındaki herkesi tara
			for i in ust:
				if c_var[i] == 1 and absf(c_x[i] - x) < 2.5 and absf(c_y[i] - y) < 2.5:
					oldur(i, "tanrının gazabı")
			efektler.append([1, x + 0.5, y + 0.5, 3])


func _kiyiya_yakin(x: int, y: int, r: int) -> bool:
	for d in [[r, 0], [-r, 0], [0, r], [0, -r], [r / 2, r / 2], [-r / 2, r / 2], [r / 2, -r / 2], [-r / 2, -r / 2], [2, 0], [-2, 0], [0, 2], [0, -2]]:
		var xx: int = x + d[0]
		var yy: int = y + d[1]
		if not icinde(xx, yy) or biyom[yy * gen + xx] <= B_SIG:
			return true
	return false


func _karodakini_oldur(k: int, sebep: String) -> void:
	var j := yer[k] - 1
	if j >= 0 and c_var[j] == 1 and int(c_y[j]) * gen + int(c_x[j]) == k:
		if t_ucan[c_tur[j]] == 0:
			if _onsezi and t_irk[c_tur[j]] == 1 and rng.randf() < 0.75:
				return
			oldur(j, sebep)


func _alan_hasar(x: int, y: int, r: int, yikim: float, hasar: float, sebep: String) -> void:
	for oy in range(-r, r + 1):
		for ox in range(-r, r + 1):
			if ox * ox + oy * oy > r * r or not icinde(x + ox, y + oy):
				continue
			var kk := (y + oy) * gen + x + ox
			if yapi[kk] != 0 and yapi[kk] != Y_HARABE and yapi[kk] != Y_MERKEZ and rng.randf() < yikim:
				_yapi_yik(kk)
			var j := yer[kk] - 1
			if j >= 0 and c_var[j] == 1 and int(c_y[j]) * gen + int(c_x[j]) == kk and rng.randf() < 0.5:
				if _onsezi and t_irk[c_tur[j]] == 1 and rng.randf() < 0.75:
					continue
				c_can[j] -= hasar * rng.randf_range(0.5, 1.5)
				if c_can[j] <= 0.0:
					oldur(j, sebep)


func yangin_baslat(x: int, y: int) -> void:
	if not icinde(x, y):
		return
	var k := y * gen + x
	var b := biyom[k]
	if ates[k] > 0 or b <= B_SIG or b == B_LAV or b == B_KAR:
		return
	if b == B_ORMAN or b == B_OVA or b == B_BOZKIR or yapi[k] != 0:
		ates[k] = rng.randi_range(3, 5)
		yanan.append(k)
		degisen.append(k)


func _ufo_tick(u: Dictionary, n: int) -> void:
	var dx: float = u["hx"] - u["x"]
	var dy: float = u["hy"] - u["y"]
	var d := sqrt(dx * dx + dy * dy)
	if d > 3.0:
		u["x"] += dx / d * 3.0
		u["y"] += dy / d * 3.0
		return
	u["x"] = float(u["hx"]); u["y"] = float(u["hy"])
	var x := int(u["x"])
	var y := int(u["y"])
	efektler.append([7, x + 0.5, y + 0.5, 3])
	_alan_hasar(x, y, 3, 0.35, 150.0, "uzaylı saldırısı")
	# kaçırılıp geri bırakılanlar
	var j := yer[y * gen + x] - 1
	if j >= 0 and c_var[j] == 1 and t_irk[c_tur[j]] == 1 and rng.randf() < 0.5:
		if _ozl_yaz(j, oz_uzayli):
			stat_hesapla(j)
	u["sure"] -= 1
	if u["sure"] <= 0:
		# iniş: üs kur
		var t: Dictionary = turler[tur_id["uzayli"]]
		var k := _yer_bul(x, y, 0, 12, t)
		if k < 0:
			k = _yer_bul(-1, -1, 0, 0, t)
		if k >= 0:
			var nv := _koy_olustur(k % gen, k / gen, t["no"], -1)
			nv["tek"] = 9000.0
			nv["cag"] = 6
			nv["yemek"] = 500.0
			nv["malzeme"] = 300.0
			for m in 10:
				var ci := canli_ekle(t["no"], k % gen + 0.5, k / gen + 0.5, 240, nv["id"])
				if m == 0:
					var kr: Dictionary = kralliklar[nv["krallik"]]
					kr["kral"] = ci; kr["kral_uid"] = c_uid[ci]; kr["kral_ad"] = c_ad[ci]
			_kronik("Uzaylılar yere indi ve bir üs kurdu: %s." % kralliklar[nv["krallik"]]["ad"], 3, nv["x"], nv["y"])
		ufolar.remove_at(n)
		return
	var v = null
	if koyler.size() > 0:
		var idler := koyler.keys()
		v = koyler[idler[rng.randi_range(0, idler.size() - 1)]]
	if v != null:
		u["hx"] = v["x"] + rng.randi_range(-3, 3)
		u["hy"] = v["y"] + rng.randi_range(-3, 3)
	else:
		u["hx"] = rng.randi_range(5, gen - 6)
		u["hy"] = rng.randi_range(5, yuk - 6)


func _rastgele_karolar() -> void:
	var n := gen * yuk
	# yanık toprak ~15 yılda yeşerir (önce ~170 yıl sürüyordu, harita kahverengi lekelerle doluyordu)
	for s in maxi(8, n / 160):
		var k := rng.randi_range(0, n - 1)
		var b := biyom[k]
		if b == B_YANIK:
			if rng.randf() < 0.8:
				biyom[k] = B_OVA
				degisen.append(k)
		elif b == B_LAV:
			if rng.randf() < 0.12:
				biyom[k] = B_TEPE
				degisen.append(k)
				_kita_kara_oldu(k)
			elif rng.randf() < 0.2:
				yangin_baslat(k % gen + rng.randi_range(-1, 1), k / gen + rng.randi_range(-1, 1))
		elif b == B_OVA and yapi[k] == 0 and rng.randf() < 0.015:
			var kom: int = k + [-1, 1, -gen, gen][rng.randi_range(0, 3)]
			if kom >= 0 and kom < n and biyom[kom] == B_ORMAN:
				biyom[k] = B_ORMAN
				degisen.append(k)
		elif yapi[k] == Y_HARABE and rng.randf() < 0.05:
			yapi[k] = Y_YOK
			degisen.append(k)


# ============================================================ TANRI ARAÇLARI
func arazi_boya(x: int, y: int, r: int, b: int) -> void:
	for oy in range(-r, r + 1):
		for ox in range(-r, r + 1):
			if ox * ox + oy * oy > r * r or not icinde(x + ox, y + oy):
				continue
			var k := (y + oy) * gen + x + ox
			if biyom[k] == b:
				continue
			if b <= B_SIG or b == B_LAV:
				_yapi_yik(k)
				if yapi[k] == Y_HARABE:
					yapi[k] = Y_YOK
				_karodakini_oldur(k, "boğulma" if b <= B_SIG else "lav")
			biyom[k] = b
			ates[k] = 0
			degisen.append(k)
	kita_kirli = true


func canli_koy(tur: int, x: float, y: float, secili: Array) -> int:
	if not icinde(int(x), int(y)):
		return -1
	var t: Dictionary = turler[tur]
	var b := biyom[int(y) * gen + int(x)]
	if t_ucan[tur] == 0 and (b <= B_SIG or b == B_LAV):
		return -1
	var yas := int(t["yetiskin"]) * 12 + rng.randi_range(0, int(t["yetiskin"]) * 6)
	return canli_ekle(tur, x, y, yas, -1, -1, -1, secili)


## Tanrı aracı: fırça alanındaki canlıları siler. Silinen sayıyı döndürür.
func canli_sil(x: float, y: float, r: float) -> int:
	var say := 0
	var r2 := r * r
	for i in ust:
		if c_var[i] == 0:
			continue
		var dx := c_x[i] - x
		var dy := c_y[i] - y
		if dx * dx + dy * dy <= r2:
			oldur(i, "tanrı sildi")
			say += 1
	return say


func canli_bul(x: float, y: float, r: float) -> int:
	var en := -1
	var en_d := r * r
	for i in ust:
		if c_var[i] == 0:
			continue
		var dx := c_x[i] - x
		var dy := c_y[i] - y
		var d := dx * dx + dy * dy
		if d < en_d:
			en_d = d
			en = i
	return en


func ozellik_adlari(i: int) -> PackedStringArray:
	var l := PackedStringArray()
	for n in MAX_OZL:
		var id := c_ozl[i * MAX_OZL + n]
		if id != 0:
			l.append(ozellikler[id]["ad"])
	return l


func ozellik_idleri(i: int) -> PackedInt32Array:
	var l := PackedInt32Array()
	for n in MAX_OZL:
		var id := c_ozl[i * MAX_OZL + n]
		if id != 0:
			l.append(id)
	return l


func uid_bul(uid: int) -> int:
	if uid <= 0:
		return -1
	for i in ust:
		if c_var[i] == 1 and c_uid[i] == uid:
			return i
	return -1


func irk_sayilari() -> Dictionary:
	var d := {}
	for t in turler:
		if sayim[t["no"]] > 0:
			d[t["ad"]] = sayim[t["no"]]
	return d


# ============================================================ KAYIT
func kaydet(yol: String) -> bool:
	var d := {
		"surum": KAYIT_SURUMU, "gen": gen, "yuk": yuk, "tohum": tohum, "ay": ay, "rng": rng.state,
		"biyom": biyom, "yapi": yapi, "yapi_koy": yapi_koy, "ates": ates, "maden": maden,
		"kap": kap, "ust": ust, "bos": bos, "son_uid": son_uid,
		"c_var": c_var, "c_tur": c_tur, "c_cins": c_cins, "c_durum": c_durum, "c_x": c_x, "c_y": c_y,
		"c_hx": c_hx, "c_hy": c_hy, "c_yas": c_yas, "c_can": c_can, "c_sans": c_sans, "c_koy": c_koy,
		"c_uid": c_uid, "c_anne": c_anne, "c_baba": c_baba, "c_oldurme": c_oldurme, "c_cocuk": c_cocuk,
		"c_ozl": c_ozl, "c_ad": c_ad,
		"koyler": koyler, "kralliklar": kralliklar, "son_koy": son_koy, "son_krallik": son_krallik,
		"kronik": kronik, "olumler": olumler, "dogum": dogum_sayisi,
		"yanan": yanan, "hortumlar": hortumlar, "ufolar": ufolar, "kuraklik": kuraklik_ay, "kis": kis_ay,
		"dogal_afet": dogal_afet, "ufo_geldi": ufo_geldi, "nufus_siniri": nufus_siniri,
		"dinler": dinler, "son_din": son_din,
		"sel": sel, "seller": seller, "gecmis": nufus_gecmis, "c_tok": c_tok,
	}
	var f := FileAccess.open_compressed(yol, FileAccess.WRITE, FileAccess.COMPRESSION_ZSTD)
	if f == null:
		return false
	f.store_var(d)
	f.close()
	return true


func yukle(yol: String) -> bool:
	if not FileAccess.file_exists(yol):
		return false
	var f := FileAccess.open_compressed(yol, FileAccess.READ, FileAccess.COMPRESSION_ZSTD)
	if f == null:
		return false
	var d = f.get_var()
	f.close()
	if typeof(d) != TYPE_DICTIONARY or not d.has("biyom"):
		return false
	gen = d["gen"]; yuk = d["yuk"]; tohum = d["tohum"]; ay = d["ay"]; rng.state = d["rng"]
	biyom = d["biyom"]; yapi = d["yapi"]; yapi_koy = d["yapi_koy"]; ates = d["ates"]; maden = d["maden"]
	var n := gen * yuk
	kita.resize(n); yer.resize(n); yer.fill(0)
	_boyutla(d["kap"])
	ust = d["ust"]; bos = d["bos"]; son_uid = d["son_uid"]
	c_var = d["c_var"]; c_tur = d["c_tur"]; c_cins = d["c_cins"]; c_durum = d["c_durum"]; c_x = d["c_x"]; c_y = d["c_y"]
	c_hx = d["c_hx"]; c_hy = d["c_hy"]; c_yas = d["c_yas"]; c_can = d["c_can"]; c_sans = d["c_sans"]; c_koy = d["c_koy"]
	c_uid = d["c_uid"]; c_anne = d["c_anne"]; c_baba = d["c_baba"]; c_oldurme = d["c_oldurme"]; c_cocuk = d["c_cocuk"]
	c_ozl = d["c_ozl"]; c_ad = d["c_ad"]
	c_ox = c_x.duplicate(); c_oy = c_y.duplicate()
	koyler = d["koyler"]; kralliklar = d["kralliklar"]; son_koy = d["son_koy"]; son_krallik = d["son_krallik"]
	kronik = d["kronik"]; olumler = d["olumler"]; dogum_sayisi = d["dogum"]
	yanan = d["yanan"]; hortumlar = d["hortumlar"]; ufolar = d["ufolar"]; kuraklik_ay = d["kuraklik"]; kis_ay = d["kis"]
	dogal_afet = d["dogal_afet"]; ufo_geldi = d["ufo_geldi"]; nufus_siniri = d["nufus_siniri"]
	dinler = d.get("dinler", {}); son_din = d.get("son_din", 0)
	# sürüm 4: köyde kusatma/kusatan, krallıkta asi/sebep/darbe_ay alanları eklendi. Hepsi isteğe bağlıdır
	# (.get ile okunur); eski kayıtta yoksa varsayılan değerle sürer, dönüştürme gerekmez.
	# sürüm 3: sel, nüfus geçmişi, avcı tokluğu, hazine/vergi/haraç, huzur, kale
	if d.has("sel"):
		sel = d["sel"]; seller = d["seller"]; nufus_gecmis = d["gecmis"]; c_tok = d["c_tok"]
	else:
		sel = PackedByteArray(); sel.resize(n); sel.fill(0); seller = PackedInt32Array(); nufus_gecmis = []
		c_tok = PackedByteArray(); c_tok.resize(kap); c_tok.fill(2)
	if c_tok.size() < kap:
		c_tok.resize(kap)
	t_kap.fill(0)
	for id in kralliklar:
		_krallik_tamamla(kralliklar[id])
	for id in koyler:
		_koy_tamamla(koyler[id])
		var v: Dictionary = koyler[id]
		var kr = kralliklar.get(v["krallik"])
		v["silah"] = CAG_SILAH[v["cag"]] * (1.0 + 0.15 * v["b"][Y_DEMIRHANE]) * (float(kr["ordu"]) if kr != null else 1.0)
	_izgara_kur()
	_kv_kur()
	if int(d.get("surum", 1)) < 2:
		# sürüm 1 → 2: nüfus sınırı kalktı (sınırsız), krallıklara din/ittifak, köylere kademe eklendi
		nufus_siniri = 0
		for id in kralliklar:
			var kr: Dictionary = kralliklar[id]
			kr["din"] = -1; kr["muttefik"] = {}; kr["kayip"] = 0
		for id in koyler:
			koyler[id]["kademe"] = 0
			koyler[id]["tavan"] = 40
	sayim.fill(0)
	irk_nufus = 0
	for i in ust:
		if c_var[i] == 1:
			sayim[c_tur[i]] += 1
			if t_irk[c_tur[i]] == 1:
				irk_nufus += 1
			stat_hesapla(i)
	efektler.clear()
	degisen.clear()
	kita_kirli = true
	_kita_hesapla()
	hepsi_degisti = true
	return true
