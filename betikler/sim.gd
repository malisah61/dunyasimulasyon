extends RefCounted
## Dünya simülasyonunun çekirdeği. Ekrandan bağımsızdır (headless çalışır).
## 1 adım (tick) = 1 ay. Canlılar "dizi yapısı" (struct-of-arrays) olarak tutulur: hız için.

enum { B_DERIN, B_SIG, B_KUM, B_OVA, B_ORMAN, B_BOZKIR, B_COL, B_BATAK, B_TEPE, B_DAG, B_KAR, B_LAV, B_YANIK }
enum { Y_YOK, Y_MERKEZ, Y_EV, Y_TARLA, Y_AMBAR, Y_MADEN, Y_DEMIRHANE, Y_KISLA, Y_TAPINAK, Y_KUTUPHANE, Y_PAZAR, Y_SARAY, Y_KULE, Y_HARABE }
enum { D_GEZ, D_ASKER, D_GOC, D_KAC }

const BIYOM_AD := ["Derin deniz", "Sığ deniz", "Kumsal", "Ova", "Orman", "Bozkır", "Çöl", "Bataklık", "Tepe", "Dağ", "Kar", "Lav", "Yanık toprak"]
const YAPI_AD := ["", "Köy meydanı", "Ev", "Tarla", "Ambar", "Maden", "Demirhane", "Kışla", "Tapınak", "Kütüphane", "Pazar", "Saray", "Gözetleme kulesi", "Harabe"]
const CAG_AD := ["Taş Çağı", "Tunç Çağı", "Demir Çağı", "Orta Çağ", "Barut Çağı", "Sanayi Çağı", "Uzay Çağı"]
const CAG_ESIK := [0.0, 120.0, 400.0, 1000.0, 2200.0, 4500.0, 9000.0]
const CAG_VERIM := [1.0, 1.15, 1.3, 1.5, 1.7, 2.0, 2.4]
const CAG_SILAH := [1.0, 1.3, 1.7, 2.2, 3.2, 4.5, 7.0]
const SILAH_AD := ["Sopa ve taş balta", "Tunç mızrak", "Demir kılıç ve yay", "Çelik kılıç ve arbalet", "Tüfek ve top", "Makineli tüfek", "Lazer silahı"]
const MEVSIM_AD := ["Kış", "Kış", "İlkbahar", "İlkbahar", "İlkbahar", "Yaz", "Yaz", "Yaz", "Sonbahar", "Sonbahar", "Sonbahar", "Kış"]
const MAX_OZL := 5
const KAYIT_SURUMU := 1
const YAGMACI := ["ork", "goblin", "dev", "uzayli"]

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
var s_guc := PackedFloat32Array()
var s_hiz := PackedFloat32Array()
var s_zeka := PackedFloat32Array()
var s_is := PackedFloat32Array()
var s_dogur := PackedFloat32Array()
var s_omur := PackedFloat32Array()
var s_cesaret := PackedFloat32Array()
var s_canmax := PackedFloat32Array()
var sayim := PackedInt32Array()       # tür başına canlı sayısı
var irk_nufus := 0

# ---- toplum ----
var koyler: Dictionary = {}
var kralliklar: Dictionary = {}
var son_koy := 0
var son_krallik := 0
var kronik: Array = []                # [ay, metin, önem]
var olumler: Dictionary = {}
var dogum_sayisi := 0

# ---- afetler ----
var yanan := PackedInt32Array()
var hortumlar: Array = []
var ufolar: Array = []
var kuraklik_ay := 0
var kis_ay := 0
var dogal_afet := true
var ufo_geldi := false

# ---- ayarlar / çizim için ----
var nufus_siniri := 3000
var hareket_adim := 1
var degisen := PackedInt32Array()     # çizimde yenilenecek karolar
var hepsi_degisti := true
var efektler: Array = []              # [tip, x, y, süre]


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
	sayim.resize(turler.size())


# ============================================================ DÜNYA ÜRETİMİ
func dunya_uret(g: int, y: int, th: int) -> void:
	gen = g
	yuk = y
	tohum = th
	rng.seed = th
	var n := g * y
	biyom.resize(n); yapi.resize(n); yapi_koy.resize(n); ates.resize(n); maden.resize(n); kita.resize(n); yer.resize(n)
	yapi.fill(0); yapi_koy.fill(-1); ates.fill(0); maden.fill(0); yer.fill(0)
	ay = 0
	koyler.clear(); kralliklar.clear(); kronik.clear(); olumler.clear()
	yanan.clear(); hortumlar.clear(); ufolar.clear(); efektler.clear()
	kuraklik_ay = 0; kis_ay = 0; ufo_geldi = false; dogum_sayisi = 0
	son_koy = 0; son_krallik = 0; son_uid = 0
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
		var sayi: int = {"dev": 10, "elf": 22, "cuce": 18}.get(ad, 14)
		for n in sayi:
			var x := k % gen + rng.randi_range(-2, 2)
			var y := k / gen + rng.randi_range(-2, 2)
			if icinde(x, y) and _kara(biyom[y * gen + x]):
				canli_ekle(t["no"], x + 0.5, y + 0.5, int(t["yetiskin"]) * 12 + rng.randi_range(0, int(t["yetiskin"]) * 6), -1)
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
	for a in [c_var, c_tur, c_cins, c_durum, c_x, c_y, c_ox, c_oy, c_hx, c_hy, c_yas, c_can, c_sans, c_koy, c_uid, c_anne, c_baba, c_oldurme, c_cocuk, c_ad, s_guc, s_hiz, s_zeka, s_is, s_dogur, s_omur, s_cesaret, s_canmax]:
		a.resize(n)
	c_ozl.resize(n * MAX_OZL)


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
			if ozl_var(anne, ozl_id["Mutant"]) or (baba >= 0 and ozl_var(baba, ozl_id["Mutant"])):
				mut = 0.25
			if rng.randf() < mut:
				_ozl_yaz(i, havuz[rng.randi_range(0, havuz.size() - 1)])
			if rng.randf() < 0.0015:
				_ozl_yaz(i, [ozl_id["Dahi"], ozl_id["Kahraman"], ozl_id["Kâhin"], ozl_id["Kutsanmış"], ozl_id["Büyü Yetenekli"]][rng.randi_range(0, 4)])
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
	if ozl_var(ebeveyn, ozl_id["Güçlü Kalıtım"]):
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
	if t_irk[tur]:
		irk_nufus -= 1
		var v = koyler.get(c_koy[i])
		if v != null:
			v["nufus"] -= 1
			var kr = kralliklar.get(v["krallik"])
			if kr != null and kr["kral_uid"] == c_uid[i]:
				_kronik("%s hükümdarı %s öldü (%s, %d yaşında)." % [kr["ad"], c_ad[i], sebep, c_yas[i] / 12], 2)
				kr["kral_uid"] = 0
				return
		if c_oldurme[i] >= 8 or ozl_var(i, ozl_id["Kahraman"]) or ozl_var(i, ozl_id["Dahi"]):
			_kronik("Ünlü %s %s öldü (%s, %d yaşında)." % [turler[tur]["ad"], c_ad[i], sebep, c_yas[i] / 12], 1)


# ============================================================ ANA DÖNGÜ
func tick() -> void:
	ay += 1
	var adim := hareket_adim
	var a := ay
	for i in ust:
		if c_var[i] == 0:
			continue
		if (i + a) % 12 == 0:
			_yillik(i)
			if c_var[i] == 0:
				continue
		if adim == 1 or (i + a) % adim == 0:
			_hareket(i, adim)
	for id in koyler.keys():
		if (id + a) % 12 == 0 and koyler.has(id):
			_koy_yillik(koyler[id])
	for id in kralliklar.keys():
		if (id * 5 + a) % 12 == 0 and kralliklar.has(id):
			_krallik_yillik(kralliklar[id])
	_afet_tick()
	_rastgele_karolar()
	if a % 12 == 0:
		if kita_kirli:
			_kita_hesapla()
		if kronik.size() > 3000:
			kronik = kronik.slice(kronik.size() - 2500)
	for n in range(efektler.size() - 1, -1, -1):
		efektler[n][3] -= 1
		if efektler[n][3] <= 0:
			efektler.remove_at(n)


func yil() -> int:
	return ay / 12 + 1


func tarih_yazi() -> String:
	return "Yıl %d, %d. ay (%s)" % [yil(), ay % 12 + 1, MEVSIM_AD[ay % 12]]


func _kronik(metin: String, onem := 1) -> void:
	kronik.append([ay, metin, onem])


# ============================================================ CANLI: YILLIK
func _yillik(i: int) -> void:
	c_yas[i] += 12
	var tur := c_tur[i]
	var t: Dictionary = turler[tur]
	var yas := c_yas[i]
	if yas > s_omur[i] and rng.randf() < 0.3:
		oldur(i, "yaşlılık")
		return
	var cm := s_canmax[i]
	if c_can[i] < cm:
		c_can[i] = minf(cm, c_can[i] + cm * 0.25)
	if kis_ay > 0 and rng.randf() < 0.10 and not ozl_var(i, ozl_id["Soğuğa Dayanıklı"]) and t["id"] != "dev":
		oldur(i, "soğuk")
		return
	var yetiskin: bool = yas >= int(t["yetiskin"]) * 12
	if t_irk[tur] == 0:
		_hayvan_yillik(i, t, yetiskin)
		return
	var v = koyler.get(c_koy[i])
	if v == null:
		c_koy[i] = -1
		if yetiskin:
			_koy_bul_veya_kur(i, t)
		return
	# kıtlık ve salgın
	if v["aclik"] and rng.randf() < 0.22:
		oldur(i, "açlık")
		return
	if v["salgin"] > 0:
		var direnc := clampf(etki(i, "hastalik_direnci") / 100.0, -0.5, 0.95)
		if rng.randf() < 0.20 * (1.0 - direnc):
			oldur(i, "salgın")
			return
	if c_durum[i] == D_KAC:
		c_durum[i] = D_GEZ
	if not yetiskin:
		return
	# köye katkı
	v["t_is"] += s_is[i]
	v["t_zeka"] += s_zeka[i]
	v["t_yetiskin"] += 1
	var puan := s_zeka[i] / 100.0 + (etki(i, "liderlik") + etki(i, "kral_olma")) / 40.0 + rng.randf() * 0.5
	if puan > v["aday_puan"]:
		v["aday_puan"] = puan
		v["aday"] = i
	if c_cins[i] == 1:
		v["son_erkek"] = i
	# göç
	if v["goc_kalan"] > 0 and koyler.has(v["goc_hedef"]):
		var hv: Dictionary = koyler[v["goc_hedef"]]
		v["goc_kalan"] -= 1
		v["nufus"] -= 1
		hv["nufus"] += 1
		c_koy[i] = hv["id"]
		c_durum[i] = D_GOC
		c_hx[i] = hv["x"]; c_hy[i] = hv["y"]
		return
	# askerlik
	if v["savasta"] and yas < s_omur[i] * 0.75:
		var oran := 3 if v["b"][Y_KISLA] > 0 else 2
		if c_uid[i] % 5 < oran and c_durum[i] != D_ASKER:
			c_durum[i] = D_ASKER
			_yeni_hedef(i)
	elif c_durum[i] == D_ASKER:
		c_durum[i] = D_GEZ
	# doğum
	if c_cins[i] == 0 and yas < s_omur[i] * 0.65 and not v["aclik"] and v["nufus"] < v["kapasite"] and irk_nufus < nufus_siniri and sayim[c_tur[i]] < nufus_siniri * 0.45:
		var baba: int = v["son_erkek"]
		if baba >= 0 and c_var[baba] == 1 and c_koy[baba] == v["id"]:
			var p: float = float(t["dogur"]) * s_dogur[i] * v["bolluk"] * (0.5 + 0.5 * s_dogur[baba])
			if rng.randf() < p:
				_dogum(i, baba, v)
				if rng.randf() < etki(i, "ikiz_sansi") / 100.0:
					_dogum(i, baba, v)
	# hayatla kazanılan özellikler
	if c_oldurme[i] >= 3 and rng.randf() < 0.3:
		if _ozl_yaz(i, ozl_id["Cesur"]):
			stat_hesapla(i)
	if yas > s_omur[i] * 0.6 and s_zeka[i] > 110 and rng.randf() < 0.02:
		if _ozl_yaz(i, ozl_id["Bilge"]):
			stat_hesapla(i)
	# avcılık
	if rng.randf() < 0.5:
		var j := _yakin_canli(i, 2)
		if j >= 0 and t_otobur[c_tur[j]] == 1:
			v["yemek"] += float(turler[c_tur[j]]["et"]) * (1.0 + etki(i, "avcilik") / 100.0)
			oldur(j, "avlandı")


func _dogum(anne: int, baba: int, v: Dictionary) -> void:
	canli_ekle(c_tur[anne], c_x[anne], c_y[anne], 0, v["id"], anne, baba)
	c_cocuk[anne] += 1
	c_cocuk[baba] += 1
	dogum_sayisi += 1


func _hayvan_yillik(i: int, t: Dictionary, yetiskin: bool) -> void:
	var tur := c_tur[i]
	if yetiskin and c_cins[i] == 0 and float(t["dogur"]) > 0.0:
		var sinir: int = gen * yuk * int(t["sinir"]) / 20000
		if sayim[tur] < sinir and rng.randf() < float(t["dogur"]):
			canli_ekle(tur, c_x[i], c_y[i], 0, -1, i, -1)
	if t_avci[tur] == 1 and rng.randf() < 0.7:
		var j := _yakin_canli(i, 4)
		if j >= 0 and _dusman(i, j):
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
					_kronik("Bir ejderha %s köyünü ateşe verdi!" % v["ad"], 2)


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
		elif b == B_DAG or b == B_BATAK:
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
		var j := _yakin_canli(i, 2)
		if j >= 0 and _dusman(i, j):
			_vur(i, j)


func _yeni_hedef(i: int) -> void:
	var x0 := int(c_x[i])
	var y0 := int(c_y[i])
	var tur := c_tur[i]
	var cx := x0
	var cy := y0
	var r := 5
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
	return kralliklar[ki]["savas"].has(kj)


func _silah(i: int) -> float:
	var v = koyler.get(c_koy[i])
	if v == null:
		return 1.0
	return CAG_SILAH[v["cag"]] * (1.0 + 0.15 * v["b"][Y_DEMIRHANE])


func _vur(i: int, j: int) -> void:
	var hasar := s_guc[i] * _silah(i) * rng.randf_range(0.6, 1.4)
	c_can[j] -= hasar
	efektler.append([0, c_x[j], c_y[j], 2])
	if c_can[j] <= 0.0:
		oldur(j, "savaş" if t_irk[c_tur[j]] == 1 and t_irk[c_tur[i]] == 1 else "saldırı")
		c_oldurme[i] += 1
		c_can[i] = minf(s_canmax[i], c_can[i] + s_canmax[i] * 0.1)
		return
	# karşılık
	c_can[i] -= s_guc[j] * _silah(j) * rng.randf_range(0.3, 1.0)
	if c_can[i] <= 0.0:
		oldur(i, "savaş" if t_irk[c_tur[i]] == 1 and t_irk[c_tur[j]] == 1 else "saldırı")
		c_oldurme[j] += 1
		return
	if t_irk[c_tur[i]] == 1 and c_can[i] < s_canmax[i] * (0.30 - s_cesaret[i] * 0.5):
		c_durum[i] = D_KAC
		_yeni_hedef(i)


func _kusatma(i: int, v: Dictionary, hv: Dictionary) -> void:
	if hv["krallik"] == v["krallik"]:
		v["hedef"] = -1
		return
	var yp: Array = hv["yapilar"]
	if yp.size() > 1 and rng.randf() < 0.25:
		var k: int = yp[rng.randi_range(1, yp.size() - 1)]
		if YAGMACI.has(turler[c_tur[i]]["id"]):
			yangin_baslat(k % gen, k / gen)
		else:
			_yapi_yik(k)
	var p := clampf(0.22 - hv["nufus"] * 0.004, 0.015, 0.22)
	if rng.randf() < p:
		_fethet(v["krallik"], hv)


func _fethet(kid: int, hv: Dictionary) -> void:
	var kr: Dictionary = kralliklar[kid]
	var eski = kralliklar.get(hv["krallik"])
	var eski_ad: String = eski["ad"] if eski != null else "?"
	if turler[hv["irk"]]["id"] == "uzayli":
		for id in koyler:
			if koyler[id]["krallik"] == kid:
				koyler[id]["tek"] += 1500.0
		_kronik("%s uzaylı üssünü ele geçirdi ve uzaylı teknolojisini öğrendi!" % kr["ad"], 3)
		_koy_yik(hv, "ele geçirildi")
	elif YAGMACI.has(turler[kr["irk"]]["id"]) and kr["irk"] != hv["irk"]:
		_kronik("%s, %s köyünü yağmalayıp yıktı (%s)." % [kr["ad"], hv["ad"], eski_ad], 2)
		_koy_yik(hv, "yağma")
	else:
		_kronik("%s, %s köyünü fethetti (%s)." % [kr["ad"], hv["ad"], eski_ad], 2)
		hv["krallik"] = kid
		hv["hedef"] = -1
		hv["savasta"] = true
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
	# kalan halk: yarısı ölür, yarısı başıboş kalır
	for i in ust:
		if c_var[i] == 1 and c_koy[i] == id and t_irk[c_tur[i]] == 1:
			if sebep == "yağma" and rng.randf() < 0.5:
				oldur(i, "savaş")
			else:
				c_koy[i] = -1
				c_durum[i] = D_GEZ


# ============================================================ KÖYLER
func koy_yakin(x: int, y: int, azami: int, irk := -1):
	var en = null
	var en_d := azami * azami + 1
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
	_kronik("%s, %s köyünü kurdu. %s doğdu." % [c_ad[i], nv["ad"], kr["ad"]], 2)


func _koy_olustur(x: int, y: int, irk: int, krallik: int) -> Dictionary:
	son_koy += 1
	var t: Dictionary = turler[irk]
	var b := []
	b.resize(Y_HARABE + 1)
	b.fill(0)
	var v := {
		"id": son_koy, "ad": _isim(t), "irk": irk, "x": x, "y": y, "krallik": krallik,
		"nufus": 0, "yemek": 40.0, "malzeme": 20.0, "altin": 0.0, "demir": 0.0,
		"tek": 0.0, "cag": 0, "kurulus": ay, "b": b, "yapilar": [], "yaricap": 4, "kapasite": 12,
		"aclik": false, "bolluk": 1.0, "salgin": 0, "cekirge": 0, "savasta": false, "hedef": -1,
		"t_is": 0.0, "t_zeka": 0.0, "t_yetiskin": 0, "aday": -1, "aday_puan": -1.0, "son_erkek": -1,
		"goc_hedef": -1, "goc_kalan": 0, "bos_yil": 0, "verim": 1.0, "orman": 0.0, "tas": 0.0, "cevher": [],
	}
	koyler[v["id"]] = v
	if krallik < 0:
		son_krallik += 1
		var renk := Color.from_hsv(rng.randf(), rng.randf_range(0.55, 0.9), rng.randf_range(0.75, 1.0))
		var kr := {
			"id": son_krallik, "ad": "%s %s" % [_isim(t), t["krallik_eki"]], "irk": irk, "renk": renk.to_html(false),
			"baskent": v["id"], "kral": -1, "kral_uid": 0, "kral_ad": "", "savas": {}, "kurulus": ay,
		}
		kralliklar[kr["id"]] = kr
		v["krallik"] = kr["id"]
	var k := y * gen + x
	_yapi_koy(v, Y_MERKEZ, k)
	_koy_cevre(v)
	return v


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
	v["kapasite"] = 12 + v["b"][Y_EV] * 5


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
		v["kapasite"] = 12 + v["b"][Y_EV] * 5
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
	var isg: float = v["t_is"]
	var yet: int = v["t_yetiskin"]
	var zeka_ort: float = v["t_zeka"] / maxi(1, yet)
	v["t_is"] = 0.0; v["t_zeka"] = 0.0; v["t_yetiskin"] = 0; v["aday_puan"] = -1.0
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
		verim *= 0.35
	if v["cekirge"] > 0:
		verim *= 0.3
		v["cekirge"] -= 12
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
	if b[Y_PAZAR] > 0:
		v["altin"] += nufus * 0.03
	if kral >= 0:
		v["altin"] *= 1.0 + etki(kral, "altin_toplama") / 2000.0
	# --- teknoloji
	var artis: float = pow(zeka_ort / 100.0, 2.0) * sqrt(float(yet)) * 0.55 * (1.0 + 0.5 * b[Y_KUTUPHANE])
	if kral >= 0:
		artis *= clampf(s_zeka[kral] / 100.0 + etki(kral, "teknoloji") / 100.0, 0.4, 2.5)
	v["tek"] += artis
	if v["cag"] < CAG_ESIK.size() - 1 and v["tek"] >= CAG_ESIK[v["cag"] + 1]:
		v["cag"] += 1
		if kr != null and kr["baskent"] == v["id"]:
			_kronik("%s %s'na girdi. Yeni silah: %s." % [kr["ad"], CAG_AD[v["cag"]], SILAH_AD[v["cag"]]], 2)
	# --- inşaat
	var cag: int = v["cag"]
	if nufus >= v["kapasite"] - 4 and v["malzeme"] >= 8.0:
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
		elif cag >= 3 and nufus > 70 and b[Y_SARAY] == 0 and kr != null and kr["baskent"] == v["id"]:
			ister = Y_SARAY
		if ister != Y_YOK and _yapi_kur(v, ister):
			v["malzeme"] -= 25.0
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
				_kronik("%s halkı yeni bir köy kurdu: %s." % [v["ad"], nv["ad"]], 1)
	# --- salgın
	if v["salgin"] > 0:
		v["salgin"] -= 12
		if rng.randf() < 0.3:
			var kv = koy_yakin(v["x"] + rng.randi_range(-25, 25), v["y"] + rng.randi_range(-25, 25), 20)
			if kv != null and kv["salgin"] <= 0 and kv["id"] != v["id"]:
				kv["salgin"] = 36
				_kronik("Salgın %s köyüne sıçradı." % kv["ad"], 1)


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
		if koy_yakin(x, y, 10) != null:
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
		if puan > en_puan:
			en_puan = puan
			en = k
	return en


# ============================================================ KRALLIKLAR
func krallik_koyleri(kid: int) -> Array:
	var l := []
	for id in koyler:
		if koyler[id]["krallik"] == kid:
			l.append(koyler[id])
	return l


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
		var aday: int = bv["aday"]
		if aday >= 0 and c_var[aday] == 1 and c_koy[aday] == bv["id"]:
			kr["kral"] = aday
			kr["kral_uid"] = c_uid[aday]
			kr["kral_ad"] = c_ad[aday]
			kral = aday
			var ozl := ozellik_adlari(aday)
			_kronik("%s tahtına %s çıktı%s." % [kr["ad"], c_ad[aday], (" (" + ", ".join(ozl) + ")") if ozl.size() > 0 else ""], 2)
		else:
			kral = -1
	# savaşlar
	var savas: Dictionary = kr["savas"]
	for did in savas.keys():
		if not kralliklar.has(did):
			savas.erase(did)
			continue
		var p := 0.10
		if kral >= 0:
			p *= clampf(1.0 + (etki(kral, "baris_yapma") + etki(kral, "diplomasi") - etki(kral, "savas_istegi")) / 60.0, 0.2, 4.0)
		if _iliski(kr, kralliklar[did]) > 4.0:
			p *= 0.1
		if rng.randf() < p:
			baris_yap(kid, did)
	var savasta := not savas.is_empty()
	if not savasta and kralliklar.size() > 1:
		# en yakın yabancı köyü bul
		var bv: Dictionary = koyler[kr["baskent"]]
		var en = null
		var en_d := 70 * 70
		for id in koyler:
			var v: Dictionary = koyler[id]
			if v["krallik"] == kid or kita[v["y"] * gen + v["x"]] != kita[bv["y"] * gen + bv["x"]]:
				continue
			for bizim in liste:
				var d: int = (v["x"] - bizim["x"]) * (v["x"] - bizim["x"]) + (v["y"] - bizim["y"]) * (v["y"] - bizim["y"])
				if d < en_d:
					en_d = d
					en = v
		if en != null and kralliklar.has(en["krallik"]):
			var dk: Dictionary = kralliklar[en["krallik"]]
			var p: float = 0.012 * (0.3 + float(turler[kr["irk"]]["saldirgan"]) * 2.5) * _iliski(kr, dk)
			if kral >= 0:
				p *= clampf(1.0 + (etki(kral, "savas_istegi") - etki(kral, "diplomasi") * 0.5) / 40.0, 0.1, 5.0)
				if s_zeka[kral] < 70:
					p *= 1.6
			if rng.randf() < p:
				savas_ilan(kid, dk["id"])
				savasta = true
	# hedefler
	for v in liste:
		v["savasta"] = savasta
		if not savasta:
			v["hedef"] = -1
			continue
		var hv = koyler.get(v["hedef"])
		if hv != null and savas.has(hv["krallik"]):
			continue
		v["hedef"] = -1
		var en_d := 80 * 80
		for id in koyler:
			var d: Dictionary = koyler[id]
			if not savas.has(d["krallik"]) or kita[d["y"] * gen + d["x"]] != kita[v["y"] * gen + v["x"]]:
				continue
			var uz: int = (d["x"] - v["x"]) * (d["x"] - v["x"]) + (d["y"] - v["y"]) * (d["y"] - v["y"])
			if uz < en_d:
				en_d = uz
				v["hedef"] = d["id"]


func savas_ilan(a: int, b: int) -> void:
	if a == b or not kralliklar.has(a) or not kralliklar.has(b):
		return
	kralliklar[a]["savas"][b] = ay
	kralliklar[b]["savas"][a] = ay
	for v in krallik_koyleri(a) + krallik_koyleri(b):
		v["savasta"] = true
	_kronik("SAVAŞ: %s, %s'na savaş ilan etti!" % [kralliklar[a]["ad"], kralliklar[b]["ad"]], 3)


func baris_yap(a: int, b: int) -> void:
	if not kralliklar.has(a) or not kralliklar.has(b):
		return
	if not kralliklar[a]["savas"].has(b):
		return
	var sure: int = (ay - int(kralliklar[a]["savas"][b])) / 12
	kralliklar[a]["savas"].erase(b)
	kralliklar[b]["savas"].erase(a)
	_kronik("BARIŞ: %s ile %s barış yaptı. Savaş %d yıl sürdü." % [kralliklar[a]["ad"], kralliklar[b]["ad"], sure], 2)


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
func afet(ad: String, x: int, y: int, tanri := true) -> void:
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
				_kronik("Deprem oldu%s. Binalar yıkıldı." % yer_adi, 2)
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
			_kronik("Bir volkan patladı%s!" % yer_adi, 2)
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
			_kronik("Gökten bir meteor düştü%s!" % yer_adi, 2)
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
				_kronik("Tsunami kıyıları vurdu%s." % yer_adi, 2)
		"hortum":
			hortumlar.append([float(x), float(y), rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0), 18])
			if v != null:
				_kronik("Bir hortum çıktı%s." % yer_adi, 1)
		"salgin":
			if v != null:
				v["salgin"] = 36
				_kronik("%s köyünde salgın başladı!" % v["ad"], 2)
		"cekirge":
			if v != null:
				v["cekirge"] = 24
				v["yemek"] = 0.0
				_kronik("Çekirgeler %s köyünün ekinlerini yedi." % v["ad"], 1)
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
			_kronik("Gökyüzünde bir UFO belirdi! Uzaylılar geldi.", 3)
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
						kita_kirli = true
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
		if _ozl_yaz(j, ozl_id["Uzaylı Geni"]):
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
			_kronik("Uzaylılar yere indi ve bir üs kurdu: %s." % kralliklar[nv["krallik"]]["ad"], 3)
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
	for s in maxi(8, n / 500):
		var k := rng.randi_range(0, n - 1)
		var b := biyom[k]
		if b == B_YANIK:
			if rng.randf() < 0.25:
				biyom[k] = B_OVA
				degisen.append(k)
		elif b == B_LAV:
			if rng.randf() < 0.12:
				biyom[k] = B_TEPE
				degisen.append(k)
				kita_kirli = true
			elif rng.randf() < 0.2:
				yangin_baslat(k % gen + rng.randi_range(-1, 1), k / gen + rng.randi_range(-1, 1))
		elif b == B_OVA and yapi[k] == 0 and rng.randf() < 0.04:
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
