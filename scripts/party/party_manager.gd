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
const RESERVE_EXP_RATE: float = 0.75
const MAX_LEVEL: int = 99

var party_gold: int = 0
var character_progress: Dictionary = {}

func _ready() -> void:
	# Load roster (Prototype: 10 characters)
	var paths = [
		"hero", "character_b", "character_c", "character_d", "character_e",
		"character_f", "character_g", "character_h", "character_i", "character_j"
	]
	
	for cid in paths:
		var res = load("res://data/party/" + cid + ".tres")
		if res:
			roster[cid] = res
			character_progress[cid] = {"level": 1, "current_exp": 0, "needs_full_heal": false}
	
	# Inisialisasi Active Party (default: Hero, B, C, D)
	active_party = ["hero", "character_b", "character_c", "character_d"]
	_update_reserve()

func _update_reserve() -> void:
	reserve_party.clear()
	for cid in roster.keys():
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
		get_tree().root.add_child(node)
		ui_instance = node
		party_ui_toggled.emit(true)

func close_party_ui() -> void:
	if ui_instance != null:
		ui_instance.queue_free()
		ui_instance = null
		party_ui_toggled.emit(false)

# ==============================================================================
# PROGRESSION SYSTEM (MILESTONE 20)
# ==============================================================================

func get_exp_required(level: int) -> int:
	if level >= MAX_LEVEL: return 9999999
	return 100 + ((level - 1) * 50)

func grant_rewards(total_exp: int, total_gold: int) -> Array[String]:
	party_gold += total_gold
	var messages: Array[String] = []
	
	# Active members
	for cid in active_party:
		var msgs = _process_exp(cid, total_exp, true)
		messages.append_array(msgs)
		
	# Reserve members
	var reserve_exp = roundi(float(total_exp) * RESERVE_EXP_RATE)
	for cid in reserve_party:
		var msgs = _process_exp(cid, reserve_exp, false)
		messages.append_array(msgs)
		
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
		progress.needs_full_heal = true # Flags combatant to fully restore HP/MP on next load
		
		var msg = display_name + " reached Level " + str(progress.level) + "!"
		if not is_active:
			msg += " (Reserve)"
		msgs.append(msg)
		
		if progress.level >= MAX_LEVEL:
			progress.current_exp = 0
			break
			
		exp_req = get_exp_required(progress.level)
		
	return msgs

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
