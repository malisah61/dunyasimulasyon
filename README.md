# Dünya Simülasyon (Dünya Kutusu)

Worldbox tarzı tanrı/dünya simülasyonu — PC (tarayıcı + Windows) ve Android.

Ana tasarım: [TASARIM.md](TASARIM.md) · Canlı özellikleri: [veri/ozellikler.json](veri/ozellikler.json)

## Oyna
- PC (tarayıcı): https://malisah61.github.io/dunyasimulasyon/
- Android: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu.apk
- Windows: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu-Windows.zip

## Performans (dogrulama, `godot --headless -s betikler/dogrulama.gd -- yil=300`, hızlı mod adim=12)
Nüfus sınırı varsayılan **Sınırsız**. Ölçümler bulut makinesinde (tek çekirdek GDScript). Son ölçüm: 2026-11-11 (Gece 2).

| Harita | Tohum | 300. yılda canlı | Süre/yıl (son dilim) | 300 yıl toplam | Gece 1 |
|---|---|---|---|---|---|
| 256x160 | 7 | 6.9 bin | 20 ms | 3.4 sn | 7.1 bin, 25 ms |
| 256x160 | 3 | 10.5 bin | 35 ms | 6.1 sn | 11.1 bin, 43 ms |
| 256x160 (1000 yıl) | 11 | 18.5 bin | 44 ms | 34 sn | 17.5 bin, 71 ms, 56 sn |
| 256x160, sınır 2500 | 7 | 2.8 bin | 9 ms | 2.2 sn | 10 ms |
| 384x240 | 5 | 22.4 bin | 77 ms | 11.9 sn | — |
| 512x320 | 5 | 35 bin | 148 ms | 20.6 sn | 34 bin, 360 ms, 45 sn |

Harita çizimi (tüm dünyanın yeniden çizilmesi, 256x160): 559 ms → 160–250 ms (bayt dizisi + 4x4 karo önbelleği). Yükleme ve yeni dünya bu kadar hızlandı.

İlk sürüm: 3000 sınırla 38 ms/yıl, 10.4 bin canlıda 79 ms/yıl.
