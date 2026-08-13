extends Node

## SaveManager — M25: Sistem Save/Load terpusat untuk Holuf.
## Save ke: user://save_01.json
## Format: JSON dengan save_version untuk migrasi masa depan.
##
## Penggunaan debug:
##   B = Save Game (hanya saat di world)
##   N = Load Game (hanya saat di world)

const SAVE_PATH := "user://save_01.json"
const SAVE_VERSION := 1

## Flag untuk pending load (diapply setelah scene world dimuat ulang)
var _has_pending_load: bool = false
var _pending_data: Dictionary = {}

# ==============================================================
# PUBLIC API
# ==============================================================

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Simpan game state saat ini.
## Mengembalikan true jika berhasil.
func save_game(player_node: Node) -> bool:
	# Guard: jangan save saat battle
	if _is_in_battle():
		push_warning("[SaveManager] Cannot save during battle.")
		return false

	var data := _collect_save_data(player_node)
	var json_string := JSON.stringify(data, "\t")

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveManager] Failed to open save file for writing: %s" % SAVE_PATH)
		return false

	file.store_string(json_string)
	file.close()

	print("[SaveManager] Game saved successfully.")
	return true

## Load game state dari file.
## Setelah validasi, set pending state dan reload world scene.
## Mengembalikan false jika file tidak ada atau invalid.
func load_game() -> bool:
	# Guard: jangan load saat battle
	if _is_in_battle():
		push_warning("[SaveManager] Cannot load during battle.")
		return false

	if not has_save():
		print("[SaveManager] No save data found.")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SaveManager] Failed to open save file for reading.")
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("[SaveManager] JSON parse error in save file: %s" % json.get_error_message())
		return false

	var data = json.get_data()
	if not data is Dictionary:
		push_error("[SaveManager] Save file root is not a Dictionary.")
		return false

	if not _validate_save_data(data):
		push_error("[SaveManager] Save file validation failed. Aborting load.")
		return false

	# Simpan sebagai pending — akan diapply setelah scene world siap
	_pending_data = data
	_has_pending_load = true

	# Reload world scene
	TransitionManager.transition_to_scene("res://scenes/main/main.tscn")
	return true

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
			"current_mp": prog.current_mp
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

	return {
		"save_version": SAVE_VERSION,
		"gold": PartyManager.party_gold,
		"characters": characters_data,
		"active_party": active,
		"inventory": inventory_data,
		"world": {
			"scene": "res://scenes/main/main.tscn",
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

	# Validate active_party references valid character IDs
	for cid in data["active_party"]:
		if not PartyManager.roster.has(cid):
			push_error("[SaveManager] Unknown character_id in active_party: %s" % cid)
			return false

	return true

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
				PartyManager.active_party.append(cid)
		# Safety: ensure at least 1 active member
		if PartyManager.active_party.is_empty():
			push_warning("[SaveManager] active_party was empty after load, restoring first roster member.")
			PartyManager.active_party.append(PartyManager.roster.keys()[0])
		PartyManager._update_reserve()

	# 4. Inventory
	var saved_inventory: Dictionary = data["inventory"]
	InventoryManager.inventory.clear()
	for item_id in saved_inventory:
		var qty = int(saved_inventory[item_id])
		qty = clamp(qty, 0, InventoryManager.MAX_STACK)
		if qty > 0:
			InventoryManager.inventory[item_id] = qty

	# 5. Player position
	var world_data: Dictionary = data.get("world", {})
	if player_node and is_instance_valid(player_node):
		var px = float(world_data.get("player_x", 0.0))
		var py = float(world_data.get("player_y", 0.0))
		if px != 0.0 or py != 0.0:
			player_node.global_position = Vector2(px, py)

	# 6. Reset encounter distance to prevent instant-encounter after load
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
