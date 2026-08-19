extends Node

## StoryManager — M71: Autoload singleton untuk menyimpan story state persisten.
## Memiliki:
##   - story flags (boolean)
##   - consumed one-shot trigger IDs
##
## Tidak memiliki:
##   - konten cerita aktual
##   - logika kamera
##   - logika encounter
##   - data quest
##
## Trigger IDs dan Flag IDs menggunakan StringName untuk efisiensi.

signal story_event_triggered(trigger_id: StringName)
signal story_flag_changed(flag_id: StringName, value: bool)

## Internal state — tidak diekspos langsung.
## Akses hanya melalui API publik.
var _consumed_triggers: Dictionary = {}  # StringName -> true
var _flags: Dictionary = {}              # StringName -> bool


# ==============================================================
# STORY FLAG API
# ==============================================================

## Set story flag. Emits story_flag_changed hanya jika nilai benar-benar berubah.
func set_flag(flag_id: StringName, value: bool = true) -> void:
	if flag_id == &"":
		push_warning("[StoryManager] set_flag: flag_id kosong diabaikan.")
		return
	var current: bool = _flags.get(flag_id, false)
	if current == value:
		return  # Tidak ada perubahan — jangan emit sinyal duplikat
	_flags[flag_id] = value
	story_flag_changed.emit(flag_id, value)


## Kembalikan nilai story flag. Default false jika belum pernah di-set.
func get_flag(flag_id: StringName) -> bool:
	return _flags.get(flag_id, false)


## Kembalikan true jika flag pernah di-set (terlepas dari nilai).
func has_flag(flag_id: StringName) -> bool:
	return _flags.has(flag_id)


## Evaluasi kondisi required dan blocked flags.
## Required: SEMUA harus true.
## Blocked:  SATU pun tidak boleh true.
## Array kosong = kondisi terpenuhi.
func conditions_met(
	required_flags: Array,
	blocked_flags: Array
) -> bool:
	for fid in required_flags:
		if not _flags.get(fid, false):
			return false
	for fid in blocked_flags:
		if _flags.get(fid, false):
			return false
	return true


# ==============================================================
# TRIGGER CONSUMPTION API
# ==============================================================

## Kembalikan true jika trigger_id sudah pernah dikonsumsi.
func has_triggered(trigger_id: StringName) -> bool:
	return _consumed_triggers.has(trigger_id)


## Minta trigger. Mengembalikan true jika diterima dan diproses.
##
## Urutan evaluasi:
## 1. Tolak jika trigger_id kosong.
## 2. Cek kondisi flags (required/blocked).
## 3. Jika one_shot dan sudah dikonsumsi → return false.
## 4. Jika diterima:
##    - Tandai consumed SEBELUM emit signal (cegah re-entrant).
##    - Emit story_event_triggered.
##    - Return true.
func try_trigger(
	trigger_id: StringName,
	one_shot: bool,
	required_flags: Array,
	blocked_flags: Array
) -> bool:
	if trigger_id == &"":
		push_warning("[StoryManager] try_trigger: trigger_id kosong ditolak.")
		return false

	# Cek kondisi flags
	if not conditions_met(required_flags, blocked_flags):
		return false

	# Cek one-shot
	if one_shot and _consumed_triggers.has(trigger_id):
		return false

	# Tandai consumed sebelum emit (cegah re-entrant duplicate)
	if one_shot:
		_consumed_triggers[trigger_id] = true

	story_event_triggered.emit(trigger_id)
	return true


# ==============================================================
# SAVE/LOAD API
# ==============================================================

## Kembalikan Dictionary yang siap diserialisasikan ke JSON.
## Hanya menyimpan String biasa untuk kompatibilitas JSON.
func get_save_data() -> Dictionary:
	var triggers_array: Array = []
	for key in _consumed_triggers:
		triggers_array.append(str(key))
	triggers_array.sort()  # Deterministic output

	var flags_dict: Dictionary = {}
	for key in _flags:
		flags_dict[str(key)] = _flags[key]

	return {
		"consumed_triggers": triggers_array,
		"flags": flags_dict
	}


## Apply data dari save. Dipanggil oleh SaveManager.apply_pending_load.
## data = {} atau Dictionary berisi "consumed_triggers" dan "flags".
## RESET state lama sebelum apply (penting untuk legacy v3 load).
func apply_save_data(data: Dictionary) -> void:
	_consumed_triggers.clear()
	_flags.clear()

	if data.is_empty():
		return  # State bersih — ini expected untuk legacy v1-v3

	var triggers = data.get("consumed_triggers", [])
	if triggers is Array:
		for item in triggers:
			if item is String and item != "":
				_consumed_triggers[StringName(item)] = true

	var flags = data.get("flags", {})
	if flags is Dictionary:
		for key in flags:
			if key is String and key != "":
				var val = flags[key]
				if val is bool:
					_flags[StringName(key)] = val


## Reset seluruh story state ke kondisi new game.
## Dipanggil oleh SaveManager.start_new_game().
func reset_to_new_game() -> void:
	_consumed_triggers.clear()
	_flags.clear()
