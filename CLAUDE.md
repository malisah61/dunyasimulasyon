# Dünya Kutusu — geliştirici notları

Worldbox tarzı tanrı/dünya simülasyonu. Sahibi: Mehmet Ali (GitHub: malisah61). Onunla ve oyun içinde her zaman Türkçe.
Ana tasarım ve yol haritası: **TASARIM.md** (biten maddeler ✅). Canlı özellikleri: **veri/ozellikler.json** (100 adet, silinmez).

## Mimari
- Godot **4.3**, GL Compatibility, saf GDScript (şimdilik). C++ GDExtension sonra eklenecek (TASARIM.md §14).
- `betikler/sim.gd` — simülasyon çekirdeği, ekrandan bağımsız. 1 tick = 1 ay. Canlılar dizi yapısında (c_x, c_y, s_guc…) tutulur; yuva tekrar kullanılır (`bos`). Köyler ve krallıklar sözlük.
- Köy durum bayrakları ve yıllık birikimler `kv_*` dizilerinde (köy id ile). Bir köyün `aclik/salgin/savasta/goc_kalan/bolluk` alanı değişirse `_bayrak(v)` çağır; köy/krallık eşleşmesi değişirse `_kk_ay = -1` (krallik_koyleri önbelleği).
- Kronik girdisi `[ay, metin, önem, x, y]` (x,y isteğe bağlı: oyuncu "Git" ile oraya gider). Önem 3 olaylar ekranda bildirim olur.
- `betikler/harita.gd` — arazi + yapılar (karo = 4x4 piksel, `piks` bayt dizisine doğrudan yazılır). Harita **32x32 karoluk parça dokulara** bölünür (`parca_sprite`); karo değişince yalnızca o parça yüklenir (`_karo_ciz_i` parçayı kirli işaretler; karede en çok ~2,5 ms karo + 4 parça). Su derinliği `su_mes`; kıyı değişimi `_su_bolgeleri` ile yerel yenilenir. Canlılar/efektler `_draw` (`_ciz`) ile: uzakta nokta listesi (önbellekli), orta uzaklıkta sade figür, yakında ayrıntı (`_asker_ciz`: çağa göre silah/zırh). **Bina katmanı** (`bina_katman`, ölçek ≥ 3): 8x8 bina resimleri atlastan çizilir, komutlar saklanır (`BINA_DESEN`; yeni bina tipi eklersen buraya da desen ekle). Krallık/ırk toprak katmanı `_toprak_adim` ile karelere yayılır.
- `betikler/ana.gd` — kamera, dokunmatik/fare/klavye, arayüz (kodla kurulur), tanrı araçları, kaydet/yükle, `onizleme` modu, `olcum` modu (kasma ölçümü), kare bütçesi (`_process`).
- `betikler/ses.gd` — tüm sesler açılışta kodla üretilir (ses dosyası yok). `ana._ses("ad")` ile çalınır.
- `betikler/dogrulama.gd` — ekransız uzun simülasyon testi: `godot --headless -s betikler/dogrulama.gd -- yil=300` (DAGILIM ve TICK satırları: tick süresinin dağılımı).
- Kasma ölçümü: `xvfb-run godot --rendering-driver opengl3 --resolution 1280x720 -- olcum` (az/orta/çok nüfus × uzak/yakın × 1x/20x/100x/500x; CI `onizleme/olcum.txt` yazar). Her gece aynı ölçüm tekrarlanır.
- Efekt tipleri (`sim.efektler`, `harita._efektleri_ciz`): 0 vuruş, 1 yıldırım, 2 deprem, 3 volkan, 4 meteor, 5 tsunami, 6 yağmur, 7 UFO ışını, 8 silgi, 9 kervan, 10 isyan, 11 sel, 12 ok, 13 tüfek, 14 lazer, 16 kıvılcım, 17 ölüm, 18 kuşatma ateşi, 19 savaş ilanı. Yeni efektleri `_efekt()` ile ekle (liste sınırlı).
- Simgeler (♛ ⚔ → ■ ★ ➤): `veri/yazi/simgeler.yazi` (DejaVu Sans alt kümesi) yedek yazı tipi olarak yüklenir; tarayıcıda sistem yazı tipi olmadığı için **emoji kullanma**, bu dosyadaki işaretleri kullan.
- `veri/turler.json` — ırklar ve hayvanlar (ömür, üreme, güç, sevdiği biyomlar, doğuştan özellik eğilimleri).

## Kurallar
- Var olan hiçbir özelliği eksiltme. Kayıt biçimi değişirse `KAYIT_SURUMU`'nu artır ve `yukle()` içinde eski kaydı dönüştür.
- GDScript'te `:=` ile tip çıkarımı, değer Dictionary/Array'den geliyorsa hata verir: `var x: float = ...` yaz.
- Hız: `hareket_adim` 1x–5x: 1 (ve `sim.yayik`: hareket ayın içine 8 dilime yayılır, `dilim_ilerlet`), 20x: 2, 100x: 6, 500x: 12. Yeni yük eklerken `dogrulama.gd` PERFORMANS/TICK satırlarına ve `olcum` çıktısına bak. Tek tick içinde tüm haritayı tarayan iş yapma (kıta etiketleri `_kita_adim` ile aylara yayılır).
- Canlının türetilmiş değerleri (`s_*`, `c_bit`) kaydedilmez; `stat_hesapla` yeniden kurar. Köy hızlı dizileri `kv_*` de öyle (`_kv_kur`).
- Yalnızca ücretsiz/açık lisanslı kaynak (CC0 tercih). Görseller şimdilik kodla çiziliyor.

## Derleme
`.github/workflows/derle.yml`: doğrulama → Web (GitHub Pages) + Windows zip + Android APK → `son-surum` yayını; `onizleme` işi oyunu sanal ekranda açıp `onizleme/*.png` kaydeder.
- Web: https://malisah61.github.io/dunyasimulasyon/
- APK: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu.apk
