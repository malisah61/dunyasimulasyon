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
	var sinir := 0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("yil="): yil = int(a.substr(4))
		if a.begins_with("tohum="): tohum = int(a.substr(6))
		if a.begins_with("adim="): adim = int(a.substr(5))
		if a.begins_with("nufus="): sinir = int(a.substr(6))
		if a.begins_with("boyut="):
			var p := a.substr(6).split("x")
			g = int(p[0]); y = int(p[1])
	var t0 := Time.get_ticks_msec()
	var s = SimS.new()
	s.dunya_uret(g, y, tohum)
	s.baslangic_canlilari()
	s.hareket_adim = adim
	s.nufus_siniri = sinir
	print("DOGRULAMA basladi: %dx%d tohum=%d, uretim %d ms, canli=%d" % [g, y, tohum, Time.get_ticks_msec() - t0, s.irk_nufus])
	var t1 := Time.get_ticks_msec()
	var azami_ms := 0
	var dilim_ms := 0
	var azami_nufus := 0
	for yy in yil:
		var ta := Time.get_ticks_msec()
		for a in 12:
			s.tick()
		var gecen := Time.get_ticks_msec() - ta
		azami_ms = maxi(azami_ms, gecen)
		dilim_ms += gecen
		azami_nufus = maxi(azami_nufus, s.ust - s.bos.size())
		if (yy + 1) % maxi(1, yil / 10) == 0:
			var dilim := maxi(1, yil / 10)
			print("Yil %d: irk_nufus=%d tum_canli=%d koy=%d krallik=%d din=%d dogum=%d | %.1f ms/yil | %s" % [s.yil(), s.irk_nufus, s.ust - s.bos.size(), s.koyler.size(), s.kralliklar.size(), s.din_nufuslari().size(), s.dogum_sayisi, float(dilim_ms) / dilim, str(s.irk_sayilari())])
			dilim_ms = 0
	var sure := Time.get_ticks_msec() - t1
	print("OLUMLER: ", s.olumler)
	for tur in s.irk_olum:
		if s.t_irk[tur] == 1:
			print("  %s olumleri: %s" % [s.turler[tur]["ad"], str(s.irk_olum[tur])])
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
	var kademeler := {}
	for id in s.koyler:
		var k: String = s.KADEME_AD[s.kademe(s.koyler[id])]
		kademeler[k] = int(kademeler.get(k, 0)) + 1
	print("KADEMELER: ", kademeler)
	var ittifak := 0
	for id in s.kralliklar:
		ittifak += s.kralliklar[id].get("muttefik", {}).size()
	print("DINLER: %d kurulmus, %d yasiyor; ITTIFAK cifti: %d" % [s.dinler.size(), s.din_nufuslari().size(), ittifak / 2])
	# ekonomi, huzur, isyan, ekosistem
	var hazine := 0.0
	var vergiler := [0, 0, 0]
	var harac := 0
	for id in s.kralliklar:
		var kr: Dictionary = s.kralliklar[id]
		hazine += float(kr.get("hazine", 0.0))
		vergiler[int(kr.get("vergi", 1))] += 1
		harac += kr.get("harac", {}).size()
	var huzur := 0.0
	var huzursuz := 0
	var kale := 0
	for id in s.koyler:
		huzur += float(s.koyler[id].get("huzur", 70.0))
		if float(s.koyler[id].get("huzur", 70.0)) < 30.0:
			huzursuz += 1
		kale += int(s.koyler[id]["b"][s.Y_KALE])
	var olay := {"İSYAN": 0, "BARIŞ ANTLAŞMASI": 0, "TİCARET": 0, "SEL": 0, "SAVAŞ:": 0, "saray yaptırdı": 0, "kale ile": 0, "DARBE": 0, "darbe girişimi": 0, "BİRLEŞME": 0, "İÇ SAVAŞ BİTTİ": 0, "BAĞIMSIZLIK": 0, "satın aldı": 0, "kâhini": 0}
	for k in s.kronik:
		for anahtar in olay:
			if (k[1] as String).contains(anahtar):
				olay[anahtar] += 1
	print("EKONOMI: toplam hazine %d, vergi (dusuk/orta/yuksek) %s, harac odeyen %d, kale %d" % [int(hazine), str(vergiler), harac, kale])
	print("HUZUR: ortalama %.1f, huzursuz koy %d / %d" % [huzur / maxi(1, s.koyler.size()), huzursuz, s.koyler.size()])
	print("OLAYLAR (kronikte kalan): ", olay)
	print("EKOSISTEM: ", s.ekosistem_durumu(), " gecmis ornek=", s.nufus_gecmis.size())
	# mevsimler, birlikler, altın, tarih kitabı
	var ms: PackedInt32Array = s.mevsim_say
	print("MEVSIM: dogum (kis/bahar/yaz/guz) %d/%d/%d/%d, savas ilani %d/%d/%d/%d" % [ms[0], ms[1], ms[2], ms[3], ms[4], ms[5], ms[6], ms[7]])
	var birimler := [0, 0, 0, 0, 0, 0, 0]
	for i in s.ust:
		if s.c_var[i] == 1 and s.c_durum[i] == s.D_ASKER:
			birimler[s.birim(i)] += 1
	print("BIRIMLER (piyade/okcu/tufekli/lazerli/atli/mancinik/top): ", birimler)
	var iflas := 0
	var enf := 0
	for k in s.kronik:
		if (k[1] as String).begins_with("İFLAS"): iflas += 1
		if (k[1] as String).begins_with("ENFLASYON"): enf += 1
	print("ALTIN: deger %%%d, iflas %d, enflasyon olayi %d | TARIH KITABI: %d olay, kronik %d | KRALLIK GECMISI: %d ornek" % [int(s.altin_deger * 100), iflas, enf, s.tarih.size(), s.kronik.size(), s.gecmis_kr.size()])
	print("PERFORMANS: %d yil %d ms (%.1f yil/sn), en yavas yil %d ms, en yuksek canli %d (sinir %s)" % [yil, sure, yil * 1000.0 / maxi(1, sure), azami_ms, azami_nufus, "yok" if sinir <= 0 else str(sinir)])
	var ou: PackedInt64Array = s.olc_us
	print("DAGILIM (ms): canli yillik %d, hareket %d, koy %d, krallik %d, afet+diger %d | en yavas tek ay %.1f ms" % [ou[0] / 1000, ou[1] / 1000, ou[2] / 1000, ou[3] / 1000, ou[4] / 1000, ou[5] / 1000.0])
	# hız kademelerinde bir ayın (tick) süresi: 20x (adım 1), 100x (adım 4), 500x (adım 12)
	for ad in [1, 4, 12]:
		s.hareket_adim = ad
		s.olc_us = PackedInt64Array([0, 0, 0, 0, 0, 0])
		var tb := Time.get_ticks_usec()
		for a in 48:
			s.tick()
		var gec := (Time.get_ticks_usec() - tb) / 48000.0
		print("TICK adim=%d: ort %.2f ms/ay, en yavas %.1f ms (canli %d) | yillik %.2f hareket %.2f koy %.2f krallik %.2f diger %.2f" % [ad, gec, s.olc_us[5] / 1000.0, s.ust - s.bos.size(), s.olc_us[0] / 48000.0, s.olc_us[1] / 48000.0, s.olc_us[2] / 48000.0, s.olc_us[3] / 48000.0, s.olc_us[4] / 48000.0])
	s.hareket_adim = adim
	var ok: bool = s.kaydet("user://dogrulama.kayit")
	var s2 = SimS.new()
	var ok2: bool = s2.yukle("user://dogrulama.kayit")
	print("KAYIT: yaz=%s oku=%s nufus=%d/%d" % [ok, ok2, s.irk_nufus, s2.irk_nufus])
	for a in 24:
		s2.tick()
	print("DOGRULAMA bitti")
	quit()
