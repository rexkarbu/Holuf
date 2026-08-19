# HOLUF Camera Behavior Production Lock — M70

Dokumen ini adalah lock kanonik untuk perilaku Camera2D HOLUF sejak M70.

---

## 1. Camera Ownership

- `Camera2D` adalah child langsung dari `Player` (`CharacterBody2D`).
- Dengan demikian kamera mengikuti `Player` secara otomatis setiap frame.
- `Main` tidak memiliki Camera2D sendiri.
- Tidak ada CameraManager autoload.

---

## 2. Default Zoom

- `Camera2D.zoom = Vector2(1, 1)` (dikunci secara runtime di `player.gd _ready()`).
- M70 tidak menggunakan zoom otomatis berdasarkan ukuran room, kecepatan player, tipe lokasi, atau kondisi lainnya.
- Konsistensi skala pixel-art dipertahankan di seluruh lokasi.

---

## 3. Follow Model

- Kamera mengikuti `Player` root (`CharacterBody2D`) secara continuous.
- Root Player adalah **ground/feet baseline** (M69 lock).
- Tidak ada look-ahead.
- Tidak ada drag margins.
- Tidak ada dead zone.
- Tidak ada directional bias berdasarkan facing atau velocity.
- Player tetap di tengah layar selama belum mencapai batas map.

---

## 4. Smoothing

- `position_smoothing_enabled = true`
- `position_smoothing_speed = 5.0`
- Dikonfigurasi di `player.tscn` dan dipertahankan oleh `player.gd`.
- Tidak ada acceleration curve, spring camera, atau easing script.
- M82 dan regional playtesting dapat meninjau kembali nilai ini jika diperlukan.

---

## 5. Per-Location Bounds

- Setiap lokasi world menyediakan `camera_bounds: Rect2` sendiri sebagai `@export var` di `world.gd`.
- Tidak ada asumsi universal `2000×2000` di `player.tscn` atau `player.gd`.
- Tidak ada dictionary scene-path → bounds di Player atau GameManager.
- Tidak ada `if scene == "..." else if ...` hardcoded.
- `Main._apply_camera_for_world()` membaca `world_node.camera_bounds` setelah setiap world swap.

### Nilai saat ini (M70 baseline)

| Scene | `camera_bounds` |
|---|---|
| `world.tscn` (prototype default) | `Rect2(0, 0, 2000, 2000)` |
| `m67_test_location_a.tscn` | `Rect2(0, 0, 800, 600)` |
| `m67_test_location_b.tscn` | `Rect2(0, 0, 800, 600)` |

---

## 6. Bounds Coordinates

- `camera_bounds.position` = pojok kiri-atas dalam koordinat lokal root World.
- `camera_bounds.size` = ukuran penuh visual map yang dapat dijelajahi.
- Karena `world_node` selalu ditambahkan sebagai child of Main (Node2D di `(0,0)`) tanpa rotasi/scale, koordinat lokal = koordinat global.
- Jika arsitektur berubah sehingga World root tidak di origin, `player.configure_camera_bounds()` harus diupdate untuk mengonversi dengan `global_transform`.

---

## 7. Edge Behavior

- `Camera2D` menggunakan `limit_left`, `limit_top`, `limit_right`, `limit_bottom` yang dikonfigurasi dari `camera_bounds`.
- Di lokasi yang lebih besar dari viewport: kamera mengikuti Player hingga mendekati batas, kemudian berhenti sebelum mengekspos area di luar `camera_bounds`.
- Kamera tidak mengubah `player.global_position`, `velocity`, atau collision Player.

---

## 8. Small Location Behavior

- Jika satu atau kedua sumbu `camera_bounds` lebih kecil dari viewport efektif (contoh: `800×600` vs `1280×720`):
  - Tidak ada auto-zoom.
  - Tidak ada stretch dunia.
  - Godot `Camera2D` built-in limit resolution menangani centering/clamping secara deterministic.
  - Latar belakang di luar batas kecil dapat terlihat — ini dapat diterima untuk fixture teknikal M67.
  - Tidak ada osilasi antara limit kiri/kanan yang bertentangan.
- Jika limit-based centering tidak cukup untuk kebutuhan presentasi di masa depan, solusi custom harus didesain secara eksplisit di milestone selanjutnya.

---

## 9. Teleport Reset

- Setelah setiap **SpawnMarker arrival**, **save/load restoration**, atau **battle return**:
  - `player.configure_camera_bounds(bounds)` dipanggil untuk mengatur limits baru.
  - `player.reset_camera_after_teleport()` dipanggil untuk memanggil `Camera2D.reset_smoothing()`.
  - Ini mencegah kamera meluncur secara visual dari posisi world lama.
- Tidak dilakukan dengan mengatur smoothing speed ke nilai besar sementara.
- Smoothing tetap enabled untuk pergerakan normal setelahnya.
- Urutan yang benar: `player.global_position` diset terlebih dahulu → `configure_camera_bounds()` → `reset_camera_after_teleport()`.

---

## 10. Seamless Place Rule

- Satu lokasi yang kontinu = satu pengalaman eksplorasi player yang kontinu.
- District/subarea dalam lokasi yang SAMA tidak memicu transisi kamera.
- Tidak ada fade antar district.
- Tidak ada camera teleport zone di dalam kota yang sama.
- Hanya transisi lokasi yang bermakna (world swap via `_swap_world()`) yang mengubah `camera_bounds`.

---

## 11. Player Root

- Kamera mengikuti `CharacterBody2D` root yang merupakan **ground/feet baseline** (M69).
- `CollisionShape2D` (24×16, offset (0,-8)) tidak diubah.
- `Polygon2D` prototype tidak diubah (position (0,-16)).
- Tidak ada Camera2D offset permanen untuk mengkompensasi visual prototype.
- Framing relatif terhadap sprite final dapat ditinjau setelah aset final tersedia.

---

## 12. Art Boundary

- Tidak ada aset Aren final yang diintegrasikan di M70.
- Tidak ada `AnimatedSprite2D`, tidak ada `SpriteFrames`.
- Prototype `Polygon2D` dipertahankan.
- M78+ menangani visual karakter final.

---

## 13. Region Boundary

- M82+ memiliki wewenang atas region-specific camera framing/taste pass (zoom, offset, framing).
- Milestone tersebut harus mengonsumsi sistem M70 ini, bukan menciptakan sistem kamera terpisah.

---

## 14. Story Boundary

- M71 memiliki wewenang atas story camera cues dan cutscene camera scripting.
- Focus targets untuk cutscene, cinematic pans, dan dialogue zoom tidak diimplementasikan di M70.

---

## 15. Camera FX Boundary

- Camera shake, boss camera, dan screen effects tidak diimplementasikan di M70.
- M205 (World VFX Pass) menangani hal tersebut.
