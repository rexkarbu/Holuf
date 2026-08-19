extends Node

## GameManager — Autoload untuk menyimpan state session persisten antar scene.
## Digunakan untuk menyimpan state yang harus bertahan saat transisi World <-> Battle.

var player_return_position: Vector2 = Vector2.ZERO
var consumed_encounters: Array[String] = []
var pending_formation: EnemyFormation = null

var is_transitioning: bool = false

# M67: State lokasi aktif saat ini (persistent antar battle return)
const DEFAULT_WORLD_SCENE := "res://scenes/world/world.tscn"
var current_world_scene: String = DEFAULT_WORLD_SCENE

# M67: State transisi tertunda (sementara — dikonsumsi setelah arrival)
var target_world_scene: String = ""
var target_spawn_id: String = ""


func start_battle(encounter_id: String, player_pos: Vector2, is_repeatable: bool = false) -> void:
	if is_transitioning:
		return
	if not is_repeatable and encounter_id in consumed_encounters:
		return
	
	is_transitioning = true
	if not is_repeatable:
		consumed_encounters.append(encounter_id)
	player_return_position = player_pos
	
	if encounter_id == "placeholder_battle_1" and pending_formation == null:
		pending_formation = load("res://data/battle/formations/prologue_tutorial.tres")
		

	# Mulai transisi ke battle scene
	TransitionManager.transition_to_scene("res://scenes/battle/battle.tscn")


func return_to_world() -> void:
	if is_transitioning:
		return
		
	is_transitioning = true
	pending_formation = null
	
	if EncounterManager:
		EncounterManager.reset_encounter()
		
	# Mulai transisi kembali ke main scene
	TransitionManager.transition_to_scene("res://scenes/main/main.tscn")
