# Dünya Kutusu — geliştirici notları

Worldbox tarzı tanrı/dünya simülasyonu. Sahibi: Mehmet Ali (GitHub: malisah61). Onunla ve oyun içinde her zaman Türkçe.
Ana tasarım ve yol haritası: **TASARIM.md** (biten maddeler ✅). Canlı özellikleri: **veri/ozellikler.json** (100 adet, silinmez).

## Mimari
- Godot **4.3**, GL Compatibility, saf GDScript (şimdilik). C++ GDExtension sonra eklenecek (TASARIM.md §14).
- `betikler/sim.gd` — simülasyon çekirdeği, ekrandan bağımsız. 1 tick = 1 ay. Canlılar dizi yapısında (c_x, c_y, s_guc…) tutulur; yuva tekrar kullanılır (`bos`). Köyler ve krallıklar sözlük.
- `betikler/harita.gd` — arazi + yapılar tek resimde (karo = 4x4 piksel), canlılar/efektler `_draw` ile.
- `betikler/ana.gd` — kamera, dokunmatik/fare/klavye, arayüz (kodla kurulur), tanrı araçları, kaydet/yükle, `onizleme` modu.
- `betikler/dogrulama.gd` — ekransız uzun simülasyon testi: `godot --headless -s betikler/dogrulama.gd -- yil=300`.
- `veri/turler.json` — ırklar ve hayvanlar (ömür, üreme, güç, sevdiği biyomlar, doğuştan özellik eğilimleri).

## Kurallar
- Var olan hiçbir özelliği eksiltme. Kayıt biçimi değişirse `KAYIT_SURUMU`'nu artır ve `yukle()` içinde eski kaydı dönüştür.
- GDScript'te `:=` ile tip çıkarımı, değer Dictionary/Array'den geliyorsa hata verir: `var x: float = ...` yaz.
- Hız: 500x'te `hareket_adim = 12` (toplu hareket). Yeni yük eklerken `dogrulama.gd` PERFORMANS satırına bak.
- Yalnızca ücretsiz/açık lisanslı kaynak (CC0 tercih). Görseller şimdilik kodla çiziliyor.

## Derleme
`.github/workflows/derle.yml`: doğrulama → Web (GitHub Pages) + Windows zip + Android APK → `son-surum` yayını; `onizleme` işi oyunu sanal ekranda açıp `onizleme/*.png` kaydeder.
- Web: https://malisah61.github.io/dunyasimulasyon/
- APK: https://github.com/malisah61/dunyasimulasyon/releases/download/son-surum/DunyaKutusu.apk
