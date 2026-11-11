extends Node
## Sesler: hiçbir ses dosyası yok; hepsi açılışta kodla üretilir (telif sorunu olmaz, indirme boyutu artmaz).
## Olay sesleri (savaş borusu, isyan davulu, gök gürültüsü, sarsıntı, çan, dokunma) ve hafif bir rüzgâr/kuş ortam sesi.

const HIZ := 22050

var acik := true
var sesler: Dictionary = {}        # ad -> AudioStreamWAV
var calicilar: Array = []
var ortam: AudioStreamPlayer
var sira := 0
var son_calma: Dictionary = {}     # ad -> son çalma zamanı (ms): aynı ses üst üste binmesin
var _tohum := 12345


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
