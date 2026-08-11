extends Node

## PartyManager — Autoload untuk mengelola state party (Active dan Reserve).
## State ini bertahan melintasi scene World dan Battle.

signal party_ui_toggled(is_open: bool)

var roster: Dictionary = {}
var active_party: Array[String] = []
var reserve_party: Array[String] = []

var ui_instance: Node = null

const MAX_ACTIVE: int = 4

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
	
	# Inisialisasi Active Party (default: Hero, B, C, D)
	active_party = ["hero", "character_b", "character_c", "character_d"]
	_update_reserve()

func _update_reserve() -> void:
	reserve_party.clear()
	for cid in roster.keys():
		if not cid in active_party:
			reserve_party.append(cid)

func swap_members(active_index: int, reserve_index: int) -> void:
	if active_index < 0 or active_index >= active_party.size(): return
	if reserve_index < 0 or reserve_index >= reserve_party.size(): return
	
	var a_id = active_party[active_index]
	var r_id = reserve_party[reserve_index]
	
	active_party[active_index] = r_id
	reserve_party[reserve_index] = a_id
	
	_update_reserve()

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
