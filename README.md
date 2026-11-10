# Dünya Simülasyon (Dünya Kutusu)

Worldbox tarzı tanrı/dünya simülasyonu — PC (tarayıcı + Windows) ve Android.

Ana tasarım: [TASARIM.md](TASARIM.md) · Canlı özellikleri: [veri/ozellikler.json](veri/ozellikler.json)

## Oyna
- PC (tarayıcı): https://malisah61.github.io/dunyasimulasyon/
- Android: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu.apk
- Windows: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu-Windows.zip

## Performans (dogrulama, `godot --headless -s betikler/dogrulama.gd -- yil=300`, hızlı mod adim=12)
Nüfus sınırı varsayılan **Sınırsız**. Ölçümler bulut makinesinde (tek çekirdek GDScript):

| Harita | Tohum | 300. yılda canlı | Süre/yıl (son dilim) | 300 yıl toplam |
|---|---|---|---|---|
| 256x160 | 7 | 7.1 bin | 25 ms | 4.9 sn |
| 256x160 | 3 | 11.1 bin | 43 ms | 8.0 sn |
| 256x160 (1000 yıl) | 11 | 17.5 bin | 71 ms | 56 sn |
| 256x160, sınır 2500 | 7 | 2.8 bin | 10 ms | 3.0 sn |
| 512x320 | 5 | 34 bin | 360 ms | 45 sn |

Önceki sürüm: 3000 sınırla 38 ms/yıl, 10.4 bin canlıda 79 ms/yıl.
