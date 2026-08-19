extends Node

## SaveManager — M25: Sistem Save/Load terpusat untuk Holuf.
## Save ke: user://save_01.json
## Format: JSON dengan save_version untuk migrasi masa depan.
##
## Penggunaan debug:
##   B = Save Game (hanya saat di world)
##   N = Load Game (hanya saat di world)

const SAVE_PATH := "user://save_01.json"
const SAVE_TEMP_PATH := "user://save_01.tmp"
const SAVE_BACKUP_PATH := "user://save_01_backup.json"
const SAVE_RECOVERY_TEMP_PATH := "user://save_01_recovery.tmp"

const SAVE_AUTOSAVE_PATH := "user://save_01_autosave.json"
const SAVE_AUTOSAVE_BACKUP_PATH := "user://save_01_autosave_backup.json"
const SAVE_AUTOSAVE_TEMP_PATH := "user://save_01_autosave.tmp"

const SAVE_VERSION := 3

## Flag untuk pending load (diapply setelah scene world dimuat ulang)
var _has_pending_load: bool = false
var _pending_data: Dictionary = {}

# ==============================================================
# M60.5 STEP 2A RUNTIME DIAGNOSTIC TEMP
# ==============================================================
func _ready() -> void:
	print("[M60.5 DIAG] SaveManager Step2A diagnostic loaded")
	print("[M60.5 DIAG] user_dir=", ProjectSettings.globalize_path("user://"))
	print("[M60.5 DIAG] primary=", ProjectSettings.globalize_path(SAVE_PATH))
	print("[M60.5 DIAG] temp=", ProjectSettings.globalize_path(SAVE_TEMP_PATH))
	print("[M60.5 DIAG] backup=", ProjectSettings.globalize_path(SAVE_BACKUP_PATH))

# ==============================================================
# PUBLIC API
# ==============================================================

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(SAVE_BACKUP_PATH)

## Mulai New Game: reset semua runtime state ke default.
## TIDAK menghapus save file yang ada.
func start_new_game() -> void:
	PartyManager.reset_to_new_game()
	InventoryManager.reset_to_new_game()
	# Clear any pending load flag so main.tscn uses default spawn
	_has_pending_load = false
	_pending_data = {}
	TransitionManager.transition_to_scene("res://scenes/main/main.tscn")

## Simpan game state saat ini.
## Mengembalikan true jika berhasil.
func save_game(player_node: Node) -> bool:
	# Guard: jangan save saat battle
	if _is_in_battle():
		push_warning("[SaveManager] Cannot save during battle.")
		return false
	if player_node == null or not is_instance_valid(player_node):
		push_error("[SaveManager] save_game failed: invalid player node.")
		return false

	print("[M60.5 DIAG] save_game ENTER")
	print("[M60.5 DIAG] player_position=", player_node.global_position)
	print("[M60.5 DIAG] primary_exists_before=", FileAccess.file_exists(SAVE_PATH))
	print("[M60.5 DIAG] backup_exists_before=", FileAccess.file_exists(SAVE_BACKUP_PATH))

	var data := _collect_save_data(player_node)
	
	var success := _write_transactional_save(data, SAVE_PATH, SAVE_BACKUP_PATH, SAVE_TEMP_PATH, "[M60.5 DIAG]")
	if success:
		print("[M60.5 DIAG] save_game RETURN TRUE")
		print("[SaveManager] Game saved successfully.")
	return success

func request_checkpoint_autosave(reason: String = "") -> bool:
	print("[M60.5 CHECKPOINT] request reason=%s" % reason)

	if GameManager.is_transitioning:
		push_warning("[M60.5 CHECKPOINT] rejected: transition active.")
		return false

	var player_node := get_tree().get_first_node_in_group("player")
	if player_node == null:
		push_warning("[M60.5 CHECKPOINT] rejected: no active world player.")
		return false

	print("[M60.5 CHECKPOINT] forwarding to autosave")
	var result := request_autosave(player_node)
	print("[M60.5 CHECKPOINT] result=", result)
	return result

func request_autosave(player_node: Node) -> bool:
	if _is_in_battle():
		push_warning("[M60.5 AUTOSAVE] rejected: battle active.")
		return false
	if player_node == null or not is_instance_valid(player_node):
		push_error("[M60.5 AUTOSAVE] rejected: invalid player node.")
		return false

	print("[M60.5 AUTOSAVE] request received")
	print("[M60.5 AUTOSAVE] player_position=", player_node.global_position)
	print("[M60.5 AUTOSAVE] primary_exists_before=", FileAccess.file_exists(SAVE_AUTOSAVE_PATH))
	print("[M60.5 AUTOSAVE] backup_exists_before=", FileAccess.file_exists(SAVE_AUTOSAVE_BACKUP_PATH))

	var data := _collect_save_data(player_node)
	
	var success := _write_transactional_save(data, SAVE_AUTOSAVE_PATH, SAVE_AUTOSAVE_BACKUP_PATH, SAVE_AUTOSAVE_TEMP_PATH, "[M60.5 AUTOSAVE]")
	if success:
		print("[M60.5 AUTOSAVE] RETURN TRUE")
		print("[M60.5 AUTOSAVE] completed successfully")
	return success

func _write_transactional_save(data: Dictionary, primary_path: String, backup_path: String, temp_path: String, log_prefix: String) -> bool:
	var json_string := JSON.stringify(data, "\t")

	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Failed to open temp save file for writing: %s" % temp_path)
		return false

	file.store_string(json_string)
	file.close()
	
	var temp_data := _read_valid_save_file(temp_path)
	if temp_data.is_empty():
		push_error("[SaveManager] Temp save validation failed. Aborting save.")
		DirAccess.remove_absolute(temp_path)
		return false
		
	print("%s temp validated" % log_prefix)
		
	if FileAccess.file_exists(primary_path):
		var primary_data := _read_valid_save_file(primary_path)
		if not primary_data.is_empty():
			print("%s existing primary validated" % log_prefix)
			var copy_err := DirAccess.copy_absolute(primary_path, backup_path)
			if copy_err != OK:
				push_error("[SaveManager] Backup rotation failed. Error: %s" % copy_err)
				DirAccess.remove_absolute(temp_path)
				return false
			print("%s backup rotation succeeded" % log_prefix)
		else:
			print("%s existing primary invalid; backup rotation skipped" % log_prefix)
			push_warning("[SaveManager] Existing primary save is malformed. Preserving old backup.")
			
	var prom_err := DirAccess.rename_absolute(temp_path, primary_path)
	if prom_err != OK:
		push_error("[SaveManager] Temp promotion failed. Error: %s" % prom_err)
		return false
	print("%s temp promotion succeeded" % log_prefix)
		
	var final_data := _read_valid_save_file(primary_path)
	if final_data.is_empty():
		push_error("[SaveManager] Final primary verification failed.")
		return false

	print("%s final primary validated" % log_prefix)
	return true

## Load game state dari file.
## Setelah validasi, set pending state dan reload world scene.
## Mengembalikan false jika file tidak ada atau invalid.
func load_game() -> bool:
	# Guard: jangan load saat battle
	if _is_in_battle():
		push_warning("[SaveManager] Cannot load during battle.")
		return false

	print("[M60.5 DIAG] load_game ENTER")
	print("[M60.5 DIAG] primary_exists=", FileAccess.file_exists(SAVE_PATH))
	print("[M60.5 DIAG] backup_exists=", FileAccess.file_exists(SAVE_BACKUP_PATH))

	var candidate_data: Dictionary = {}
	
	if FileAccess.file_exists(SAVE_PATH):
		candidate_data = _read_valid_save_file(SAVE_PATH)
		if not candidate_data.is_empty():
			print("[M60.5 DIAG] load candidate=PRIMARY")
		else:
			print("[M60.5 RECOVERY] primary invalid")
	else:
		print("[M60.5 RECOVERY] primary missing")
		
	if candidate_data.is_empty() and FileAccess.file_exists(SAVE_BACKUP_PATH):
		print("[M60.5 RECOVERY] trying backup")
		push_warning("[SaveManager] Primary save is invalid. Attempting backup recovery.")
		candidate_data = _attempt_backup_recovery()
		
	if candidate_data.is_empty():
		push_warning("[SaveManager] Backup recovery failed: backup is missing or invalid.")
		print("[SaveManager] No valid save data found.")
		return false

	# Simpan sebagai pending — akan diapply setelah scene world siap
	_pending_data = candidate_data
	_has_pending_load = true

	# Reload world scene
	TransitionManager.transition_to_scene("res://scenes/main/main.tscn")
	return true

func _attempt_backup_recovery() -> Dictionary:
	var backup_data := _read_valid_save_file(SAVE_BACKUP_PATH)
	if backup_data.is_empty():
		return {}
	
	print("[M60.5 RECOVERY] backup validated")
	
	var copy_err := DirAccess.copy_absolute(SAVE_BACKUP_PATH, SAVE_RECOVERY_TEMP_PATH)
	if copy_err != OK:
		push_error("[SaveManager] Failed to create recovery temp.")
		return {}
		
	print("[M60.5 RECOVERY] recovery temp created")
	
	var temp_data := _read_valid_save_file(SAVE_RECOVERY_TEMP_PATH)
	if temp_data.is_empty():
		push_error("[SaveManager] Recovery temp validation failed.")
		return {}
		
	print("[M60.5 RECOVERY] recovery temp validated")
	
	var prom_err := DirAccess.rename_absolute(SAVE_RECOVERY_TEMP_PATH, SAVE_PATH)
	if prom_err != OK:
		push_error("[SaveManager] Failed to promote recovered save to primary.")
		return {}
		
	print("[M60.5 RECOVERY] primary restoration succeeded")
	
	var final_data := _read_valid_save_file(SAVE_PATH)
	if final_data.is_empty():
		push_error("[SaveManager] Restored primary validation failed.")
		return {}
		
	print("[M60.5 RECOVERY] restored primary validated")
	print("[M60.5 RECOVERY] recovery complete")
	
	return final_data

func _read_valid_save_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		return {}

	var data = json.get_data()
	if not data is Dictionary:
		return {}

	if not _validate_save_data(data):
		return {}

	return data

## Dipanggil dari main.gd setelah scene world siap.
## Apply semua saved state ke Autoloads.
func apply_pending_load(player_node: Node) -> void:
	if not _has_pending_load:
		return

	_has_pending_load = false
	var data: Dictionary = _pending_data
	_pending_data = {}

	_apply_save_data(data, player_node)
	print("[SaveManager] Game loaded successfully.")


## Batalkan pending load tanpa mengaplikasikan data ke world/player.
## Digunakan ketika lokasi yang disimpan gagal dimuat oleh main.gd.
func cancel_pending_load(reason: String = "") -> void:
	if not _has_pending_load:
		return
	push_warning("[SaveManager] Pending load dibatalkan: " + reason)
	_has_pending_load = false
	_pending_data = {}

# ==============================================================
# COLLECT SAVE DATA
# ==============================================================

func _collect_save_data(player_node: Node) -> Dictionary:
	var characters_data: Dictionary = {}
	for cid in PartyManager.character_progress:
		var prog = PartyManager.character_progress[cid]
		characters_data[cid] = {
			"level": prog.level,
			"current_exp": prog.current_exp,
			"current_hp": prog.current_hp,
			"current_mp": prog.current_mp,
			"has_joined": prog.get("has_joined", false),
			"is_available": prog.get("is_available", false)
		}

	var active: Array = []
	for cid in PartyManager.active_party:
		active.append(cid)

	var inventory_data: Dictionary = {}
	for item_id in InventoryManager.inventory:
		inventory_data[item_id] = InventoryManager.inventory[item_id]

	var player_x := 0.0
	var player_y := 0.0
	if player_node and is_instance_valid(player_node):
		player_x = player_node.global_position.x
		player_y = player_node.global_position.y

	# Equipment state (M30)
	var equipment_save = EquipmentManager.get_save_data()
	
	return {
		"save_version": SAVE_VERSION,
		"gold": PartyManager.party_gold,
		"characters": characters_data,
		"active_party": active,
		"inventory": inventory_data,
		"character_equipment": equipment_save,
		"world": {
			"scene": "res://scenes/main/main.tscn",
			"location_scene": GameManager.current_world_scene,
			"player_x": player_x,
			"player_y": player_y
		}
	}

# ==============================================================
# VALIDATE
# ==============================================================

func _validate_save_data(data: Dictionary) -> bool:
	if not data.has("save_version"):
		push_error("[SaveManager] Missing save_version.")
		return false
	if not data.has("characters") or not data["characters"] is Dictionary:
		push_error("[SaveManager] Missing or invalid 'characters' field.")
		return false
	if not data.has("active_party") or not data["active_party"] is Array:
		push_error("[SaveManager] Missing or invalid 'active_party' field.")
		return false
	if not data.has("inventory") or not data["inventory"] is Dictionary:
		push_error("[SaveManager] Missing or invalid 'inventory' field.")
		return false
	if not data.has("world") or not data["world"] is Dictionary:
		push_error("[SaveManager] Missing or invalid 'world' field.")
		return false

	# M67: Validasi ketat world.location_scene untuk save v3+
	var ver := int(data.get("save_version", 1))
	if ver >= 3:
		var world_data: Dictionary = data["world"]
		if not world_data.has("location_scene") or not world_data["location_scene"] is String:
			push_error("[SaveManager] Save v3 missing or non-String 'world.location_scene'.")
			return false
		var loc: String = world_data["location_scene"]
		if loc == "":
			push_error("[SaveManager] Save v3 has empty 'world.location_scene'.")
			return false
		if not ResourceLoader.exists(loc):
			push_error("[SaveManager] Save v3 'world.location_scene' does not exist: " + loc)
			return false
		# Buktikan resource adalah PackedScene, bukan .tres atau tipe lain
		var packed := load(loc) as PackedScene
		if packed == null:
			push_error("[SaveManager] Save v3 'world.location_scene' is not a valid PackedScene: " + loc)
			return false

	# Validate active_party references valid character IDs
	for cid in data["active_party"]:
		if not PartyManager.roster.has(cid):
			push_error("[SaveManager] Unknown character_id in active_party: %s" % cid)
			return false

	return true

# ==============================================================
# MIGRATION HELPERS
# ==============================================================

## Kembalikan true jika save adalah versi lama (< 2) yang tidak memiliki equipment.
func _is_legacy_save(data: Dictionary) -> bool:
	var ver = int(data.get("save_version", 1))
	return ver < 2 or not data.has("character_equipment")

# ==============================================================
# APPLY SAVE DATA
# ==============================================================

func _apply_save_data(data: Dictionary, player_node: Node) -> void:
	# 1. Gold
	PartyManager.party_gold = int(data.get("gold", 0))

	# 2. Character progression
	var characters_data: Dictionary = data["characters"]
	for cid in characters_data:
		if not PartyManager.character_progress.has(cid):
			continue
		var saved = characters_data[cid]
		var prog = PartyManager.character_progress[cid]

		prog.level = clamp(int(saved.get("level", 1)), 1, PartyManager.MAX_LEVEL)
		prog.current_exp = max(0, int(saved.get("current_exp", 0)))
		prog.has_joined = bool(saved.get("has_joined", true))
		prog.is_available = bool(saved.get("is_available", true))

		# Load HP/MP — get effective max from CombatantData + level
		var effective_max_hp := _get_effective_max_hp(cid, prog.level)
		var effective_max_mp := _get_effective_max_mp(cid, prog.level)

		prog.current_hp = clamp(int(saved.get("current_hp", effective_max_hp)), 0, effective_max_hp)
		prog.current_mp = clamp(int(saved.get("current_mp", effective_max_mp)), 0, effective_max_mp)

	# 3. Active party
	var saved_active: Array = data["active_party"]
	if saved_active.size() >= PartyManager.MIN_ACTIVE:
		PartyManager.active_party.clear()
		for cid in saved_active:
			if PartyManager.roster.has(cid):
				var prog = PartyManager.character_progress.get(cid)
				if prog and prog.get("has_joined", false) and prog.get("is_available", false):
					PartyManager.active_party.append(cid)
		# Safety: ensure at least 1 active member if possible
		if PartyManager.active_party.is_empty():
			push_warning("[SaveManager] active_party was empty after load, attempting to restore a valid fallback member.")
			for cid in PartyManager.roster.keys():
				var prog = PartyManager.character_progress.get(cid)
				if prog and prog.get("has_joined", false) and prog.get("is_available", false):
					PartyManager.active_party.append(cid)
					break
		PartyManager._update_reserve()

	# 4. Inventory
	var saved_inventory: Dictionary = data["inventory"]
	InventoryManager.inventory.clear()
	for item_id in saved_inventory:
		var qty = int(saved_inventory[item_id])
		qty = clamp(qty, 0, InventoryManager.MAX_STACK)
		if qty > 0:
			InventoryManager.inventory[item_id] = qty

	# 5. Equipment (M30/M31) — aman untuk Save v1 (backward compat)
	if _is_legacy_save(data):
		# Save v1: tidak ada equipment data → kosongkan semua slot
		print("[SaveManager] Legacy save (v1) detected — initializing empty equipment state and giving prototype items.")
		EquipmentManager.reset_to_new_game()
		
		# M31: Berikan prototype equipment jika ini save lama
		InventoryManager.inventory["training_sword"] = 1
		InventoryManager.inventory["training_bow"] = 1
		InventoryManager.inventory["leather_cap"] = 1
		InventoryManager.inventory["leather_armor"] = 1
		InventoryManager.inventory["copper_ring"] = 1
	else:
		EquipmentManager.apply_save_data(data.get("character_equipment", {}))
	
	# 6. Player position dan restorasi lokasi dunia
	var world_data: Dictionary = data.get("world", {})
	var save_ver := int(data.get("save_version", 1))
	var saved_location: String = ""
	
	if save_ver >= 3:
		# v3: location_scene sudah lolos validasi ketat di _validate_save_data()
		saved_location = world_data.get("location_scene", "")
	else:
		# v1/v2 legacy: tidak ada location_scene → gunakan default
		saved_location = GameManager.DEFAULT_WORLD_SCENE
		print("[SaveManager] Legacy save (v%d): menggunakan default world scene." % save_ver)
	
	# Simpan ke GameManager agar main.gd dapat menggunakannya
	GameManager.current_world_scene = saved_location
	
	if player_node and is_instance_valid(player_node):
		var px = float(world_data.get("player_x", 0.0))
		var py = float(world_data.get("player_y", 0.0))
		if px != 0.0 or py != 0.0:
			player_node.global_position = Vector2(px, py)

	# 7. Reset encounter distance to prevent instant-encounter after load
	if EncounterManager:
		EncounterManager.reset_encounter()

# ==============================================================
# HELPERS
# ==============================================================

func _is_in_battle() -> bool:
	# Check if current scene is the battle scene
	var tree := get_tree()
	if tree == null: return false
	var current := tree.current_scene
	if current == null: return false
	return current.scene_file_path == "res://scenes/battle/battle.tscn"

func _get_effective_max_hp(char_id: String, level: int) -> int:
	var path = "res://data/battle/" + char_id + ".tres"
	if ResourceLoader.exists(path):
		var data = load(path)
		if data:
			return data.max_hp + (data.hp_growth * (level - 1))
	return 100  # fallback

func _get_effective_max_mp(char_id: String, level: int) -> int:
	var path = "res://data/battle/" + char_id + ".tres"
	if ResourceLoader.exists(path):
		var data = load(path)
		if data:
			return data.max_mp + (data.mp_growth * (level - 1))
	return 0  # fallback
