# DÜNYA KUTUSU — Ana Tasarım Belgesi

Worldbox tarzında, çok detaylı bir tanrı/dünya simülasyonu. Oyuncu tanrıdır: dünyayı şekillendirir, canlıları yerleştirir, onlara özellik verir, afet gönderir ve 5000 yıllık bir tarihin kendi kendine yazılmasını izler.

Bu belge projenin **anayasasıdır**. Gece görevleri buradaki her maddeyi zamanla oyuna ekler ve ekledikçe ilgili maddeyi ✅ ile işaretler. Var olan madde silinmez, sadece genişletilir.

Platformlar: **PC (tarayıcıda HTML + Windows .exe)** ve **Android (APK)**. Motor: Godot 4, ağır simülasyon C++ (GDExtension). Görseller 2D piksel.

---

## 1. Zaman sistemi
- [ ] Simülasyonun 1 adımı = **1 ay**. 12 ay = 1 yıl. Hedef süre **5000 yıl (60.000 ay)**.
- [ ] Ekranda tarih gösterilsin: `Yıl 1247, 5. ay (İlkbahar)`.
- [ ] Hız ayarları: ⏸ Duraklat · 1x (1 ay/sn) · 5x · 20x · 100x · 500x. 500x'te 5000 yıl yaklaşık 2 dakikada geçer. Hızlı modda birimlerin ayrıntılı hareketi yerine toplu hesap yapılsın ki oyun takılmasın.
- [ ] Mevsimler (İlkbahar, Yaz, Sonbahar, Kış): ekin, göç, salgın ve savaşı etkilesin. Kışın kuzeyde kar, güneyde kuraklık olsun.
- [ ] Çağlar: Taş → Tunç → Demir → Orta Çağ → Barut → Sanayi → (Uzaylı teknolojisi). Her ırk ve krallık kendi hızında ilerler.
- [ ] **Tarih kaydı (Kronik):** krallıkların kuruluşu ve yıkılışı, savaşlar, ünlü kişiler, afetler, ilk icatlar. Bunlar oyunda okunabilir bir zaman çizelgesi olarak tutulsun.

## 2. Irklar
Her ırkın kendine özgü taban değerleri, sevdiği arazisi, binaları, silahları ve doğuştan gelen özellik olasılıkları var.

| Irk | Ömür | Üreme | Güçlü yanı | Zayıf yanı | Sevdiği arazi |
|---|---|---|---|---|---|
| [ ] **İnsan** | 70 yıl | Hızlı | Dengeli; ticaret, teknolojide hızlı ilerleme | Özel bir üstünlüğü yok | Ova, kıyı |
| [ ] **Elf** | 600 yıl | Çok yavaş | Okçuluk, büyü, ormanla uyum, bilgelik | Az nüfus; ormansız yerde zorlanır | Orman |
| [ ] **Ork** | 45 yıl | Çok hızlı | Güç, saldırganlık, kalabalık ordular | Düşük zekâ, iç kavga, zayıf diplomasi | Bozkır, çorak |
| [ ] **Cüce** | 300 yıl | Yavaş | Madencilik, demircilik, sağlam kaleler | Yavaş hareket; denizcilikte kötü | Dağ, yeraltı |
| [ ] **Dev** | 400 yıl | Çok çok yavaş | Muazzam güç ve can; tek başına ordu | Çok yemek ister, sayıca çok az, yavaş | Dağ, tundra |
| [ ] **Goblin** | 30 yıl | Aşırı hızlı | Kurnazlık, gizlilik, yağma | Zayıf, korkak, kısa ömür | Mağara, bataklık |
| [ ] **Kertenkele Halkı** | 120 yıl | Yumurtayla, orta | Yüzme, zehir bağışıklığı, sıcağa dayanım | Soğukta yavaşlar, kışın uyuşur | Bataklık, çöl |
| [ ] **Uzaylılar** | ? | Klonlama | Lazer silahlar, kalkan, gelişmiş teknoloji | Dünyanın hastalıklarına karşı zayıf | Gökten gelir (bkz. 9) |

- [ ] Irklar arası ilişki tablosu: Elf ile Cüce birbirini sevmez, Ork herkese düşmandır, İnsan herkesle ticaret yapar. Bu tablo savaş ve ittifak olasılığını etkiler.
- [ ] Melez doğum (İnsan + Elf = Yarı Elf vb.): her iki ebeveynin ırk özelliklerinden karışım.

## 3. Hayvanlar ve ekosistem
- [ ] **Otoburlar:** koyun, inek, geyik, tavşan, at, tavuk.
- [ ] **Avcılar:** kurt, ayı, aslan, timsah.
- [ ] **Deniz:** balık sürüleri, köpekbalığı, deniz canavarı.
- [ ] **Uçanlar:** kartal, akbaba.
- [ ] **Efsanevi:** ejderha, dev solucan, anka kuşu. Çok nadir doğarlar ya da tanrı tarafından konurlar.
- [ ] Besin zinciri: otlar büyür → otoburlar yer ve çoğalır → avcılar otoburları avlar. Avcı biterse otoburlar her şeyi yer ve kıtlık olur.
- [ ] Evcilleştirme: at (binicilik), inek ve koyun (yiyecek, yün), kurt → köpek.
- [ ] Hayvanlar da özellik taşır ve özelliklerini yavrularına aktarır.

## 4. Canlı özellikleri (100 adet) — `veri/ozellikler.json`
- [ ] Her canlının 0–5 özelliği olur. Bir kısmı doğuştan gelir (ırk olasılıkları + ebeveynlerden kalıtım), bir kısmı hayat boyunca kazanılır (ör. savaştan sağ çıkan "Cesur" olabilir).
- [ ] Tanrı paneli: oyuncu herhangi bir canlıya dokunup listeden özellik **ekleyebilir veya silebilir**. "Yerleştirme fırçası" ile yeni konan canlılara önceden seçilmiş özellikler verilebilir.
- [ ] Zıt özellikler bir arada olamaz (Aptal + Dahi gibi). Liste JSON dosyasındaki `zit` alanında.
- [ ] Etkiler gerçekten oyunu değiştirmeli:
  - Zeki/Dahi bir kral ülkenin teknolojisini hızlandırır. Aptal kral kötü kararlar verir: gereksiz savaş açar, hazineyi boşa harcar.
  - Çalışkan halk daha çok üretir; Tembel halkın ambarı boş kalır.
  - Hızlı asker önce varır, Korkak asker savaşta kaçar, Hain general düşmana geçer.
  - Doğurgan bir köy hızla büyür, Kısır bir soy tükenir.
  - Güçlü Kalıtım taşıyan bir soy, yüzyıllar içinde özelliklerini yayarak "dahi bir hanedan" ya da "devler soyu" oluşturur.
- [ ] Nadirlik: ★ yaygın → ★★★★★ efsanevi. Efsanevi özellikler (Dahi, Ölümsüz, Kahraman) kendiliğinden çok nadir doğar.
- [ ] Canlı bilgi kartı: adı, ırkı, yaşı, ebeveynleri, çocukları, özellikleri, mesleği, öldürdüğü düşman sayısı, krallığı. Ünlü canlılar kroniğe girer.

## 5. Üreme ve nüfus
- [ ] Yetişkinlik yaşı, gebelik süresi ve çocuk sayısı ırka ve özelliklere göre değişir.
- [ ] Eş bulma; Karizmatik/İtici gibi özellikler buna etki eder. Aileler ve soy ağacı tutulur.
- [ ] Kalıtım: her özellik ebeveynden %30 olasılıkla geçer (Güçlü Kalıtım bu oranı artırır). %2 mutasyon olasılığı yeni bir özellik getirir.
- [ ] Ölüm nedenleri: yaşlılık, açlık, hastalık, savaş, afet, hayvan saldırısı, kaza. İstatistikleri tutulur.
- [ ] Nüfus grafiği: ırk ve krallık bazında, yıllara göre.

## 6. Ekonomi: kaynaklar ve altın
- [ ] Kaynaklar: yiyecek, odun, taş, demir, **altın**, gümüş, değerli taş, yün, at.
- [ ] Altın madenleri haritada sabit yerlerde bulunur; o topraklar için savaş çıkar.
- [ ] Altının kullanımı: bina, silah, paralı asker, rüşvet ve diplomasi, kralın sarayı. Vergi sistemi; yüksek vergi isyana yol açar.
- [ ] Ticaret yolları (karadan ve denizden), pazar binaları, tüccar kervanları. Haydutlar kervan soyar.
- [ ] Kıtlık, enflasyon (çok altın çıkarılırsa), ekonomik çöküş.

## 7. Binalar (çağa göre açılır)
- [ ] **Taş Çağı:** çadır, kulübe, ateş başı, avcı kampı.
- [ ] **Tunç / Demir:** ev, ambar, tarla, değirmen, maden, demirhane, ahır, kışla, ahşap sur.
- [ ] **Orta Çağ:** taş ev, taş sur, gözetleme kulesi, kale, tapınak, kütüphane, pazar, liman, tersane, saray.
- [ ] **Barut ve sonrası:** top dökümhanesi, fabrika, demiryolu, üniversite.
- [ ] Irka özel binalar: Elf ağaç evleri, Cüce dağ kaleleri, Ork savaş totemleri, Dev taş halkaları, Goblin yeraltı tünelleri.
- [ ] Şehirler büyür: köy → kasaba → şehir → başkent. Yıkılan şehirler harabe olarak kalır.

## 8. Silahlar, ordular ve savaş
- [ ] Çağa göre silahlar: sopa → taş balta → mızrak → tunç kılıç → demir kılıç / yay → çelik kılıç, arbalet, mancınık → tüfek, top → (uzaylı lazer silahı).
- [ ] Zırhlar: deri → tunç → zincir → plaka.
- [ ] Ordu birimleri: piyade, okçu, atlı, kuşatma makinesi, gemi. Generaller özelliklerine göre savaşır (Stratejist, Korkak...).
- [ ] Savaş sebepleri: toprak, altın, din, intikam, ırk düşmanlığı, Kana Susamış bir kral.
- [ ] Kuşatmalar, barış antlaşmaları, ittifaklar, haraç, iç savaş, isyan, darbe.

## 9. Uzaylılar
- [ ] Belli bir yıldan sonra (ör. 2000. yıl) ya da tanrı tetiklerse **UFO istilası** olur: gökten gemiler iner, lazerle saldırır, insan kaçırır.
- [ ] Uzaylılar dünyada bir üs kurabilir. Bir krallık onları yenerse **uzaylı teknolojisini ele geçirir** ve çağ atlar.
- [ ] Kaçırılıp geri dönen canlılarda "Uzaylı Geni" özelliği belirebilir.

## 10. Doğal afetler
Her afet iki yoldan gelir: **kendiliğinden** (aylık küçük bir olasılıkla, mevsime ve araziye göre) ya da **tanrı tarafından** (güçler menüsünden, haritada istenen yere).

| Afet | Kendiliğinden ne zaman | Etkisi |
|---|---|---|
| [ ] Deprem | Fay hatları ve dağ kenarlarında | Binalar yıkılır, arazi yarılır |
| [ ] Volkan | Volkanik dağlarda | Lav akar, kül ekinleri öldürür, yeni kara oluşur |
| [ ] Tsunami | Depremden sonra kıyılarda | Kıyı şehirlerini yutar |
| [ ] Sel | Uzun yağmurlardan sonra nehir kenarlarında | Tarlalar ve evler sular altında kalır |
| [ ] Kuraklık | Yaz mevsiminde, çöl kenarında | Kıtlık, göç |
| [ ] Kasırga / hortum | Yazın açık ovada | Yolundaki her şeyi savurur |
| [ ] Orman yangını | Kuraklık ve yıldırım | Yayılır; söndürmek için yağmur gerekir |
| [ ] Kara kış | Rastgele soğuk yıllar | Donma, hayvan ölümleri |
| [ ] Salgın / veba | Kalabalık ve pis şehirlerde | Yayılır; Şifacı ve Hastalığa Bağışık canlılar yavaşlatır |
| [ ] Çekirge istilası | Sıcak yıllarda | Ekinleri yer |
| [ ] Meteor | Çok nadir | Krater, yangın; bazen nadir maden bırakır |
| [ ] Yıldırım fırtınası | Yaz yağmurlarında | Yangın çıkarır, canlı öldürür |

- [ ] Kâhin özelliği taşıyan canlılar afeti önceden sezer ve halkını kaçırır.
- [ ] Afet sonrası: göç, yeniden inşa, din etkisi ("tanrılar kızdı").

## 11. Tanrı güçleri (oyuncu araçları)
- [ ] **Arazi:** kara yükselt/alçalt, su, dağ, orman, çöl, kar, lav, nehir çiz.
- [ ] **Canlı koy:** her ırk, her hayvan, efsanevi yaratıklar. Yanında seçilen özellik fırçası kullanılır.
- [ ] **Afetler:** yukarıdaki tablonun tamamı.
- [ ] **Kutsama / lanet:** bir şehre bolluk, bir krallığa kıtlık. Tek canlıya özellik ver veya al.
- [ ] **Müdahale:** iki krallığa savaş ilan ettir, barış yaptır, kral değiştir, isyan çıkar.
- [ ] **Bilgi araçları:** krallık haritası, ırk haritası, nüfus/altın/teknoloji grafikleri, kronik.

## 12. Din ve kültür
- [ ] Krallıklar kendi dinlerini kurar (doğa, ateş, ata, güneş). Din savaşları, misyonerler (Hatip, Rahip özellikleri).
- [ ] Kültür: krallık adı, bayrak rengi, şehir adları ırka göre üretilir (Elf adları yumuşak, Ork adları sert).

## 13. Dünya ve harita
- [ ] Harita boyutları: Küçük (256²) · Orta (512²) · Büyük (1024²) · Dev (2048², yalnızca PC).
- [ ] Prosedürel üretim: kıtalar, adalar, iklim kuşakları, nehirler, maden yatakları. Aynı tohum aynı dünyayı verir.
- [ ] Biyomlar: okyanus, kıyı, ova, orman, yağmur ormanı, bataklık, çöl, bozkır, dağ, kar, tundra, volkanik.

## 14. Teknik hedefler
- [ ] 60 FPS; orta seviye telefonda 5.000+, PC'de 20.000+ canlı.
- [ ] Kayıt/yükleme (birden çok yuva). Eski kayıtlar yeni sürümlerde de açılsın.
- [ ] Türkçe arayüz, dokunmatik ve fare desteği, PC klavye kısayolları.
- [ ] Ses: ortam sesleri, afet sesleri, çağa göre değişen müzik (yalnızca ücretsiz kaynaklar).

---

## Ek: 100 özelliğin tam listesi
Etkiler yüzde değişimdir: `+30` = %30 artış. Asıl veri `veri/ozellikler.json` dosyasındadır.

| # | Özellik | Kategori | Tür | Nadirlik | Etkiler |
|---|---|---|---|---|---|
| 1 | Aptal | Zihin | olumsuz | ★★ | zeka -40, ogrenme -30, calisma +5 |
| 2 | Zeki | Zihin | olumlu | ★★ | zeka +25, ogrenme +20 |
| 3 | Dahi | Zihin | olumlu | ★★★★★ | zeka +60, ogrenme +50, teknoloji +40, moral -5 |
| 4 | Bilge | Zihin | olumlu | ★★★★ | zeka +30, diplomasi +25, karar +30 |
| 5 | Saf | Zihin | olumsuz | ★★ | zeka -15, diplomasi -10, aldatilma +40 |
| 6 | Kurnaz | Zihin | olumlu | ★★★ | zeka +15, ticaret +20, casusluk +30 |
| 7 | Unutkan | Zihin | olumsuz | ★★ | ogrenme -25, calisma -10 |
| 8 | Meraklı | Zihin | olumlu | ★★ | kesif +30, ogrenme +15, tehlike +10 |
| 9 | Yaratıcı | Zihin | olumlu | ★★★ | teknoloji +20, kultur +25 |
| 10 | Mucit | Zihin | olumlu | ★★★★ | teknoloji +45, silah_yapim +20 |
| 11 | Deli | Zihin | karma | ★★★ | zeka -10, cesaret +40, karar -40, teknoloji +10 |
| 12 | Odaklı | Zihin | olumlu | ★★ | calisma +15, ogrenme +10 |
| 13 | Dalgın | Zihin | olumsuz | ★★ | calisma -15, kaza +20 |
| 14 | Stratejist | Zihin | olumlu | ★★★★ | savas_taktik +45, liderlik +15 |
| 15 | Hafızalı | Zihin | olumlu | ★★★ | ogrenme +25, kultur +10 |
| 16 | Güçlü | Beden | olumlu | ★★ | guc +30, insaat +15, madencilik +15 |
| 17 | Zayıf | Beden | olumsuz | ★★ | guc -30, can -10 |
| 18 | Hızlı | Beden | olumlu | ★★ | hiz +30, kacis +25 |
| 19 | Yavaş | Beden | olumsuz | ★★ | hiz -30 |
| 20 | Dev Cüsseli | Beden | karma | ★★★★ | guc +50, can +40, hiz -15, yemek +60 |
| 21 | Ufak Tefek | Beden | karma | ★★★ | guc -15, gizlilik +30, yemek -30 |
| 22 | Dayanıklı | Beden | olumlu | ★★ | can +30, hastalik_direnci +15 |
| 23 | Hastalıklı | Beden | olumsuz | ★★ | can -25, omur -20, hastalik_direnci -40 |
| 24 | Çevik | Beden | olumlu | ★★★ | hiz +15, kacinma +30, okculuk +10 |
| 25 | Sakar | Beden | olumsuz | ★★ | kaza +30, kacinma -20, zanaat -15 |
| 26 | Uzun Ömürlü | Beden | olumlu | ★★★ | omur +50 |
| 27 | Kısa Ömürlü | Beden | olumsuz | ★★ | omur -40, dogurganlik +10 |
| 28 | Zayıf Gözlü | Beden | olumsuz | ★★ | gorus -40, okculuk -30 |
| 29 | Keskin Göz | Beden | olumlu | ★★★ | gorus +35, okculuk +30, avcilik +15 |
| 30 | Yenilenen | Beden | olumlu | ★★★★ | iyilesme +60, can +10 |
| 31 | Çalışkan | Karakter | olumlu | ★★ | calisma +35, uretim +25 |
| 32 | Tembel | Karakter | olumsuz | ★★ | calisma -35, uretim -25, moral +5 |
| 33 | Cesur | Karakter | olumlu | ★★ | cesaret +35, moral +10 |
| 34 | Korkak | Karakter | olumsuz | ★★ | cesaret -40, kacis +20, hayatta_kalma +10 |
| 35 | Saldırgan | Karakter | karma | ★★ | saldiri +25, savas_istegi +40, diplomasi -20 |
| 36 | Barışçıl | Karakter | karma | ★★ | savas_istegi -40, diplomasi +20, saldiri -10 |
| 37 | Açgözlü | Karakter | karma | ★★ | altin_toplama +30, ihanet +15, diplomasi -10 |
| 38 | Cömert | Karakter | olumlu | ★★ | diplomasi +20, moral_cevre +15, altin_toplama -15 |
| 39 | Sadık | Karakter | olumlu | ★★ | sadakat +40 |
| 40 | Hain | Karakter | olumsuz | ★★★ | sadakat -50, ihanet +50, casusluk +15 |
| 41 | Kibirli | Karakter | olumsuz | ★★ | diplomasi -25, liderlik +5, moral +10 |
| 42 | Alçakgönüllü | Karakter | olumlu | ★★ | diplomasi +15, sadakat +10 |
| 43 | Sabırlı | Karakter | olumlu | ★★ | kusatma +25, karar +10 |
| 44 | Sabırsız | Karakter | olumsuz | ★★ | karar -20, hiz +5 |
| 45 | Neşeli | Karakter | olumlu | ★★ | moral +25, moral_cevre +10 |
| 46 | Karamsar | Karakter | olumsuz | ★★ | moral -25, dogurganlik -10 |
| 47 | Hırslı | Karakter | karma | ★★★ | liderlik +20, darbe +30, calisma +15 |
| 48 | Kanaatkâr | Karakter | olumlu | ★★ | moral +15, yemek -15, darbe -30 |
| 49 | Kıskanç | Karakter | olumsuz | ★★ | kavga +30, diplomasi -15 |
| 50 | Merhametli | Karakter | olumlu | ★★ | sifa +15, esir_serbest +40, saldiri -10 |
| 51 | Karizmatik | Sosyal | olumlu | ★★★ | liderlik +30, diplomasi +25, es_bulma +30 |
| 52 | İtici | Sosyal | olumsuz | ★★ | es_bulma -40, diplomasi -25 |
| 53 | Diplomat | Sosyal | olumlu | ★★★ | diplomasi +45, ittifak +30 |
| 54 | Lider | Sosyal | olumlu | ★★★★ | liderlik +50, kral_olma +40 |
| 55 | Yalnız Kurt | Sosyal | karma | ★★ | hayatta_kalma +25, es_bulma -25, kesif +15 |
| 56 | Kalabalık Sever | Sosyal | olumlu | ★★ | moral_sehir +20, dogurganlik +10 |
| 57 | Hatip | Sosyal | olumlu | ★★★ | din_yayma +35, isyan_cikarma +25, liderlik +15 |
| 58 | Yalancı | Sosyal | olumsuz | ★★ | casusluk +20, diplomasi -20, sadakat -10 |
| 59 | Dürüst | Sosyal | olumlu | ★★ | diplomasi +15, ticaret +10, casusluk -20 |
| 60 | Arabulucu | Sosyal | olumlu | ★★★ | baris_yapma +45, diplomasi +20 |
| 61 | Doğurgan | Üreme | olumlu | ★★ | dogurganlik +45 |
| 62 | Kısır | Üreme | olumsuz | ★★ | dogurganlik -100 |
| 63 | İkiz Doğurur | Üreme | olumlu | ★★★ | ikiz_sansi +50 |
| 64 | Güçlü Kalıtım | Üreme | olumlu | ★★★ | ozellik_aktarma +40 |
| 65 | Mutant | Üreme | karma | ★★★★ | mutasyon +60, can -5 |
| 66 | Sağlıklı Soy | Üreme | olumlu | ★★★ | cocuk_olumu -50, hastalik_direnci +15 |
| 67 | Erken Olgun | Üreme | karma | ★★ | yetiskinlik_yasi -30, omur -10 |
| 68 | Geç Olgun | Üreme | karma | ★★ | yetiskinlik_yasi +40, ogrenme +15 |
| 69 | Usta Çiftçi | Yetenek | olumlu | ★★ | tarim +50 |
| 70 | Usta Avcı | Yetenek | olumlu | ★★ | avcilik +50, okculuk +10 |
| 71 | Usta Madenci | Yetenek | olumlu | ★★ | madencilik +50 |
| 72 | Usta Demirci | Yetenek | olumlu | ★★★ | silah_yapim +45, zirh_yapim +45 |
| 73 | Usta İnşaatçı | Yetenek | olumlu | ★★ | insaat +50 |
| 74 | Tüccar | Yetenek | olumlu | ★★ | ticaret +45, altin_toplama +20 |
| 75 | Denizci | Yetenek | olumlu | ★★★ | denizcilik +50, kesif +15 |
| 76 | Şifacı | Yetenek | olumlu | ★★★ | sifa +50, salgin_direnci_cevre +20 |
| 77 | Simyacı | Yetenek | karma | ★★★★ | iksir +50, teknoloji +15, kaza +10 |
| 78 | Okçu | Yetenek | olumlu | ★★ | okculuk +45 |
| 79 | Kılıç Ustası | Yetenek | olumlu | ★★★ | yakin_dovus +45 |
| 80 | Atlı | Yetenek | olumlu | ★★★ | binicilik +50, hiz_savas +20 |
| 81 | Büyü Yetenekli | Yetenek | olumlu | ★★★★★ | buyu +60 |
| 82 | Rahip | Yetenek | olumlu | ★★★ | din_yayma +40, moral_sehir +15 |
| 83 | Kâşif | Yetenek | olumlu | ★★ | kesif +50, yerlesim_kurma +20 |
| 84 | Soğuğa Dayanıklı | Doğa | olumlu | ★★ | soguk_direnci +60 |
| 85 | Sıcağa Dayanıklı | Doğa | olumlu | ★★ | sicak_direnci +60 |
| 86 | Yüzücü | Doğa | olumlu | ★★ | yuzme +60, bogulma -60 |
| 87 | Gece Görüşü | Doğa | olumlu | ★★★ | gece_savas +40, gorus +10 |
| 88 | Zehre Bağışık | Doğa | olumlu | ★★★★ | zehir_direnci +90 |
| 89 | Hastalığa Bağışık | Doğa | olumlu | ★★★★ | hastalik_direnci +80 |
| 90 | Ateşe Dayanıklı | Doğa | olumlu | ★★★★ | ates_direnci +70 |
| 91 | Doğa Dostu | Doğa | olumlu | ★★ | orman_uyumu +40, hayvan_saldiri -40 |
| 92 | Hayvan Terbiyecisi | Doğa | olumlu | ★★★ | evcillestirme +60 |
| 93 | Dağlı | Doğa | olumlu | ★★ | dag_hareket +50, madencilik +10 |
| 94 | Kutsanmış | Özel | olumlu | ★★★★★ | sans +40, moral +20, can +15 |
| 95 | Lanetli | Özel | olumsuz | ★★★★ | sans -40, kaza +30, moral_cevre -15 |
| 96 | Ölümsüz | Özel | olumlu | ★★★★★ | omur +10000, dogurganlik -60 |
| 97 | Kâhin | Özel | olumlu | ★★★★★ | afet_onsezi +70, diplomasi +10 |
| 98 | Kana Susamış | Özel | olumsuz | ★★★★ | saldiri +40, savas_istegi +70, diplomasi -50 |
| 99 | Kahraman | Özel | olumlu | ★★★★★ | cesaret +50, yakin_dovus +30, moral_ordu +40 |
| 100 | Uzaylı Geni | Özel | karma | ★★★★★ | teknoloji +40, mutasyon +30, diplomasi -15 |
