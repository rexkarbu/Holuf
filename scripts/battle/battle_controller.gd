extends Node2D

## BattleController — mengelola state machine dan logika pertempuran Turn-Based.

enum State { STARTING, ROUND_START, TURN_START, PLAYER_COMMAND, PLAYER_SKILL_SELECT, PLAYER_ITEM_SELECT, PLAYER_TARGET_SELECT, ALLY_TARGET_SELECT, PLAYER_ACTION, ENEMY_ACTION, TURN_END, VICTORY, DEFEAT, FLED }



var players: Array[Combatant] = []
var enemies: Array[Combatant] = []
var current_state: State = State.STARTING

var turn_queue: Array[Combatant] = []
var current_combatant: Combatant

var command_index: int = 0
var available_commands: Array[String] = []
const COMMAND_COUNT: int = 5 # M22: ATTACK, SKILL, ITEM, DEFEND, FLEE

# M22: Flee system constants
const BASE_FLEE_CHANCE: float = 0.70  # 70% base flee chance
enum FleeDebugMode { RANDOM, FORCE_SUCCESS, FORCE_FAILURE }
var flee_debug_mode: FleeDebugMode = FleeDebugMode.RANDOM
var can_flee_from_battle: bool = true  # Set from formation data

var skill_index: int = 0
var item_index: int = 0
var selected_target_index: int = 0
var pending_action: Callable
var pending_item: ItemData = null

var debug_bonus_mode: int = BreakBonus.DebugMode.RANDOM
var enemy_ai_mode: int = EnemyAI.Mode.RANDOM  # DEVELOPMENT: change to FORCE_SKILL / FORCE_BASIC_ATTACK for testing

# === Arena Views ===
var party_views: Array = []
var enemy_views: Array = []

# Formation slot positions — diagonal party on left, staggered enemies on right.
# Arena safe zone: y ≈ 170..490 (above BottomHUD at y=510)
const PARTY_SLOTS: Array = [
	Vector2(155, 440),  # Slot 0 (front / Hero)
	Vector2(215, 370),  # Slot 1
	Vector2(275, 305),  # Slot 2
	Vector2(335, 245),  # Slot 3 (back)
]
const ENEMY_SLOTS: Array = [
	Vector2(610, 415),  # Slot 0 (front)
	Vector2(710, 325),  # Slot 1 (back)
	Vector2(650, 245),  # Slot 2
]

@onready var ui = $UI

func _ready() -> void:
	players.clear()
	for char_id in PartyManager.active_party:
		var data = _get_fallback_combatant_data(char_id)
		var combatant = Combatant.new(data, char_id)
		combatant.character_id = char_id
		combatant.beast_used_this_battle = false # Explicit reset per character at battle start
		players.append(combatant)
	
	ui.setup_players(players)
	
	# M22: Check if this battle allows fleeing
	if GameManager.pending_formation != null:
		can_flee_from_battle = GameManager.pending_formation.can_flee
	else:
		can_flee_from_battle = true  # Fallback: allow fleeing from test battles
	
	# Instantiate multiple enemies
	enemies.clear()
	if GameManager.pending_formation != null:
		var counts: Dictionary = {}
		for edata in GameManager.pending_formation.enemies:
			var n = edata.display_name
			if counts.has(n):
				counts[n] += 1
			else:
				counts[n] = 1
				
		var current_index: Dictionary = {}
		for edata in GameManager.pending_formation.enemies:
			var enemy = Combatant.new(edata)
			enemy.beast_used_this_battle = false
			var n = edata.display_name
			if counts[n] > 1:
				if not current_index.has(n):
					current_index[n] = 0
				var letters = ["A", "B", "C", "D", "E"]
				var idx = current_index[n]
				var letter = letters[idx] if idx < letters.size() else str(idx + 1)
				enemy.runtime_name = n + " " + letter
				current_index[n] += 1
			enemies.append(enemy)
	else:
		# Fallback to existing manual test setup
		var forest_beast_data = load("res://data/battle/forest_beast.tres")
		var wolf_data = load("res://data/battle/wolf.tres")
		if forest_beast_data: 
			var e = Combatant.new(forest_beast_data)
			e.beast_used_this_battle = false
			enemies.append(e)
		if wolf_data: 
			var e = Combatant.new(wolf_data)
			e.beast_used_this_battle = false
			enemies.append(e)

	
	ui.setup_enemies(enemies)
	
	# Spawn arena views for each party member
	for i in range(players.size()):
		var view = BattleCombatantView.new()
		$Combatants.add_child(view)
		view.position = PARTY_SLOTS[min(i, PARTY_SLOTS.size() - 1)]
		view.setup_party(players[i], i)
		party_views.append(view)
	
	# Spawn arena views for each enemy
	for i in range(enemies.size()):
		var view = BattleCombatantView.new()
		$Combatants.add_child(view)
		view.position = ENEMY_SLOTS[min(i, ENEMY_SLOTS.size() - 1)]
		view.setup_enemy(enemies[i], i)
		enemy_views.append(view)
	
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
	
	await BattleSpeed.wait(1.0)
	_set_state(State.ROUND_START)


func _get_fallback_combatant_data(char_id: String) -> CombatantData:
	var path = "res://data/battle/" + char_id + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
		
	var data = CombatantData.new()
	data.tier = CombatantData.EnemyTier.NORMAL
	if char_id == "aelia":
		data.max_hp = 95; data.attack = 18; data.defense = 5; data.magic_attack = 5; data.magic_defense = 5; data.speed = 27
	elif char_id == "lyra":
		data.max_hp = 105; data.attack = 17; data.defense = 7; data.magic_attack = 5; data.magic_defense = 6; data.speed = 24
	elif char_id == "doran":
		data.max_hp = 90; data.attack = 19; data.defense = 4; data.magic_attack = 5; data.magic_defense = 4; data.speed = 21
	else:
		data.max_hp = 90; data.attack = 15; data.defense = 5; data.magic_attack = 5; data.magic_defense = 5; data.speed = 20
		
	data.max_mp = 0
	if PartyManager.roster.has(char_id):
		data.display_name = PartyManager.roster[char_id].display_name
	else:
		data.display_name = char_id.capitalize()
		
	return data

func _set_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.ROUND_START:
			_process_round_start()
		State.TURN_START:
			_process_turn_start()
		State.PLAYER_COMMAND:
			ui.set_turn_title(current_combatant.get_display_name().to_upper() + " TURN")
			command_index = 0
			ui.set_command_selection(command_index)
			ui.show_commands(true)
			ui.show_skills(false)
			ui.show_items(false)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("")
		State.PLAYER_SKILL_SELECT:
			skill_index = 0
			ui.show_commands(false)
			ui.populate_skill_menu(current_combatant.base_data.skills)
			if current_combatant.base_data.skills.size() > 0:
				ui.set_skill_selection(skill_index, current_combatant.base_data.skills)
			ui.show_skills(true)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("Press ESC to cancel")
		State.PLAYER_ITEM_SELECT:
			item_index = 0
			ui.show_commands(false)
			var items = InventoryManager.get_battle_items()
			ui.populate_item_menu(items)
			if items.size() > 0:
				ui.set_item_selection(item_index, items)
			ui.show_items(true)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("Press ESC to cancel")
		State.PLAYER_TARGET_SELECT:
			ui.show_commands(false)
			ui.show_skills(false)
			ui.show_items(false)
			_ensure_valid_target_selection()
			ui.set_enemy_target_indicator(selected_target_index, enemies)
			_arena_update_enemy_target(selected_target_index)
			ui.set_hint("Select Target / ESC to cancel")
		State.ALLY_TARGET_SELECT:
			ui.show_commands(false)
			ui.show_skills(false)
			ui.show_items(false)
			_ensure_valid_ally_target_selection()
			ui.set_ally_target_indicator(selected_target_index, players)
			ui.set_hint("Select Ally / ESC to cancel")
		State.ENEMY_ACTION:
			ui.set_turn_title("ENEMY TURN")
			ui.show_commands(false)
			ui.show_skills(false)
			ui.show_items(false)
			ui.clear_enemy_target_indicator(enemies)
			_process_enemy_turn()
		State.VICTORY:
			ui.set_turn_title("VICTORY")
			ui.add_log("All enemies defeated!")
			ui.show_commands(false)
			ui.show_skills(false)
			ui.show_items(false)
			ui.clear_enemy_target_indicator(enemies)
			_process_victory_rewards()
		State.DEFEAT:
			ui.set_turn_title("DEFEAT")
			ui.add_log("The party has fallen.")
			ui.show_commands(false)
			ui.show_skills(false)
			ui.show_items(false)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("Press ENTER to return")
		State.FLED:
			ui.set_turn_title("FLED")
			ui.show_commands(false)
			ui.show_skills(false)
			ui.show_items(false)
			ui.clear_enemy_target_indicator(enemies)
			_process_flee_return()

func _process_round_start() -> void:
	turn_queue.clear()
	for p in players:
		if not p.is_dead(): 
			p.has_acted_this_round = false
			turn_queue.append(p)
	for e in enemies:
		if not e.is_dead(): 
			e.has_acted_this_round = false
			turn_queue.append(e)
	
	_sort_turn_queue()
	_set_state(State.TURN_START)

func _sort_turn_queue() -> void:
	turn_queue.sort_custom(func(a, b):
		var a_spd = a.get_effective_speed() if a.has_method("get_effective_speed") else a.base_data.speed
		var b_spd = b.get_effective_speed() if b.has_method("get_effective_speed") else b.base_data.speed
		if a_spd == b_spd:
			return a in players
		return a_spd > b_spd
	)
	_update_turn_order_ui()

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
	current_combatant.has_acted_this_round = true
	
	# M23: Decrement active effects duration
	var effects_to_remove = []
	for dict in current_combatant.active_effects:
		if dict.has("is_new") and dict["is_new"]:
			dict["is_new"] = false
		else:
			dict["duration"] -= 1
			if dict["duration"] <= 0:
				effects_to_remove.append(dict)
	for dict in effects_to_remove:
		current_combatant.active_effects.erase(dict)
	if effects_to_remove.size() > 0:
		ui.add_log("%s's status returned to normal." % current_combatant.get_display_name())
	
	if current_combatant in players:
		# M23 BUGFIX: BP only increases on natural turn 2 and onwards
		current_combatant.natural_turns_started += 1
		if current_combatant.natural_turns_started > 1:
			if current_combatant.current_bp < BoostMultiplier.MAX_BP:
				current_combatant.current_bp += 1
		
		# Reset selected boost to 0 for new turn
		current_combatant.selected_boost_level = 0
		
		# M23 BUGFIX: Refresh BP display immediately at turn start
		ui.update_all_bp_ui(players)
		
		# Build available commands dynamically
		available_commands.clear()
		available_commands.append("ATTACK")
		available_commands.append("SKILL")
		if current_combatant.base_data.beast_skill != null:
			available_commands.append("BEAST")
		available_commands.append("ITEM")
		available_commands.append("DEFEND")
		available_commands.append("FLEE")
		
		var disabled_indices = []
		var beast_idx = available_commands.find("BEAST")
		if beast_idx != -1:
			var beast_skill = current_combatant.base_data.beast_skill
			if current_combatant.beast_used_this_battle or not current_combatant.can_spend_mp(beast_skill.mp_cost):
				disabled_indices.append(beast_idx)
		
		ui.setup_commands(available_commands, disabled_indices)
		
		# Validate command index
		if command_index >= available_commands.size():
			command_index = 0
		
		ui.highlight_current_actor(current_combatant.get_display_name(), players)
		_arena_update_party_highlights()
		_set_state(State.PLAYER_COMMAND)
	else:
		ui.highlight_current_actor("", players) # clear highlight
		_arena_update_party_highlights()
		_set_state(State.ENEMY_ACTION)

func _update_turn_order_ui() -> void:
	var names = []
	if current_combatant and not current_combatant.is_dead():
		names.append("> " + current_combatant.get_display_name())
	for c in turn_queue:
		if not c.is_dead():
			names.append(c.get_display_name())
	ui.update_turn_order(names)

func _check_victory() -> bool:
	for e in enemies:
		if not e.is_dead(): return false
	return true

func _check_defeat() -> bool:
	for p in players:
		if not p.is_dead(): return false
	return true

func _ensure_valid_ally_target_selection() -> void:
	if players.size() == 0: return
	if selected_target_index < 0 or selected_target_index >= players.size():
		selected_target_index = 0
	if not players[selected_target_index].is_dead(): return
	_next_valid_ally_target(1)

func _next_valid_ally_target(direction: int) -> void:
	var count = players.size()
	if count == 0: return
	for i in range(count):
		selected_target_index = (selected_target_index + direction + count) % count
		if not players[selected_target_index].is_dead():
			return


# ==============================================================
# TARGET SELECTION
# ==============================================================
func _ensure_valid_target_selection() -> void:
	if enemies.size() == 0: return
	if selected_target_index < 0 or selected_target_index >= enemies.size():
		selected_target_index = 0
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

func _calculate_damage(attacker: Combatant, target: Combatant, damage_type: int, skill_power: float = 1.0, use_magic_scaling: bool = false, boost_level: int = 0, condition: int = 0, cond_mult: float = 1.0) -> Dictionary:
	var base: int
	var def_stat = target.get_effective_defense()
	
	if use_magic_scaling:
		var atk_mag = attacker.get_effective_magic_attack() if attacker.has_method("get_effective_magic_attack") else attacker.base_data.magic_attack
		var def_mag = target.get_effective_magic_defense() if target.has_method("get_effective_magic_defense") else target.base_data.magic_defense
		base = atk_mag - def_mag
	else:
		var atk_phys = attacker.get_effective_attack() if attacker.has_method("get_effective_attack") else attacker.base_data.attack
		base = atk_phys - def_stat
	
	base = max(0, base)
	var amount: float = float(base) * skill_power
	
	# Conditional Bonus
	if condition == 1 and target.is_broken: # TARGET_BROKEN
		amount *= cond_mult
	elif condition == 2 and (turn_queue.has(target) or target == current_combatant): # TARGET_NOT_ACTED
		amount *= cond_mult
	
	# M23: Apply Boost multiplier
	var boost_mult = BoostMultiplier.get_multiplier(boost_level)
	amount *= boost_mult
	
	var is_weakness: bool = damage_type in target.base_data.weaknesses
	
	if is_weakness:
		amount *= 1.25
		
	# Defensive Stance check
	for dict in target.active_effects:
		var e: SkillEffectData = dict["effect"]
		if e.effect_type == SkillEffectData.Type.DEFENSIVE_STANCE:
			amount *= e.value # e.value is fraction, e.g. 0.5
			break
	
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
		
	ui.add_log("BREAK! %s is staggered!" % target.get_display_name())
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
	# M22: Battle Speed Toggle (works in any state except menus)
	if event.is_action_pressed("battle_speed_toggle"):
		BattleSpeed.toggle_speed()
		ui.update_speed_indicator()  # Update UI indicator
		get_viewport().set_input_as_handled()
		return
	
	# M23: Boost Selection Toggle (TAB) - only in PLAYER_COMMAND state
	if event.is_action_pressed("battle_boost_toggle") and current_state == State.PLAYER_COMMAND:
		if current_combatant in players:
			_cycle_boost_selection()
		get_viewport().set_input_as_handled()
		return
	
	match current_state:
		State.PLAYER_COMMAND:
			if event.is_action_pressed("ui_down") or (event is InputEventKey and event.keycode == KEY_S and event.pressed and not event.echo):
				command_index = (command_index + 1) % available_commands.size()
				ui.set_command_selection(command_index)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.keycode == KEY_W and event.pressed and not event.echo):
				command_index = (command_index - 1 + available_commands.size()) % available_commands.size()
				ui.set_command_selection(command_index)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				_execute_player_command()
		State.PLAYER_SKILL_SELECT:
			var skills = current_combatant.base_data.skills
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
		State.PLAYER_ITEM_SELECT:
			var items = InventoryManager.get_battle_items()
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				_set_state(State.PLAYER_COMMAND)
			elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.keycode == KEY_S and event.pressed and not event.echo):
				if items.size() > 0:
					item_index = (item_index + 1) % items.size()
					ui.set_item_selection(item_index, items)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.keycode == KEY_W and event.pressed and not event.echo):
				if items.size() > 0:
					item_index = (item_index - 1 + items.size()) % items.size()
					ui.set_item_selection(item_index, items)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				if items.size() > 0:
					_execute_player_item(items[item_index])
		State.PLAYER_TARGET_SELECT:
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				if command_index == 1: _set_state(State.PLAYER_SKILL_SELECT)
				else: _set_state(State.PLAYER_COMMAND)
			elif event.is_action_pressed("ui_right") or (event is InputEventKey and event.keycode == KEY_D and event.pressed and not event.echo):
				_next_valid_target(1)
				ui.set_enemy_target_indicator(selected_target_index, enemies)
				_arena_update_enemy_target(selected_target_index)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_left") or (event is InputEventKey and event.keycode == KEY_A and event.pressed and not event.echo):
				_next_valid_target(-1)
				ui.set_enemy_target_indicator(selected_target_index, enemies)
				_arena_update_enemy_target(selected_target_index)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				_ensure_valid_target_selection()
				_arena_update_enemy_target(-1) # clear arena target on confirm
				var target = enemies[selected_target_index]
				pending_action.call(target)
		State.ALLY_TARGET_SELECT:
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				if pending_item != null:
					pending_item = null
					_set_state(State.PLAYER_ITEM_SELECT)
				else:
					_set_state(State.PLAYER_SKILL_SELECT)
				ui.clear_ally_target_indicator(players)
			elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down") or (event is InputEventKey and (event.keycode == KEY_D or event.keycode == KEY_S) and event.pressed and not event.echo):
				_next_valid_ally_target(1)
				ui.set_ally_target_indicator(selected_target_index, players)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up") or (event is InputEventKey and (event.keycode == KEY_A or event.keycode == KEY_W) and event.pressed and not event.echo):
				_next_valid_ally_target(-1)
				ui.set_ally_target_indicator(selected_target_index, players)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				_ensure_valid_ally_target_selection()
				ui.clear_ally_target_indicator(players)
				var target = players[selected_target_index]
				pending_action.call(target)
		State.VICTORY, State.DEFEAT:
			if event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				GameManager.return_to_world()

# ==============================================================
# BOOST SELECTION (M23)
# ==============================================================

func _cycle_boost_selection() -> void:
	"""Cycle selected_boost_level: 0 -> 1 -> 2 -> 3 -> 0 (limited by current_bp)"""
	if current_combatant.current_bp == 0:
		current_combatant.selected_boost_level = 0
		return
	
	# Cycle: 0 -> 1 -> ... -> max_bp -> 0
	current_combatant.selected_boost_level += 1
	if current_combatant.selected_boost_level > current_combatant.current_bp:
		current_combatant.selected_boost_level = 0
	
	# Update UI to show new selection
	ui.update_all_bp_ui(players)
	if current_combatant.selected_boost_level > 0:
		ui.add_log("BOOST %d selected" % current_combatant.selected_boost_level)
	else:
		ui.add_log("BOOST cleared")

# ==============================================================
# PLAYER ACTIONS
# ==============================================================

func _execute_player_command() -> void:
	var cmd = available_commands[command_index]
	match cmd:
		"ATTACK":
			pending_action = _process_player_attack
			_set_state(State.PLAYER_TARGET_SELECT)
		"SKILL":
			_set_state(State.PLAYER_SKILL_SELECT)
		"BEAST":
			var beast_skill = current_combatant.base_data.beast_skill
			if current_combatant.beast_used_this_battle:
				ui.add_log("BEAST has already been used this battle!")
				return
			if not current_combatant.can_spend_mp(beast_skill.mp_cost):
				ui.add_log("Not enough MP for BEAST.")
				return
			_execute_player_skill(beast_skill)
		"ITEM":
			current_combatant.selected_boost_level = 0  # M23: Cannot boost items
			_set_state(State.PLAYER_ITEM_SELECT)
		"DEFEND":
			current_combatant.selected_boost_level = 0  # M23: Cannot boost defend
			_set_state(State.PLAYER_ACTION)
			ui.show_commands(false)
			current_combatant.is_defending = true
			ui.add_log("%s braces for the next attack." % current_combatant.get_display_name())
			await BattleSpeed.wait(0.8)
			_set_state(State.TURN_START)
		"FLEE":
			_attempt_flee()

func _process_player_attack(target: Combatant) -> void:
	_set_state(State.PLAYER_ACTION)
	ui.clear_enemy_target_indicator(enemies)
	
	await BattleSpeed.wait(0.3)
	
	var boost = current_combatant.selected_boost_level
	var wpn_type = DamageType.Type.SWORD
	if current_combatant.character_id != "" and PartyManager.roster.has(current_combatant.character_id):
		wpn_type = PartyManager.roster[current_combatant.character_id].weapon_type
		
	var result = _calculate_damage(current_combatant, target, wpn_type, 1.0, false, boost)
	target.take_damage(result.amount)
	
	# M23: Consume BP after successful action
	current_combatant.current_bp -= boost
	current_combatant.selected_boost_level = 0
	
	_update_all_hp_mp_ui()
	
	if result.is_weakness:
		_handle_weakness_hit(wpn_type, target)
	
	_process_shield_after_hit(target, result)
	
	if result.is_weakness:
		ui.add_log("WEAK! %s attacks %s for %d damage!" % [current_combatant.get_display_name(), target.get_display_name(), result.amount])
	else:
		ui.add_log("%s attacks %s for %d damage!" % [current_combatant.get_display_name(), target.get_display_name(), result.amount])
	
	if target.is_dead():
		var idx = enemies.find(target)
		if idx != -1:
			ui.hide_enemy_ui(idx)
			if idx < enemy_views.size():
				(enemy_views[idx] as BattleCombatantView).set_defeated()
				
	await _process_counter_attacks(current_combatant, [target])
	
	await BattleSpeed.wait(0.8)
	
	if _check_victory():
		_set_state(State.VICTORY)
	else:
		_set_state(State.TURN_START)

func _execute_player_skill(skill: SkillData) -> void:
	if not current_combatant.can_spend_mp(skill.mp_cost):
		ui.add_log("Not enough MP.")
		return
	
	match skill.target_type:
		SkillData.TargetType.ENEMY:
			pending_action = func(tgt): _process_skill_attack(skill, [tgt])
			_set_state(State.PLAYER_TARGET_SELECT)
		SkillData.TargetType.ALLY:
			pending_action = func(tgt): _process_skill_heal(skill, [tgt])
			selected_target_index = players.find(current_combatant)
			_set_state(State.ALLY_TARGET_SELECT)
		SkillData.TargetType.ALL_ENEMIES:
			var valid_targets: Array[Combatant] = []
			for e in enemies:
				if not e.is_dead(): valid_targets.append(e)
			_process_skill_attack(skill, valid_targets)
		SkillData.TargetType.ALL_ALLIES:
			var valid_targets: Array[Combatant] = []
			for p in players:
				if not p.is_dead(): valid_targets.append(p)
			_process_skill_heal(skill, valid_targets)
		SkillData.TargetType.SELF:
			_process_skill_heal(skill, [current_combatant])

func _process_skill_attack(skill: SkillData, targets: Array[Combatant]) -> void:
	var valid_targets = []
	for tgt in targets:
		if not tgt.is_dead(): valid_targets.append(tgt)
	if valid_targets.size() == 0:
		ui.add_log("Action failed: No valid targets.")
		_set_state(State.TURN_START)
		return
		
	if current_combatant.base_data.beast_skill != null and skill == current_combatant.base_data.beast_skill:
		current_combatant.beast_used_this_battle = true
		
	current_combatant.spend_mp(skill.mp_cost)
	var boost = current_combatant.selected_boost_level
	current_combatant.current_bp -= boost
	current_combatant.selected_boost_level = 0
	_update_all_hp_mp_ui()
	
	_set_state(State.PLAYER_ACTION)
	ui.clear_enemy_target_indicator(enemies)
	
	await BattleSpeed.wait(0.3)
	
	ui.add_log("%s uses %s!" % [current_combatant.get_display_name(), skill.display_name])
	var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
	
	for target in targets:
		if target.is_dead(): continue
		var result = _calculate_damage(current_combatant, target, skill.damage_type, skill.power, use_magic, boost, skill.condition_type, skill.conditional_power_multiplier)
		
		target.take_damage(result.amount)
		
		if result.is_weakness:
			_handle_weakness_hit(skill.damage_type, target)
		
		_process_shield_after_hit(target, result)
		
		if result.is_weakness:
			ui.add_log("WEAK! %s takes %d damage!" % [target.get_display_name(), result.amount])
		else:
			ui.add_log("%s takes %d damage!" % [target.get_display_name(), result.amount])
			
		_apply_skill_effects(current_combatant, target, skill)
		
		if target.is_dead():
			var idx = enemies.find(target)
			if idx != -1:
				ui.hide_enemy_ui(idx)
				if idx < enemy_views.size():
					(enemy_views[idx] as BattleCombatantView).set_defeated()
					
	_update_all_hp_mp_ui()
	await _process_counter_attacks(current_combatant, targets)
	await BattleSpeed.wait(0.8)
	
	if _check_victory():
		_set_state(State.VICTORY)
	else:
		_set_state(State.TURN_START)

func _process_skill_heal(skill: SkillData, targets: Array[Combatant]) -> void:
	var valid_targets = []
	for tgt in targets:
		if not tgt.is_dead(): valid_targets.append(tgt)
	if valid_targets.size() == 0:
		ui.add_log("Action failed: No valid targets.")
		_set_state(State.TURN_START)
		return
		
	if current_combatant.base_data.beast_skill != null and skill == current_combatant.base_data.beast_skill:
		current_combatant.beast_used_this_battle = true
		
	current_combatant.spend_mp(skill.mp_cost)
	var boost = current_combatant.selected_boost_level
	current_combatant.current_bp -= boost
	current_combatant.selected_boost_level = 0
	_update_all_hp_mp_ui()
	
	_set_state(State.PLAYER_ACTION)
	ui.show_skills(false)
	ui.set_hint("")
	
	await BattleSpeed.wait(0.3)
	ui.add_log("%s uses %s!" % [current_combatant.get_display_name(), skill.display_name])
	
	var base_heal: int
	if skill.scaling_type == SkillData.ScalingType.PHYSICAL:
		base_heal = current_combatant.get_effective_attack() if current_combatant.has_method("get_effective_attack") else current_combatant.base_data.attack
	else:
		base_heal = current_combatant.get_effective_magic_attack() if current_combatant.has_method("get_effective_magic_attack") else current_combatant.base_data.magic_attack
	
	# M23: Apply Boost multiplier to healing
	var boost_mult = BoostMultiplier.get_multiplier(boost)
	var heal_amount = 0
	if skill.power > 0.0:
		heal_amount = max(1, roundi(float(base_heal) * skill.power * boost_mult))
	
	for target in targets:
		if target.is_dead(): continue
		var old_hp = target.current_hp
		var target_max_hp = target.get_effective_max_hp() if target.has_method("get_effective_max_hp") else target.base_data.max_hp
		target.current_hp = min(target.current_hp + heal_amount, target_max_hp)
		var actual_heal = target.current_hp - old_hp
		
		if actual_heal > 0:
			ui.add_log("%s recovers %d HP!" % [target.get_display_name(), actual_heal])
			
		_apply_skill_effects(current_combatant, target, skill)
	
	_update_all_hp_mp_ui()
	await BattleSpeed.wait(0.8)
	_set_state(State.TURN_START)

func _apply_skill_effects(attacker: Combatant, target: Combatant, skill: SkillData) -> void:
	for eff in skill.effects:
		if randf() > eff.chance: continue
		
		match eff.effect_type:
			SkillEffectData.Type.CLEANSE:
				var to_remove = []
				for dict in target.active_effects:
					var active: SkillEffectData = dict["effect"]
					if active.effect_type in [SkillEffectData.Type.ATK_DOWN, SkillEffectData.Type.DEF_DOWN, SkillEffectData.Type.MAG_DOWN, SkillEffectData.Type.SPD_DOWN]:
						to_remove.append(dict)
				for r in to_remove: target.active_effects.erase(r)
				if to_remove.size() > 0: ui.add_log("%s's negative statuses were cleansed!" % target.get_display_name())
			
			SkillEffectData.Type.SELF_HEAL:
				var max_hp = attacker.get_effective_max_hp() if attacker.has_method("get_effective_max_hp") else attacker.base_data.max_hp
				var heal_amt = max(1, roundi(max_hp * eff.value))
				var old_hp = attacker.current_hp
				attacker.current_hp = min(attacker.current_hp + heal_amt, max_hp)
				if attacker.current_hp > old_hp:
					ui.add_log("%s recovers %d HP from self-heal!" % [attacker.get_display_name(), attacker.current_hp - old_hp])
			
			_:
				if eff.effect_type != SkillEffectData.Type.NONE:
					var recipient = target
					if eff.effect_target == SkillEffectData.EffectTarget.CASTER:
						recipient = attacker
						
					# Apply or refresh effect
					var found = false
					for dict in recipient.active_effects:
						var active: SkillEffectData = dict["effect"]
						if active.effect_type == eff.effect_type:
							if (eff.value >= active.value and eff.effect_type in [SkillEffectData.Type.ATK_UP, SkillEffectData.Type.DEF_UP, SkillEffectData.Type.MAG_UP, SkillEffectData.Type.SPD_UP, SkillEffectData.Type.COUNTER_STANCE]) or \
							   (eff.value <= active.value and eff.effect_type in [SkillEffectData.Type.ATK_DOWN, SkillEffectData.Type.DEF_DOWN, SkillEffectData.Type.MAG_DOWN, SkillEffectData.Type.SPD_DOWN, SkillEffectData.Type.DEFENSIVE_STANCE]):
								active.value = eff.value
								dict["duration"] = eff.duration
								dict["is_new"] = true
								found = true
							elif eff.value == active.value:
								dict["duration"] = max(dict["duration"], eff.duration)
								dict["is_new"] = true
								found = true
							break
					if not found:
						var new_eff = eff.duplicate()
						recipient.active_effects.append({
							"effect": new_eff,
							"duration": eff.duration,
							"is_new": true
						})
					
					# Recompute speed queue if speed changed
					if eff.effect_type in [SkillEffectData.Type.SPD_UP, SkillEffectData.Type.SPD_DOWN]:
						_sort_turn_queue()

func _execute_player_item(item: ItemData) -> void:
	pending_item = item
	if item.target_type == ItemData.TargetType.ONE_LIVING_ALLY:
		pending_action = func(tgt): _process_item_use(item, tgt)
		selected_target_index = players.find(current_combatant)
		_set_state(State.ALLY_TARGET_SELECT)

func _process_item_use(item: ItemData, target: Combatant) -> void:
	# Validate target based on effect type
	var is_valid = _validate_item_target(item, target)
	if not is_valid:
		return  # Stay in target selection
	
	# Consume item from inventory
	if not InventoryManager.remove_item(item.item_id, 1):
		ui.add_log("Item no longer available.")
		_set_state(State.PLAYER_COMMAND)
		return
	
	pending_item = null
	_set_state(State.PLAYER_ACTION)
	ui.show_items(false)
	ui.set_hint("")
	
	await BattleSpeed.wait(0.3)
	
	# Apply item effect
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			var old_hp = target.current_hp
			var target_max_hp = target.get_effective_max_hp() if target.has_method("get_effective_max_hp") else target.base_data.max_hp
			target.current_hp = min(target.current_hp + item.power, target_max_hp)
			var actual_heal = target.current_hp - old_hp
			_update_all_hp_mp_ui()
			ui.add_log("%s uses %s on %s. +%d HP!" % [current_combatant.get_display_name(), item.display_name, target.get_display_name(), actual_heal])
		
		ItemData.EffectType.RESTORE_MP:
			var old_mp = target.current_mp
			var target_max_mp = target.get_effective_max_mp() if target.has_method("get_effective_max_mp") else target.base_data.max_mp
			target.current_mp = min(target.current_mp + item.power, target_max_mp)
			var actual_restore = target.current_mp - old_mp
			_update_all_hp_mp_ui()
			ui.add_log("%s uses %s on %s. +%d MP!" % [current_combatant.get_display_name(), item.display_name, target.get_display_name(), actual_restore])
	
	await BattleSpeed.wait(0.8)
	_set_state(State.TURN_START)

func _validate_item_target(item: ItemData, target: Combatant) -> bool:
	var target_max_hp = target.get_effective_max_hp() if target.has_method("get_effective_max_hp") else target.base_data.max_hp
	var target_max_mp = target.get_effective_max_mp() if target.has_method("get_effective_max_mp") else target.base_data.max_mp
	
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			if target.current_hp >= target_max_hp:
				ui.add_log("HP is already full.")
				return false
		ItemData.EffectType.RESTORE_MP:
			if target_max_mp <= 0:
				ui.add_log("Target has no MP.")
				return false
			if target.current_mp >= target_max_mp:
				ui.add_log("MP is already full.")
				return false
	
	return true

# ==============================================================
# ENEMY TURN — BREAK-AWARE
# ==============================================================

func _process_enemy_turn() -> void:
	var enemy_actor = current_combatant
	await BattleSpeed.wait(0.7)
	
	# --- Break State Check (runs BEFORE AI decision) ---
	if enemy_actor.is_broken:
		if enemy_actor.break_skips_remaining > 0:
			enemy_actor.break_skips_remaining -= 1
			ui.add_log("%s is Broken and cannot act!" % enemy_actor.get_display_name())
			await BattleSpeed.wait(0.8)
			_set_state(State.TURN_START)
			return
		else:
			enemy_actor.recover_from_break()
			ui.add_log("%s recovered from Break." % enemy_actor.get_display_name())
			_update_all_shield_ui()
			await BattleSpeed.wait(0.6)
	
	# --- Basic Enemy AI: target selection ---
	var target: Combatant = EnemyAI.choose_target(players)
	if target == null:
		_set_state(State.DEFEAT)
		return
	
	# --- Basic Enemy AI: action selection (70% Basic / 30% Skill) ---
	var action = EnemyAI.choose_action(enemy_actor, enemy_ai_mode)
	
	if action["type"] == "skill":
		var skill: SkillData = action["skill"]
		var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
		
		var targets_to_hit: Array[Combatant] = []
		if skill.target_type == SkillData.TargetType.ALL_ENEMIES:
			for p in players:
				if not p.is_dead():
					targets_to_hit.append(p)
		else:
			targets_to_hit.append(target)
			
		if targets_to_hit.size() > 1:
			ui.add_log("%s uses %s!" % [enemy_actor.get_display_name(), skill.display_name])
			for t in targets_to_hit:
				var result = _calculate_damage(enemy_actor, t, skill.damage_type, skill.power, use_magic, 0)
				t.take_damage(result.amount)
				ui.add_log("...hits %s for %d damage!" % [t.get_display_name(), result.amount])
			_update_all_hp_mp_ui()
			_arena_update_party_highlights()
		else:
			var single_target = targets_to_hit[0]
			var result = _calculate_damage(enemy_actor, single_target, skill.damage_type, skill.power, use_magic, 0)  # Enemies don't use boost
			single_target.take_damage(result.amount)
			_update_all_hp_mp_ui()
			_arena_update_party_highlights()
			ui.add_log("%s uses %s on %s for %d damage!" % [
				enemy_actor.get_display_name(),
				skill.display_name,
				single_target.get_display_name(),
				result.amount
			])
	else:
		# Basic Attack
		var result = _calculate_damage(enemy_actor, target, DamageType.Type.SWORD, 1.0, false, 0)  # Enemies don't use boost
		target.take_damage(result.amount)
		_update_all_hp_mp_ui()
		_arena_update_party_highlights()
		ui.add_log("%s attacks %s for %d damage!" % [
			enemy_actor.get_display_name(),
			target.get_display_name(),
			result.amount
		])
	
	await _process_counter_attacks(enemy_actor, [target])
	await BattleSpeed.wait(0.8)
	
	if _check_defeat():
		_set_state(State.DEFEAT)
	else:
		_set_state(State.TURN_START)

# ==============================================================
# UI HELPERS
# ==============================================================

func _update_all_hp_mp_ui() -> void:
	for i in range(players.size()):
		var p = players[i]
		var max_hp = p.get_effective_max_hp() if p.has_method("get_effective_max_hp") else p.base_data.max_hp
		var max_mp = p.get_effective_max_mp() if p.has_method("get_effective_max_mp") else p.base_data.max_mp
		ui.update_player_hp(i, p.current_hp, max_hp)
		ui.update_player_mp(i, p.current_mp, max_mp)
	for i in range(enemies.size()):
		var e = enemies[i]
		ui.update_enemy_hp(i, e.current_hp, e.base_data.max_hp)
		ui.update_enemy_mp(i, e.current_mp, e.base_data.max_mp)
	
	# M23: Update BP display
	ui.update_all_bp_ui(players)

func _process_counter_attacks(attacker: Combatant, targets: Array[Combatant]) -> void:
	if attacker.is_dead(): return
	for tgt in targets:
		if tgt.is_dead(): continue
		if attacker.is_dead(): break
		
		# Find COUNTER_STANCE
		var counter_dict = null
		for dict in tgt.active_effects:
			var e: SkillEffectData = dict["effect"]
			if e.effect_type == SkillEffectData.Type.COUNTER_STANCE:
				counter_dict = dict
				break
				
		if counter_dict != null:
			var counter_eff: SkillEffectData = counter_dict["effect"]
			# Trigger counter!
			tgt.active_effects.erase(counter_dict) # consume stance
			ui.add_log("%s triggers Counter Attack!" % tgt.get_display_name())
			await BattleSpeed.wait(0.5)
			
			# Perform basic attack equivalent counter
			var wpn_type = DamageType.Type.SWORD
			if tgt.character_id != "" and PartyManager.roster.has(tgt.character_id):
				wpn_type = PartyManager.roster[tgt.character_id].weapon_type
				
			var result = _calculate_damage(tgt, attacker, wpn_type, counter_eff.value, false, 0)
			attacker.take_damage(result.amount)
			_update_all_hp_mp_ui()
			
			if result.is_weakness:
				_handle_weakness_hit(wpn_type, attacker)
			_process_shield_after_hit(attacker, result)
			
			if result.is_weakness:
				ui.add_log("WEAK! %s counters %s for %d damage!" % [tgt.get_display_name(), attacker.get_display_name(), result.amount])
			else:
				ui.add_log("%s counters %s for %d damage!" % [tgt.get_display_name(), attacker.get_display_name(), result.amount])
			
			if attacker.is_dead():
				var idx = enemies.find(attacker)
				if idx != -1:
					ui.hide_enemy_ui(idx)
					if idx < enemy_views.size():
						(enemy_views[idx] as BattleCombatantView).set_defeated()
				break

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
		var skills = current_combatant.base_data.skills
		if skills.size() > 0:
			skill_index = index
			ui.set_skill_selection(skill_index, skills)

func _on_ui_skill_clicked(index: int) -> void:
	if current_state == State.PLAYER_SKILL_SELECT:
		var skills = current_combatant.base_data.skills
		if skills.size() > 0:
			skill_index = index
			ui.set_skill_selection(skill_index, skills)
			_execute_player_skill(skills[skill_index])

# ==============================================================
# ARENA VIEW HELPERS
# ==============================================================

func _arena_update_party_highlights() -> void:
	for i in range(party_views.size()):
		var view = party_views[i] as BattleCombatantView
		if view == null: continue
		if players[i].is_dead():
			view.set_ko()
		else:
			view.set_current_actor(current_combatant == players[i])

func _arena_update_enemy_target(target_idx: int) -> void:
	for i in range(enemy_views.size()):
		var view = enemy_views[i] as BattleCombatantView
		if view == null: continue
		view.set_targeted(i == target_idx)

# ==============================================================
# VICTORY REWARDS (MILESTONE 20)
# ==============================================================

var rewards_processed: bool = false

func _process_victory_rewards() -> void:
	if rewards_processed:
		return
	rewards_processed = true
	
	# M21 PATCH: Sync battle HP/MP state back to PartyManager BEFORE calculating rewards
	for player in players:
		if player.character_id != "":
			PartyManager.sync_battle_state(player.character_id, player.current_hp, player.current_mp)
	
	# Calculate total rewards
	var total_exp: int = 0
	var total_gold: int = 0
	
	for enemy in enemies:
		total_exp += enemy.base_data.exp_reward
		total_gold += enemy.base_data.gold_reward
	
	# Grant rewards through PartyManager
	var level_up_messages = PartyManager.grant_rewards(total_exp, total_gold)
	
	# Show reward UI
	ui.show_victory_rewards(total_exp, total_gold, level_up_messages, players)
	ui.set_hint("Press ENTER to return")

# ==============================================================
# FLEE SYSTEM (M22)
# ==============================================================

func _attempt_flee() -> void:
	# M23: Cannot boost flee
	current_combatant.selected_boost_level = 0
	
	# M22: Check if battle allows fleeing
	if not can_flee_from_battle:
		ui.add_log("Cannot flee from this battle!")
		return  # Stay in PLAYER_COMMAND state
	
	_set_state(State.PLAYER_ACTION)
	ui.show_commands(false)
	
	await BattleSpeed.wait(0.5)
	
	# Determine flee success based on debug mode or RNG
	var flee_success: bool = false
	match flee_debug_mode:
		FleeDebugMode.FORCE_SUCCESS:
			flee_success = true
		FleeDebugMode.FORCE_FAILURE:
			flee_success = false
		FleeDebugMode.RANDOM:
			var roll = randf()
			flee_success = roll < BASE_FLEE_CHANCE
	
	if flee_success:
		ui.add_log("Escaped successfully!")
		await BattleSpeed.wait(1.0)
		_set_state(State.FLED)
	else:
		ui.add_log("Failed to escape!")
		await BattleSpeed.wait(0.8)
		# Flee failure consumes turn, continue to next combatant
		_set_state(State.TURN_START)

func _process_flee_return() -> void:
	# M22: Sync battle HP/MP state back to PartyManager (preserve current state)
	for player in players:
		if player.character_id != "":
			PartyManager.sync_battle_state(player.character_id, player.current_hp, player.current_mp)
	
	# No EXP/Gold rewards on flee
	ui.set_hint("Press ENTER to return")
	
	# Wait for player confirmation then return to world
	await BattleSpeed.wait(0.5)
	GameManager.return_to_world()
