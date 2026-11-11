# Dünya Simülasyon (Dünya Kutusu)

Worldbox tarzı tanrı/dünya simülasyonu — PC (tarayıcı + Windows) ve Android.

Ana tasarım: [TASARIM.md](TASARIM.md) · Canlı özellikleri: [veri/ozellikler.json](veri/ozellikler.json)

## Oyna
- PC (tarayıcı): https://malisah61.github.io/dunyasimulasyon/
- Android: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu.apk
- Windows: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu-Windows.zip

## Kasma ölçümü (kare süreleri) — `godot -- olcum`
Az/orta/çok nüfus × uzak/yakın/çok yakın × 1x/20x/100x/500x. Yazılım çizimiyle (ekran kartsız bulut makinesi) ölçülür; gece gece karşılaştırma içindir. Tam tablo: [GUNLUK.md](GUNLUK.md), her derlemenin ölçümü: `onizleme/olcum.txt`. Son ölçüm: 2026-11-11 (Gece 4), önce = Gece 3 kodu, aynı makine.

| Nüfus | Görünüm | Hız | Ort. kare ms (önce → sonra) | En yavaş kare ms | Ulaşılan hız (ay/sn) |
|---|---|---|---|---|---|
| az (~1–3 bin) | uzak | 500x | 41.6 → **37.1** | 71.1 → **58.2** | 254 → **346** |
| orta (~5–6 bin) | yakın | 1x | 31.5 → **26.2** | 45.1 → **35.7** | 1 → 1 |
| orta (~5–6 bin) | yakın | 100x | 53.6 → **39.9** | 70.3 → **60.1** | 72 → **98** |
| orta (~5–6 bin) | uzak | 100x | 44.7 → **37.7** | 69.6 → **52.9** | 83 → **99** |
| çok (Dev harita, ~10–12 bin) | yakın | 1x | 52.7 → **38.1** | 82.9 → **62.6** | 1 → 1 |
| çok (Dev harita, ~10–12 bin) | yakın | 500x | 71.2 → **57.8** | 104.9 → **79.3** | 31 → **42** |
| çok (Dev harita, ~10–12 bin) | çok yakın | 100x | 60.7 → **50.7** | 76.6 → **66.6** | 30 → **39** |

Gece 3'te: parçalı harita dokusu (5–18 kat). Gece 4'te: 100x–500x'te seyrek sivil yürüyüşü, ayrı canlı katmanı, çok yakında 12 dikdörtgen yerine 3 hazır resim.

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
- Görseller ve sesler kodla üretilir (dosya yok).
- `veri/yazi/simgeler.yazi`: DejaVu Sans yazı tipinin simge alt kümesi (özgür lisans, bkz. `veri/yazi/LISANS-DejaVu.txt`).
