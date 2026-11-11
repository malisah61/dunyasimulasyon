# Gece günlüğü

## 2026-11-11 (5. çalışma) — Gece 6: limanlar ve deniz ticareti, köpekler ve kurt sürüleri, kutsama ve lanet, 14 boş özellik etkisi

### Analiz bulguları (dogrulama 256x160 tohum 7/3, 300 yıl; 512x320 tohum 5 kayıtlı dünya, sınırsız nüfus)
- **Yırtıcılar yok oluyordu:** tohum 7'de 300 yılda kurt 4–14, ayı 0–6 (kapasite 15); tohum 3'te ayı 250. yılda **0**. Kurtlar tek tek avlanıyor, aç kalıp ölüyordu (açlık 34, yaşlılık 126); ayılar yalnızca et yiyordu.
- **100 özelliğin 44 etki anahtarı hiçbir yerde okunmuyordu** (ör. Karizmatik/İtici eş bulma, Neşeli/Karamsar moral, Dalgın/Sakar/Lanetli kaza, Kutsanmış/Lanetli şans, Yenilenen iyileşme, Usta Demirci/Mucit silah-zırh yapımı, Hayvan Terbiyecisi, Doğa Dostu, Denizci, Yüzücü, Hain/Sadık sadakat).
- **Deniz hiç kullanılmıyordu:** kıtalar arasında ticaret, bilgi akışı yoktu; ada krallıkları yalnız kalıyordu. Liman binası yoktu.
- **Tanrı gücü "Bereket" tek seferlikti**, uzun süreli kutsama/lanet yoktu (TASARIM §11).
- **Hız (512x320, ~22 bin canlı, kayıtlı dünya):** 20x'te (adim 2) bir ay ~18–20 ms, bunun ~12 ms'si köyünde gezinen sivillerin yürümesi (100x–500x'te seyrek yürüyüş vardı, 20x'te yoktu). Kalabalık dünyada yeni köy yeri arama (`_yer_bul`) ayda ~0,6 ms'ydi. Askerin krallığı her adımda sözlükten okunuyordu.
- Denenip geri alınan: "ordu ızgarası" (cepheden uzak askerler düşman taramasın) — ölçünce askerlerin yalnızca %3'ü cepheden uzaktaydı (askerler hep hedef köyün başında), kazanç yoktu; kaldırıldı.

### Kasma ölçümü (önce → sonra)
**Aynı kayıtlı dünya** (512x320 tohum 5, 250. yıl, ~22 bin canlı), Gece 5 kodu ve bu gecenin kodu dönüşümlü 4–5 kez, her biri 3 denemenin en iyisi, bir ayın süresi (bulut makinesi ±%15 oynuyor). "Sonra" yeni sistemlerin (gemiler, köpekler, kurt sürüleri, kutsama) yükünü de taşır:

| Hız | Bir ay (önce → sonra) | Hareket |
|---|---|---|
| 20x (adim 2) | 17.3–19.5 → **14.2–16.8 ms** (≈ −%15) | 11.1–12.8 → **8.7–10.3 ms** (≈ −%20) |
| 100x (adim 6) | 7.2–9.2 → 8.1–9.6 ms (gürültü içinde aynı) | 2.3–2.9 → 2.3–2.9 ms |
| 500x (adim 12) | 5.6–7.9 → 6.7–8.4 ms (gürültü içinde aynı) | 0.9–1.3 → 1.3–1.6 ms (yaşayan kurt sürüleri her adımda yürür) |

Köy işi (`_koy_yillik`, 512x320): yeni köy yeri arama ön elemesi ile ayda **2.1 → 1.35 ms**.
dogrulama (256x160 tohum 7, 300 yıl): 4.37 → **4.09 sn**; ayın süresi (dogrulama artık oyunun gerçek adımlarıyla ölçüyor: 2/6/12) adim 12: 2.81 → **1.77 ms**.
Kare ölçümü (`olcum`, derleme makinesi, `onizleme/olcum.txt`): bu gece derleme makinesi belirgin yavaştı — simülasyonun hiç çalışmadığı 1x satırlarında bile kare %30–37 uzun (az/uzak/1x 14.0 → 19.1 ms, Dev/uzak/1x 21.5 → 29.5 ms). Bu yüzden ulaşılan hız düştü görünüyor (Dev/uzak/100x 63 → 34 ay/sn): kare bütçesi çizime giden süre uzayınca simülasyona daha az ay bırakır. Kod karşılaştırması için yukarıdaki aynı-dünya tablosu esas.
- Derleme sonrası ek düzeltme: yırtıcıların yıllık av araması (15x15 karo) aç kurtta birer atlanarak taranır — kurdun yıllık işi **37 → 21 µs**, ayınınki **34 → 15 µs** (512x320'de ayda ~0,15 ms).

### Performans (yapılanlar)
- **20x'te de seyrek sivil yürüyüşü:** köyünde gezinen siviller ve otlayan hayvanlar 20x'te iki ayda bir, iki kat adımla yürür (100x–500x'te dört kat). Toplam yol aynı, 20x'te ayın hareket işi ~%20 az.
- **Köy yeri arama ön eleme:** aday karonun ızgara hücresinde 10 karo içinde köy varsa 8 örnekli puanlama yapılmadan geçilir (dolu dünyada adayların çoğu böyle).
- **Askerin krallığı dizide (`kv_kr`):** düşman/savaş denetimleri sözlüksüz.
- **Deniz rotaları önbellekte:** liman çiftlerinin rotası bir kez hesaplanır (50 yılda bir tazelenir); ortak yalnızca limanlı köyler listesinden aranır.

### Görünürlük
- **Ticaret gemileri:** limandan limana yelkenli gemiler yol alır — kahverengi gövde, krallık renkli şerit ve flama, rüzgârda dalgalanan iki yelken, dalga izi. Uzaktan bakınca deniz yolu ince kesik çizgiyle görünür, gemi ekranda en az ~14 piksel kalır.
- **Liman binası:** iskele, ambar ve vinç (yakında 8x8, uzakta 4x4 desen).
- **Kutsanmış köy:** altın ışıltı, yükselen kıvılcımlar, üstünde güneş simgesi; adı ☀ ile yazılır. **Lanetli köy:** mor halka, kara bulut, yağmur, ara sıra mor şimşek; adı ☁ ile. Kutsama anında gökten altın ışık sütunu, lanette mor yıldırım.
- **Generallerin adı haritada:** yıldızın altında "★ Gen. Ad" (orta ve yakın uzaklıkta, köy adlarıyla çakışmaz).

### Oynanabilirlik
- **Güçler → Kutsa / Lanetle:** köye dokun; on yıl sürer, ipucu ne olacağını anlatır. Kutsama laneti kaldırır.
- **Köy kartı:** huzur satırının hemen altında kutsama/lanet durumu (kalan yıl), "⚓ Liman", köpek sayısı, "⚓ Deniz yolları" (deniz ticareti ortakları).
- **Canlı kartı:** köpekte "Sahibi: … köyü", kurtta "Sürü avcısı".

### Mantık
- **Kurt sürüleri ve ayı:** tok kurt sürüdaşının yanında dolaşır, sürü halinde %60 sert ısırır ve avı paylaşır, kurt yavruları batın batın doğar; aç kurt köpeksiz köyün sürüsüne dadanır (köyün yiyeceği azalır); ayı ormanda, tepede, dağda ve kıyıda böğürtlen, bal ve balıkla açlıktan kurtulur. Aynı tohumla 300 yıl (30 yılda bir sayım), önce → sonra: tohum 3 kurt ortalama **25 → 30–32** (en düşük **1 → 12–23**), tohum 7 kurt **7.8 → 9.7–10.1** (iki ayrı ölçüm). Ayı sayısı değişmedi (2–16 arası, gürültü içinde) — sıradaki gece.
- **14 özellik etkisi artık işliyor** (bkz. derinleştirilenler).
- **Hain general düşmana geçer** (TASARIM §4).

### Görsel kalite ve detay
- Yakın plan hayvanlar ayırt edilir: koyunun yünü, ineğin benekleri ve boynuzları, geyiğin çatallı boynuzu ve beyaz kuyruğu, tavşanın uzun kulakları, kurdun sivri kulakları ve sarı gözleri, ayının yuvarlak kulakları, köpeğin sallanan kuyruğu ve krallık renkli tasması. Gemiler, liman, kutsama/lanet ışıltıları.

### Derinleştirilen 3 özellik
1. **Canlı özellikleri (§4 "etkiler gerçekten oyunu değiştirmeli"):** 44 okunmayan anahtardan 14'ü işler hale geldi — eş bulma (Karizmatik +, İtici/Yalnız Kurt −) doğurganlığa; moral (Neşeli, Karamsar, Cesur, Kutsanmış…) cesarete; zanaat (Sakar) çalışkanlığa; kaza (Dalgın, Sakar, Simyacı, Lanetli) yıllık kaza ölümü (300 yılda ~20); şans (Kutsanmış/Lanetli) darbeden sıyrılmaya; iyileşme (Yenilenen) yaraların her yıl tamamen kapanmasına; silah/zırh yapımı (Usta Demirci, Mucit) köyün silahına ×1.15 ve zırhına +%6; evcilleştirme (Hayvan Terbiyecisi) kurt evcilleştirmeye; hayvan saldırısı (Doğa Dostu) yırtıcıların dokunmamasına; denizcilik (Denizci) deniz seferi sıklığına; yüzme/boğulma (Yüzücü) tsunami ve selden %70 kurtulmaya; sadakat (Hain) generalin düşmana geçmesine. Hepsi önceden hesaplı (sıcak döngüde sözlük yok).
2. **Generaller:** Hain general savaşta köyüyle birlikte düşman safına geçebilir ("İHANET", ekranda bildirim; ordu sarsılır ×0.85); generallerin adı haritada yazılır.
3. **Hayvan ekosistemi:** kurt sürüleri, ayının her şeyi yemesi, köpeklerin yırtıcıları kovalaması ve avcılara yardımı.

### Eklenen yeni sistemler (TASARIM.md)
1. **Liman ve deniz ticareti (§6, §7):** Demir Çağı'ndan itibaren 30+ nüfuslu kıyı köyleri açık denize bakan bir karoya liman kurar. Limanlı köy her yıl %35 (denizcisi varsa %55) olasılıkla uzak bir limana gemi yollar: rota düz ya da tek dönüşlü deniz yoludur. İki köy altın kazanır (kıtalar arası ×1.6), aç limana tahıl gider, geride kalan liman öndekinden bilgi öğrenir (teknoloji farkının %4'ü). Korsanlar savaşta, huzursuz kıyılarda ve uzun seferlerde gemi soyar. Krallıklar arası ilk deniz yolu kroniğe ve tarih kitabına yazılır; deniz ortakları birbirine zor savaş açar. Tohum 7, 300 yıl: **57 liman, ~1100 sefer, ~50 korsan baskını**.
2. **Evcilleştirme: köpekler (§3):** köy yakınındaki kurtlar zamanla evcilleşip köpek olur (Hayvan Terbiyecisi olan köyde çok daha hızlı); "EVCİLLEŞTİRME" kroniği. Köpek köyüne bağlı yaşar, halkın sekizde biri kadar çoğalır, yaklaşan kurda/ayıya saldırır; köpekli köyün avcıları daha uzaktan iz sürer ve %40 fazla et getirir. Köyü yıkılan köpek komşu köye sığınır. Kurtlar ancak kapasitelerinin %80'ini aşınca evcilleşir (yabani sürü tükenmesin). Tohum 3: 300 yılda ~200 köpek, kurtlar 23–43 arasında kaldı.
3. **Kutsama ve lanet (§11):** Güçler'de "Kutsa" (on yıl: ekin ×1.4, doğum ×1.3, huzur +10, inanç daha kolay doğar, çocukların %4'ü Kutsanmış doğar) ve "Lanetle" (on yıl: ekin ×0.45, doğum ×0.6, huzur −15, salgın olabilir, halk tapınak ister, çocukların %4'ü Lanetli doğar). Doğrulama denemesi: 5 yılda kutsanan köy huzur 100, lanetli köy 45.

### Kayıt
- `KAYIT_SURUMU` 7: yeni bina tipi Liman (köylerin bina sayacı 16 elemana uzar, eski köyler yüklemede genişletilir), köyde kutsal/lanet/liman/liman_yok/kopek, krallıkta deniz/kopek/liman_ilk. Hepsi isteğe bağlı; eski kayıt dönüştürme gerekmeden açılır. Yeni tür Köpek listenin sonuna eklendi (eski kayıtlardaki tür numaraları değişmedi). Gemiler kaydedilmez (yolda olanlar yüklemede kaybolur, yenileri çıkar).

### Sorunlar / sonraki gece
- Ölçüm makinesi çok gürültülü (aynı kod art arda %20 oynuyor); 100x/500x'te değişim gürültü içinde kaldı. Bir sonraki adım: canlı yıllığını (ayın %40'ı) bölmek — doğum ve ölüm dışındaki işleri köy düzeyine taşımak.
- Kurtlar 200. yıldan sonra yine azalıyor (otobur kapasitesi düşüyor, evcilleştirme); göç onları geri getiriyor ama sürüler küçük.
- Gemiler henüz asker taşımıyor (deniz aşırı çıkarma, deniz savaşı) — sıradaki adım.

## 2026-11-11 (4. çalışma) — Gece 5: generaller, zırhlar, haydutlar, çağa göre müzik, göçmen kabileler

### Analiz bulguları (dogrulama 256x160 tohum 7/3, 512x320 tohum 5; 300 ve 1000 yıl, sınırsız nüfus)
- **Devler tohum 7'de 300 yıl boyunca tek kişiydi:** 14 devin 15'i ilk savaşlarda öldü, kalan tek dev eşsiz kaldı; ırk fiilen yok olmuştu ama haritada "1" olarak duruyordu.
- **Kervan ticareti neredeyse yoktu:** 300 yılda yalnızca **5 kervan** (yalnızca aç köye tahıl taşınıyordu, alıcı rastgele tüm haritadan seçiliyor, çoğu 50 karodan uzak çıkıyordu).
- **Askerin zırhı yalnızca resimdi:** göğüslük/miğfer çiziliyordu ama hasarı azaltmıyordu; 100 özelliğin `savas_taktik` (Stratejist), `moral_ordu` (Kahraman), `kusatma` (Sabırlı) etkileri hiçbir yerde okunmuyordu.
- **Afetlerin sonrası boştu:** deprem, volkan, meteor köyü yıkıyor ama halkın inancına, huzuruna bir etkisi olmuyordu.
- **Hız (ölçerek bulunan darboğazlar, 512x320, 29 bin canlı, 500x'te bir ay ~13 ms):** krallıkların savaş hedefi araması her seferinde tüm köy sözlüğünü 6 kez tarıyordu (ayda ~1 ms); kalabalık dünyada köyler her yıl 60 deneme × 8 örnekle boşuna yeni köy yeri arıyordu; her doğumda özellik etkileri sözlüklerden 8 kez okunuyordu (doğum başına ~21 µs).

### Kasma ölçümü (önce → sonra)
**Aynı kayıtlı dünya** (512x320 tohum 5, 250. yıl, ~29 bin canlı), Gece 4 kodu ve bu gecenin kodu art arda, bir ayın süresi (2–3 ölçüm ortalaması; bulut makinesi ±%15 oynuyor). "Sonra" yeni sistemlerin (generaller, 15 kat artan kervan ticareti, haydutlar) yükünü de taşıyor:

| Hız | Bir ay | Hareket | Krallıklar |
|---|---|---|---|
| 500x (adim 12) | 13.1 → **10.4 ms** (−%21) | 3.15 → **1.75 ms** | 1.68 → **0.99 ms** |
| 100x (adim 6) | 13.5 → 13.4 ms | 4.5 → **3.9 ms** | 1.42 → **1.13 ms** |
| 20x (adim 2) | 28.6 → **26.7 ms** (−%7) | 18.1 → **17.1 ms** | 1.72 → **1.14 ms** |

256x160 tohum 3 (~10 bin canlı, aynı kayıt): 100x'te bir ay 4.0–4.8 → **3.4–3.7 ms**, hareket 1.6–1.9 → **1.1–1.2 ms**; 500x aynı (~3.1 ms).

Kare ölçümü (`olcum`, yazılım çizimi; dünyalar yeni kurallarla farklı büyüdü, "çok" senaryosu bu gece ~%20 daha az kalabalık — asıl karşılaştırma yukarıdaki aynı-dünya tablosu):

| Nüfus | Görünüm | Hız | Canlı (önce → sonra) | Ort. kare ms | En yavaş kare ms | Ulaşılan hız (ay/sn) |
|---|---|---|---|---|---|---|
| az | uzak | 500x | 2429 → 3362 | 44.4 → **39.7** | 65.6 → **56.6** | 245 → **287** |
| az | yakın | 100x | 1178 → 1123 | 34.0 → **29.9** | 54.4 → **46.3** | 99 → 99 |
| orta | uzak | 100x | 6157 → 5074 | 50.4 → 46.8 | 70.6 → 69.2 | 71 → **87** |
| orta | uzak | 500x | 6018 → 5686 | 52.5 → 47.4 | 96.0 → **63.1** | 78 → **129** |
| orta | yakın | 500x | 6010 → 5314 | 56.8 → 56.6 | 83.9 → 75.9 | 70 → **83** |
| orta | çok yakın | 100x | 5846 → 5244 | 53.3 → 45.5 | 77.3 → 69.9 | 68 → **87** |
| çok (Dev) | uzak | 100x | 11488 → 9112 | 64.3 → 59.7 | 83.2 → 88.1 | 28 → **39** |
| çok (Dev) | yakın | 100x | 11503 → 9143 | 70.6 → 65.8 | 103.6 → **88.9** | 25 → **36** |
| çok (Dev) | yakın | 500x | 11742 → 9433 | 69.8 → 69.4 | 97.2 → 94.7 | 28 → **37** |
| çok (Dev) | çok yakın | 100x | 11328 → 9082 | 61.6 → 55.2 | 92.2 → 79.0 | 28 → **43** |

Derleme makinesinde (CI, `onizleme/olcum.txt`, Gece 4 → Gece 5): Dev harita 100x uzak **37 → 60 ay/sn** (11.7 → 13.2 bin canlı, kare 53.8 → 40.6 ms), 500x uzak **39 → 71 ay/sn**; orta 500x uzak **118 → 244 ay/sn**. (Derleme makineleri her seferinde aynı olmayabilir; yön tutarlı.)

1x'te kareler değişmedi (ölçüm gürültüsü içinde; 1x'te simülasyon karenin %1'inden az, karenin çoğu yazılım çizimiyle haritanın kendisi).

### Performans (yapılanlar)
- **Krallık aramaları dizilerden:** köylerin konumu, krallığı ve kıtası ayda bir paketli dizilere yazılır; savaş hedefi, düşman köyleri, kervan alıcısı, afet çevresi bu dizilerden aranır (sözlük taraması yok). Krallık işi ayda 1.7 → 1.0 ms.
- **Özellik etkileri önceden hesaplı:** liderlik, vuruş, okçuluk, kaçınma, önsezi/ihanet/şifa bitleri ve komutanlık puanı her özellik için bir kez diziye yazılır; doğumda ve yüklemede sözlük okunmaz. Irkların doğuştan eğilimleri de dizide.
- **Dolu dünyada boşa arama yok:** yeni köy yeri bulamayan köy 5 yıl yeniden aramaz.
- **100x–500x'te siviller dört kat seyrek, dört kat uzun adımla yürür** (önce iki kat). Toplam yol aynı; askerler, avcılar, göçenler her adımda.

### Görünürlük
- **Generaller:** savaşan her ordunun komutanı haritada her uzaklıkta krallık renginde, altın kenarlı ★ yıldızla görünür. Yakında: rüzgârda dalgalanan pelerin, kırmızı tüylü miğfer, altın kuşak. Orta uzaklıkta altın tüy.
- **Zırhlar çağa göre:** Taş Çağı deri yelek, Tunç göğüslük, Demir zincir zırh (benekli), Orta Çağ plaka (parlak omuzluklar), Sanayi çelik yelek, Uzay enerji kalkanı (titreyen mavi halka).
- **Haydut baskını efekti:** devrilmiş kervan arabası, saçılan yük, bıçaklı iki karaltı, kırmızı uyarı halkası. Kervanlar artık 15 kat sık yola çıkıyor: haritada yürüyen arabalar ticaretin nereden nereye aktığını gösteriyor.

### Oynanabilirlik
- **Savaşlar paneli:** her savaşta iki tarafın generali (komuta gücüyle); adına dokununca generale gidilir. "Son savaş olayları"nda general atamaları ve düşen generaller.
- **Köy kartı:** "Ordu: silah · zırh (%)" satırı, "★ General" düğmesi (generale git), haydut ve tanrı öfkesi uyarıları. **Canlı kartı:** "★ General — ordunun komutanı (komuta ×1.12)", "Silah · Zırh".
- **Müzik:** Menü → "Müzik (çağa göre)" açılıp kapanır (ayar saklanır).

### Mantık
- **Zırh hasarı keser:** kılıcı ve oku tam, kurşunu %40, gülleyi hiç; lazeri yalnızca enerji kalkanı keser. Demirhane zırhı artırır (en çok %50).
- **Generaller** (bkz. yeni sistemler) savaşın gidişini değiştirir: usta general ×1.4'e kadar, Korkak ×0.8'e kadar.
- **Göçmen kabile:** bir zamanlar 12+ kişiye ulaşıp 6'nın altına düşen ırka uzak diyarlardan 10 kişilik kabile gelir (yılda %7). Tamamen yok olan ırk geri gelmez, boş başlayan dünyada kendiliğinden ırk çıkmaz. Tohum 7, 300. yıl: **Dev 1 → 166**.
- **Avcı hayvanlar:** açlıktan ölüm yılda %15 → %10, aç avcı daha geniş alanda av arar.

### Görsel kalite ve detay
- General pelerini/tüyü/kuşağı, çağa göre beş farklı zırh, haydut baskını efekti, savaş paneline ★ işaretleri.

### Derinleştirilen 3 özellik
1. **Savaş:** zırh değeri (deri → tunç → zincir → plaka → çelik yelek → enerji kalkanı), komutanlar, düşen şehirle düşen general.
2. **Ticaret/ekonomi:** kervanlar artık yalnızca kıtlıkta değil, her yıl mal (zanaat, kumaş, demir) taşır, iki köy de kazanır; 300 yılda 5 → ~3300 kervan (tohum 3).
3. **Din:** afet sonrası "TANRILAR KIZDI" — çevre köyler 5 yıl korkar (tapınağı olan köy daha az), tapınaksız köy önce tapınak yapar, dinsiz krallıkta inanç doğabilir, inancından yüz çeviren halk yeni inanç kurabilir.

### Eklenen yeni sistemler (TASARIM.md)
1. **Generaller (§8):** savaş başlayınca iki taraf da ordusunun başına komutan atar (liderlik, Stratejist, Kahraman, Cesur, Sabırlı, savaş deneyimi; Korkak eksi). General askerlerin vuruşunu ve kuşatmayı ×0.8–1.4 değiştirir, öldürdükçe ustalaşır. Düşen şehri savunan general çoğu zaman şehirle düşer: "GENERAL DÜŞTÜ … Ordu sarsıldı" (ordu bir yıl ×0.85, savaş yorgunluğu artar). 512x320, 300 yıl: 138 general atandı, 24'ü savaşta düştü.
2. **Haydutlar kervan soyar (§6):** huzursuz topraklarda, savaşta, iflasta ve uzun yollarda kervanlar soyulur; gözetleme kulesi yolu korur. Soygunlar birikince krallık hazineden asker yollayıp yolları temizler; temizlemezse halk huzursuzlanır. Tohum 3: 300 yılda ~200 soygun / ~3300 kervan.
3. **Çağa göre müzik (§14):** dosyasız, kodla üretilen üç parça — Kadim (Taş/Tunç: kemik flüt, çerçeve davulu, bordun), Orta Çağ (Demir/Orta: Hicaz makamında lavta, darbuka düm-tek, bordun), Yeni Çağ (Barut ve sonrası: çan arpeji, bas, pad). Dünyanın en ileri çağına göre yumuşak geçişle değişir. Parçalar oyun açıkken karede ≤1,5 ms'lik dilimlerle üretilir (takılma yok; ~0,6–1,2 sn toplam iş).
- Ek: **göçmen kabile**, **tanrıların öfkesi** (§10 afet sonrası din etkisi).

### Kayıt
- `KAYIT_SURUMU` 6: krallıkta general/general_uid/komuta/haydut, köyde ofke/tapinak_iste/goc_bekle. Hepsi isteğe bağlı; eski kayıt dönüştürme gerekmeden açılır (generalsiz başlar).

- Düzeltme: köyü yıkılan ya da krallık değiştiren general görevden düşer (ilk derlemenin ekran görüntüsünde köysüz bir general adada yalnız kalmıştı).

### Sorunlar / sonraki gece
- 100x'te (adim 6) ayın süresi yeni sistemlerle birlikte aynı kaldı; hareketin büyük kısmı artık cephedeki askerlerin düşman taraması. Sıradaki adım: krallık başına kaba "ordu ızgarası" ile cepheden uzak askerlerin taramayı atlaması.
- Avcı hayvanlar büyük haritada kapasitenin altında (16 / 165); köylüler kurtları avlıyor. Kurt sürüleri ve köpek evcilleştirme düşünülmeli.
- Müzik bulutta yalnızca dalga şekliyle denetlendi (spektrum); telefonda ses düzeyi fazla gelirse Menü'den kapatılabilir.


## 2026-11-11 (3. çalışma) — Gece 4: mevsimler, atlılar ve kuşatma makineleri, altın/teknoloji grafikleri, tarih kitabı

### Analiz bulguları (dogrulama 256x160 tohum 3 ve 512x320 tohum 5, 300 yıl, sınırsız nüfus)
- **Cüceler neredeyse yok oluyordu:** küçük haritada 300 yılda 9–31 cüce (ölüm yok denecek kadar az, doğum da yok). Sebep: dağa bina kurulamıyordu; dağdaki cüce köyünün evi olmadığı için kapasitesi 12'de takılıyor, doğum duruyordu.
- **Goblinler büyük haritayı kaplıyordu:** 512x320'de 30,7 bin canlının 17 bini goblin.
- **Mevsim yalnızca isimdi:** takvimde "Kış/Yaz" yazıyordu ama doğum, salgın, savaş, yürüyüş mevsimden etkilenmiyordu; kış örtüsü haritaya düz bir beyaz bant çiziyordu.
- **Kronik 3000 satırla sınırlı:** uzun oyunda ilk yüzyılların savaşları siliniyordu.
- **Altın sınırsız birikiyordu**, fiyatlar hiç değişmiyordu; hazinesi tükenen krallığın başına bir şey gelmiyordu.
- **Hız:** 500x'te tek ay 10 bin canlıda 4,0 ms; bunun 1,27 ms'si köyünde gezinen sivillerin yürümesi.

### Kasma ölçümü (önce → sonra; aynı makine, Gece 3 kodu ile bu gecenin kodu art arda; yazılım çizimi)
Yeni satır: **çok yakın** görünüm (yakınlık 7). "Sonra" dünyaları cücelerin hayatta kalması yüzünden biraz daha kalabalık.

| Nüfus | Görünüm | Hız | Canlı (önce → sonra) | Ort. kare ms | En yavaş kare ms | Canlı çizimi ms | Ulaşılan hız (ay/sn) |
|---|---|---|---|---|---|---|---|
| az | uzak | 500x | 3234 → 2774 | 41.6 → **37.1** | 71.1 → **58.2** | 0.5 → 0.4 | 254 → **346** |
| az | çok yakın | 100x | 1151 → 966 | 26.6 → **21.2** | 66.7 → **32.3** | 0.6 → 0.4 | 100 → 99 |
| orta | uzak | 1x | 4435 → 4885 | 31.0 → **27.7** | 60.4 → **40.2** | 0.5 → 0.5 | 1 → 1 |
| orta | uzak | 100x | 5061 → 6170 | 44.7 → **37.7** | 69.6 → **52.9** | 1.0 → 0.8 | 83 → **99** |
| orta | yakın | 1x | 4435 → 4885 | 31.5 → **26.2** | 45.1 → **35.7** | 3.3 → **2.2** | 1 → 1 |
| orta | yakın | 20x | 4521 → 5017 | 38.6 → **29.7** | 58.6 → **40.1** | 3.5 → **2.4** | 20 → 20 |
| orta | yakın | 100x | 5055 → 6222 | 53.6 → **39.9** | 70.3 → **60.1** | 3.9 → **2.8** | 72 → **98** |
| orta | yakın | 500x | 5438 → 6204 | 56.5 → **50.0** | 78.6 → 93.2 | 4.8 → **3.4** | 83 → **103** |
| orta | çok yakın | 1x | 4435 → 4885 | 33.2 → **27.9** | 46.1 → **41.2** | 2.9 → **2.1** | 1 → 1 |
| orta | çok yakın | 100x | 5266 → 6159 | 53.5 → **46.2** | 70.8 → **67.7** | 3.9 → **3.0** | 70 → **87** |
| çok (Dev) | uzak | 1x | 9783 → 9815 | 40.3 → **33.9** | 55.8 → **47.0** | 1.8 → 1.0 | 1 → 1 |
| çok (Dev) | uzak | 100x | 11289 → 11701 | 58.8 → **56.3** | 86.1 → **76.7** | 2.3 → 2.4 | 30 → **36** |
| çok (Dev) | yakın | 1x | 9696 → 9788 | 52.7 → **38.1** | 82.9 → **62.6** | 6.7 → **3.8** | 1 → 1 |
| çok (Dev) | yakın | 20x | 10646 → 10607 | 65.0 → **53.7** | 91.4 → **76.4** | 6.3 → **4.4** | 15 → **19** |
| çok (Dev) | yakın | 500x | 11607 → 12135 | 71.2 → **57.8** | 104.9 → **79.3** | 6.8 → **4.5** | 31 → **42** |
| çok (Dev) | çok yakın | 1x | 9783 → 9815 | 41.0 → **30.1** | 57.3 → 61.1 | 3.8 → **1.8** | 1 → 1 |
| çok (Dev) | çok yakın | 100x | 11378 → 11800 | 60.7 → **50.7** | 76.6 → **66.6** | 4.7 → **3.0** | 30 → **39** |

Ekransız (dogrulama, 256x160 tohum 3, ~10 bin canlı): 500x'te tek ay **4,00 → 3,41 ms** (hareket 1,27 → 0,92 ms), 100x'te 5,54 → 5,66 ms (aynı), en yavaş tek ay **19,1 → 9,2 ms**; 300 yıl 7,8 → 7,2 sn.

Not: ölçüm sırasında bir deneme yanlış çıktı ve geri alındı — tüm canlıları mip-haritalı atlas resimleriyle çizmek CPU'yu hafifletmedi, yazılım çiziminde kareyi ~10 ms ağırlaştırdı. Son hâli: orta-yakında düz dikdörtgen, çok yakında (12 dikdörtgen yerine) 3 resim, iki boy atlas, mipmap yok.

### Performans (yapılanlar)
- **Seyrek sivil yürüyüşü (100x–500x):** köyünde gezinen siviller ve otlayan hayvanlar iki ayda bir, iki kat adımla yürür; askerler, avcılar, göçenler her adımda. Toplam yol aynı, hareket işi ~%30 az.
- **Canlı katmanı ayrıldı:** canlılar ve efektler haritanın alt düğümlerinde çizilir; çok yakında bir canlı 3 hazır resimle (gövde/baş/saç) çizilir, her resim yalnızca dolu bölgesiyle (boş saydam alan yok). İki boy atlas: ekrana ~1:1 düşer, titremez.
- **Mevsim boyaması ekran kartında:** harita yeniden çizilmeden, gölgelendiricide; işi olmayan dallar atlanır (kış yoksa kar hesabı yapılmaz).
- `olcum` moduna "çok yakın" satırları ve `sadece=… gorunum=…` süzgeci eklendi (tek satırı 20 saniyede ölçmek için).

### Görünürlük
- **Atlılar** (atın/kurdun üstünde, krallık renkli eyer örtüsü, uzun mızrak ve flama), **mancınık** (kolunu savurur, taş fırlatır) ve **top** (namlu alevi, duman, gülle). Taş ve gülle yay çizerek uçar; düştüğü yerde toz/patlama. Orta uzaklıkta da at ve makine gövdesi seçilir.
- **Mevsimler haritada:** bahar çiçekleri, sararan yaz otları, sarı-turuncu-kızıl güz ormanları (bazı çamlar yeşil kalır), kışın kuzeyde benekli kar ve buz tutan sığ sular. Kara kışta kar kuşağı güneye iner.
- Üst çubukta tarih mevsim renginde (kış buz mavisi, bahar yeşil, yaz sarı, güz turuncu).

### Oynanabilirlik
- **İstatistik sekmeleri:** Nüfus / Altın (hazine) / Teknoloji / Toprak (köy) grafikleri. Teknoloji grafiğinde çağ eşikleri kesik çizgi; yıkılan krallığın çizgisi çarpıyla biter. Altının değeri yazılır.
- **Tarih kitabı** (Kronik → Tarih kitabı): dünyanın bütün önemli olayları yüzyıl yüzyıl; satıra dokun → oraya git.
- Canlı kartında askerin birimi yazar ("Asker — Atlı", "Mancınık"…).

### Mantık
- **Mevsimler:** doğumlar baharda, salgın kışın, yangın yazın; savaşlar baharda açılır (kış ×0.4, bahar ×1.5). Ölçüm (300 yıl): doğum kış/bahar/yaz/güz 6716/10970/8145/7304; savaş ilanı 36/67/50/63. Kuzeyde kışın yürüyüş yavaş, kuşatma ×0.45 ve kuşatan askerler soğuktan can kaybeder.
- **Kuşatma makineleri** surları 4 kat hızlı yıkar ve kuşatmayı hızlandırır; atlı hücumu ×1.3.
- **Irk dengesi:** cüceler ve devler dağa ev kurabilir; goblin doğurganlığı 0.28 → 0.25, yemek 0.6 → 0.7. Tohum 3, 300 yıl: Cüce **11 → 485**, Kertenkele 932 → 477, Goblin 2309 → 1921; hiçbir ırk yok olmuyor.
- **Ekonomi:** altının değeri kişi başına altına göre (%35–%160); kıtlıkta tahıl, paralı asker, saray ve kale fiyatı buna bağlı. Savaşta hazinesi 4 yıl boş kalan (3+ köylü) krallık **iflas eder**: ordu ×0.75, köylerde huzur −12 (10 yıl).

### Görsel kalite ve detay
- Binek ve kuşatma makinesi çizimleri, iki yeni mermi efekti, mevsim renkleri; yakın planda canlılar keskin piksel resimler.

### Derinleştirilen 3 özellik
1. **Savaş:** atlı birlikler, kış kuşatması, sefer mevsimi, kuşatma makineleri ile surların düşmesi.
2. **Ekonomi:** altının değeri (enflasyon), fiyatlar, iflas.
3. **Kronik:** kalıcı tarih kitabı (önceden 3000 satırdan sonra eski olaylar siliniyordu).

### Eklenen yeni sistemler (TASARIM.md)
1. **Mevsimler** (§1).
2. **Atlılar ve kuşatma makineleri: mancınık, top** (§8).
3. **Altın / teknoloji / toprak grafikleri** (§11).
- Ek: **cüce dağ evleri** (§7 ırka özel binalar), **goblin kurt binicileri**.

### Kayıt
- `KAYIT_SURUMU` 5: krallık geçmişi, tarih kitabı, altının değeri. Eski kayıtta tarih kitabı kroniğin önemli olaylarından kurulur.

### Sorunlar / sonraki gece
- Yazılım çiziminde (bulut) haritanın kendisini çizmek karenin çoğunu alıyor; gerçek cihazda ölçülemedi. Mevsim gölgelendiricisi telefonda hafif bir ek iş; yavaşlarsa söyle.
- 500x'te Dev haritada ulaşılan hız hâlâ ~40 ay/sn: sıradaki adım simülasyonu ayrı iş parçacığına almak.
- Krallık sayısı arttı (tohum 3: 17 → 39), çünkü cüce ve dev krallıkları artık yaşıyor; çok sayıda küçük krallık birleşmeli mi bakılacak.

## 2026-11-11 (2. çalışma) — Gece 3: kasma avı, görünür savaşlar, ayrıntılı binalar, darbe, ses

### Analiz bulguları (dogrulama 256x160 tohum 3/7/11/21/33, 512x320 tohum 5; 300–1000 yıl, sınırsız nüfus; yeni `olcum` modu)
- **Kasmanın asıl sebebi harita dokusuydu, simülasyon değil.** Haritada tek bir karo değişince (ova ormana döndü, ev yapıldı, yanık yeşerdi) değişen karoların *sınır kutusu* yeniden çiziliyordu; iki uzak karo değişince bu kutu tüm harita oluyordu. Hız arttıkça her 60 ms'de bir **tüm harita** yeniden çiziliyor ve tüm doku (Dev haritada ~8 MB) ekran kartına yeniden yükleniyordu. Ölçüm: 100x'te karenin 131–913 ms'si buna gidiyordu; Dev haritada 20x'te kare 845 ms (saniyede 1 kare), ulaşılan hız 20 yerine **1 ay/sn**.
- **Yılda bir takılma:** kıta etiketleri (kara parçalarının hangi kıtada olduğu) soğuyan her lav karosunda baştan hesaplanıyordu: Dev haritada tek ayda **57–79 ms**.
- **1x'te saniyede bir sarsıntı:** her ay tüm canlılar aynı karede yürütülüyordu (10 bin canlıda ~10 ms, telefonda birkaç katı).
- **Köy adları her karede** yeniden sıralanıp ölçülüyordu (400 köyde her kare binlerce çağrı); üst çubuk her karede tüm köyleri tarıyordu.
- **Bahar seli hiç olmuyordu:** 300 yılda kendiliğinden 0 sel (rastgele tek köy deneniyor, kıyıda değilse vazgeçiliyordu).
- **100 özelliğin çoğu etkisizdi:** `okculuk`, `saldiri`, `yakin_dovus`, `kacinma`, `afet_onsezi`, `sifa`, `ihanet`, `darbe` hiçbir yerde okunmuyordu.
- **İsyancı krallıklar birikiyordu** (Gece 2'nin sorunu): 300 yılda 23–27 krallık, çoğu "Özgür …".
- **Tarayıcıda simgeler kutu çıkıyordu:** ♛ ⚔ → ■ ★ gibi işaretler oyunun yazı tipinde yok; PC'de sistem yazı tipinden geliyordu, tarayıcıda sistem yazı tipi kullanılamıyor. 📍 hiçbir yerde çıkmıyordu.
- Savaşlar haritada neredeyse görünmüyordu: asker köylüden yalnızca koyu renkle ayrılıyordu, çarpışma tek kırmızı nokta.

### Kasma ölçümü (önce → sonra)
Yeni ölçüm: `godot -- olcum` (az/orta/çok nüfus × uzak/yakın görünüm × 1x/20x/100x/500x; her satır aynı kayıttan başlar). Aynı ölçüm betiği Gece 2 koduna da takılıp **aynı makinede** çalıştırıldı. Süreler yazılım çizimiyle (ekran kartsız bulut makinesi) ölçüldü; gerçek cihazda kareler daha kısa, ama oranlar geçerli. "Sonra" dünyaları yeni kurallar yüzünden ~%15 daha az canlı içeriyor.

| Nüfus | Görünüm | Hız | Canlı (önce → sonra) | Ort. kare ms | En yavaş kare ms | Harita dokusu ms/kare | Ulaşılan hız (ay/sn) |
|---|---|---|---|---|---|---|---|
| az | uzak | 1x | 1059 → 869 | 18.6 → **21.0** | 75.6 → **29.0** | 0.6 → 0.0 | 1 → **1** |
| az | uzak | 20x | 1010 → 808 | 22.1 → **20.2** | 77.4 → **28.1** | 2.9 → 0.1 | 20 → **20** |
| az | uzak | 100x | 2958 → 1087 | 167.5 → **22.5** | 398.8 → **29.3** | 131.0 → 0.9 | 56 → **100** |
| az | uzak | 500x | 4539 → 3259 | 270.4 → **37.5** | 419.7 → **67.3** | 221.3 → 2.0 | 52 → **322** |
| az | yakın | 100x | 2909 → 1096 | 176.2 → **23.2** | 400.9 → **36.4** | 134.2 → 0.9 | 53 → **101** |
| az | yakın | 500x | 4470 → 3360 | 306.0 → **38.2** | 473.6 → **57.7** | 239.0 → 2.0 | 45 → **337** |
| orta | uzak | 1x | 5179 → 4519 | 32.2 → **25.4** | 282.0 → **35.4** | 5.5 → 0.0 | 1 → **1** |
| orta | uzak | 20x | 5567 → 4647 | 64.0 → **28.3** | 288.5 → **47.0** | 25.5 → 0.5 | 19 → **20** |
| orta | uzak | 100x | 6976 → 5422 | 239.1 → **38.9** | 516.9 → **60.0** | 185.3 → 1.8 | 25 → **98** |
| orta | uzak | 500x | 7257 → 6216 | 215.2 → **43.3** | 626.2 → **58.3** | 158.3 → 2.1 | 36 → **124** |
| orta | yakın | 1x | 5164 → 4519 | 46.6 → **33.9** | 200.4 → **47.7** | 4.0 → 0.0 | 1 → **1** |
| orta | yakın | 20x | 5697 → 4727 | 125.3 → **38.5** | 417.4 → **57.3** | 63.1 → 0.7 | 15 → **20** |
| orta | yakın | 100x | 6978 → 5700 | 252.4 → **53.4** | 583.6 → **71.6** | 189.6 → 2.0 | 23 → **83** |
| orta | yakın | 500x | 7264 → 6334 | 223.0 → **51.4** | 586.4 → **71.7** | 157.8 → 2.1 | 36 → **114** |
| çok (Dev harita) | uzak | 1x | 12482 → 11041 | 83.6 → **34.6** | 1449.9 → **55.2** | 50.0 → 0.1 | 1 → **1** |
| çok (Dev harita) | uzak | 20x | 13712 → 11516 | 845.3 → **54.8** | 1728.2 → **83.6** | 780.5 → 1.7 | 1 → **18** |
| çok (Dev harita) | uzak | 100x | 15096 → 12837 | 978.1 → **60.2** | 1592.6 → **74.5** | 913.0 → 2.3 | 2 → **31** |
| çok (Dev harita) | uzak | 500x | 15878 → 13255 | 1071.3 → **54.8** | 1606.2 → **76.4** | 1004.4 → 2.1 | 3 → **39** |
| çok (Dev harita) | yakın | 1x | 12240 → 10903 | 189.9 → **50.4** | 1779.1 → **71.1** | 98.3 → 0.2 | 0 → **1** |

Özet: hızlandırılmış oyunda ortalama kare **5–18 kat**, en yavaş kare **7–20 kat** kısaldı; 100x gerçekten 100x gidiyor (önce 25–56). Yazılım çiziminde bir karenin ~20–30 ms'si boş haritayı çizmeye gidiyor; gerçek ekran kartında bu pay çok daha küçük.

Derleme makinesinde (GitHub, `onizleme/olcum.txt`, yeni kod): kareler 11–49 ms; 500x'te ulaşılan hız az nüfusta **488**, orta nüfusta **207**, Dev haritada **71** ay/sn; 20x her nüfusta tam 20; 100x az ve orta nüfusta tam 100.

Tek ayın (tick) süresi, ekransız (dogrulama TICK satırları): en yavaş tek ay Dev haritada **57–79 ms → 7–17 ms**. Simülasyonun ham hızı aynı kaldı (300 yıl, 256x160 tohum 3: 7.07 → 7.04 sn; 512x320: 22.2 → 20.7 sn; 1000 yıl tohum 11: aynı makinede 42.5 → 50.1 sn ama 17.2 bin yerine 19.6 bin canlıyla, canlı başına eşit). Bu gecenin kazancı kare akıcılığı; ham simülasyon hızı için sıradaki adım aşağıda.

### Performans (yapılanlar)
- **Parçalı harita dokusu:** harita 32x32 karoluk parçalara bölündü; değişen karonun yalnızca kendi parçası ekran kartına yüklenir (önce her değişiklikte tüm harita). Karede en çok ~2,5 ms karo çizilir ve 4 parça yüklenir; fazlası sonraki karelere kalır.
- **Kıyı yenileme yerelleşti:** yalnızca su ↔ kara değişen karoların çevresi, yakın kümeler hâlinde yeniden hesaplanır (önce tüm değişikliklerin sınır kutusu).
- **Kıta etiketleri aylara yayıldı** (`_kita_adim`); soğuyan lav komşusunun etiketini alır, tam hesap gerekmez.
- **Yayık hareket (1x–5x):** canlıların hareketi ayın içine 8 dilime bölündü; her karede sekizde biri yürür, çizim her canlıyı kendi diliminden başlatarak akıtır. Tick anındaki sarsıntı kalktı.
- **Kare bütçesi:** karenin çizim/arayüz payı ölçülür, simülasyona kalan süre verilir (düşük hızda hedef 60 FPS, yüksek hızda en az ~30 FPS). Hareket adımı: 20x'te 2, 100x'te 6, 500x'te 12.
- **Uzak görünüm:** canlı nokta listesi her karede değil, simülasyon ilerleyince (en çok saniyede ~8 kez) kurulur. **Yakın görünüm:** ekrandaki canlıların listesi önbelleklenir (her karede 10–30 bin canlı taranmaz). Orta uzaklıkta sade figürler.
- **Köy adları** yarım saniyede bir hazırlanır, her karede yalnızca yerleştirilir; üst çubuk saniyede birkaç kez güncellenir.
- **Krallık/ırk haritası** karelere yayılarak hesaplanır (önce saniyede bir tek karede 40–80 ms).
- **Bina katmanı** çizim komutlarını saklar: kamera aynı bölgedeyken yeniden çalışmaz.
- Okçu/tüfekli hedef araması karoları birer atlayarak tarar (1000 yıllık dünyada hareket payı 26 → 19 sn).

### Görünürlük (dünyada olanlar net görünsün)
- **Askerler krallık renginde** giyinir; çağa göre silah: sopa (Taş), mızrak (Tunç), kılıç ya da yay (Demir), çelik kılıç ya da arbalet (Orta Çağ), süngülü tüfek (Barut/Sanayi), lazer (Uzay). Kalkan (Tunç'tan), miğfer (Demir'den; Orta Çağ'da tepelikli), göğüslük. Her dokuz askerden biri **sancaktar** (dalgalanan krallık bayrağı).
- **Çarpışma efektleri:** kılıç kıvılcımı, uçan ok, namlu alevi ve duman, lazer ışını, ölüm izi (kan ve yükselen ruh), kuşatılan köyde ateş ve duman.
- **Savaşın özeti her uzaklıkta:** kuşatılan köyün üstünde atan çapraz kılıç simgesi (kuşatanın rengiyle), sefere çıkan köyden hedefe kesik ok, savaş ilan edilen başkentte kırmızı halka. Simgeler ekranda sabit boyda.
- **Krallık toprakları uzaktan her zaman** hafif renkli ve sınırlı görünür (yaklaştıkça silikleşir; Menü → Uzaktan sınırlar). Yakında köy sınırı krallık renginde ince halka.
- **Ayrıntılı binalar** (yakınlaştırınca): 8x8 piksel ev, ambar, maden, demirhane, kışla, tapınak, kütüphane, pazar, saray, kule, kale, harabe, köy meydanı (kuyu ve bayrak); çatılar krallık renginde, duvarlar ırka göre.
- **Savaşlar paneli** ve üst çubukta "⚔ N savaş".

### Oynanabilirlik
- **⚔ Savaşlar** (Gözlem): süren savaşlar, kaç yıldır sürdüğü, skor, sebep, kuşatılan köyler; satıra dokun → cepheye git. Altında son savaş olayları.
- **Gerçek hız göstergesi:** oyun istenen hıza yetişemiyorsa üst çubukta "hız ~180x" yazar (oyuncu neden yavaş aktığını görür).
- **Simgeler tarayıcıda da çıkıyor:** oyuna küçük bir simge yazı tipi (DejaVu Sans alt kümesi, 127 KB, özgür lisans) eklendi; 📍 yerine ➤.
- Kronik/İstatistik/Savaşlar paneli artık alt araç çubuğunun üstüne taşmıyor. Yeni dünya açılınca eski dünyanın olay bildirimi ekranda kalmıyor.
- Yeni tanrı gücü **Darbe yaptır**; Gözlem'e **Irk haritası**; menüde **Ses** ve **Uzaktan sınırlar** (ayar kalıcı). Menü bir satır kısaldı.
- Kronikte Türkçe ekler düzeldi ("Çetesi'na" → "Çetesi'ne", "Permar'i" → "Permar'ı").

### Mantık
- **Menzilli savaş:** okçu, tüfekli ve lazerli askerler 4–5 karodan vurur ve karşılık almaz; okçuluk özelliği hasarı artırır. Cüce zırhı ve Dev derisi oku/mermiyi keser (×0.55 / ×0.7).
- **Özellikler savaşta işliyor:** Saldırgan, Kana Susamış, yakın dövüş ustaları daha sert vurur; Çevik canlı darbeden sıyrılır; Korkak (cesareti düşük) vurulunca kaçar; usta savaşçı kuşatmayı hızlandırır.
- **İç savaşın sonu var:** isyancılar yenilirse köyleri eski krallığa döner; kazanırsa bağımsızlık tanınır. Tek köylü yaşlı krallıklar müttefik/dindaş büyük komşuya katılabilir. 300 yılda krallık sayısı 23–27 → 16–22.
- **Barış satın alınır:** kaybeden taraf hazinesinden savaş tazminatı ödeyerek barış yapabilir.
- **Darbe:** zayıf, sevilmeyen, yüksek vergi alan ya da savaş kaybeden hükümdar devrilebilir; 15 yılda en çok bir girişim (300 yılda 3–10 başarılı darbe).
- **Kâhin** felaketi sezer, halk kaçar (sınama: aynı deprem + meteor, 10 ölü → 2 ölü). **Şifacı** salgın ölümlerini azaltır.
- **Bahar selleri** artık oluyor (300 yılda 0 → ~10).

### Görsel kalite ve detay
- Binalar 4 kat ayrıntılı (yakında); evler çağa göre **kulübe → ev → taş ev**, ırka göre **elf ağaç evi, ork deri çadırı, cüce taş evi, goblin çamur kulübesi, kertenkele kamış evi, dev taş halkası, uzaylı kubbesi**.
- Canlılar: saç (beş ton; elflerde sarı/gümüş; yaşlılarda ağarır; kadınlarda omuza iner), kişiye göre giysi tonu, kuşak, çok yakında gözler.
- Yeni efektler (7 adet) ve savaş simgeleri; uzaktan krallık renkli bölgeler.

### Derinleştirilen 3 özellik
1. **Savaş:** birimler (piyade, okçu, tüfekli, lazerli, sancaktar), menzilli atış, çağa göre silah ve zırh görünümü, çarpışma efektleri, kuşatma işaretleri, savaşlar paneli.
2. **Diplomasi:** iç savaşın sonucu (yeniden birleşme / bağımsızlık), barışı satın alma, gönüllü katılma (hanedan evliliği), savaş sebebinin saklanması.
3. **Canlı özellikleri:** saldırı, yakın dövüş, okçuluk, kaçınma, afet önsezisi, şifa, ihanet ve darbe etkileri simülasyona bağlandı.

### Eklenen yeni sistemler (TASARIM.md)
1. **Darbe** (§8) + tanrı gücü "Darbe yaptır" (§11 "kral değiştir").
2. **Kâhin önsezisi** (§10).
3. **Ses** (§14): kodla üretilen ortam, afet, savaş ve arayüz sesleri (ses dosyası yok).
- Ek: **Irk haritası** (§11), **ırka özel ev görünümleri** (§7), **okçu/tüfekli birimler** (§8).

### Kayıt
- `KAYIT_SURUMU` 4. Yeni alanlar (köyde kuşatma bilgisi, krallıkta isyan kaynağı / savaş sebebi / son darbe) isteğe bağlı; Gece 2 koduyla üretilmiş sürüm 3 kayıt yüklendi, 62 yıl sorunsuz sürdü, yeniden kaydedilip açıldı.

### Derleme / depo
- CI'a `olcum` adımı eklendi (`onizleme/olcum.txt`); önizlemeye 9 yeni kare (ırk haritası, orta uzaklık, binalar yakın plan, savaş uzak/kuşatma/asker, tüfekli ve lazerli askerler, savaşlar paneli).
- `jekyll-gh-pages.yml` yalnızca elle çalışacak şekilde değiştirildi: her push'ta README'yi site olarak yayınlayıp oyunun web sayfasının üstüne yazabiliyordu (iki iş yarışıyordu).

### Sorunlar / sonraki gece
- **Ham simülasyon hızı artmadı.** 10 bin canlıda bir ay 500x kipinde ~3–4 ms; 500x'e ancak ~3 bin canlıya kadar tam ulaşılıyor (ölçüm: az 322, orta 124, Dev harita 39 ay/sn — yazılım çiziminde). Sıradaki adımlar: simülasyonu ayrı iş parçacığına almak (PC/Android), canlı döngülerini C++'a taşımak ya da 500x'te sivillerin hareketini istatistiksel yapmak.
- Yakın görünümde canlı çizimi biraz ağırlaştı (ölçüm, orta nüfus: 2.4 → 3.6 ms/kare; saç ve donanım). Canlıları tek çizim çağrılı hazır resimlere (atlas / MultiMesh) taşımak planlı.
- Irk dengesi hâlâ tohuma göre çok oynuyor (Cüce 11 ile 1576, Dev 1 ile 438 arasında); küçük nüfuslu ırkların ilk yüzyılı şansa bağlı.
- Kronik 3000 satırla sınırlı: uzun oyunda ilk yüzyılların olayları siliniyor (önemli olayları ayrı saklamak gerek).
- Sesler kulakla denenemedi (bulutta hoparlör yok); seviyeleri sayısal olarak ölçüldü. Rahatsız ederse Menü → Ses: KAPALI.
- Telefon düzeni (büyük düğmeler) bulutta denenemiyor; menü taşarsa bildir.

## 2026-11-11 — Gece 2: ekonomi, isyan/iç savaş, sel, besin zinciri, kıyılar

### Analiz bulguları (dogrulama 256x160, tohum 7 ve 3; 300 ve 600 yıl, sınırsız nüfus)
- **Altının hiçbir kullanımı yoktu:** köylerde 300 yılda toplam ~17 bin altın birikti, yalnızca savaş sebebi yazısında kullanılıyordu. Hükümdarın "altın hırsı" her yıl altını %0.x katlıyordu (anlamsız).
- **Krallıklar hiç bölünmüyordu:** 120 köylük dünyada 9-11 krallık; büyük krallığın uzak köyleri için hiçbir sonuç yoktu. Barışlar hep "eşit", savaşın kazananı yoktu ("Savaş 0 yıl sürdü" yazıyordu).
- **Hayvanlar donmuştu:** 11 bin canlılı dünyada hep tam 81 koyun, 51 inek; kurt/ayı hiç aç kalmıyor, ayılar 400. yılda tükendi ve ekosistemin hiçbir etkisi yoktu.
- **Harita kahverengi lekelerle dolmuştu:** yanık toprak ortalama ~170 yılda yeşeriyordu.
- **Kıyılar keskin ve düz:** derin/sığ su arasında geçiş yok, köpük yok.
- **Performans:** yıllık canlı işlemi 17 ms/yıl (10 bin canlı), krallık işlemi 1.8 ms; tüm haritanın çizimi 559 ms (telefonda yeni dünya/yükleme birkaç saniye).

### Oynanabilirlik
- **Önemli olay bildirimi:** savaş, isyan, din, krallık yıkılışı, UFO ekranın sol üstünde belirir; **dokununca olay yerine gidilir**.
- **Kronikte 📍 bağlantıları:** yeri olan olaylara dokununca kamera oraya gider.
- **Canlı kartında soy ağacı:** "↑ Anne", "↑ Baba", "♛ Hükümdar" düğmeleri; **Takip** düğmesi açık/kapalı durumunu gösterir.
- **Köy kartı:** huzur (renkli, isyan uyarısı), vergi, hazine, haraç, ticaret ortakları, kale, alüvyon; "Hükümdar" ve "Başkente git" düğmeleri.
- **Huzur haritası** (Gözlem): köyler yeşil (huzurlu) → kırmızı (isyana hazır) halkalarla.
- Yeni araçlar: Afetler → **Sel**, Güçler → **İsyan çıkar** (ipuçlarıyla).

### Mantık
- Vergi/hazine/bakım/yolsuzluk döngüsü: hazine boşalınca vergi yükselir → huzur düşer → isyan. Dolunca vergi iner.
- Huzur formülü: vergi, kıtlık, salgın, savaş yorgunluğu, başkente uzaklık, farklı ırk, krallık büyüklüğü (bürokrasi), tapınak, bolluk, haraç, hükümdarın liderliği/kana susamışlığı.
- Hazine kıtlıkta tahıl alır (açlık ölümleri azaldı), savaşta paralı asker ve zırh alır.
- Barış antlaşması: skorla kazanan belirlenir, kaybeden 10 yıl haraç öder; "haraçtan kurtulmak" yeni savaş sebebi.
- Besin zinciri ve taşıma kapasitesi; avcılar aç kalınca ölür, tok olunca yavrular (kurt sayısı 5 ile 53 arasında dalgalanıyor — avcı-av döngüsü).
- Yanık toprak ~15 yılda yeşerir; ova ormana daha yavaş döner.
- Denge: Goblin doğurganlığı 0.32 → 0.28 (büyük haritada dünyanın %60'ını kaplıyordu), Elf 0.05 → 0.06.

### Görsel kalite ve detay
- **Kıyılar:** su derinliği gradyanı (karaya yaklaştıkça turkuaz), karaya bakan kenarlarda köpük, karada ıslak kıyı şeridi.
- **Su parıltısı:** suya piksel piksel kıpırdayan ışıltı (shader; yalnızca mavi pikseller).
- Dağlarda sol kenar ışığı, ağaçlarda gövde gölgesi, ovalarda çiçek, yanık toprakta kül ve yeni filizler.
- Yeni bina **Kale** (taş sur, krallık bayrağı); efektler: **ticaret kervanı** (yolda yürüyen araba), **isyan** (dalgalanan kırmızı bayrak, öfke halkası), **sel** (genişleyen su halkaları, bulanık sel suyu).

### Performans
- Harita çizimi `set_pixel` yerine bayt dizisine; karo başına 6 renklik palet; açık deniz ve iç kara karoları 4x4 **önbellekten `blit_rect`** ile. Tüm harita: **559 ms → 160–250 ms**. Arazi boyarken yalnızca değişen bölgenin su derinliği yeniden hesaplanır.
- Yıllık canlı döngüsü köy sözlüğü yerine **`kv_*` dizilerini** okuyor/yazıyor (bayraklar + birikimler): 20 → 16 ms/yıl (11 bin canlı).
- `krallik_koyleri()` ayda bir kurulan önbellekten; savaş hedefi araması ortalama 4 yılda bir (olasılık ×4): krallık işlemi **6.3 → 1.8 ms/yıl** (isyanlarla krallık sayısı arttığında).
- Sonuç (README tablosu): 512x320'de 35 bin canlı **360 → 148 ms/yıl**; 1000 yıllık 18.5 bin canlılık dünya **56 → 34 sn**; 256x160 10.5 bin canlı 43 → 35 ms/yıl.

### Derinleştirilen 3 özellik
1. **Ekonomi ve altın:** vergi, hazine, bakım, kıtlık yardımı, ticaret kervanları, saray/kale maliyeti, paralı asker.
2. **Savaş:** skor, barış antlaşması ve haraç, haraçtan kurtulma savaşı, kale kuşatması (surlar önce yıkılır), ticaret ortaklarının barışçıllığı.
3. **Hayvan ekosistemi:** otlak kapasitesi, lojistik üreme, avcı tokluğu/açlığı, sürü izi süren avcılar, aşırı otlatma ile çölleşme, İstatistik'te ekosistem durumu.

### Eklenen 3 yeni sistem (TASARIM.md)
1. **İsyan ve iç savaş** (§8) + tanrı gücü "İsyan çıkar" (§11) + Huzur haritası.
2. **Sel afeti** (§10) + alüvyon bereketi.
3. **Nüfus grafiği** (§5, §11 bilgi araçları) — İstatistik panelinde ırk çizgileri.
- Ek: **Kale** binası (§7), önemli olay bildirimleri.

### Kayıt
- `KAYIT_SURUMU` 3. Eski (sürüm 2) kayıt denendi: açıldı, eksik alanlar (hazine, vergi, haraç, huzur, kale, sel, nüfus geçmişi, avcı tokluğu) tamamlandı, 50 yıl sorunsuz sürdü.

### Sorunlar / sonraki gece
- İsyanlarla krallık sayısı 300 yılda 20-40'a çıkabiliyor (önce 9-15). Tarih daha hareketli ama "Özgür …" krallıkları kalabalıklaşıyor; isyancıların geri fethedilmesi/birleşme (hanedan evliliği, vasallık) eklenmeli.
- Irk dengesi hâlâ tohuma göre çok değişiyor (bir dünyada Kertenkele 1300, başkasında 130).
- Avcılar küçük haritada zaman zaman tükenip göçle geri geliyor.
- Önizleme kare süreleri yazılım çiziminde ölçülüyor; gerçek cihazı yansıtmaz. Bu gece CI önizlemesinde kare süresi yükseldi (uzak 12.5 → 16.4 ms, yakın 14.8 → 22.8 ms; ~4.8 bin canlı). Su parıltısı shader'ı yerelde kapatılıp denendi, fark ölçüm gürültüsü içinde; sebep sonraki gece araştırılacak (canlı çizimini MultiMesh'e taşımak planlı).
- GitHub Pages hâlâ kapalı: pages işi "Ensure GitHub Pages has been enabled" ile düşüyor (derleme, APK, Windows ve önizleme başarılı).

## 2026-11-10 — Gece 1: sınırsız nüfus, boş dünya, canlı sil, din, ittifak, şehirler

### Analiz bulguları (dogrulama, 256x160, tohum 7 ve 3, 300 yıl)
- **Dev ırkı 30 yılda yok oluyordu:** yılda 4 yiyecek yiyip 1 kişilik iş yapıyordu (sürekli kıtlık); köyü yıkılınca çocukları 40 yaşına kadar köysüz kalıyordu.
- **Kara kış tüm dünyada her yıl %10 öldürüyordu:** 300 yılda 1978 "soğuk" ölümü; yavaş üreyen Elfler 35'ten 14'e düştü.
- **Köyler sınırsız büyüyordu:** tek köy 471 nüfusa çıktı, harita evlerle doldu.
- **Nüfus 3000/5000'de donuyordu** (ırk başına %45 sınırı Goblinleri ve İnsanları kilitliyordu).
- İnekler avlanarak soyu tükeniyordu (300 yılda 0); geri gelmiyordu.
- Performans: tick döngüsü her ay tüm canlı dizisini mod hesabıyla tarıyordu; köy yeri ararken her aday için tüm köyler taranıyordu (büyük haritada köy başına 180 µs).

### Oynanabilirlik
- Menüde **Nüfus sınırı** (varsayılan Sınırsız) ve **Başlangıç: Rastgele canlılar / Boş dünya** seçimi. Boş dünyada Canlılar sekmesi otomatik açılır.
- **Canlı sil** aracı (Güçler) + Güçler/Arazi sekmesinde **Fırça: 1·2·4·7·12**; fare/parmak altında fırça çemberi (silgide kırmızı).
- Alt çubukta seçili aracın **ipucu satırı** (ne yapacağını anlatır).
- **Krallık haritası** düğmesi (Gözlem): topraklar ve sınırlar.
- Köy adları önem sırasına göre yazılır, üst üste binenler atlanır; uzaktan yalnızca başkent (♛) ve şehirler görünür.

### Mantık
- Kara kış yalnızca soğuk bölgede (kuzey %28, kar, dağ) öldürür (%8); güneyde verim %75.
- Dev: iş gücü ×3 (`uretim` alanı), yemek 3, doğurganlık 0.07, saldırganlık 0.25. Elf doğurganlığı 0.05. Goblin 0.60 → 0.32 (dünyayı ele geçiriyordu).
- Başlangıç kabilelerinde kadın/erkek dengesi; köyü yıkılan çocuklar yakın soydaş köye sığınır.
- Ev arazisi savunma üstünlüğü (%25).
- Köy kapasitesine çağ tavanı; taşan halk göçle yeni köy kurar.
- Avlanma yalnızca ambar bir yıldan azsa ve tür azalmamışsa; azalan yabani türlere sürü göçü.
- Sonuç: 300 yılda **7 ırkın hepsi yaşıyor** (önce Dev ve neredeyse Elf yok oluyordu).

### Görsel kalite ve detay
- Canlılara gölge, yürürken sırayla adım atan bacaklar; ırka özgü ayrıntılar (elf sivri kulak, ork dişleri, cüce sakalı, goblin kulakları, kertenkele kuyruğu, uzaylı antenleri).
- Hükümdarların başında altın taç; askerlerin elinde çağa göre silah (mızrak → kılıç → tüfek → lazer).
- Mevsim örtüsü: kışın kuzey yumuşak geçişle karla kaplanır; kara kışta dünya mavimsi, kuraklıkta sarımsı.
- Krallık toprakları dokusu (iç %33, sınır koyu); silgi efekti.

### Performans
- Tick: yıllık ve hareket döngüleri adımlı (`range(bas, ust, 12)`), tüm diziyi taramıyor.
- Sık özellik id'leri ve tür değerleri dizilerde önbellekli (sözlük araması yok); liderlik puanı `s_lider` önbelleği.
- **Köy ızgarası** (16x16 karo hücre): yakın köy araması tüm köyleri taramıyor. Köy yeri aramasında pahalı denetim yalnızca en iyi adaya.
- Savaş hedefi aramasında düşman köyleri bir kez süzülüyor; ilan için başkent + 5 örnek köy.
- Uzak görünümde tüm canlılar **tek çizim çağrısıyla** (`draw_multiline_colors`); yakında tür değerleri dizilerden.
- Ölçüm (adim=12, bu makine): 256x160'ta 10.8k canlı **43 ms/yıl** (önce 10.4k'da 79 ms/yıl, ~%45 hızlı); 6.8k canlı 25 ms/yıl. 512x320'de köy işleme 4.4 ms → 1.2 ms/tick.

### Derinleştirilen 3 özellik
1. **Kara kış / mevsimler:** bölgesel ölüm, bölgesel verim, haritada kış örtüsü.
2. **Savaş:** sebepler (kroniğe yazılır), savaş yorgunluğu (süre + kayıp), müttefiklerin katılması, ev arazisi üstünlüğü.
3. **Irk dengesi ve ekosistem:** Dev/Elf/Goblin dengesi, yetim çocuklar, avlanma kuralı, hayvan göçü.

### Eklenen 3 yeni sistem (TASARIM.md)
1. **Köy → Kasaba → Şehir → Büyük şehir** (§7), kapasite tavanı, kronikte "artık bir şehir".
2. **Din** (§12): kuruluş, yayılma, savaş/ittifak etkisi; bilgi kartında ve istatistikte.
3. **İttifaklar** (§8): kendiliğinden kurulur/bozulur, savaşta yardım, tanrı gücü "İttifak kur".

### Kayıt
- `KAYIT_SURUMU` 2. Sürüm 1 kayıtları yüklenince: nüfus sınırı Sınırsız, krallıklara din/ittifak/kayıp, köylere kademe eklenir (denendi: eski kayıt açılıp 50 yıl sorunsuz sürdü).

### Sorunlar / sonraki gece
- 512x320 haritada nüfus 30 binin üstüne çıkıyor; orada tick ~30 ms (500x hızında simülasyon yavaşlar ama ekran donmaz, kare bütçesi korunuyor). Sonraki adım: yıllık işlemi daha da hafifletmek ve çizimi MultiMesh'e taşımak.
- Önizlemede yazılım çizimi (llvmpipe) kare süreleri gerçek cihazı yansıtmıyor; yalnızca göreli karşılaştırma için.

## 2026-11-10 — İlk sürüm (sohbette yazıldı)
- Prosedürel dünya, 8 ırk + 7 hayvan, köy/krallık, üreme ve kalıtım, 100 özellik (bilgi kartı + tanrı paneli + özellik fırçası), çağlar ve silahlar, savaş/barış, 13 afet (kendiliğinden + elle), uzaylı istilası, kronik, istatistik, 3 kayıt yuvası + otomatik kayıt.
- Performans (256x160, 5000 nüfus sınırı): 150 yıl ≈ 4 sn (500x modu).
