# Gece günlüğü

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
