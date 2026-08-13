#!/usr/bin/env python3
"""
M23 - BOOST UI Implementation

Adds UI display for:
- BP (Boost Points) for each party member
- Selected boost level indicator
- update_boost_selection() function
"""

import re

def read_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

def add_bp_to_party_status():
    """Add BP display to party status UI"""
    print("Adding BP display to party status...")
    
    path = 'scripts/battle/battle_ui.gd'
    content = read_file(path)
    
    # Add BP label to setup_players (duplicate BasePlayerRow with BP)
    search = """func setup_players(players: Array) -> void:
	for i in range(1, player_stats_nodes.size()):
		player_stats_nodes[i].queue_free()
	player_stats_nodes.clear()

	for i in range(players.size()):
		var row = base_player_row
		if i > 0:
			row = base_player_row.duplicate()
			party_list.add_child(row)

		row.show()
		row.get_node("NameLabel").text = players[i].base_data.display_name
		player_stats_nodes.append(row)"""
    
    replace = """func setup_players(players: Array) -> void:
	for i in range(1, player_stats_nodes.size()):
		player_stats_nodes[i].queue_free()
	player_stats_nodes.clear()

	for i in range(players.size()):
		var row = base_player_row
		if i > 0:
			row = base_player_row.duplicate()
			party_list.add_child(row)

		row.show()
		row.get_node("NameLabel").text = players[i].base_data.display_name
		player_stats_nodes.append(row)
	
	# M23: Initialize BP display
	update_all_bp_ui(players)"""
    
    content = content.replace(search, replace)
    
    # Add update_all_bp_ui function
    search_func = """func update_player_mp(index: int, current: int, max_mp: int) -> void:
	if index >= player_stats_nodes.size(): return
	player_stats_nodes[index].get_node("MPLabel").text = "MP %d/%d" % [current, max_mp]"""
    
    replace_func = """func update_player_mp(index: int, current: int, max_mp: int) -> void:
	if index >= player_stats_nodes.size(): return
	player_stats_nodes[index].get_node("MPLabel").text = "MP %d/%d" % [current, max_mp]

# ==============================================================
# BOOST DISPLAY (M23)
# ==============================================================

func update_all_bp_ui(players: Array) -> void:
	for i in range(player_stats_nodes.size()):
		if i < players.size():
			update_player_bp(i, players[i].current_bp, players[i].selected_boost_level)

func update_player_bp(index: int, current_bp: int, selected_boost: int) -> void:
	if index >= player_stats_nodes.size(): return
	var bp_label = player_stats_nodes[index].get_node("BPLabel")
	bp_label.text = "BP %d" % current_bp
	
	# Highlight selected boost level
	if selected_boost > 0:
		bp_label.text = "BP %d [BOOST %d]" % [current_bp, selected_boost]
		bp_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
	else:
		bp_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))

func update_boost_selection(boost_level: int) -> void:
	# This is called when TAB is pressed to cycle boost selection
	# Update is handled by update_all_bp_ui which is called from BattleController
	pass"""
    
    content = content.replace(search_func, replace_func)
    
    write_file(path, content)
    print("BP display functions added to battle_ui.gd")

def add_bp_update_calls():
    """Add calls to update BP UI in BattleController"""
    print("Adding BP UI update calls to BattleController...")
    
    path = 'scripts/battle/battle_controller.gd'
    content = read_file(path)
    
    # Update _update_all_hp_mp_ui to also update BP
    search = """func _update_all_hp_mp_ui() -> void:
	for i in range(players.size()):
		var p = players[i]
		var max_hp = p.get_effective_max_hp() if p.has_method("get_effective_max_hp") else p.base_data.max_hp
		var max_mp = p.get_effective_max_mp() if p.has_method("get_effective_max_mp") else p.base_data.max_mp
		ui.update_player_hp(i, p.current_hp, max_hp)
		ui.update_player_mp(i, p.current_mp, max_mp)
	for i in range(enemies.size()):
		var e = enemies[i]
		ui.update_enemy_hp(i, e.current_hp, e.base_data.max_hp)
		ui.update_enemy_mp(i, e.current_mp, e.base_data.max_mp)"""
    
    replace = """func _update_all_hp_mp_ui() -> void:
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
	ui.update_all_bp_ui(players)"""
    
    content = content.replace(search, replace)
    
    # Also update BP UI after cycling boost selection
    search_cycle = """func _cycle_boost_selection() -> void:
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
	ui.add_log("BOOST %d selected" % current_combatant.selected_boost_level)"""
    
    replace_cycle = """func _cycle_boost_selection() -> void:
	\"\"\"Cycle selected_boost_level: 0 -> 1 -> 2 -> 3 -> 0 (limited by current_bp)\"\"\"
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
		ui.add_log("BOOST cleared")"""
    
    content = content.replace(search_cycle, replace_cycle)
    
    write_file(path, content)
    print("BP UI update calls added to BattleController")

def add_bp_label_to_scene():
    """Add BPLabel to battle.tscn BasePlayerRow"""
    print("Adding BPLabel to battle.tscn...")
    
    path = 'scenes/battle/battle.tscn'
    content = read_file(path)
    
    # Find BasePlayerRow and add BPLabel after MPLabel
    search = """[node name="MPLabel" type="Label" parent="UI/BottomHUD/PartyStatusPanel/MarginContainer/PartyList/BasePlayerRow"]
custom_minimum_size = Vector2(70, 0)
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.7, 1, 1)
theme_override_font_sizes/font_size = 14
text = "MP 40/40"

[node name="EnemyStatusPanel" type="PanelContainer" parent="UI/BottomHUD"]"""
    
    replace = """[node name="MPLabel" type="Label" parent="UI/BottomHUD/PartyStatusPanel/MarginContainer/PartyList/BasePlayerRow"]
custom_minimum_size = Vector2(70, 0)
layout_mode = 2
theme_override_colors/font_color = Color(0.4, 0.7, 1, 1)
theme_override_font_sizes/font_size = 14
text = "MP 40/40"

[node name="BPLabel" type="Label" parent="UI/BottomHUD/PartyStatusPanel/MarginContainer/PartyList/BasePlayerRow"]
custom_minimum_size = Vector2(80, 0)
layout_mode = 2
theme_override_colors/font_color = Color(0.7, 0.85, 1, 1)
theme_override_font_sizes/font_size = 14
text = "BP 0"

[node name="EnemyStatusPanel" type="PanelContainer" parent="UI/BottomHUD"]"""
    
    content = content.replace(search, replace)
    write_file(path, content)
    print("BPLabel added to battle.tscn")

def main():
    print("=" * 60)
    print("M23 - BOOST UI Implementation")
    print("=" * 60)
    
    add_bp_to_party_status()
    add_bp_update_calls()
    add_bp_label_to_scene()
    
    print("\n" + "=" * 60)
    print(" M23 UI IMPLEMENTATION COMPLETE!")
    print("=" * 60)
    print("\nBoost UI features:")
    print("- BP display for each party member")
    print("- Selected boost level highlighted in yellow")
    print("- Updates automatically when TAB is pressed")
    print("- Updates after actions consume BP")
    print("\nReady to test in Godot!")

if __name__ == "__main__":
    main()
