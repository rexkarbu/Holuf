# HOLUF Story / Event Trigger Pipeline — M71

Dokumen ini adalah lock kanonik untuk infrastruktur Story / Event Trigger HOLUF sejak M71.

---

## 1. Purpose

M71 menyediakan **infrastruktur generik** agar produksi regional masa depan dapat mengautori:

- Player memasuki Area2D
- Validasi kondisi story
- Request named story event
- Konsumsi one-shot yang persisten
- Story flags yang memblokir atau membuka trigger / transisi

M71 adalah **pipeline**, bukan konten cerita aktual.

---

## 2. StoryManager Ownership

- `StoryManager` adalah satu-satunya Autoload yang memiliki generic story state.
- Tidak ada per-region story manager autoload lain.
- `GameManager` tidak boleh memiliki story flags.
- `QuestManager` tetap terpisah dan tidak digabung ke `StoryManager`.

---

## 3. StoryTrigger Ownership

- `StoryTrigger` adalah komponen reusable `Area2D` yang menggunakan `class_name StoryTrigger`.
- Hanya MEMINTA named story event ke `StoryManager`.
- Tidak langsung memulai dialogue, battle, teleport, kamera, atau cutscene.
- Listener konten future (M87+, M88+) bereaksi terhadap signal `story_event_triggered`.

---

## 4. One-Shot vs Repeatable

| `one_shot` | Perilaku |
|---|---|
| `true` (default) | Hanya diterima sekali seumur hidup game. State tersimpan di StoryManager dan persisten antar save/load. |
| `false` | Dapat diterima lagi setiap kali Player masuk ulang ke Area2D. |

---

## 5. Trigger IDs

- Bertipe `StringName` secara internal.
- Harus unik di seluruh game.
- Contoh naming convention: `"prologue_opening"`, `"aelia_first_meeting"`.
- M71 tidak membuat IDs produksi. ID tersebut dibuat di M87+.

---

## 6. Required Flags

- `required_flags: Array[StringName]` pada `StoryTrigger`.
- Semua flag dalam array harus bernilai `true` agar trigger diterima.
- Array kosong = tidak ada requirement (always pass).

---

## 7. Blocked Flags

- `blocked_flags: Array[StringName]` pada `StoryTrigger`.
- Jika SATU PUN flag dalam array bernilai `true`, trigger ditolak.
- Array kosong = tidak ada blocker (always pass).

---

## 8. Consumed Trigger Semantics

- "Consumed" berarti **Area2D story event request diterima**.
- Ini **bukan** berarti:
  - Cutscene selesai
  - Quest selesai
  - Dialogue selesai
  - Boss dikalahkan
- Story progression flags harus di-set secara eksplisit oleh konten event di titik yang tepat.
- `StoryTrigger` tidak secara otomatis menciptakan narrative completion flags.

---

## 9. StoryManager Flags

- `set_flag(flag_id, value)` — set flag boolean. Tidak emit signal jika nilai tidak berubah.
- `get_flag(flag_id)` → bool. Default `false` jika belum pernah di-set.
- `has_flag(flag_id)` → bool. True jika key ada.
- `conditions_met(required, blocked)` → bool. Evaluasi required AND NOT blocked.

---

## 10. Event Signal Architecture

```
StoryTrigger (Area2D)
  → body_entered filter (group "player")
  → StoryManager.try_trigger(...)
  → [jika diterima] StoryManager.story_event_triggered.emit(trigger_id)
  → [jika diterima] StoryTrigger.triggered.emit(trigger_id)
```

- `story_event_triggered` adalah signal global dari StoryManager.
- `triggered` adalah signal lokal dari StoryTrigger (untuk script yang spesifik ke node).
- M88+ konten cutscene/dialogue terhubung ke salah satu atau keduanya.

---

## 11. StoryTransitionGate

- Komponen `Node` (class_name: `StoryTransitionGate`) yang dipasang sebagai **child** dari `TransitionZone`.
- Mengontrol `TransitionZone.is_enabled` dari story flags.
- Subscribe ke `StoryManager.story_flag_changed` — tidak polling per frame.

---

## 12. External Control of M67 TransitionZone.is_enabled

- `TransitionZone.is_enabled` adalah property yang sudah ada sejak M67.
- `StoryTransitionGate` hanya memodifikasi `is_enabled` — tidak mengubah logika transisi inti.
- Rumus efektif:
  ```
  TransitionZone.is_enabled = base_enabled AND StoryManager.conditions_met(required, blocked)
  ```
  di mana `base_enabled` adalah nilai yang di-author di Godot editor.
- Gate tidak pernah mengaktifkan TransitionZone yang sengaja dinonaktifkan untuk alasan non-story.

---

## 13. Persistence

Story state (flags + consumed triggers) persisten melewati:

- World transition (StoryManager adalah Autoload)
- Battle (StoryManager adalah Autoload)
- Save dan quit
- Reload save
- Legacy v1-v3 load (initialize empty)

---

## 14. Save v4 Structure

```json
{
  "save_version": 4,
  "gold": ...,
  "characters": { ... },
  "active_party": [ ... ],
  "inventory": { ... },
  "character_equipment": { ... },
  "story": {
    "consumed_triggers": ["event_a", "event_b"],
    "flags": {
      "flag_a": true,
      "flag_b": false
    }
  },
  "world": { ... }
}
```

- `consumed_triggers` adalah Array of String (bukan Array of StringName).
- `flags` adalah Dictionary String → bool.

---

## 15. Legacy v1-v3 Behavior

- Save v1, v2, v3 tidak memiliki field `"story"`.
- Saat di-load, `StoryManager.apply_save_data({})` dipanggil → state bersih.
- Tidak ada requirement `"story"` untuk save v1-v3.
- Setelah menyimpan ulang dari session ini, save menjadi v4.

---

## 16. New Game Reset

- `SaveManager.start_new_game()` memanggil `StoryManager.reset_to_new_game()`.
- Ini membersihkan semua flags dan consumed triggers.
- `reset_to_new_game()` TIDAK dipanggil saat: world transition biasa, battle, return from battle.

---

## 17. Quest System Separation

- `QuestManager` tetap sepenuhnya terpisah dari `StoryManager`.
- Quest state BUKAN story flags.
- M71 tidak meredesain QuestManager atau arsitektur save quest.
- Jika QuestManager tidak persisten melewati restart aplikasi, itu adalah masalah pre-existing yang harus dilaporkan secara terpisah.

---

## 18. old_ruins_trigger Remains Quest-Specific

- `scripts/world/old_ruins_trigger.gd` tidak dikonversi ke `StoryTrigger`.
- Tetap berfungsi sebagai trigger quest `whispers_beneath_forest`.
- `StoryTrigger` quest-specific dan generic story trigger dapat koeksistensi.

---

## 19. No Automatic Autosave on Trigger

- M71 tidak melakukan autosave setiap kali `StoryTrigger` diterima.
- M60.5 menyediakan checkpoint autosave API.
- Konten story future dapat memanggil checkpoint secara eksplisit saat sesuai.

---

## 20. No Story Content in M71

- M71 tidak membuat:
  - Trigger IDs produksi (prologue, Elaris, dsb.)
  - Dialogue content
  - Cutscene blocking
  - Regional story progression
- Pengujian M71 menggunakan IDs netral disposable (`test_event_a`, `test_flag_a`).

---

## 21. M87+ Placement Handoff

- M87 Elaris Story Trigger Scaffolding mengonsumsi sistem M71.
- M87 menempatkan `StoryTrigger` node dengan IDs produksi.
- M87 TIDAK boleh menciptakan sistem trigger kamera/story baru.

---

## 22. M88+ Dialogue/Cutscene Handoff

- M88+ mengimplementasikan konten cutscene aktual.
- Konten ini terhubung ke signal `StoryManager.story_event_triggered`.
- M88+ tidak mengubah sistem M71.

---

## 23. M70 Camera Boundary

- Camera behavior tetap sepenuhnya di bawah M70.
- StoryManager tidak mengubah Camera2D limits, zoom, atau smoothing.

---

## 24. M72 Encounter Boundary

- Encounter placement tetap sepenuhnya di bawah M72.
- StoryManager tidak mengubah EncounterManager atau encounter triggers.
