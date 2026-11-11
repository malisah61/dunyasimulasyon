extends Node
## Sesler: hiçbir ses dosyası yok; hepsi açılışta kodla üretilir (telif sorunu olmaz, indirme boyutu artmaz).
## Olay sesleri (savaş borusu, isyan davulu, gök gürültüsü, sarsıntı, çan, dokunma) ve hafif bir rüzgâr/kuş ortam sesi.
## Müzik: çağa göre üç parça (Kadim: davul ve kemik flüt; Orta Çağ: Hicaz makamında lavta, bordun ve darbuka;
## Yeni Çağ: çan arpeji, bas ve pad). Parçalar oyun açıkken karelere bölünerek üretilir (takılma olmaz).

const HIZ := 22050

var acik := true
var sesler: Dictionary = {}        # ad -> AudioStreamWAV
var calicilar: Array = []
var ortam: AudioStreamPlayer
var sira := 0
var son_calma: Dictionary = {}     # ad -> son çalma zamanı (ms): aynı ses üst üste binmesin
var _tohum := 12345

# --- müzik
const MHIZ := 16000                # müzik örnekleme hızı (üretim hızı için düşük)
var muzik_acik := true
var muzik: AudioStreamPlayer
var muzik_parca := -1              # çalan parça (0 kadim, 1 orta çağ, 2 yeni çağ)
var muzik_hedef := 0               # dünyanın çağına göre çalınması gereken parça
var muzik_ses := -60.0             # anlık ses (dB): parçalar arası yumuşak geçiş
const MUZIK_DB := -17.0
var parcalar: Array = [null, null, null]     # üretilmiş AudioStreamWAV
var _uretim: Dictionary = {}                 # sürmekte olan üretim: {no, ornek, olaylar, sira, ofs, uzun}


func _ready() -> void:
	for n in 5:
		var p := AudioStreamPlayer.new()
		add_child(p)
		calicilar.append(p)
	ortam = AudioStreamPlayer.new()
	ortam.volume_db = -22.0
	add_child(ortam)
	_uret()
	ortam.stream = sesler["ortam"]
	if acik:
		ortam.play()
	muzik = AudioStreamPlayer.new()
	muzik.volume_db = -60.0
	add_child(muzik)


## Dünyanın en ileri çağı (0–6) → çalınacak parça.
func cag_ayarla(cag: int) -> void:
	muzik_hedef = 0 if cag <= 1 else (1 if cag <= 3 else 2)


func muzik_ayarla(a: bool) -> void:
	muzik_acik = a
	if not a and muzik != null:
		muzik.stop()
		muzik_parca = -1
		muzik_ses = -60.0


func _process(delta: float) -> void:
	if not muzik_acik or not acik:
		if muzik != null and muzik.playing:
			muzik.stop()
			muzik_parca = -1
		return
	# üretim: karede en çok ~1,5 ms
	if parcalar[muzik_hedef] == null:
		if _uretim.is_empty() or int(_uretim["no"]) != muzik_hedef:
			_uretim_baslat(muzik_hedef)
		_uretim_adim(1500)
	# geçiş: çalan parça hedef değilse kıs, sonra yenisini aç
	if muzik_parca != muzik_hedef:
		if muzik.playing and muzik_ses > -40.0:
			muzik_ses -= delta * 12.0
			muzik.volume_db = muzik_ses
			return
		if parcalar[muzik_hedef] != null:
			muzik.stream = parcalar[muzik_hedef]
			muzik.play()
			muzik_parca = muzik_hedef
			muzik_ses = -40.0
	elif muzik_ses < MUZIK_DB:
		muzik_ses = minf(MUZIK_DB, muzik_ses + delta * 8.0)
		muzik.volume_db = muzik_ses


## Parçanın notalarını (olay listesi) kurar; örnekler sonra karelere bölünerek yazılır.
## Olay: [başlangıç (örnek), süre (örnek), çalgı, frekans, şiddet]
func _uretim_baslat(no: int) -> void:
	var r := RandomNumberGenerator.new()
	r.seed = 1000 + no * 77
	var bpm: float = [72.0, 92.0, 104.0][no]
	var vurus := int(MHIZ * 60.0 / bpm)
	var olcu := 8
	var uzun := vurus * 4 * olcu
	var ol: Array = []
	var kok: float = [220.0, 293.66, 261.63][no]
	# diziler (kökten yarım ses aralıkları)
	var dizi: Array = [[0, 3, 5, 7, 10, 12, 15], [0, 1, 4, 5, 7, 8, 10, 12], [0, 2, 4, 7, 9, 12, 14, 16]][no]
	# ezgi: 2 ölçülük motif A, değişik A', B, A (kulakta kalsın)
	var motif: Array = []
	var d := 2
	for n in 8:
		d = clampi(d + r.randi_range(-2, 2), 0, dizi.size() - 2)
		motif.append([d, 1 if r.randf() < 0.65 else 2])   # derece, süre (yarım vuruş birimi)
	var kalip := [0, 1, 2, 0]
	for parca in 4:
		var t := parca * 2 * 4 * vurus
		var konum := 0
		for m in motif.size():
			var der: int = motif[m][0]
			if kalip[parca] == 1 and m >= 5:
				der = clampi(der + 1, 0, dizi.size() - 1)
			elif kalip[parca] == 2:
				der = clampi(dizi.size() - 1 - der, 0, dizi.size() - 1)
			var sure: int = motif[m][1] * 2 if no == 0 else motif[m][1]
			var bas: int = t + konum * vurus / 2
			if bas >= t + 8 * vurus:
				break
			var f: float = kok * pow(2.0, float(dizi[der]) / 12.0) * (2.0 if no == 2 else 1.0)
			var calgi: int = [1, 0, 2][no]      # 0 lavta, 1 flüt, 2 çan
			ol.append([bas, int(sure * vurus / 2.0 * (1.6 if calgi == 1 else 2.2)), calgi, f, 0.32 if calgi != 2 else 0.22])
			konum += sure
	# ritim ve eşlik
	for v in olcu * 4:
		var t: int = v * vurus
		match no:
			0:
				# çerçeve davulu: güçlü-zayıf; her ölçü başında kök bordun
				ol.append([t, int(vurus * 0.9), 3, 0.0, 0.5 if v % 4 == 0 else (0.28 if v % 2 == 0 else 0.15)])
				if v % 8 == 0:
					ol.append([t, vurus * 8, 5, kok * 0.5, 0.13])
			1:
				# darbuka: düm – tek – tek – düm tek (Orta Çağ çarşı havası), bordun ve kök lavta
				var dum: bool = v % 4 == 0 or v % 4 == 3
				ol.append([t, int(vurus * 0.6), 3 if dum else 4, 0.0, 0.42 if dum else 0.22])
				if v % 4 != 0:
					ol.append([t + vurus / 2, int(vurus * 0.3), 4, 0.0, 0.12])
				if v % 8 == 0:
					ol.append([t, vurus * 8, 5, kok * 0.5, 0.12])
			2:
				# akorlar: I – vi – IV – V; bas ve yumuşak arpej
				var akor: Array = [[0, 4, 7], [9, 12, 16], [5, 9, 12], [7, 11, 14]][(v / 4) % 4]
				if v % 4 == 0:
					ol.append([t, vurus * 4, 6, kok * 0.5 * pow(2.0, float(akor[0]) / 12.0), 0.3])
					for a in akor:
						ol.append([t, vurus * 4, 5, kok * pow(2.0, float(a) / 12.0), 0.05])
				ol.append([t + vurus / 2, int(vurus * 1.2), 0, kok * pow(2.0, float(akor[v % 3]) / 12.0), 0.1])
	var ornek := PackedFloat32Array()
	ornek.resize(uzun)
	_uretim = {"no": no, "ornek": ornek, "olaylar": ol, "sira": 0, "ofs": 0, "uzun": uzun}


func _uretim_adim(butce_us: int) -> void:
	var bas := Time.get_ticks_usec()
	var o: PackedFloat32Array = _uretim["ornek"]
	var ol: Array = _uretim["olaylar"]
	var uzun: int = _uretim["uzun"]
	var sira: int = _uretim["sira"]
	var ofs: int = _uretim["ofs"]
	var gurultu := 0.0
	while sira < ol.size():
		var e: Array = ol[sira]
		var t0: int = e[0]
		var sure: int = e[1]
		var calgi: int = e[2]
		var f: float = e[3]
		var g: float = e[4]
		var w := TAU * f / MHIZ
		var son := mini(sure, ofs + 800)
		for n in range(ofs, son):
			var t := float(n) / MHIZ
			var v := 0.0
			match calgi:
				0:
					# lavta / tel: birkaç harmonik, tiz olanlar daha çabuk söner
					var a := clampf(t * 300.0, 0.0, 1.0) * exp(-t * 3.2)
					v = (sin(w * n) + 0.5 * sin(2.0 * w * n) * exp(-t * 4.0) + 0.25 * sin(3.0 * w * n) * exp(-t * 7.0)) * a
				1:
					# kemik flüt: titreşimli, nefesli
					var a := clampf(t * 14.0, 0.0, 1.0) * clampf((float(sure - n) / MHIZ) * 8.0, 0.0, 1.0)
					var vib := 0.9 * sin(TAU * 5.0 * t) * clampf(t * 3.0, 0.0, 1.0)
					_tohum = (_tohum * 1103515245 + 12345) & 0x7fffffff
					v = (sin(w * n + vib) + 0.12 * sin(2.0 * w * n) + (float(_tohum) / 1073741824.0 - 1.0) * 0.05) * a
				2:
					# çan: uyumsuz kısmi sesler
					v = sin(w * n) * exp(-t * 2.4) + 0.35 * sin(2.76 * w * n) * exp(-t * 5.0) + 0.15 * sin(5.4 * w * n) * exp(-t * 9.0)
				3:
					# davul (düm): aşağı kayan alçak ses
					v = sin(TAU * (55.0 + 70.0 * exp(-t * 28.0)) * t) * exp(-t * 9.0) * 1.4
				4:
					# tek: kısa tiz tıkırtı
					_tohum = (_tohum * 1103515245 + 12345) & 0x7fffffff
					var gr := float(_tohum) / 1073741824.0 - 1.0
					v = (gr - gurultu) * exp(-t * 45.0) * 0.8 + sin(TAU * 420.0 * t) * exp(-t * 30.0) * 0.4
					gurultu = gr
				5:
					# bordun / pad: yavaş açılıp kapanan, hafif dalgalı
					var a := sin(PI * float(n) / sure)
					v = (sin(w * n) + 0.5 * sin(2.003 * w * n) + 0.25 * sin(3.0 * w * n)) * a
				6:
					# bas
					v = (sin(w * n) + 0.3 * sin(2.0 * w * n)) * exp(-t * 1.6) * clampf(t * 200.0, 0.0, 1.0)
			var k := (t0 + n) % uzun
			o[k] += v * g
		ofs = son
		if ofs >= sure:
			sira += 1
			ofs = 0
		if Time.get_ticks_usec() - bas > butce_us:
			_uretim["sira"] = sira
			_uretim["ofs"] = ofs
			return
	_uretim["sira"] = sira
	_uretim["ofs"] = 0
	# bitti: tepe bulunur, yumuşak sınırlanıp 16 bit sese çevrilir (bunlar da karelere bölünür)
	var i: int = _uretim.get("i", 0)
	var tepe: float = _uretim.get("tepe", 0.01)
	if not _uretim.has("veri"):
		while i < o.size():
			var son := mini(o.size(), i + 4000)
			for n in range(i, son):
				tepe = maxf(tepe, absf(o[n]))
			i = son
			if Time.get_ticks_usec() - bas > butce_us:
				_uretim["i"] = i
				_uretim["tepe"] = tepe
				return
		var vb := PackedByteArray()
		vb.resize(o.size() * 2)
		_uretim["veri"] = vb
		_uretim["tepe"] = tepe
		i = 0
	var veri: PackedByteArray = _uretim["veri"]
	var carp := 0.85 / tepe
	while i < o.size():
		var son := mini(o.size(), i + 4000)
		for n in range(i, son):
			veri.encode_s16(n * 2, int(tanh(o[n] * carp) * 26000.0))
		i = son
		if Time.get_ticks_usec() - bas > butce_us:
			_uretim["i"] = i
			return
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = MHIZ
	w.stereo = false
	w.data = veri
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = o.size()
	parcalar[int(_uretim["no"])] = w
	_uretim = {}


func ayarla(a: bool) -> void:
	acik = a
	if ortam == null:
		return
	if a and not ortam.playing:
		ortam.play()
	elif not a:
		ortam.stop()
		for p in calicilar:
			p.stop()


## Bir sesi çalar. `aralik_ms`: aynı ses bu süreden sık çalınmaz (hızlı oyunda kulak tırmalamasın).
func cal(ad: String, db := -8.0, aralik_ms := 250) -> void:
	if not acik or not sesler.has(ad):
		return
	var simdi := Time.get_ticks_msec()
	if simdi - int(son_calma.get(ad, -100000)) < aralik_ms:
		return
	son_calma[ad] = simdi
	var p: AudioStreamPlayer = calicilar[sira]
	sira = (sira + 1) % calicilar.size()
	p.stream = sesler[ad]
	p.volume_db = db
	p.play()


func _rastgele() -> float:
	_tohum = (_tohum * 1103515245 + 12345) & 0x7fffffff
	return float(_tohum) / 1073741824.0 - 1.0


func _wav(ornek: PackedFloat32Array, dongu := false) -> AudioStreamWAV:
	var veri := PackedByteArray()
	veri.resize(ornek.size() * 2)
	for n in ornek.size():
		var v := int(clampf(ornek[n], -1.0, 1.0) * 32000.0)
		veri.encode_s16(n * 2, v)
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = HIZ
	w.stereo = false
	w.data = veri
	if dongu:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = ornek.size()
	return w


func _uret() -> void:
	# dokunma: kısa, yumuşak tık
	var o := PackedFloat32Array()
	o.resize(int(HIZ * 0.05))
	for n in o.size():
		var t := float(n) / HIZ
		o[n] = sin(TAU * 880.0 * t) * exp(-t * 90.0) * 0.5
	sesler["tik"] = _wav(o)
	# çan: iki notalı bildirim (önemli olay)
	o = PackedFloat32Array()
	o.resize(int(HIZ * 0.7))
	for n in o.size():
		var t := float(n) / HIZ
		var a := sin(TAU * 659.0 * t) * exp(-t * 5.0)
		var b := 0.0
		if t > 0.16:
			b = sin(TAU * 988.0 * (t - 0.16)) * exp(-(t - 0.16) * 5.0)
		o[n] = (a + b) * 0.35 + sin(TAU * 1318.0 * t) * exp(-t * 9.0) * 0.08
	sesler["can"] = _wav(o)
	# savaş borusu: alçak, yükselen iki nefes
	o = PackedFloat32Array()
	o.resize(int(HIZ * 1.5))
	var faz := 0.0
	for n in o.size():
		var t := float(n) / HIZ
		var f := 110.0 + 36.0 * clampf(t / 0.5, 0.0, 1.0)
		if t > 0.75:
			f = 147.0 + 49.0 * clampf((t - 0.75) / 0.3, 0.0, 1.0)
		faz += TAU * f / HIZ
		var zarf := clampf(t / 0.06, 0.0, 1.0) * clampf((0.7 - t) / 0.12, 0.0, 1.0)
		if t > 0.75:
			zarf = clampf((t - 0.75) / 0.06, 0.0, 1.0) * clampf((1.5 - t) / 0.35, 0.0, 1.0)
		# pirinç tınısı: birkaç harmonik
		o[n] = (sin(faz) * 0.5 + sin(faz * 2.0) * 0.28 + sin(faz * 3.0) * 0.16 + sin(faz * 4.0) * 0.08) * zarf * 0.6
	sesler["boru"] = _wav(o)
	# davul: üç vuruş (isyan, darbe)
	o = PackedFloat32Array()
	o.resize(int(HIZ * 0.9))
	for n in o.size():
		var t := float(n) / HIZ
		var v := 0.0
		for bas in [0.0, 0.28, 0.5]:
			if t >= bas:
				var d: float = t - bas
				v += sin(TAU * (95.0 - 40.0 * d) * d) * exp(-d * 14.0) * 0.8 + _rastgele() * exp(-d * 40.0) * 0.15
		o[n] = v * 0.6
	sesler["davul"] = _wav(o)
	# gök gürültüsü: çatırtı ve uzayan uğultu (süzülmüş gürültü)
	o = PackedFloat32Array()
	o.resize(int(HIZ * 1.6))
	var alcak := 0.0
	for n in o.size():
		var t := float(n) / HIZ
		var g := _rastgele()
		alcak += (g - alcak) * (0.5 if t < 0.08 else 0.045)
		o[n] = alcak * (exp(-t * 2.2) * 1.6 + (0.9 if t < 0.08 else 0.0)) * (0.8 + 0.2 * sin(t * 31.0))
	sesler["gok"] = _wav(o)
	# sarsıntı: çok alçak uğultu (deprem, volkan, meteor)
	o = PackedFloat32Array()
	o.resize(int(HIZ * 1.8))
	alcak = 0.0
	for n in o.size():
		var t := float(n) / HIZ
		alcak += (_rastgele() - alcak) * 0.02
		var zarf := clampf(t / 0.15, 0.0, 1.0) * exp(-maxf(0.0, t - 0.3) * 2.0)
		o[n] = (alcak * 4.0 + sin(TAU * 42.0 * t) * 0.35 + sin(TAU * 57.0 * t + sin(t * 9.0)) * 0.25) * zarf * 0.7
	sesler["sarsinti"] = _wav(o)
	# su: sel ve tsunami (yükselip alçalan hışırtı)
	o = PackedFloat32Array()
	o.resize(int(HIZ * 1.4))
	alcak = 0.0
	for n in o.size():
		var t := float(n) / HIZ
		alcak += (_rastgele() - alcak) * (0.12 + 0.1 * sin(t * 5.0))
		o[n] = alcak * sin(PI * t / 1.4) * 1.1
	sesler["su"] = _wav(o)
	# canlı koyma: kısa "pıt"
	o = PackedFloat32Array()
	o.resize(int(HIZ * 0.09))
	for n in o.size():
		var t := float(n) / HIZ
		o[n] = sin(TAU * (420.0 + 900.0 * t) * t) * exp(-t * 38.0) * 0.5
	sesler["pit"] = _wav(o)
	# ortam: 6 saniyelik rüzgâr döngüsü ve birkaç kuş cıvıltısı (baş ve son aynı seviyede: dikişsiz)
	var sure := 6.0
	o = PackedFloat32Array()
	o.resize(int(HIZ * sure))
	alcak = 0.0
	var alcak2 := 0.0
	for n in o.size():
		var t := float(n) / HIZ
		alcak += (_rastgele() - alcak) * 0.03
		alcak2 += (alcak - alcak2) * 0.2
		var ruzgar := alcak2 * (0.55 + 0.45 * sin(TAU * t / sure)) * (0.8 + 0.2 * sin(TAU * 3.0 * t / sure))
		var kus := 0.0
		for bas in [0.9, 1.05, 3.4, 3.52, 3.66, 5.0]:
			if t >= bas and t < bas + 0.09:
				var d: float = t - bas
				kus += sin(TAU * (2400.0 + 9000.0 * d + 600.0 * sin(d * 180.0)) * d) * sin(PI * d / 0.09) * 0.12
		o[n] = ruzgar * 2.2 + kus
	# dikiş yumuşatma
	var gecis := int(HIZ * 0.05)
	for n in gecis:
		var k := float(n) / gecis
		o[n] = o[n] * k + o[o.size() - gecis + n] * (1.0 - k)
	o.resize(o.size() - gecis)
	sesler["ortam"] = _wav(o, true)
