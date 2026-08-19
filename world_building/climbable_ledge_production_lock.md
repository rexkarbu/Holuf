# HOLUF Climbable Ledge Production Lock — M73

Dokumen ini adalah pedoman mutlak (production lock) untuk desain dan penggunaan Climbable Ledge di HOLUF berdasarkan spesifikasi M73.

## 1. Purpose
Tujuan komponen ini adalah menyediakan purwarupa *one-way* (hanya naik) yang _art-agnostic_ untuk mekanik tebing/tangga tanpa harus menggunakan transisi *scene* atau *fade-out*.

## 2. One-way M73 scope
Ledge pada fase M73 hanya dirancang untuk pergerakan naik (lower → upper). Ledge tidak memiliki trigger di bagian atas untuk turun.

## 3. M74 boundary
Fungsi turun (drop-down), algoritma pencarian posisi jika tersangkut (anti-stuck), dan pergerakan jatuh secara bebas (freefall) berada di luar batas M73 dan dikhususkan secara terpisah untuk milestone M74.

## 4. Interaction via existing E / Enter
Komponen ini menggunakan arsitektur `Interactable` dari Player. Ketika Player berada dekat batas bawah tebing (deteksi via InteractionShape), notifikasi *prompt* (misalnya: `[Press E to climb ledge]`) akan muncul, sama seperti berinteraksi dengan NPC atau objek lain.

## 5. ClimbableLedge ownership
Level designer cukup menempatkan instance dari `res://scenes/world/climbable_ledge.tscn` (sebagai turunan `Interactable`). Tidak diperlukan *state machine* terpisah atau *Autoload* untuk mengaturnya.

## 6. ClimbStart marker
Target posisi koordinat Player sebelum mulai menaiki tebing (Fase 1). Digunakan untuk meluruskan titik jangkar (*alignment*).

## 7. ClimbEnd marker
Target posisi koordinat Player setelah memanjat (Fase 2).

## 8. feet/root coordinate semantics
Kedua marker (ClimbStart dan ClimbEnd) merepresentasikan *root / feet baseline* murni dari `CharacterBody2D` milik Player (offset standar M69). Tidak perlu menambahkan kompensasi +8/-8 di editor.

## 9. marker-driven distance
Jarak memanjat tidak ditentukan secara kaku (misalnya 32px atau 64px) di logika sistem. Titik awal (ClimbStart) dan titik akhir (ClimbEnd) yang dapat dipindah-pindahkan dalam editor akan langsung menjadi acuan jarak *tweening*.

## 10. barrier vs interaction vs visual separation
- `Barrier` (StaticBody2D) akan menghalau M68 *movement*.
- `InteractionShape` memicu tombol *prompt* jika Player mendekat di bawah.
- Tampilan tebing (Visual) murni urusan susunan *TileMap* atau `Polygon2D`. Ketiga elemen ini independen.

## 11. scripted traversal state
Terdapat boolean murni pada Player `is_traversing_ledge` (terpisah dari `is_locked`) yang menandakan bahwa Player saat ini sedang dikontrol sepenuhnya oleh *script* memanjat.

## 12. normal movement suppression during traversal
Ketika `is_traversing_ledge` bernilai `true`:
- Fungsi `move_and_slide()` ditiadakan.
- Input jalan diblokir.
- Interaksi ganda dicegah.
- Menu _Party_ atau *Debug* tidak dapat dibuka.

## 13. encounter-distance exclusion
Dikarenakan `move_and_slide()` tidak terpanggil selama traversal, pergerakan naiknya tidak menyumbang apa pun terhadap metrik pembentukan batas ambang *random encounter* pada `EncounterManager`.

## 14. camera behavior
Kamera M70 (Camera2D) otomatis mengikuti panjatan dengan *smoothing* yang aktif tanpa dimatikan dan di-reset, karena `reset_camera_after_teleport` tidak dipanggil untuk efek *tweening* linear yang wajar.

## 15. save-after-completion behavior
Penyimpanan *save data* yang dilakukan tepat setelah panjatan selesai, ketika dimuat kembali akan secara otomatis meletakkan Player tepat pada ujung tebing (sesuai koordinat standar). Tidak perlu logika *save* tambahan untuk ledge ini.

## 16. battle-return compatibility
Memulai *random battle* atau pertarungan di puncak setelah panjatan usai (atau di tengah perjalanan tebing, jika pemicu khusus ditambahkan nantinya), saat selesai (*battle return*) tetap mengembalikan posisi Player utuh dengan baik tanpa bug *phasing*.

## 17. clear-landing authoring responsibility
Desainer level HARUS memastikan penempatan `ClimbEnd` berada pada area bersih (*clearance*) ukuran 24x16 piksel `CollisionShape2D` Player. Jangan meletakkan `ClimbEnd` menumpuk di atas tembok fisik lain.

## 18. invalid landing = authoring error
Tidak disediakannya mitigasi anti-stuck di M73 (seperti teleportasi darurat) berarti setiap kesalahan penempatan `ClimbEnd` yang menempatkan Player terjebak di tebing sepenuhnya menjadi **kesalahan authoring**.

## 19. no drop-down
Sistem tidak mendukung loncat turun/drop down. (Ranah M74)

## 20. no anti-stuck
Sistem tidak melakukan validasi bebas-terjebak ke segala arah. (Ranah M74)

## 21. no final art
Sistem M73 ini dipraktikkan sebagai purwarupa kubus tanpa animasi final maupun grafis dari kawasan sebenarnya (mis. Caelora/Elaris).

## 22. no final region placement
Level designer belum dipersilakan meletakkan tangga secara final di layout Elaris sebelum M83 dieksekusi.

## 23. M83 handoff
Purwarupa mekanik tangga/tebing M73 akan diturunkan langsung untuk diuji dalam penempatan kawasan pada *Elaris Climbable Ledge Placement Test* (M83).
