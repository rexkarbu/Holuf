extends CanvasLayer

## BattleUI — menangani update visual pertempuran.

signal command_hovered(index: int)
signal command_clicked(index: int)
signal skill_hovered(index: int)
signal skill_clicked(index: int)

@onready var title_label: Label = $Title
@onready var hint_label: Label = $Hint
@onready var log_label: Label = $LogPanel/MarginContainer/LogLabel

# Party Status Panel (in BottomHUD)
@onready var party_list: VBoxContainer = $BottomHUD/PartyStatusPanel/MarginContainer/PartyList
@onready var base_player_row: HBoxContainer = $BottomHUD/PartyStatusPanel/MarginContainer/PartyList/BasePlayerRow
var player_stats_nodes: Array[Control] = []

# Command / Skill Panels (in BottomHUD/LeftSection)
@onready var command_panel: PanelContainer = $BottomHUD/LeftSection/CommandPanel
@onready var command_vbox: VBoxContainer = $BottomHUD/LeftSection/CommandPanel/MarginContainer/VBoxContainer

@onready var turn_order_label: Label = $TurnOrderPanel/MarginContainer/TurnOrderLabel

@onready var skill_panel: PanelContainer = $BottomHUD/LeftSection/SkillPanel
@onready var skill_vbox: VBoxContainer = $BottomHUD/LeftSection/SkillPanel/MarginContainer/VBoxContainer

# Enemy Status Panel (in BottomHUD - horizontal layout)
@onready var enemy_list: HBoxContainer = $BottomHUD/EnemyStatusPanel/MarginContainer/EnemyList
@onready var base_enemy_block: PanelContainer = $BottomHUD/EnemyStatusPanel/MarginContainer/EnemyList/BaseEnemyBlock

var enemy_stats_nodes: Array[Control] = []

func _ready() -> void:
	command_panel.hide()
	skill_panel.hide()

	for i in range(command_vbox.get_child_count()):
		var label = command_vbox.get_child(i) as Control
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_on_command_hovered.bind(i))
		label.gui_input.connect(_on_command_gui_input.bind(i))

# ==============================================================
# ENEMY SETUP
# ==============================================================

func setup_enemies(enemies: Array) -> void:
	for i in range(1, enemy_stats_nodes.size()):
		enemy_stats_nodes[i].queue_free()
	enemy_stats_nodes.clear()

	for i in range(enemies.size()):
		var block = base_enemy_block
		if i > 0:
			block = base_enemy_block.duplicate()
			enemy_list.add_child(block)

		block.show()
		_get_enemy_name_label(block).text = enemies[i].base_data.display_name
		enemy_stats_nodes.append(block)

		# Init weaknesses to "?"
		for child in _get_weakness_slots(block):
			var label = child as Label
			if label:
				label.text = "?"
				label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))

func _get_enemy_name_label(block: Control) -> Label:
	return block.get_node("MarginContainer/VBoxContainer/NameLabel")

func _get_weakness_slots(block: Control) -> Array:
	return block.get_node("MarginContainer/VBoxContainer/WeaknessPanel/WeaknessSlots").get_children()

# ==============================================================
# PLAYER SETUP
# ==============================================================

func setup_players(players: Array) -> void:
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

# ==============================================================
# TARGET INDICATORS
# ==============================================================

func set_ally_target_indicator(player_index: int, players: Array) -> void:
	for i in range(player_stats_nodes.size()):
		var label = player_stats_nodes[i].get_node("NameLabel") as Label
		if i == player_index:
			label.text = "> " + players[i].base_data.display_name
			label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		else:
			label.text = players[i].base_data.display_name
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func clear_ally_target_indicator(players: Array) -> void:
	for i in range(player_stats_nodes.size()):
		var label = player_stats_nodes[i].get_node("NameLabel") as Label
		label.text = players[i].base_data.display_name
		label.add_theme_color_override("font_color", Color(1, 1, 1))

func highlight_current_actor(combatant_name: String, players: Array) -> void:
	for i in range(player_stats_nodes.size()):
		var label = player_stats_nodes[i].get_node("NameLabel") as Label
		if players[i].base_data.display_name == combatant_name:
			label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.4))
		else:
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func set_enemy_target_indicator(enemy_index: int, enemies: Array) -> void:
	for i in range(enemy_stats_nodes.size()):
		var label = _get_enemy_name_label(enemy_stats_nodes[i])
		if i == enemy_index:
			label.text = "> " + enemies[i].base_data.display_name
			label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		else:
			label.text = enemies[i].base_data.display_name
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func clear_enemy_target_indicator(enemies: Array) -> void:
	for i in range(enemy_stats_nodes.size()):
		var label = _get_enemy_name_label(enemy_stats_nodes[i])
		label.text = enemies[i].base_data.display_name
		label.add_theme_color_override("font_color", Color(1, 1, 1))

# ==============================================================
# ENEMY STAT UPDATES
# ==============================================================

func update_enemy_hp(index: int, current: int, max_hp: int) -> void:
	if index >= enemy_stats_nodes.size(): return
	enemy_stats_nodes[index].get_node("MarginContainer/VBoxContainer/HBoxStats/HPLabel").text = "HP %d/%d" % [current, max_hp]

func update_enemy_mp(index: int, current: int, max_mp: int) -> void:
	if index >= enemy_stats_nodes.size(): return
	enemy_stats_nodes[index].get_node("MarginContainer/VBoxContainer/HBoxStats/MPLabel").text = "MP %d/%d" % [current, max_mp]

func update_enemy_shield(index: int, current: int, max_shield: int, is_broken: bool) -> void:
	if index >= enemy_stats_nodes.size(): return
	var shield_label = enemy_stats_nodes[index].get_node("MarginContainer/VBoxContainer/ShieldLabel")
	if max_shield <= 0:
		shield_label.text = ""
		return
	if is_broken:
		shield_label.text = "** BREAK! **"
		shield_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1, 1))
	else:
		var diamonds = ""
		for i in range(current):
			if i > 0: diamonds += " "
			diamonds += "\u25C6"
		shield_label.text = "SHIELD: " + diamonds
		shield_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1))

func update_enemy_weakness(index: int, actual_weaknesses: Array, discovered: Array) -> void:
	if index >= enemy_stats_nodes.size(): return
	var slots = _get_weakness_slots(enemy_stats_nodes[index])
	var types = DamageType.OFFENSIVE_TYPES
	for i in range(min(types.size(), slots.size())):
		var label = slots[i] as Label
		if label == null: continue
		var t = types[i]
		if t in discovered and t in actual_weaknesses:
			label.text = DamageType.DISPLAY_NAMES[t]
			label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.1, 1))
		else:
			label.text = "?"
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))

func hide_enemy_ui(index: int) -> void:
	if index < enemy_stats_nodes.size():
		enemy_stats_nodes[index].hide()

# ==============================================================
# PLAYER STAT UPDATES
# ==============================================================

func update_player_hp(index: int, current: int, max_hp: int) -> void:
	if index >= player_stats_nodes.size(): return
	player_stats_nodes[index].get_node("HPLabel").text = "HP %d/%d" % [current, max_hp]

func update_player_mp(index: int, current: int, max_mp: int) -> void:
	if index >= player_stats_nodes.size(): return
	player_stats_nodes[index].get_node("MPLabel").text = "MP %d/%d" % [current, max_mp]

# ==============================================================
# GENERAL UI
# ==============================================================

func update_turn_order(names_array: Array) -> void:
	turn_order_label.text = " > ".join(names_array)

func set_turn_title(text: String) -> void:
	title_label.text = text

func add_log(text: String) -> void:
	log_label.text = text

func show_commands(visible_state: bool) -> void:
	command_panel.visible = visible_state

func set_command_selection(index: int) -> void:
	for i in range(command_vbox.get_child_count()):
		var label = command_vbox.get_child(i) as Label
		if i == index:
			label.text = "> " + label.name.to_upper()
			label.add_theme_color_override("font_color", Color(1, 1, 0.4))
		else:
			label.text = "  " + label.name.to_upper()
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func show_skills(visible_state: bool) -> void:
	skill_panel.visible = visible_state

func populate_skill_menu(skills: Array) -> void:
	for child in skill_vbox.get_children():
		child.free()

	for i in range(skills.size()):
		var skill = skills[i] as SkillData
		if skill == null: continue
		var label = Label.new()
		label.text = "  %s (%d MP)" % [skill.display_name, skill.mp_cost]
		label.add_theme_font_size_override("font_size", 18)
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_on_skill_hovered.bind(i))
		label.gui_input.connect(_on_skill_gui_input.bind(i))
		skill_vbox.add_child(label)

func set_skill_selection(index: int, skills: Array) -> void:
	var children = skill_vbox.get_children()
	for i in range(children.size()):
		var label = children[i] as Label
		if label == null or i >= skills.size(): continue
		var skill = skills[i] as SkillData
		if skill == null: continue
		if i == index:
			label.text = "> %s (%d MP)" % [skill.display_name, skill.mp_cost]
			label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		else:
			label.text = "  %s (%d MP)" % [skill.display_name, skill.mp_cost]
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func set_hint(text: String) -> void:
	hint_label.text = text

func _on_command_hovered(index: int) -> void:
	command_hovered.emit(index)

func _on_command_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		command_clicked.emit(index)

func _on_skill_hovered(index: int) -> void:
	skill_hovered.emit(index)

func _on_skill_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		skill_clicked.emit(index)
