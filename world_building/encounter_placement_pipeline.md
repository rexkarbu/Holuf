# HOLUF Encounter Placement Pipeline — M72

Dokumen ini adalah standarisasi produksi (production lock) untuk penempatan *encounter* musuh di *world map* HOLUF (mulai M72). Seluruh implementasi *Encounter* di region mana pun (termasuk M76+ Elaris/Caelora) wajib mematuhi aturan ini.

## 1. Random Encounter (Zone & Table)
*Random encounter* beroperasi secara dinamis menggunakan pergerakan riil pemain sebagai tolak ukur jarak (mengikuti resolusi M68).
- **`EncounterZone`**: Merupakan `Area2D` di map. Mendaftarkan tabelnya ketika player masuk.
- **`EncounterTable`**: Resource yang diekspor berisi `min_distance`, `max_distance`, dan sekumpulan `EnemyFormation` (lengkap dengan *weight*/bobotnya).
  
**Aturan Jarak**:
- Hanya akumulasi *actual post-movement displacement* (jarak riil yang ditempuh player) yang meningkatkan ambang batas. Membentur dinding, bergerak dalam *cutscene*/dialog, atau teleportasi **TIDAK** menambah jarak encounter.
- Ketika *distance* > *threshold*, battle terpicu menggunakan mekanisme *weighted RNG*. 

**Zone Overlap**:
- `EncounterZone` yang memiliki **tabel berbeda** tidak boleh dibuat saling menumpuk secara fisik. Pembagian wilayah bahaya harus bersisian.
- Jika bersebelahan dengan tabel yang *sama*, sistem akan memperbaruinya secara deterministik (direset ketika keluar, disambung kembali ketika masuk).

**Lifecycle Data**:
- Tabel yang invalid (`min_distance <= 0`, `max_distance < min_distance`, atau total bobot <= 0) akan langsung **ditolak** oleh *EncounterManager* tanpa merusak (retaining) tabel yang sebelumnya aktif (langsung me-*null*-kan diri secara aman).

## 2. Safe Zone
- **`SafeZone`**: Node `Area2D` yang menimpa (suppress) *random encounter*.
- Jika Player masuk, `encounters_enabled = false`. Selama di dalam, jarak tempuh encounter tidak akan berakumulasi. 
- Keluar dari SafeZone otomatis melanjutkan (resume) kalkulasi tabel yang tersisa.
- **Overlap Aturan**: Hindari tumpukan berlapis beberapa `SafeZone`. Buat satu SafeZone luas jika memungkinkan.

> [!TIP]
> **Tidak ada zona danger = Tempat aman natural.** 
> Sebuah map kota *town/interior* yang memang seharusnya tidak ada musuh **TIDAK MEMBUTUHKAN** sebuah `SafeZone` raksasa. Cukup jangan meletakkan `EncounterZone` sama sekali di map tersebut.

## 3. Scripted / Fixed Battle Triggers
Trigger diam untuk pertempuran tetap (tutorial, boss, *mandatory fight*) direpresentasikan dengan `BattleEncounterTrigger` yang telah terstandarisasi.
- **Explicit Formation**: Berbeda dengan *random*, _scripted battle_ HARUS memiliki resource `EnemyFormation` yang diekspor langsung ke propertinya di Inspector. Sistem switch-case ID di masa lalu sudah dihapus (kecuali fallback legacy `placeholder_battle_1` untuk M41).
- **Repeatable vs One-shot**: Tentukan `is_repeatable` di Inspector. Battle one-shot akan dicatat global di `GameManager.consumed_encounters` menggunakan string `encounter_id` miliknya.
- Jangan gunakan _EncounterZone_ untuk Boss; itu adalah domain mutlak _BattleEncounterTrigger_.

## 4. Reset & Transisi Konteks (M67/M71 Boundary)
- Data pergerakan acak (*random encounter progress*) adalah state **transien** (sementara). Data ini TIDAK dimasukkan ke dalam mekanisme simpan SaveManager v4. 
- Setiap terjadinya perpindahan dunia (*TransitionZone*, Battle Return, dan Load Save Game), `EncounterManager` menjamin terbuangnya status sisa (*stale*) dari map lama melalui metode `reset_location_context()`.
- Artinya, tidak akan terjadi bug seperti *terkena random battle segera saat muncul di map baru*. Map baru akan membaca secara valid dari *body_entered* berkat simulasi benturan pasca-*spawn* dari Godot physics.

## 5. Sinkronisasi dengan Cerita (M71)
*Story System* tidak boleh dicampuradukkan dengan trigger battle. Membunuh monster sembarangan tidak boleh otomatis mengaktifkan *story flag* kecuali dirancang secara skriptual sebagai *scripted trigger* yang dilanjutkan lewat mekanisme Event/Quest.

## Pendelegasian
- Pembuatan isi monster dan peletakan final (seperti letak bos Elaris, frekuensi musuh, balancing min/max_distance per area) diserahkan penuh kepada desainer level pada milestone M76+ dan milestone region terkait.
