# Dünya Simülasyon (Dünya Kutusu)

Worldbox tarzı tanrı/dünya simülasyonu — PC (tarayıcı + Windows) ve Android.

Ana tasarım: [TASARIM.md](TASARIM.md) · Canlı özellikleri: [veri/ozellikler.json](veri/ozellikler.json)

## Oyna
- PC (tarayıcı): https://malisah61.github.io/dunyasimulasyon/
- Android: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu.apk
- Windows: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu-Windows.zip

## Kasma ölçümü (kare süreleri) — `godot -- olcum`
Az/orta/çok nüfus × uzak/yakın/çok yakın × 1x/20x/100x/500x. Yazılım çizimiyle (ekran kartsız bulut makinesi) ölçülür; gece gece karşılaştırma içindir. Tam tablo: [GUNLUK.md](GUNLUK.md), her derlemenin ölçümü: `onizleme/olcum.txt`.

**Son ölçüm: 2026-11-11 (Gece 6).** Aynı kayıtlı dünya (512x320, ~22 bin canlı), Gece 5 ve Gece 6 kodu dönüşümlü 4–5 kez, her biri 3 denemenin en iyisi (bulut makinesi ±%15 oynuyor). Sonra sütunu yeni sistemlerin (gemiler, köpekler, kurt sürüleri, kutsama) yükünü de taşır:

| Hız | Bir ay (önce → sonra) | Hareket |
|---|---|---|
| 20x (adim 2) | 17.3–19.5 → **14.2–16.8 ms** (≈ −%15) | 11.1–12.8 → **8.7–10.3 ms** (≈ −%20) |
| 100x (adim 6) | 7.2–9.2 → 8.1–9.6 ms (aynı) | 2.3–2.9 → 2.3–2.9 ms |
| 500x (adim 12) | 5.6–7.9 → 6.7–8.4 ms (aynı) | 0.9–1.3 → 1.3–1.6 ms |

Gece 6'da: 20x'te de seyrek sivil yürüyüşü, yeni köy yeri aramada ucuz ön eleme (köy işi ayda 2.1 → 1.35 ms), askerin krallığı dizide, deniz rotaları önbellekte.

Gece 5 ölçümü: Aynı kayıtlı dünyada (512x320, ~29 bin canlı), eski ve yeni kod art arda, bir simülasyon ayının süresi (2–3 ölçümün ortalaması; makine gürültüsü ±%15). "Sonra" sütunu bu gecenin yeni sistemlerini (generaller, kervan ticareti, haydutlar) de taşır:

| Hız | Bir ay (önce → sonra) | Hareket | Krallıklar |
|---|---|---|---|
| 500x (adim 12) | 13.1 → **10.4 ms** (−%21) | 3.15 → **1.75 ms** | 1.68 → **0.99 ms** |
| 100x (adim 6) | 13.5 → 13.4 ms | 4.5 → **3.9 ms** | 1.42 → **1.13 ms** |
| 20x (adim 2) | 28.6 → **26.7 ms** (−%7) | 18.1 → **17.1 ms** | 1.72 → **1.14 ms** |

Derleme makinesinde (CI olcum, Gece 4 → 5): Dev harita 100x **37 → 60 ay/sn**, 500x **39 → 71 ay/sn**; orta 500x **118 → 244 ay/sn**.
Bulut ölçümü (olcum, Dev harita): 100x'te ulaşılan hız 28 → **39 ay/sn**, 500x'te 31 → **40 ay/sn** (yeni kurallarla dünya ~%20 daha az kalabalık; asıl karşılaştırma yukarıdaki aynı-dünya tablosu).

Önceki geceler (Gece 4, olcum): az/uzak/500x kare 41.6 → 37.1 ms; orta/yakın/100x 53.6 → 39.9 ms; Dev/yakın/500x 71.2 → 57.8 ms.
Gece 3'te: parçalı harita dokusu (5–18 kat). Gece 4'te: 100x–500x'te seyrek sivil yürüyüşü, ayrı canlı katmanı. Gece 5'te: krallık aramaları sözlük yerine dizilerden, özellik etkileri önceden hesaplı, dolu dünyada boşa köy yeri aranmaz, 100x–500x'te siviller dört kat seyrek yürür.

## Simülasyon hızı (dogrulama, `godot --headless -s betikler/dogrulama.gd -- yil=300`, hızlı mod adim=12)
Nüfus sınırı varsayılan **Sınırsız**. Ölçümler bulut makinesinde (tek çekirdek GDScript). Son ölçüm: 2026-11-11 (Gece 3). Bu geceki makine Gece 2'dekinden ~%25 yavaştı; "Gece 2 (aynı makine)" sütunu eski kodun bu makinedeki süresidir.

| Harita | Tohum | 300. yılda canlı | Süre/yıl (son dilim) | 300 yıl toplam | En yavaş tek ay | Gece 2 (aynı makine) |
|---|---|---|---|---|---|---|
| 256x160 | 7 | 6.5 bin | 24 ms | 4.6 sn | 4.9 ms | 6.8 bin, 4.0 sn |
| 256x160 | 3 | 10.5 bin | 43 ms | 7.0–8.2 sn | 12.5 ms | 10.7 bin, 7.1 sn |
| 256x160 (1000 yıl) | 11 | 19.6 bin | 59 ms | 50 sn | 22 ms | 17.2 bin, 42.5 sn |
| 256x160, sınır 2500 | 7 | 2.8 bin | 10 ms | 3.0 sn | 3.2 ms | — |
| 384x240 | 5 | 21.8 bin | 73 ms | 12.7 sn | 14 ms | — |
| 512x320 | 5 | 32.6 bin | 172 ms | 20.7 sn | 28 ms | 31.3 bin, 22.2 sn (tek ay 57–79 ms) |

Bir ayın süresi (10.5 bin canlı): 1x–5x ~10 ms (8 kareye yayılır), 100x ~4.3 ms, 500x ~2.9 ms.

Harita çizimi (tüm dünyanın yeniden çizilmesi, 256x160): 559 ms → 160–250 ms (Gece 2). Gece 3'ten beri oyun sırasında tüm harita yeniden çizilmez; yalnızca değişen 32x32 karoluk parçalar yüklenir.

İlk sürüm: 3000 sınırla 38 ms/yıl, 10.4 bin canlıda 79 ms/yıl.

## Kaynaklar ve lisans
- Görseller, sesler ve müzik kodla üretilir (dosya yok).
- `veri/yazi/simgeler.yazi`: DejaVu Sans yazı tipinin simge alt kümesi (özgür lisans, bkz. `veri/yazi/LISANS-DejaVu.txt`).
