extends Node2D

## BattleController — mengelola state machine dan logika pertempuran Turn-Based.

enum State { STARTING, ROUND_START, TURN_START, PLAYER_COMMAND, PLAYER_SKILL_SELECT, PLAYER_TARGET_SELECT, PLAYER_ACTION, ENEMY_ACTION, TURN_END, VICTORY, DEFEAT }

@export var hero_data: CombatantData
@export var enemy_data: CombatantData # Fallback

var player: Combatant
var enemies: Array[Combatant] = []
var current_state: State = State.STARTING

var turn_queue: Array[Combatant] = []
var current_combatant: Combatant

var command_index: int = 0
const COMMAND_COUNT: int = 3 # ATTACK, SKILL, DEFEND

var skill_index: int = 0
var selected_target_index: int = 0
var pending_action: Callable

var debug_bonus_mode: int = BreakBonus.DebugMode.RANDOM

@onready var ui = $UI

func _ready() -> void:
	if not hero_data: hero_data = load("res://data/battle/hero.tres")
	player = Combatant.new(hero_data)
	
	# Instantiate multiple enemies
	var forest_beast_data = load("res://data/battle/forest_beast.tres")
	var wolf_data = load("res://data/battle/wolf.tres")
	if forest_beast_data: enemies.append(Combatant.new(forest_beast_data))
	if wolf_data: enemies.append(Combatant.new(wolf_data))
	
	ui.setup_enemies(enemies)
	
	_update_all_hp_mp_ui()
	_update_all_shield_ui()
	
	ui.set_hint("")
	ui.show_commands(false)
	ui.show_skills(false)
	
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
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("")
		State.PLAYER_SKILL_SELECT:
			skill_index = 0
			ui.show_commands(false)
			ui.populate_skill_menu(player.base_data.skills)
			if player.base_data.skills.size() > 0:
				ui.set_skill_selection(skill_index, player.base_data.skills)
			ui.show_skills(true)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("Press ESC to cancel")
		State.PLAYER_TARGET_SELECT:
			ui.show_commands(false)
			ui.show_skills(false)
			_ensure_valid_target_selection()
			ui.set_enemy_target_indicator(selected_target_index, enemies)
			ui.set_hint("Select Target / ESC to cancel")
		State.ENEMY_ACTION:
			ui.set_turn_title("ENEMY TURN")
			ui.show_commands(false)
			ui.show_skills(false)
			ui.clear_enemy_target_indicator(enemies)
			_process_enemy_turn()
		State.VICTORY:
			ui.set_turn_title("VICTORY")
			ui.add_log("All enemies defeated!")
			ui.show_commands(false)
			ui.show_skills(false)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("Press ENTER to return")
		State.DEFEAT:
			ui.set_turn_title("DEFEAT")
			ui.add_log("%s has fallen." % player.base_data.display_name)
			ui.show_commands(false)
			ui.show_skills(false)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("Press ENTER to return")

func _process_round_start() -> void:
	turn_queue.clear()
	if not player.is_dead(): turn_queue.append(player)
	for e in enemies:
		if not e.is_dead(): turn_queue.append(e)
	
	turn_queue.sort_custom(func(a, b):
		var a_spd = a.get_effective_speed() if a.has_method("get_effective_speed") else a.base_data.speed
		var b_spd = b.get_effective_speed() if b.has_method("get_effective_speed") else b.base_data.speed
		if a_spd == b_spd:
			return a == player
		return a_spd > b_spd
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

func _check_victory() -> bool:
	for e in enemies:
		if not e.is_dead(): return false
	return true

# ==============================================================
# TARGET SELECTION
# ==============================================================
func _ensure_valid_target_selection() -> void:
	if enemies.size() == 0: return
	if not enemies[selected_target_index].is_dead(): return
	_next_valid_target(1)

func _next_valid_target(direction: int) -> void:
	var count = enemies.size()
	if count == 0: return
	for i in range(count):
		selected_target_index = (selected_target_index + direction + count) % count
		if not enemies[selected_target_index].is_dead():
			return

# ==============================================================
# DAMAGE PIPELINE
# ==============================================================

func _calculate_damage(attacker: Combatant, target: Combatant, damage_type: int, skill_power: float = 1.0, use_magic_scaling: bool = false) -> Dictionary:
	var base: int
	var def_stat = target.get_effective_defense() if target.has_method("get_effective_defense") else target.base_data.defense
	
	if use_magic_scaling:
		base = attacker.base_data.magic_attack - target.base_data.magic_defense
	else:
		base = attacker.base_data.attack - def_stat
	
	base = max(0, base)
	var amount: float = float(base) * skill_power
	var is_weakness: bool = damage_type in target.base_data.weaknesses
	
	if is_weakness:
		amount *= 1.25
	
	if target.is_broken:
		var mult = target.base_data.get_break_multiplier()
		if target.current_break_bonus == BreakBonus.Type.DEEP_STAGGER and target.base_data.tier == CombatantData.EnemyTier.BOSS:
			mult += 0.05
		amount *= mult
	
	if target.is_defending:
		amount *= 0.5
	
	return { "amount": max(1, roundi(amount)), "is_weakness": is_weakness }

func _process_shield_after_hit(target: Combatant, result: Dictionary) -> void:
	if not result.is_weakness: return
	if target.is_broken: return
	if target.base_data.max_shield <= 0: return
	
	var break_triggered = target.process_shield_hit()
	_update_all_shield_ui()
	
	if break_triggered and not target.is_dead():
		_trigger_break(target)

func _roll_break_bonus() -> int:
	if debug_bonus_mode == BreakBonus.DebugMode.FORCE_ARMOR_SHATTER: return BreakBonus.Type.ARMOR_SHATTER
	if debug_bonus_mode == BreakBonus.DebugMode.FORCE_DISORIENT: return BreakBonus.Type.DISORIENT
	if debug_bonus_mode == BreakBonus.DebugMode.FORCE_DEEP_STAGGER: return BreakBonus.Type.DEEP_STAGGER
	
	var roll = randi() % 100
	if roll < 40: return BreakBonus.Type.ARMOR_SHATTER
	elif roll < 75: return BreakBonus.Type.DISORIENT
	else: return BreakBonus.Type.DEEP_STAGGER

func _trigger_break(target: Combatant) -> void:
	target.is_broken = true
	target.current_break_bonus = _roll_break_bonus()
	
	if target.current_break_bonus == BreakBonus.Type.DEEP_STAGGER and target.base_data.tier != CombatantData.EnemyTier.BOSS:
		target.break_skips_remaining = 2
	else:
		target.break_skips_remaining = 1
		
	ui.add_log("BREAK! %s is staggered!" % target.base_data.display_name)
	match target.current_break_bonus:
		BreakBonus.Type.ARMOR_SHATTER: ui.add_log("Break Bonus: Armor Shatter! DEF reduced.")
		BreakBonus.Type.DISORIENT: ui.add_log("Break Bonus: Disorient! SPEED reduced.")
		BreakBonus.Type.DEEP_STAGGER: ui.add_log("Break Bonus: Deep Stagger!")
		
	_update_all_shield_ui()

func _handle_weakness_hit(damage_type: int, target: Combatant) -> void:
	if damage_type not in target.discovered_weaknesses:
		target.discovered_weaknesses.append(damage_type)
	var idx = enemies.find(target)
	if idx != -1:
		ui.update_enemy_weakness(idx, target.base_data.weaknesses, target.discovered_weaknesses)

# ==============================================================
# INPUT HANDLING
# ==============================================================

func _unhandled_input(event: InputEvent) -> void:
	match current_state:
		State.PLAYER_COMMAND:
			if event.is_action_pressed("ui_down") or (event is InputEventKey and event.keycode == KEY_S and event.pressed and not event.echo):
				command_index = (command_index + 1) % COMMAND_COUNT
				ui.set_command_selection(command_index)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.keycode == KEY_W and event.pressed and not event.echo):
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
			elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.keycode == KEY_S and event.pressed and not event.echo):
				if skills.size() > 0:
					skill_index = (skill_index + 1) % skills.size()
					ui.set_skill_selection(skill_index, skills)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.keycode == KEY_W and event.pressed and not event.echo):
				if skills.size() > 0:
					skill_index = (skill_index - 1 + skills.size()) % skills.size()
					ui.set_skill_selection(skill_index, skills)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				if skills.size() > 0:
					_execute_player_skill(skills[skill_index])
		State.PLAYER_TARGET_SELECT:
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				if command_index == 1: _set_state(State.PLAYER_SKILL_SELECT)
				else: _set_state(State.PLAYER_COMMAND)
			elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.keycode == KEY_D and event.pressed and not event.echo):
				_next_valid_target(1)
				ui.set_enemy_target_indicator(selected_target_index, enemies)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_left") or (event is InputEventKey and event.keycode == KEY_A and event.pressed and not event.echo):
				_next_valid_target(-1)
				ui.set_enemy_target_indicator(selected_target_index, enemies)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				_ensure_valid_target_selection()
				var target = enemies[selected_target_index]
				pending_action.call(target)
		State.VICTORY, State.DEFEAT:
			if event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				GameManager.return_to_world()

# ==============================================================
# PLAYER ACTIONS
# ==============================================================

func _execute_player_command() -> void:
	match command_index:
		0: # ATTACK
			pending_action = _process_player_attack
			_set_state(State.PLAYER_TARGET_SELECT)
		1: # SKILL
			_set_state(State.PLAYER_SKILL_SELECT)
		2: # DEFEND
			_set_state(State.PLAYER_ACTION)
			ui.show_commands(false)
			player.is_defending = true
			ui.add_log("%s braces for the next attack." % player.base_data.display_name)
			await get_tree().create_timer(0.8).timeout
			_set_state(State.TURN_START)

func _process_player_attack(target: Combatant) -> void:
	_set_state(State.PLAYER_ACTION)
	ui.clear_enemy_target_indicator(enemies)
	
	await get_tree().create_timer(0.3).timeout
	
	var result = _calculate_damage(player, target, DamageType.Type.SWORD)
	target.take_damage(result.amount)
	_update_all_hp_mp_ui()
	
	if result.is_weakness:
		_handle_weakness_hit(DamageType.Type.SWORD, target)
	
	_process_shield_after_hit(target, result)
	
	if result.is_weakness:
		ui.add_log("WEAK! %s attacks %s for %d damage!" % [player.base_data.display_name, target.base_data.display_name, result.amount])
	else:
		ui.add_log("%s attacks %s for %d damage!" % [player.base_data.display_name, target.base_data.display_name, result.amount])
	
	await get_tree().create_timer(0.8).timeout
	
	if target.is_dead():
		var idx = enemies.find(target)
		if idx != -1: ui.hide_enemy_ui(idx)
	
	if _check_victory():
		_set_state(State.VICTORY)
	else:
		_set_state(State.TURN_START)

func _execute_player_skill(skill: SkillData) -> void:
	if not player.can_spend_mp(skill.mp_cost):
		ui.add_log("Not enough MP.")
		return
	
	if skill.target_type == SkillData.TargetType.ENEMY:
		pending_action = func(tgt): _process_skill_attack(skill, tgt)
		_set_state(State.PLAYER_TARGET_SELECT)
	elif skill.target_type == SkillData.TargetType.SELF:
		_process_skill_heal(skill)

func _process_skill_attack(skill: SkillData, target: Combatant) -> void:
	player.spend_mp(skill.mp_cost)
	_update_all_hp_mp_ui()
	_set_state(State.PLAYER_ACTION)
	ui.clear_enemy_target_indicator(enemies)
	
	await get_tree().create_timer(0.3).timeout
	
	var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
	var result = _calculate_damage(player, target, skill.damage_type, skill.power, use_magic)
	
	target.take_damage(result.amount)
	_update_all_hp_mp_ui()
	
	if result.is_weakness:
		_handle_weakness_hit(skill.damage_type, target)
	
	_process_shield_after_hit(target, result)
	
	if result.is_weakness:
		ui.add_log("WEAK! %s uses %s for %d damage!" % [player.base_data.display_name, skill.display_name, result.amount])
	else:
		ui.add_log("%s uses %s for %d damage!" % [player.base_data.display_name, skill.display_name, result.amount])
	
	await get_tree().create_timer(0.8).timeout
	
	if target.is_dead():
		var idx = enemies.find(target)
		if idx != -1: ui.hide_enemy_ui(idx)
	
	if _check_victory():
		_set_state(State.VICTORY)
	else:
		_set_state(State.TURN_START)

func _process_skill_heal(skill: SkillData) -> void:
	player.spend_mp(skill.mp_cost)
	_update_all_hp_mp_ui()
	_set_state(State.PLAYER_ACTION)
	ui.show_skills(false)
	ui.set_hint("")
	
	await get_tree().create_timer(0.3).timeout
	
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

# ==============================================================
# ENEMY TURN — BREAK-AWARE
# ==============================================================

func _process_enemy_turn() -> void:
	var enemy_actor = current_combatant
	await get_tree().create_timer(0.7).timeout
	
	# --- Break State Check ---
	if enemy_actor.is_broken:
		if enemy_actor.break_skips_remaining > 0:
			enemy_actor.break_skips_remaining -= 1
			ui.add_log("%s is Broken and cannot act!" % enemy_actor.base_data.display_name)
			await get_tree().create_timer(0.8).timeout
			_set_state(State.TURN_START)
			return
		else:
			enemy_actor.recover_from_break()
			ui.add_log("%s recovered from Break." % enemy_actor.base_data.display_name)
			_update_all_shield_ui()
			await get_tree().create_timer(0.6).timeout
	
	# --- Aksi Normal ---
	var result = _calculate_damage(enemy_actor, player, DamageType.Type.SWORD)
	player.take_damage(result.amount)
	_update_all_hp_mp_ui()
	
	ui.add_log("%s attacks %s for %d damage!" % [enemy_actor.base_data.display_name, player.base_data.display_name, result.amount])
	
	await get_tree().create_timer(0.8).timeout
	
	if player.is_dead():
		_set_state(State.DEFEAT)
	else:
		_set_state(State.TURN_START)

# ==============================================================
# UI HELPERS
# ==============================================================

func _update_all_hp_mp_ui() -> void:
	ui.update_player_hp(player.current_hp, player.base_data.max_hp)
	ui.update_player_mp(player.current_mp, player.base_data.max_mp)
	for i in range(enemies.size()):
		var e = enemies[i]
		ui.update_enemy_hp(i, e.current_hp, e.base_data.max_hp)
		ui.update_enemy_mp(i, e.current_mp, e.base_data.max_mp)

func _update_all_shield_ui() -> void:
	for i in range(enemies.size()):
		var e = enemies[i]
		ui.update_enemy_shield(i, e.current_shield, e.base_data.max_shield, e.is_broken)

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
