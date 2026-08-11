extends Node

## GameManager — Autoload untuk menyimpan state session persisten antar scene.
## Digunakan untuk menyimpan state yang harus bertahan saat transisi World <-> Battle.

var player_return_position: Vector2 = Vector2.ZERO
var consumed_encounters: Array[String] = []

var is_transitioning: bool = false


func start_battle(encounter_id: String, player_pos: Vector2) -> void:
	if is_transitioning:
		return
	if encounter_id in consumed_encounters:
		return
	
	is_transitioning = true
	consumed_encounters.append(encounter_id)
	player_return_position = player_pos
	
	# Mulai transisi ke battle scene
	TransitionManager.transition_to_scene("res://scenes/battle/battle.tscn")


func return_to_world() -> void:
	if is_transitioning:
		return
		
	is_transitioning = true
	# Mulai transisi kembali ke main scene
	TransitionManager.transition_to_scene("res://scenes/main/main.tscn")
