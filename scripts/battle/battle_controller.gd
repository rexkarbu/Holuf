extends Node2D

## BattleController — mengelola state machine dan logika pertempuran Turn-Based.

enum State { STARTING, ROUND_START, TURN_START, PLAYER_COMMAND, PLAYER_SKILL_SELECT, PLAYER_ACTION, ENEMY_ACTION, TURN_END, VICTORY, DEFEAT }

@export var hero_data: CombatantData
@export var enemy_data: CombatantData

var player: Combatant
var enemy: Combatant
var current_state: State = State.STARTING

var turn_queue: Array[Combatant] = []
var current_combatant: Combatant

var command_index: int = 0
const COMMAND_COUNT: int = 3 # ATTACK, SKILL, DEFEND

var skill_index: int = 0

@onready var ui = $UI

func _ready() -> void:
	if not hero_data: hero_data = load("res://data/battle/hero.tres")
	if not enemy_data: enemy_data = load("res://data/battle/forest_beast.tres")
	
	player = Combatant.new(hero_data)
	enemy = Combatant.new(enemy_data)
	
	_update_all_hp_mp_ui()
	ui.set_hint("")
	ui.show_commands(false)
	ui.show_skills(false)
	ui.init_weakness_display(enemy.base_data.weaknesses)
	
	ui.command_hovered.connect(_on_ui_command_hovered)
	ui.command_clicked.connect(_on_ui_command_clicked)
	ui.skill_hovered.connect(_on_ui_skill_hovered)
	ui.skill_clicked.connect(_on_ui_skill_clicked)
	
	_set_state(State.STARTING)
	ui.add_log("Battle Started!")
	
	await get_tree().create_timer(1.0).timeout
	_set_state(State.ROUND_START)

func _set_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.ROUND_START:
			_process_round_start()
		State.TURN_START:
			_process_turn_start()
		State.PLAYER_COMMAND:
			ui.set_turn_title("PLAYER TURN")
			command_index = 0
			ui.set_command_selection(command_index)
			ui.show_commands(true)
			ui.show_skills(false)
			ui.set_hint("")
		State.PLAYER_SKILL_SELECT:
			skill_index = 0
			ui.show_commands(false)
			ui.populate_skill_menu(player.base_data.skills)
			if player.base_data.skills.size() > 0:
				ui.set_skill_selection(skill_index, player.base_data.skills)
			ui.show_skills(true)
			ui.set_hint("Press ESC to cancel")
		State.ENEMY_ACTION:
			ui.set_turn_title("ENEMY TURN")
			ui.show_commands(false)
			ui.show_skills(false)
			_process_enemy_turn()
		State.VICTORY:
			ui.set_turn_title("VICTORY")
			ui.add_log("%s defeated!" % enemy.base_data.display_name)
			ui.show_commands(false)
			ui.show_skills(false)
			ui.set_hint("Press ENTER to return")
		State.DEFEAT:
			ui.set_turn_title("DEFEAT")
			ui.add_log("%s has fallen." % player.base_data.display_name)
			ui.show_commands(false)
			ui.show_skills(false)
			ui.set_hint("Press ENTER to return")

func _process_round_start() -> void:
	turn_queue.clear()
	if not player.is_dead(): turn_queue.append(player)
	if not enemy.is_dead(): turn_queue.append(enemy)
	
	turn_queue.sort_custom(func(a, b): 
		if a.base_data.speed == b.base_data.speed:
			return a == player
		return a.base_data.speed > b.base_data.speed
	)
	
	_update_turn_order_ui()
	_set_state(State.TURN_START)

func _process_turn_start() -> void:
	if turn_queue.is_empty():
		_set_state(State.ROUND_START)
		return
		
	current_combatant = turn_queue.pop_front()
	_update_turn_order_ui()
	
	if current_combatant.is_dead():
		_set_state(State.TURN_START)
		return
		
	current_combatant.is_defending = false
	
	if current_combatant == player:
		_set_state(State.PLAYER_COMMAND)
	else:
		_set_state(State.ENEMY_ACTION)

func _update_turn_order_ui() -> void:
	var names = []
	if current_combatant and not current_combatant.is_dead():
		names.append("> " + current_combatant.base_data.display_name)
	for c in turn_queue:
		if not c.is_dead():
			names.append(c.base_data.display_name)
	ui.update_turn_order(names)

## Damage pipeline terpusat. Mengembalikan Dictionary {amount: int, is_weakness: bool}.
## Pipeline: base → × skill_power → weakness ×1.25 → defend ×0.5 → max(1, roundi)
func _calculate_damage(attacker: Combatant, defender: Combatant, damage_type: int, skill_power: float = 1.0, use_magic_scaling: bool = false) -> Dictionary:
	var base: int
	if use_magic_scaling:
		base = attacker.base_data.magic_attack - defender.base_data.magic_defense
	else:
		base = attacker.base_data.attack - defender.base_data.defense
	
	base = max(0, base)
	
	var amount: float = float(base) * skill_power
	
	var is_weakness: bool = damage_type in defender.base_data.weaknesses
	if is_weakness:
		amount *= 1.25
	
	if defender.is_defending:
		amount *= 0.5
	
	return { "amount": max(1, roundi(amount)), "is_weakness": is_weakness }

func _handle_weakness_hit(damage_type: int, target: Combatant) -> void:
	if damage_type not in target.discovered_weaknesses:
		target.discovered_weaknesses.append(damage_type)
	ui.update_weakness_display(target.base_data.weaknesses, target.discovered_weaknesses)

func _unhandled_input(event: InputEvent) -> void:
	match current_state:
		State.PLAYER_COMMAND:
			if event.is_action_pressed("ui_down"):
				command_index = (command_index + 1) % COMMAND_COUNT
				ui.set_command_selection(command_index)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_up"):
				command_index = (command_index - 1 + COMMAND_COUNT) % COMMAND_COUNT
				ui.set_command_selection(command_index)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				_execute_player_command()
		State.PLAYER_SKILL_SELECT:
			var skills = player.base_data.skills
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				_set_state(State.PLAYER_COMMAND)
			elif event.is_action_pressed("ui_down"):
				if skills.size() > 0:
					skill_index = (skill_index + 1) % skills.size()
					ui.set_skill_selection(skill_index, skills)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_up"):
				if skills.size() > 0:
					skill_index = (skill_index - 1 + skills.size()) % skills.size()
					ui.set_skill_selection(skill_index, skills)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				if skills.size() > 0:
					_execute_player_skill(skills[skill_index])
		State.VICTORY, State.DEFEAT:
			if event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				GameManager.return_to_world()

func _execute_player_command() -> void:
	match command_index:
		0: # ATTACK
			_process_player_attack()
		1: # SKILL
			_set_state(State.PLAYER_SKILL_SELECT)
		2: # DEFEND
			_set_state(State.PLAYER_ACTION)
			ui.show_commands(false)
			player.is_defending = true
			ui.add_log("%s braces for the next attack." % player.base_data.display_name)
			await get_tree().create_timer(0.8).timeout
			_set_state(State.TURN_START)

func _execute_player_skill(skill: SkillData) -> void:
	if not player.can_spend_mp(skill.mp_cost):
		ui.add_log("Not enough MP.")
		return
		
	player.spend_mp(skill.mp_cost)
	_update_all_hp_mp_ui()
	
	_set_state(State.PLAYER_ACTION)
	ui.show_skills(false)
	ui.set_hint("")
	
	await get_tree().create_timer(0.3).timeout
	
	if skill.target_type == SkillData.TargetType.ENEMY:
		var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
		var result = _calculate_damage(player, enemy, skill.damage_type, skill.power, use_magic)
		
		enemy.take_damage(result.amount)
		_update_all_hp_mp_ui()
		
		if result.is_weakness:
			_handle_weakness_hit(skill.damage_type, enemy)
			ui.add_log("WEAK! %s uses %s for %d damage!" % [player.base_data.display_name, skill.display_name, result.amount])
		else:
			ui.add_log("%s uses %s for %d damage!" % [player.base_data.display_name, skill.display_name, result.amount])
		
		await get_tree().create_timer(0.8).timeout
		
		if enemy.is_dead():
			_set_state(State.VICTORY)
		else:
			_set_state(State.TURN_START)
			
	elif skill.target_type == SkillData.TargetType.SELF:
		# Heal — tidak mengecek weakness
		var base_heal: int
		if skill.scaling_type == SkillData.ScalingType.PHYSICAL:
			base_heal = player.base_data.attack
		else:
			base_heal = player.base_data.magic_attack
			
		var heal_amount = max(1, roundi(float(base_heal) * skill.power))
		var old_hp = player.current_hp
		player.current_hp = min(player.current_hp + heal_amount, player.base_data.max_hp)
		var actual_heal = player.current_hp - old_hp
		
		_update_all_hp_mp_ui()
		ui.add_log("%s casts %s and restores %d HP!" % [player.base_data.display_name, skill.display_name, actual_heal])
		
		await get_tree().create_timer(0.8).timeout
		_set_state(State.TURN_START)

func _process_player_attack() -> void:
	_set_state(State.PLAYER_ACTION)
	ui.show_commands(false)
	
	await get_tree().create_timer(0.3).timeout
	
	var result = _calculate_damage(player, enemy, DamageType.Type.SWORD)
	enemy.take_damage(result.amount)
	_update_all_hp_mp_ui()
	
	if result.is_weakness:
		_handle_weakness_hit(DamageType.Type.SWORD, enemy)
		ui.add_log("WEAK! %s attacks %s for %d damage!" % [player.base_data.display_name, enemy.base_data.display_name, result.amount])
	else:
		ui.add_log("%s attacks %s for %d damage!" % [player.base_data.display_name, enemy.base_data.display_name, result.amount])
	
	await get_tree().create_timer(0.8).timeout
	
	if enemy.is_dead():
		_set_state(State.VICTORY)
	else:
		_set_state(State.TURN_START)

func _process_enemy_turn() -> void:
	await get_tree().create_timer(0.7).timeout
	
	var result = _calculate_damage(enemy, player, DamageType.Type.SWORD)
	player.take_damage(result.amount)
	_update_all_hp_mp_ui()
	
	ui.add_log("%s attacks %s for %d damage!" % [enemy.base_data.display_name, player.base_data.display_name, result.amount])
	
	await get_tree().create_timer(0.8).timeout
	
	if player.is_dead():
		_set_state(State.DEFEAT)
	else:
		_set_state(State.TURN_START)

func _update_all_hp_mp_ui() -> void:
	ui.update_player_hp(player.current_hp, player.base_data.max_hp)
	ui.update_player_mp(player.current_mp, player.base_data.max_mp)
	ui.update_enemy_hp(enemy.current_hp, enemy.base_data.max_hp)
	ui.update_enemy_mp(enemy.current_mp, enemy.base_data.max_mp)

func _on_ui_command_hovered(index: int) -> void:
	if current_state == State.PLAYER_COMMAND:
		command_index = index
		ui.set_command_selection(command_index)

func _on_ui_command_clicked(index: int) -> void:
	if current_state == State.PLAYER_COMMAND:
		command_index = index
		ui.set_command_selection(command_index)
		_execute_player_command()

func _on_ui_skill_hovered(index: int) -> void:
	if current_state == State.PLAYER_SKILL_SELECT:
		var skills = player.base_data.skills
		if skills.size() > 0:
			skill_index = index
			ui.set_skill_selection(skill_index, skills)

func _on_ui_skill_clicked(index: int) -> void:
	if current_state == State.PLAYER_SKILL_SELECT:
		var skills = player.base_data.skills
		if skills.size() > 0:
			skill_index = index
			ui.set_skill_selection(skill_index, skills)
			_execute_player_skill(skills[skill_index])
