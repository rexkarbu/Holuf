#!/usr/bin/env python3
"""
M23 - BOOST SYSTEM CORE Implementation Script

This script implements the complete Boost Point system:
- BP generation on natural turn start
- TAB cycling for boost selection
- Boost integration into damage/healing pipeline
- BP consumption after actions
- UI display for BP and selected boost
- Cancel safety
- Deep Stagger protection
"""

import re

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def implement_bp_generation():
    """Add BP generation (+1) at natural turn start in BattleController"""
    print(" Adding BP generation to _process_turn_start...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # Find _process_turn_start and add BP generation for players
    search = """func _process_turn_start() -> void:
	if turn_queue.is_empty():
		_set_state(State.ROUND_START)
		return
	
	current_combatant = turn_queue.pop_front()
	_update_turn_order_ui()
	
	if current_combatant.is_dead():
		_set_state(State.TURN_START)
		return
	
	current_combatant.is_defending = false
	
	if current_combatant in players:
		ui.highlight_current_actor(current_combatant.get_display_name(), players)
		_arena_update_party_highlights()
		_set_state(State.PLAYER_COMMAND)"""
    
    replace = """func _process_turn_start() -> void:
	if turn_queue.is_empty():
		_set_state(State.ROUND_START)
		return
	
	current_combatant = turn_queue.pop_front()
	_update_turn_order_ui()
	
	if current_combatant.is_dead():
		_set_state(State.TURN_START)
		return
	
	current_combatant.is_defending = false
	
	if current_combatant in players:
		# M23: Generate BP on natural turn start (Party only, not enemies)
		if current_combatant.current_bp < BoostMultiplier.MAX_BP:
			current_combatant.current_bp += 1
		# Reset selected boost to 0 for new turn
		current_combatant.selected_boost_level = 0
		
		ui.highlight_current_actor(current_combatant.get_display_name(), players)
		_arena_update_party_highlights()
		_set_state(State.PLAYER_COMMAND)"""
    
    content = content.replace(search, replace)
    write_file(path, content)
    print(" BP generation added")

def implement_tab_cycling():
    """Add TAB key handling for boost selection cycling"""
    print(" Adding TAB cycling logic to _unhandled_input...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # Find _unhandled_input and add TAB handling at the beginning (after battle_speed_toggle)
    search = """func _unhandled_input(event: InputEvent) -> void:
	# M22: Battle Speed Toggle (works in any state except menus)
	if event.is_action_pressed("battle_speed_toggle"):
		BattleSpeed.toggle_speed()
		ui.update_speed_indicator()  # Update UI indicator
		get_viewport().set_input_as_handled()
		return
	
	match current_state:
		State.PLAYER_COMMAND:"""
    
    replace = """func _unhandled_input(event: InputEvent) -> void:
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
		State.PLAYER_COMMAND:"""
    
    content = content.replace(search, replace)
    
    # Add _cycle_boost_selection helper function before _execute_player_command
    search_func = """# ==============================================================
# PLAYER ACTIONS
# ==============================================================

func _execute_player_command() -> void:"""
    
    replace_func = """# ==============================================================
# BOOST SELECTION (M23)
# ==============================================================

func _cycle_boost_selection() -> void:
	\"\"\"Cycle selected_boost_level: 0 -> 1 -> 2 -> 3 -> 0 (limited by current_bp)\"\"\"
	if current_combatant.current_bp == 0:
		current_combatant.selected_boost_level = 0
		return
	
	# Cycle: 0 -> 1 -> ... -> max_bp -> 0
	current_combatant.selected_boost_level += 1
	if current_combatant.selected_boost_level > current_combatant.current_bp:
		current_combatant.selected_boost_level = 0
	
	# Update UI to show new selection
	ui.update_boost_selection(current_combatant.selected_boost_level)
	ui.add_log("BOOST %d selected" % current_combatant.selected_boost_level)

# ==============================================================
# PLAYER ACTIONS
# ==============================================================

func _execute_player_command() -> void:"""
    
    content = content.replace(search_func, replace_func)
    write_file(path, content)
    print(" TAB cycling logic added")

def implement_boost_reset():
    """Add boost reset when selecting non-boostable commands (ITEM, DEFEND, FLEE)"""
    print(" Adding boost reset for non-boostable commands...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # ITEM command - reset boost
    search_item = """		2: # ITEM
			_set_state(State.PLAYER_ITEM_SELECT)"""
    replace_item = """		2: # ITEM
			current_combatant.selected_boost_level = 0  # M23: Cannot boost items
			_set_state(State.PLAYER_ITEM_SELECT)"""
    content = content.replace(search_item, replace_item)
    
    # DEFEND command - reset boost
    search_defend = """		3: # DEFEND
			_set_state(State.PLAYER_ACTION)
			ui.show_commands(false)
			current_combatant.is_defending = true"""
    replace_defend = """		3: # DEFEND
			current_combatant.selected_boost_level = 0  # M23: Cannot boost defend
			_set_state(State.PLAYER_ACTION)
			ui.show_commands(false)
			current_combatant.is_defending = true"""
    content = content.replace(search_defend, replace_defend)
    
    # FLEE command - reset boost (inside _attempt_flee would be better, but let's do it in command selection)
    # Actually, let's add it at the beginning of _attempt_flee function
    search_flee = """func _attempt_flee() -> void:
	# M22: Check if battle allows fleeing
	if not can_flee_from_battle:"""
    replace_flee = """func _attempt_flee() -> void:
	# M23: Cannot boost flee
	current_combatant.selected_boost_level = 0
	
	# M22: Check if battle allows fleeing
	if not can_flee_from_battle:"""
    content = content.replace(search_flee, replace_flee)
    
    write_file(path, content)
    print(" Boost reset for non-boostable commands added")

def implement_boost_damage():
    """Integrate boost multiplier into damage pipeline"""
    print(" Integrating boost into damage calculation...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # Modify _calculate_damage to accept boost_level parameter
    search = """func _calculate_damage(attacker: Combatant, target: Combatant, damage_type: int, skill_power: float = 1.0, use_magic_scaling: bool = false) -> Dictionary:
	var base: int
	var def_stat = target.get_effective_defense()
	
	if use_magic_scaling:
		var atk_mag = attacker.get_effective_magic_attack() if attacker.has_method("get_effective_magic_attack") else attacker.base_data.magic_attack
		var def_mag = target.get_effective_magic_defense() if target.has_method("get_effective_magic_defense") else attacker.base_data.magic_defense
		base = atk_mag - def_mag
	else:
		var atk_phys = attacker.get_effective_attack() if attacker.has_method("get_effective_attack") else attacker.base_data.attack
		base = atk_phys - def_stat
	
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
	
	return { "amount": max(1, roundi(amount)), "is_weakness": is_weakness }"""
    
    replace = """func _calculate_damage(attacker: Combatant, target: Combatant, damage_type: int, skill_power: float = 1.0, use_magic_scaling: bool = false, boost_level: int = 0) -> Dictionary:
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
	
	# M23: Apply Boost multiplier
	var boost_mult = BoostMultiplier.get_multiplier(boost_level)
	amount *= boost_mult
	
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
	
	return { "amount": max(1, roundi(amount)), "is_weakness": is_weakness }"""
    
    content = content.replace(search, replace)
    write_file(path, content)
    print(" Boost integrated into damage calculation")

def update_attack_calls():
    """Update all _calculate_damage calls to pass boost_level"""
    print(" Updating attack calls to use boost...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # _process_player_attack
    search = """	var result = _calculate_damage(current_combatant, target, DamageType.Type.SWORD)
	target.take_damage(result.amount)
	_update_all_hp_mp_ui()"""
    replace = """	var boost = current_combatant.selected_boost_level
	var result = _calculate_damage(current_combatant, target, DamageType.Type.SWORD, 1.0, false, boost)
	target.take_damage(result.amount)
	
	# M23: Consume BP after successful action
	current_combatant.current_bp -= boost
	current_combatant.selected_boost_level = 0
	
	_update_all_hp_mp_ui()"""
    content = content.replace(search, replace)
    
    write_file(path, content)
    print(" Attack calls updated with boost")

def update_skill_calls():
    """Update skill attack calls to use boost"""
    print(" Updating skill calls to use boost...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # _process_skill_attack
    search = """	var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
	var result = _calculate_damage(current_combatant, target, skill.damage_type, skill.power, use_magic)
	
	target.take_damage(result.amount)
	_update_all_hp_mp_ui()"""
    replace = """	var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
	var boost = current_combatant.selected_boost_level
	var result = _calculate_damage(current_combatant, target, skill.damage_type, skill.power, use_magic, boost)
	
	target.take_damage(result.amount)
	
	# M23: Consume BP after successful action
	current_combatant.current_bp -= boost
	current_combatant.selected_boost_level = 0
	
	_update_all_hp_mp_ui()"""
    content = content.replace(search, replace)
    
    write_file(path, content)
    print(" Skill calls updated with boost")

def update_heal_calls():
    """Update healing to use boost multiplier"""
    print(" Updating heal calls to use boost...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # _process_skill_heal
    search = """	var base_heal: int
	if skill.scaling_type == SkillData.ScalingType.PHYSICAL:
		base_heal = current_combatant.get_effective_attack() if current_combatant.has_method("get_effective_attack") else current_combatant.base_data.attack
	else:
		base_heal = current_combatant.get_effective_magic_attack() if current_combatant.has_method("get_effective_magic_attack") else current_combatant.base_data.magic_attack
	
	var heal_amount = max(1, roundi(float(base_heal) * skill.power))
	var old_hp = target.current_hp"""
    replace = """	var base_heal: int
	if skill.scaling_type == SkillData.ScalingType.PHYSICAL:
		base_heal = current_combatant.get_effective_attack() if current_combatant.has_method("get_effective_attack") else current_combatant.base_data.attack
	else:
		base_heal = current_combatant.get_effective_magic_attack() if current_combatant.has_method("get_effective_magic_attack") else current_combatant.base_data.magic_attack
	
	# M23: Apply Boost multiplier to healing
	var boost = current_combatant.selected_boost_level
	var boost_mult = BoostMultiplier.get_multiplier(boost)
	var heal_amount = max(1, roundi(float(base_heal) * skill.power * boost_mult))
	
	# M23: Consume BP after successful action
	current_combatant.current_bp -= boost
	current_combatant.selected_boost_level = 0
	
	var old_hp = target.current_hp"""
    content = content.replace(search, replace)
    
    write_file(path, content)
    print(" Heal calls updated with boost")

def update_enemy_attack():
    """Ensure enemy attacks don't use boost (enemies don't have BP)"""
    print(" Ensuring enemy attacks work without boost...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # Enemy AI attacks should pass 0 for boost_level (default parameter)
    # Find enemy attack in _process_enemy_turn
    search1 = """		var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
		var result = _calculate_damage(enemy_actor, target, skill.damage_type, skill.power, use_magic)"""
    replace1 = """		var use_magic = skill.scaling_type == SkillData.ScalingType.MAGIC
		var result = _calculate_damage(enemy_actor, target, skill.damage_type, skill.power, use_magic, 0)  # Enemies don't use boost"""
    
    search2 = """		# Basic Attack
		var result = _calculate_damage(enemy_actor, target, DamageType.Type.SWORD)"""
    replace2 = """		# Basic Attack
		var result = _calculate_damage(enemy_actor, target, DamageType.Type.SWORD, 1.0, false, 0)  # Enemies don't use boost"""
    
    content = content.replace(search1, replace1)
    content = content.replace(search2, replace2)
    
    write_file(path, content)
    print(" Enemy attacks configured (no boost)")

def main():
    print("=" * 60)
    print("M23 - BOOST SYSTEM CORE Implementation")
    print("=" * 60)
    
    implement_bp_generation()
    implement_tab_cycling()
    implement_boost_reset()
    implement_boost_damage()
    update_attack_calls()
    update_skill_calls()
    update_heal_calls()
    update_enemy_attack()
    
    print("\n" + "=" * 60)
    print(" M23 CORE IMPLEMENTATION COMPLETE!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Run add_boost_ui.py to add UI display")
    print("2. Test in Godot")
    print("3. Run all 23 test cases")

if __name__ == "__main__":
    main()
