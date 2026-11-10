extends SceneTree
## Ekransız doğrulama: uzun hızlı simülasyon. Kullanım:
##   godot --headless -s betikler/dogrulama.gd -- yil=300 tohum=7 boyut=256x160
const SimS = preload("res://betikler/sim.gd")

func _init() -> void:
	var yil := 300
	var tohum := 7
	var g := 256
	var y := 160
	var adim := 12
	for a in OS.get_cmdline_user_args():
		if a.begins_with("yil="): yil = int(a.substr(4))
		if a.begins_with("tohum="): tohum = int(a.substr(6))
		if a.begins_with("adim="): adim = int(a.substr(5))
		if a.begins_with("boyut="):
			var p := a.substr(6).split("x")
			g = int(p[0]); y = int(p[1])
	var t0 := Time.get_ticks_msec()
	var s = SimS.new()
	s.dunya_uret(g, y, tohum)
	s.baslangic_canlilari()
	s.hareket_adim = adim
	print("DOGRULAMA basladi: %dx%d tohum=%d, uretim %d ms, canli=%d" % [g, y, tohum, Time.get_ticks_msec() - t0, s.irk_nufus])
	var t1 := Time.get_ticks_msec()
	var azami_ms := 0
	for yy in yil:
		var ta := Time.get_ticks_msec()
		for a in 12:
			s.tick()
		azami_ms = maxi(azami_ms, Time.get_ticks_msec() - ta)
		if (yy + 1) % maxi(1, yil / 10) == 0:
			print("Yil %d: irk_nufus=%d koy=%d krallik=%d dogum=%d | %s" % [s.yil(), s.irk_nufus, s.koyler.size(), s.kralliklar.size(), s.dogum_sayisi, str(s.irk_sayilari())])
	var sure := Time.get_ticks_msec() - t1
	print("OLUMLER: ", s.olumler)
	var caglar := {}
	for id in s.koyler:
		var c: String = s.CAG_AD[s.koyler[id]["cag"]]
		caglar[c] = int(caglar.get(c, 0)) + 1
	print("CAGLAR: ", caglar)
	print("KRONIK (son 25 onemli):")
	var say := 0
	for n in range(s.kronik.size() - 1, -1, -1):
		if s.kronik[n][2] >= 2:
			print("  Yil %d: %s" % [s.kronik[n][0] / 12 + 1, s.kronik[n][1]])
			say += 1
			if say >= 25: break
	print("PERFORMANS: %d yil %d ms (%.1f yil/sn), en yavas yil %d ms" % [yil, sure, yil * 1000.0 / maxi(1, sure), azami_ms])
	var ok: bool = s.kaydet("user://dogrulama.kayit")
	var s2 = SimS.new()
	var ok2: bool = s2.yukle("user://dogrulama.kayit")
	print("KAYIT: yaz=%s oku=%s nufus=%d/%d" % [ok, ok2, s.irk_nufus, s2.irk_nufus])
	for a in 24:
		s2.tick()
	print("DOGRULAMA bitti")
	quit()
