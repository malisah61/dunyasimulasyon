# Gece günlüğü

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
