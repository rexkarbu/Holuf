extends Node2D

## BattleController — mengelola state machine dan logika pertempuran Turn-Based.

enum State { STARTING, PLAYER_TURN, PLAYER_ACTION, ENEMY_TURN, ENEMY_ACTION, VICTORY, DEFEAT }

@export var hero_data: CombatantData
@export var enemy_data: CombatantData

var player: Combatant
var enemy: Combatant
var current_state: State = State.STARTING

@onready var ui = $UI

func _ready() -> void:
	# Load default stat jika belum di-assign (untuk kemudahan testing langsung scene ini)
	if not hero_data: hero_data = load("res://data/battle/hero.tres")
	if not enemy_data: enemy_data = load("res://data/battle/forest_beast.tres")
	
	player = Combatant.new(hero_data)
	enemy = Combatant.new(enemy_data)
	
	_update_all_hp_ui()
	ui.set_hint("")
	ui.show_commands(false)
	
	_set_state(State.STARTING)
	ui.add_log("Battle Started!")
	
	# Delay singkat sebelum turn pertama
	await get_tree().create_timer(1.0).timeout
	_set_state(State.PLAYER_TURN)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		match current_state:
			State.PLAYER_TURN:
				get_viewport().set_input_as_handled()
				_process_player_attack()
			State.VICTORY, State.DEFEAT:
				get_viewport().set_input_as_handled()
				GameManager.return_to_world()


func _set_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.PLAYER_TURN:
			ui.set_turn_title("PLAYER TURN")
			ui.show_commands(true)
		State.ENEMY_TURN:
			ui.set_turn_title("ENEMY TURN")
			ui.show_commands(false)
			_process_enemy_turn()
		State.VICTORY:
			ui.set_turn_title("VICTORY")
			ui.add_log("%s defeated!" % enemy.base_data.display_name)
			ui.show_commands(false)
			ui.set_hint("Press ENTER to return")
		State.DEFEAT:
			ui.set_turn_title("DEFEAT")
			ui.add_log("%s has fallen." % player.base_data.display_name)
			ui.show_commands(false)
			ui.set_hint("Press ENTER to return")


func _process_player_attack() -> void:
	_set_state(State.PLAYER_ACTION)
	ui.show_commands(false)
	
	# Delay untuk memberikan kesan 'action'
	await get_tree().create_timer(0.3).timeout
	
	var damage = max(1, player.base_data.attack - enemy.base_data.defense)
	enemy.take_damage(damage)
	_update_all_hp_ui()
	
	ui.add_log("%s attacks %s for %d damage!" % [player.base_data.display_name, enemy.base_data.display_name, damage])
	
	await get_tree().create_timer(0.8).timeout
	
	if enemy.is_dead():
		_set_state(State.VICTORY)
	else:
		_set_state(State.ENEMY_TURN)


func _process_enemy_turn() -> void:
	# Delay berfikir musuh
	await get_tree().create_timer(0.7).timeout
	
	_set_state(State.ENEMY_ACTION)
	
	var damage = max(1, enemy.base_data.attack - player.base_data.defense)
	player.take_damage(damage)
	_update_all_hp_ui()
	
	ui.add_log("%s attacks %s for %d damage!" % [enemy.base_data.display_name, player.base_data.display_name, damage])
	
	await get_tree().create_timer(0.8).timeout
	
	if player.is_dead():
		_set_state(State.DEFEAT)
	else:
		_set_state(State.PLAYER_TURN)


func _update_all_hp_ui() -> void:
	ui.update_player_hp(player.current_hp, player.base_data.max_hp)
	ui.update_enemy_hp(enemy.current_hp, enemy.base_data.max_hp)

