extends CanvasLayer

## BattleUI — menangani update visual pertempuran.

signal command_hovered(index: int)
signal command_clicked(index: int)
signal skill_hovered(index: int)
signal skill_clicked(index: int)
signal item_hovered(index: int)
signal item_clicked(index: int)

@onready var title_label: Label = $Title
@onready var hint_label: Label = $Hint
@onready var log_label: Label = $LogPanel/MarginContainer/LogLabel
@onready var speed_indicator: Label = $SpeedIndicator

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

@onready var item_panel: PanelContainer = $BottomHUD/LeftSection/ItemPanel
@onready var item_vbox: VBoxContainer = $BottomHUD/LeftSection/ItemPanel/MarginContainer/VBoxContainer

# Enemy Status Panel (in BottomHUD - horizontal layout)
@onready var enemy_list: HBoxContainer = $BottomHUD/EnemyStatusPanel/MarginContainer/EnemyList
@onready var base_enemy_block: PanelContainer = $BottomHUD/EnemyStatusPanel/MarginContainer/EnemyList/BaseEnemyBlock

var enemy_stats_nodes: Array[Control] = []
var current_commands: Array = []

func _ready() -> void:
	command_panel.hide()
	skill_panel.hide()
	if item_panel:
		item_panel.hide()

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
	
	# M23: Initialize BP display
	update_all_bp_ui(players)

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
	pass

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

func setup_commands(commands_list: Array, disabled_indices: Array) -> void:
	current_commands = commands_list.duplicate()
	# Clear existing immediately from tree so child count is accurate
	for child in command_vbox.get_children():
		command_vbox.remove_child(child)
		child.queue_free()
	
	# Create new labels
	for i in range(commands_list.size()):
		var label = Label.new()
		# M23 PATCH: Do not rely on node.name for gameplay text
		label.text = "  " + commands_list[i]
		label.add_theme_font_size_override("font_size", 20)
		if i in disabled_indices:
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5)) # Disabled color
			label.set_meta("disabled", true)
		else:
			label.add_theme_color_override("font_color", Color(1, 1, 1))
			label.set_meta("disabled", false)
			
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_on_command_hovered.bind(i))
		label.gui_input.connect(_on_command_gui_input.bind(i))
		
		command_vbox.add_child(label)

func set_command_selection(index: int) -> void:
	for i in range(command_vbox.get_child_count()):
		var label = command_vbox.get_child(i) as Label
		var is_disabled = label.get_meta("disabled", false)
		var cmd_text = current_commands[i] if i < current_commands.size() else "UNKNOWN"
		
		if i == index:
			label.text = "> " + cmd_text
			if not is_disabled:
				label.add_theme_color_override("font_color", Color(1, 1, 0.4))
		else:
			label.text = "  " + cmd_text
			if not is_disabled:
				label.add_theme_color_override("font_color", Color(1, 1, 1))

func show_skills(visible_state: bool) -> void:
	skill_panel.visible = visible_state

func populate_skill_menu(skills: Array) -> void:
	for child in skill_vbox.get_children():
		child.free()

	if skills.is_empty():
		var label = Label.new()
		label.text = "  No skills available."
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		skill_vbox.add_child(label)
		return

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

# ==============================================================
# BATTLE SPEED INDICATOR (M22)
# ==============================================================

var speed_indicator_timer: Timer = null

func update_speed_indicator() -> void:
	speed_indicator.text = BattleSpeed.get_display_text()
	speed_indicator.show()
	
	# Create timer if not exists
	if speed_indicator_timer == null:
		speed_indicator_timer = Timer.new()
		speed_indicator_timer.one_shot = true
		speed_indicator_timer.timeout.connect(_hide_speed_indicator)
		add_child(speed_indicator_timer)
	
	# Restart timer (2 seconds display)
	speed_indicator_timer.start(2.0)

func _hide_speed_indicator() -> void:
	speed_indicator.hide()

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

# ==============================================================
# ITEM MENU
# ==============================================================

func show_items(visible_state: bool) -> void:
	if item_panel:
		item_panel.visible = visible_state

func populate_item_menu(items: Array) -> void:
	if not item_vbox:
		return
	
	for child in item_vbox.get_children():
		child.free()
	
	for i in range(items.size()):
		var item = items[i]
		var qty = InventoryManager.get_quantity(item.item_id)
		var label = Label.new()
		label.text = "  %s x%d" % [item.display_name, qty]
		label.add_theme_font_size_override("font_size", 18)
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_on_item_hovered.bind(i))
		label.gui_input.connect(_on_item_gui_input.bind(i))
		item_vbox.add_child(label)

func set_item_selection(index: int, items: Array) -> void:
	if not item_vbox:
		return
	
	var children = item_vbox.get_children()
	for i in range(children.size()):
		var label = children[i] as Label
		if label == null or i >= items.size(): continue
		var item = items[i]
		var qty = InventoryManager.get_quantity(item.item_id)
		if i == index:
			label.text = "> %s x%d" % [item.display_name, qty]
			label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		else:
			label.text = "  %s x%d" % [item.display_name, qty]
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func _on_item_hovered(index: int) -> void:
	item_hovered.emit(index)

func _on_item_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		item_clicked.emit(index)

# ==============================================================
# VICTORY REWARDS UI (MILESTONE 20)
# ==============================================================

var victory_panel: PanelContainer = null
var victory_rewards_label: Label = null
var victory_level_ups_vbox: VBoxContainer = null

func show_victory_rewards(total_exp: int, total_gold: int, level_up_messages: Array, _players: Array) -> void:
	# Create victory panel if not exists
	if victory_panel == null:
		_create_victory_panel()
	
	# Update content directly using stored references
	victory_rewards_label.text = "Gained %d EXP  •  %d Gold" % [total_exp, total_gold]
	
	# Clear previous level up messages
	for child in victory_level_ups_vbox.get_children():
		child.queue_free()
	
	# Add new level up messages
	if level_up_messages.size() > 0:
		for msg in level_up_messages:
			var label = Label.new()
			label.text = msg
			label.add_theme_font_size_override("font_size", 16)
			label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			victory_level_ups_vbox.add_child(label)
	
	victory_panel.show()

func _create_victory_panel() -> void:
	victory_panel = PanelContainer.new()
	add_child(victory_panel)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.9, 0.8, 0.2, 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	victory_panel.add_theme_stylebox_override("panel", style)
	
	victory_panel.anchor_left = 0.5
	victory_panel.anchor_top = 0.5
	victory_panel.anchor_right = 0.5
	victory_panel.anchor_bottom = 0.5
	victory_panel.offset_left = -300
	victory_panel.offset_top = -200
	victory_panel.offset_right = 300
	victory_panel.offset_bottom = 200
	victory_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	victory_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 20)
	victory_panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.name = "VictoryTitle"
	title.text = "VICTORY!"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var separator1 = HSeparator.new()
	vbox.add_child(separator1)
	
	victory_rewards_label = Label.new()
	victory_rewards_label.name = "RewardsLabel"
	victory_rewards_label.add_theme_font_size_override("font_size", 20)
	victory_rewards_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	victory_rewards_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(victory_rewards_label)
	
	var separator2 = HSeparator.new()
	vbox.add_child(separator2)
	
	victory_level_ups_vbox = VBoxContainer.new()
	victory_level_ups_vbox.name = "LevelUpsVBox"
	victory_level_ups_vbox.add_theme_constant_override("separation", 8)
	vbox.add_child(victory_level_ups_vbox)
