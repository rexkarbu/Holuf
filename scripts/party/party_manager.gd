
extends Node

## PartyManager — Autoload untuk mengelola state party (Active dan Reserve).
## State ini bertahan melintasi scene World dan Battle.

signal party_ui_toggled(is_open: bool)

var roster: Dictionary = {}
var active_party: Array[String] = []
var reserve_party: Array[String] = []

var ui_instance: Node = null

const MIN_ACTIVE: int = 1
const MAX_ACTIVE: int = 4

# --- PROGRESSION STATE ---
const ACTIVE_EXP_RATE: float = 1.0
const RESERVE_EXP_RATE: float = 0.0  # M21 PATCH: Reserve characters no longer receive battle EXP
const MAX_LEVEL: int = 99

const AUTHORED_JOIN_LEVELS := {
	"aren": 1,
	"aelia": 1,
	"lyra": 3,
	"doran": 4,
	"neria": 8,
	"torga": 9,
	"katsura": 13,
	"kaelis": 14,
	"sylven": 15,
	"orin": 16
}

var party_gold: int = 0
var character_progress: Dictionary = {}

func _ready() -> void:
	# Load roster (Prototype: 10 characters)
	var paths = [
		"aren", "aelia", "lyra", "doran", "neria",
		"torga", "katsura", "kaelis", "sylven", "orin"
	]

	for cid in paths:
		var res = load("res://data/party/" + cid + ".tres")
		if res:
			roster[cid] = res
			# M21 PATCH: Load CombatantData to get HP/MP stats
			var combat_data_path = "res://data/battle/" + cid + ".tres"
			var combat_data = load(combat_data_path) if ResourceLoader.exists(combat_data_path) else null

			var initial_max_hp = 100  # Default fallback
			var initial_max_mp = 50   # Default fallback

			if combat_data:
				initial_max_hp = combat_data.max_hp + (combat_data.hp_growth * 0)  # Level 1
				initial_max_mp = combat_data.max_mp + (combat_data.mp_growth * 0)  # Level 1
			var is_starter = (cid == "aren" or cid == "aelia")

			character_progress[cid] = {
				"level": 1,
				"current_exp": 0,
				"current_hp": initial_max_hp,  # Persistent HP
				"current_mp": initial_max_mp,  # Persistent MP
				"has_joined": is_starter,
				"is_available": is_starter
			}

	active_party = ["aren", "aelia"]
	_update_reserve()





func _update_reserve() -> void:
	reserve_party.clear()
	for cid in roster.keys():
		var prog = character_progress.get(cid)
		if prog and prog.get("has_joined", false) and prog.get("is_available", false):
			if not cid in active_party:
				reserve_party.append(cid)

## Swap anggota active dengan reserve.
func swap_members(active_index: int, reserve_index: int) -> void:
	if active_index < 0 or active_index >= active_party.size(): return
	if reserve_index < 0 or reserve_index >= reserve_party.size(): return

	var a_id = active_party[active_index]
	var r_id = reserve_party[reserve_index]

	active_party[active_index] = r_id
	reserve_party[reserve_index] = a_id

	_update_reserve()

## Tambahkan karakter dari reserve ke active (jika ada slot kosong).
## Mengembalikan true jika berhasil, false jika active sudah penuh.
func add_to_active(char_id: String) -> bool:
	if active_party.size() >= MAX_ACTIVE: return false
	if char_id in active_party: return false
	if not char_id in roster: return false

	var prog = character_progress.get(char_id)
	if not prog or not prog.get("has_joined", false) or not prog.get("is_available", false):
		return false

	active_party.append(char_id)
	_update_reserve()
	return true

## Hapus karakter dari active ke reserve.
## Mengembalikan true jika berhasil, false jika melanggar minimum.
func remove_from_active(char_id: String) -> bool:
	if active_party.size() <= MIN_ACTIVE: return false
	if not char_id in active_party: return false

	active_party.erase(char_id)
	_update_reserve()
	return true

func open_party_ui() -> void:
	if ui_instance != null: return

	var ui_scene = load("res://scripts/party/party_ui.gd")
	if ui_scene:
		var node = ui_scene.new()
		node.process_mode = Node.PROCESS_MODE_ALWAYS # M27: Allow processing when game is paused
		get_tree().root.add_child(node)
		ui_instance = node
		party_ui_toggled.emit(true)

func close_party_ui() -> void:
	if ui_instance != null:
		ui_instance.queue_free()
		ui_instance = null
		party_ui_toggled.emit(false)

## Reset semua runtime/progression state ke kondisi New Game.
## JANGAN memanggil ini untuk Load Game.
## CharacterData statik (display_name, race, dll) tidak disentuh.
func reset_to_new_game() -> void:
	party_gold = 0
	active_party = ["aren", "aelia"]
	EquipmentManager.reset_to_new_game()

	for cid in roster.keys():
		var combat_data_path = "res://data/battle/" + cid + ".tres"
		var combat_data = load(combat_data_path) if ResourceLoader.exists(combat_data_path) else null

		var max_hp = 100
		var max_mp = 0
		if combat_data:
			max_hp = combat_data.max_hp  # Level 1: no growth bonus
			max_mp = combat_data.max_mp

		var is_starter = (cid == "aren" or cid == "aelia")

		character_progress[cid] = {
			"level": 1,
			"current_exp": 0,
			"current_hp": max_hp,
			"current_mp": max_mp,
			"has_joined": is_starter,
			"is_available": is_starter
		}

	_update_reserve()




# ==============================================================================
# RECRUITMENT & AVAILABILITY SYSTEM (M59)
# ==============================================================================

func recruit_character(char_id: String, join_level: int = -1) -> bool:
	if not char_id in roster: return false
	if not char_id in character_progress: return false

	if join_level < 1:
		join_level = AUTHORED_JOIN_LEVELS.get(char_id, 1)

	join_level = clamp(join_level, 1, MAX_LEVEL)
	var prog = character_progress[char_id]

	if not prog.get("has_joined", false):
		prog["has_joined"] = true
		prog["is_available"] = true
		prog["level"] = join_level
		prog["current_exp"] = 0

		# Get max HP/MP
		var combat_data_path = "res://data/battle/" + char_id + ".tres"
		var combat_data = load(combat_data_path) if ResourceLoader.exists(combat_data_path) else null

		if combat_data:
			var level_bonus = join_level - 1
			prog["current_hp"] = combat_data.max_hp + (combat_data.hp_growth * level_bonus)
			prog["current_mp"] = combat_data.max_mp + (combat_data.mp_growth * level_bonus)

		_update_reserve()
		return true
	else:
		# If already joined, just ensure availability
		prog["is_available"] = true
		_update_reserve()
		return true

func set_character_available(char_id: String, available: bool) -> bool:
	if not char_id in roster: return false
	var prog = character_progress.get(char_id)
	if not prog or not prog.get("has_joined", false): return false

	prog["is_available"] = available

	if not available and char_id in active_party:
		active_party.erase(char_id)

	_update_reserve()
	return true

func ensure_minimum_level(char_id: String, minimum_level: int, restore_full: bool = false) -> bool:
	if not char_id in roster: return false
	var prog = character_progress.get(char_id)
	if not prog: return false

	var needs_level_up = prog.level < minimum_level
	if needs_level_up:
		prog.level = minimum_level
		prog.current_exp = 0

	var combat_data_path = "res://data/battle/" + char_id + ".tres"
	var combat_data = load(combat_data_path) if ResourceLoader.exists(combat_data_path) else null

	if combat_data:
		var level_bonus = prog.level - 1
		var new_max_hp = combat_data.max_hp + (combat_data.hp_growth * level_bonus)
		var new_max_mp = combat_data.max_mp + (combat_data.mp_growth * level_bonus)

		if needs_level_up and not restore_full:
			prog.current_hp = min(prog.current_hp, new_max_hp)
			prog.current_mp = min(prog.current_mp, new_max_mp)

		if restore_full:
			prog.current_hp = new_max_hp
			prog.current_mp = new_max_mp

	return true

# ==============================================================================
# PROGRESSION SYSTEM (MILESTONE 20)
# ==============================================================================

func get_exp_required(level: int) -> int:
	if level >= MAX_LEVEL: return 9999999
	return 100 + ((level - 1) * 50)

func grant_rewards(total_exp: int, total_gold: int) -> Array[String]:
	party_gold += total_gold
	var messages: Array[String] = []

	# M21 PATCH: Only Active members receive battle EXP (100% each, not divided)
	for cid in active_party:
		var msgs = _process_exp(cid, total_exp, true)
		messages.append_array(msgs)

	# Reserve members receive NO battle EXP (RESERVE_EXP_RATE = 0.0)
	# This is intentional - removed old 75% reserve EXP behavior

	return messages

func _process_exp(char_id: String, exp_amount: int, is_active: bool) -> Array[String]:
	var msgs: Array[String] = []
	var progress = character_progress[char_id]
	var display_name = roster[char_id].display_name

	if progress.level >= MAX_LEVEL: return msgs

	progress.current_exp += exp_amount
	var exp_req = get_exp_required(progress.level)

	while progress.current_exp >= exp_req and progress.level < MAX_LEVEL:
		progress.current_exp -= exp_req
		progress.level += 1

		# M21 PATCH: Level Up does NOT restore HP/MP to full
		# Only clamp current values if they exceed new maximum
		var combat_data_path = "res://data/battle/" + char_id + ".tres"
		var combat_data = load(combat_data_path) if ResourceLoader.exists(combat_data_path) else null

		if combat_data:
			var level_bonus = progress.level - 1
			var new_max_hp = combat_data.max_hp + (combat_data.hp_growth * level_bonus)
			var new_max_mp = combat_data.max_mp + (combat_data.mp_growth * level_bonus)

			progress.current_hp = min(progress.current_hp, new_max_hp)
			progress.current_mp = min(progress.current_mp, new_max_mp)

		var msg = display_name + " reached Level " + str(progress.level) + "!"
		if not is_active:
			msg += " (Reserve)"
		msgs.append(msg)

		if progress.level >= MAX_LEVEL:
			progress.current_exp = 0
			break

		exp_req = get_exp_required(progress.level)

	return msgs

# M21 PATCH: Sync battle HP/MP back to persistent state after battle
func sync_battle_state(char_id: String, hp: int, mp: int) -> void:
	if char_id in character_progress:
		character_progress[char_id].current_hp = hp
		character_progress[char_id].current_mp = mp

# --- DEBUG HELPERS ---
func grant_test_exp(char_id: String, amount: int) -> void:
	if char_id in character_progress:
		var is_active = char_id in active_party
		var msgs = _process_exp(char_id, amount, is_active)
		for m in msgs:
			print("[DEBUG] " + m)

func grant_test_gold(amount: int) -> void:
	party_gold += amount
	print("[DEBUG] Party Gold is now: " + str(party_gold))
