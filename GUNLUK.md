# Gece günlüğü

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
