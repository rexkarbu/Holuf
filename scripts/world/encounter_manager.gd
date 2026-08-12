extends Node

## EncounterManager — Autoload untuk mengelola Random Encounters di World map.

enum DebugMode { NORMAL, DISABLED, FAST }

var current_table: EncounterTable = null
var distance_walked: float = 0.0
var next_threshold: float = 0.0
var is_locked: bool = false
var encounters_enabled: bool = true

var debug_mode: DebugMode = DebugMode.NORMAL

func _ready() -> void:
	_generate_threshold()

func set_table(table: EncounterTable) -> void:
	if current_table != table:
		current_table = table
		# Mereset progress ketika berpindah zona
		distance_walked = 0.0
		_generate_threshold()

func set_encounters_enabled(enabled: bool) -> void:
	encounters_enabled = enabled
	# Jika kita ingin behavior: B = reset progress pada save zone
	# distance_walked = 0.0
	# Namun kita pilih behavior A (preserve progress) sementara di dalam safe zone, 
	# hanya saja add_distance akan ditahan jika encounters_enabled = false.

func add_distance(amount: float) -> void:
	if is_locked or not encounters_enabled or current_table == null:
		return
	if debug_mode == DebugMode.DISABLED:
		return
		
	distance_walked += amount
	
	if distance_walked >= next_threshold:
		_trigger_encounter()

func _generate_threshold() -> void:
	if current_table == null:
		next_threshold = 999999.0
		return
		
	if debug_mode == DebugMode.FAST:
		next_threshold = randf_range(50.0, 100.0)
	else:
		next_threshold = randf_range(current_table.min_distance, current_table.max_distance)

func _trigger_encounter() -> void:
	if current_table == null or current_table.formations.size() == 0:
		return
		
	is_locked = true
	
	# Weighted random selection
	var total_weight = 0
	for f in current_table.formations:
		if f.weight > 0:
			total_weight += f.weight
			
	if total_weight <= 0:
		is_locked = false
		return
		
	var roll = randi() % total_weight
	var current_sum = 0
	var selected: EnemyFormation = null
	
	for f in current_table.formations:
		if f.weight > 0:
			current_sum += f.weight
			if roll < current_sum:
				selected = f
				break
				
	if selected != null:
		print("[Encounter] Triggered formation: ", selected.formation_id)
		GameManager.pending_formation = selected
		
		# Hentikan player
		var players = get_tree().get_nodes_in_group("player")
		var player_pos = Vector2.ZERO
		if players.size() > 0:
			player_pos = players[0].global_position
			
		GameManager.start_battle("random_encounter", player_pos)

func reset_encounter() -> void:
	distance_walked = 0.0
	is_locked = false
	_generate_threshold()
