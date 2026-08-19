# HOLUF — World Transition Pipeline (M67)
## Canonical Reference Document

---

## 1. Philosophical Foundation

**ONE CONTIGUOUS PLACE = ONE CONTIGUOUS PLAYER EXPERIENCE.**

A transition represents a **meaningful LOCATION CHANGE** — not a district boundary within one city.

### Valid Transitions (Seamless Place Rule)
| From | To | Valid? |
|------|----|--------|
| Town | Route | ✅ |
| Route | Dungeon | ✅ |
| Exterior | Meaningful Interior | ✅ |
| Region | Region | ✅ |
| Dungeon Floor | Separate Floor | ✅ (when justified) |

### Invalid Transitions
| From | To | Why Invalid |
|------|----|-------------|
| Caelora Harbor | Caelora Plaza | Same contiguous city |
| Residential District | Market District | Same city |
| East Street | West Street | Same settlement |

---

## 2. Terminology

| Term | Definition |
|------|-----------|
| **ROOT GAMEPLAY SCENE** | `res://scenes/main/main.tscn` — always the Godot scene root |
| **ACTIVE WORLD LOCATION** | The location content currently hosted inside Main (e.g. `world.tscn`, `dungeon.tscn`) |
| **LOCATION** | A meaningful explorable place |
| **LOCATION BOUNDARY** | Conceptual boundary between two meaningful locations |
| **ENTRANCE / EXIT** | Player-facing entry/departure point |
| **TRANSITION ZONE** | Runtime `Area2D` trigger at a legitimate location boundary |
| **DESTINATION** | Target location scene file |
| **SPAWN POINT** | Named `Marker2D` in the destination |
| **RETURN POINT** | Logical counterpart for reversible transitions |
| **DISTRICT / SUBAREA** | Part of one seamless location — NOT a valid transition boundary |

---

## 8. Save Schema (Version 3)

### Implemented Components

#### `scripts/world/transition_zone.gd` (`TransitionZone`, extends `Area2D`)
**Exported properties:**
- `destination_scene_path: String` — path ke .tscn lokasi tujuan
- `target_spawn_id: String` — ID SpawnMarker di tujuan
- `is_enabled: bool` — false untuk story-lock (M71 will set this externally)

**Preflight sebelum transisi (urutan):**
1. `destination_scene_path` tidak kosong
2. `ResourceLoader.exists(destination_scene_path)`
3. Load sebagai `PackedScene` berhasil
4. Instantiasi preview sementara, cari `SpawnMarker` dengan `spawn_id == target_spawn_id`, hapus preview
5. Jika semua lulus → set GameManager state → mulai transisi

**Jika preflight gagal:** `push_error`, return. Tidak ada fade. Tidak ada scene change. State GameManager tidak berubah. Player tetap di lokasi saat ini.

#### `scripts/world/spawn_marker.gd` (`SpawnMarker`, extends `Marker2D`)
**Exported properties:**
- `spawn_id: String` — identifier stabil (contoh: `south_gate`, `dungeon_entrance`)

**Behavior:** Komponen pasif. Posisi di-authoring di editor. Memberi peringatan jika `spawn_id` kosong.

---

## 4. GameManager State (M67)

```gdscript
# Lokasi aktif saat ini — persisten antar battle return
const DEFAULT_WORLD_SCENE := "res://scenes/world/world.tscn"
var current_world_scene: String = DEFAULT_WORLD_SCENE

# State transisi tertunda — sementara, dikonsumsi setelah arrival
var target_world_scene: String = ""
var target_spawn_id: String = ""
```

**`current_world_scene`** = lokasi dunia yang sedang aktif. Diperbarui setelah setiap arrival berhasil. Disimpan ke save file v3.

**`target_world_scene`** = permintaan transisi sementara. Dikonsumsi dan dikosongkan di `main.gd._ready()`.

**`target_spawn_id`** = ID SpawnMarker tujuan. Dikonsumsi dan dikosongkan di `main.gd._ready()`.

---

## 5. Spawn Resolution Precedence

Diimplementasikan di `scripts/core/main.gd`:

```
1. MANUAL SAVE PENDING LOAD
   SaveManager._has_pending_load == true
   → Baca location_scene dari save data
   → Swap world ke scene tersebut
   → apply_pending_load() menangani koordinat X/Y

2. M67 TARGET SPAWN
   GameManager.target_world_scene != ""
   → Swap world ke target scene
   → Update current_world_scene
   → Temukan SpawnMarker dengan target_spawn_id
   → Kosongkan target_world_scene dan target_spawn_id

3. BATTLE RETURN
   GameManager.player_return_position != Vector2.ZERO
   → Pastikan current_world_scene ter-load (bukan hanya default)
   → Pindahkan player ke player_return_position

4. DEFAULT
   New game atau boot pertama
   → world.tscn sudah terpasang di main.tscn
   → current_world_scene = DEFAULT_WORLD_SCENE
```

---

## 9. Save Schema (Version 3)

```json
{
  "save_version": 3,
  "world": {
    "scene": "res://scenes/main/main.tscn",
    "location_scene": "res://scenes/world/world.tscn",
    "player_x": 1024.0,
    "player_y": 768.0
  },
  ...
}
```

**`world.scene`** = root gameplay scene (selalu `main.tscn`)  
**`world.location_scene`** = active world location scene yang aktif saat save  
**`world.player_x / player_y`** = koordinat pemain di lokasi tersebut

### Legacy v1/v2 Compatibility

Save v1/v2 tidak memiliki `world.location_scene`. Diperlakukan sebagai save dari dunia prototype:

```
location_scene (missing) → res://scenes/world/world.tscn
```

Tidak ada konversi otomatis. Save baru setelah load v2 akan menjadi v3.

---

## 7. _swap_world() Contract (Transaksional)

```
1. ResourceLoader.exists(new_scene_path)  → fail: return false, world lama aman
2. load() sebagai PackedScene             → fail: return false, world lama aman
3. instantiate()                          → fail: return false, world lama aman
4. HANYA SEKARANG: world_node.queue_free()
5. add_child(new_node), move_child ke index 0
6. return true
```

World lama tidak pernah dihapus jika penggantinya gagal dimuat.

`TransitionManager.transition_to_scene()` mengembalikan `bool`:
- Jika `_is_transitioning == true` saat dipanggil → `push_warning`, return `false` langsung
- `TransitionZone` juga memeriksa `GameManager.is_transitioning` sebelum memulai

---

## 8. Failure Handling

| Kondisi Gagal | Behavior |
|--------------|----------|
| Scene tujuan tidak ada | `push_error`, return `false` sebelum fade |
| Scene load gagal (`err != OK`) | Fade balik, restore input, return `false` |
| SpawnMarker tidak ditemukan | `push_error`, player tidak dipindah ke Vector2.ZERO |
| Layar hitam permanen | Tidak mungkin: setiap path kegagalan memanggil fade-out recovery |

---

## 9. Battle Return Location Preservation

Skenario:
1. Player berada di **Location B** (`dungeon.tscn`)
2. `start_battle()` menyimpan `player_return_position`
3. `current_world_scene` = `dungeon.tscn`
4. Battle selesai → `return_to_world()` → `main.tscn`
5. `main.gd._ready()` memeriksa: `player_return_position != Vector2.ZERO`
6. Jika `current_world_scene != DEFAULT_WORLD_SCENE`, swap ke dungeon.tscn
7. Player kembali di posisi yang benar di Location B

---

## 10. Story-Lock Boundary (M71)

`TransitionZone.is_enabled = false` memblokir transisi tanpa menyentuh logika quest.
M71 akan mengontrol nilai `is_enabled` dari luar tanpa mengubah kode TransitionZone.

---

## 11. Checkpoint / Autosave API

Untuk transisi checkpoint-worthy (region → region, story boundary):
```gdscript
SaveManager.request_checkpoint_autosave("region_transition")
```

Jika player node diperlukan secara langsung:
```gdscript
SaveManager.request_autosave(player_node)  # player_node wajib diisi
```

**Jangan panggil `SaveManager.request_autosave()` tanpa argumen.**

---

## 12. Authoring Workflow

1. M66 mendefinisikan batas lokasi yang sah
2. Author map menempatkan `TransitionZone` (Area2D) di titik keluar
3. Author map menempatkan `SpawnMarker` (Marker2D) di titik kedatangan — di luar overlap TransitionZone
4. Set `destination_scene_path` dan `target_spawn_id` di Inspector
5. Verifikasi round-trip A ↔ B
6. Verifikasi tidak ada ping-pong
7. Klasifikasi save/checkpoint policy
8. Koneksikan story availability di M71 jika diperlukan

---

## 13. M76+ Consumption

**M76 adalah consumer M67, bukan implementor-nya.**

M76 (Elaris Layout Lock) akan:
- Menempatkan `TransitionZone` di batas kota/rute Elaris
- Menempatkan `SpawnMarker` di setiap titik kedatangan
- Menggunakan sistem ini tanpa memodifikasi kode inti M67

---

## 14. Test Results

| Test | Result |
|------|--------|
| A → B | INCONCLUSIVE (runtime tidak tersedia) |
| B → A | INCONCLUSIVE (runtime tidak tersedia) |
| Correct Spawn | INCONCLUSIVE (runtime tidak tersedia) |
| Duplicate Request | STATIC PASS |
| Missing Spawn | STATIC PASS |
| Save Location B | INCONCLUSIVE (runtime tidak tersedia) |
| Reload Location B | INCONCLUSIVE (runtime tidak tersedia) |
| Legacy v2 fallback | STATIC PASS |
| Battle Entry | STATIC PASS |
| Battle Return same location | STATIC PASS |
| NPC Regression | STATIC PASS |
| Encounter Regression | STATIC PASS |

---

## 15. Deferred Items

- **Spawn Facing Direction**: DEFERRED ke M68 setelah arsitektur animasi direktional dikonfirmasi
- **Runtime test harness execution**: DEFERRED — memerlukan Godot editor runtime
