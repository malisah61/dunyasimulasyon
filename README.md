# Dünya Simülasyon (Dünya Kutusu)

Worldbox tarzı tanrı/dünya simülasyonu — PC (tarayıcı + Windows) ve Android.

Ana tasarım: [TASARIM.md](TASARIM.md) · Canlı özellikleri: [veri/ozellikler.json](veri/ozellikler.json)

## Oyna
- PC (tarayıcı): https://malisah61.github.io/dunyasimulasyon/
- Android: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu.apk
- Windows: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu-Windows.zip

## Kasma ölçümü (kare süreleri) — `godot -- olcum`
Az/orta/çok nüfus × uzak/yakın × 1x/20x/100x/500x. Yazılım çizimiyle (ekran kartsız bulut makinesi) ölçülür; gece gece karşılaştırma içindir. Tam tablo: [GUNLUK.md](GUNLUK.md), her derlemenin ölçümü: `onizleme/olcum.txt`. Son ölçüm: 2026-11-11 (Gece 3), önce = Gece 2 kodu, aynı makine.

| Nüfus | Görünüm | Hız | Ort. kare ms (önce → sonra) | En yavaş kare ms | Ulaşılan hız (ay/sn) |
|---|---|---|---|---|---|
| az (~1–3 bin) | uzak | 100x | 167.5 → **22.5** | 398.8 → **29.3** | 56 → **100** |
| az (~1–3 bin) | uzak | 500x | 270.4 → **37.5** | 419.7 → **67.3** | 52 → **322** |
| orta (~5–6 bin) | uzak | 20x | 64.0 → **28.3** | 288.5 → **47.0** | 19 → **20** |
| orta (~5–6 bin) | uzak | 100x | 239.1 → **38.9** | 516.9 → **60.0** | 25 → **98** |
| orta (~5–6 bin) | uzak | 500x | 215.2 → **43.3** | 626.2 → **58.3** | 36 → **124** |
| orta (~5–6 bin) | yakın | 100x | 252.4 → **53.4** | 583.6 → **71.6** | 23 → **83** |
| çok (Dev harita, ~12–13 bin) | uzak | 1x | 83.6 → **34.6** | 1449.9 → **55.2** | 1 → **1** |
| çok (Dev harita, ~12–13 bin) | uzak | 20x | 845.3 → **54.8** | 1728.2 → **83.6** | 1 → **18** |
| çok (Dev harita, ~12–13 bin) | uzak | 500x | 1071.3 → **54.8** | 1606.2 → **76.4** | 3 → **39** |

Sebep ve çözüm: her küçük değişiklikte tüm harita yeniden çizilip ekran kartına yükleniyordu → parçalı doku; kıta hesabı aylara, canlı hareketi karelere yayıldı.

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
