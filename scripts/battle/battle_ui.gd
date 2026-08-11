extends CanvasLayer

## BattleUI — menangani update visual pertempuran.

signal command_hovered(index: int)
signal command_clicked(index: int)
signal skill_hovered(index: int)
signal skill_clicked(index: int)

@onready var title_label: Label = $Title
@onready var hint_label: Label = $Hint
@onready var log_label: Label = $LogPanel/MarginContainer/LogLabel

@onready var player_hp_label: Label = $PlayerStats/VBoxContainer/HPLabel
@onready var player_mp_label: Label = $PlayerStats/VBoxContainer/MPLabel

@onready var enemy_hp_label: Label = $EnemyStats/VBoxContainer/HPLabel
@onready var enemy_mp_label: Label = $EnemyStats/VBoxContainer/MPLabel
@onready var shield_label: Label = $EnemyStats/VBoxContainer/ShieldLabel

@onready var command_panel: PanelContainer = $CommandPanel
@onready var command_vbox: VBoxContainer = $CommandPanel/MarginContainer/VBoxContainer

@onready var turn_order_label: Label = $TurnOrderPanel/MarginContainer/TurnOrderLabel

@onready var skill_panel: PanelContainer = $SkillPanel
@onready var skill_vbox: VBoxContainer = $SkillPanel/MarginContainer/VBoxContainer

@onready var weakness_slots: HBoxContainer = $WeaknessPanel/WeaknessSlots

func _ready() -> void:
	command_panel.hide()
	skill_panel.hide()
	
	for i in range(command_vbox.get_child_count()):
		var label = command_vbox.get_child(i) as Control
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_on_command_hovered.bind(i))
		label.gui_input.connect(_on_command_gui_input.bind(i))

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

func update_player_hp(current: int, max_hp: int) -> void:
	player_hp_label.text = "HP: %d / %d" % [current, max_hp]

func update_player_mp(current: int, max_mp: int) -> void:
	player_mp_label.text = "MP: %d / %d" % [current, max_mp]

func update_enemy_hp(current: int, max_hp: int) -> void:
	enemy_hp_label.text = "HP: %d / %d" % [current, max_hp]

func update_enemy_mp(current: int, max_mp: int) -> void:
	enemy_mp_label.text = "MP: %d / %d" % [current, max_mp]

func update_turn_order(names_array: Array) -> void:
	turn_order_label.text = " → ".join(names_array)

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
		if skill == null:
			continue
		var label = Label.new()
		label.text = "  %s (%d MP)" % [skill.display_name, skill.mp_cost]
		label.add_theme_font_size_override("font_size", 22)
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_on_skill_hovered.bind(i))
		label.gui_input.connect(_on_skill_gui_input.bind(i))
		skill_vbox.add_child(label)

func set_skill_selection(index: int, skills: Array) -> void:
	var children = skill_vbox.get_children()
	for i in range(children.size()):
		var label = children[i] as Label
		if label == null or i >= skills.size():
			continue
		var skill = skills[i] as SkillData
		if skill == null:
			continue
		if i == index:
			label.text = "> %s (%d MP)" % [skill.display_name, skill.mp_cost]
			label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		else:
			label.text = "  %s (%d MP)" % [skill.display_name, skill.mp_cost]
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func set_hint(text: String) -> void:
	hint_label.text = text

## Update tampilan Shield musuh. Tampilkan diamonds, atau BREAK! saat broken.
func update_shield_display(current: int, max_shield: int, is_broken: bool) -> void:
	if max_shield <= 0:
		shield_label.text = ""
		return
	if is_broken:
		shield_label.text = "BREAK!"
		shield_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1, 1))
	else:
		var diamonds = ""
		for i in range(current):
			if i > 0:
				diamonds += " "
			diamonds += "\u25C6"
		shield_label.text = "SHIELD: " + diamonds
		shield_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1))

## Inisialisasi 5 slot weakness dengan "?" di awal battle.
func init_weakness_display(_actual_weaknesses: Array) -> void:
	for child in weakness_slots.get_children():
		var label = child as Label
		if label:
			label.text = "?"
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))

## Update slot weakness sesuai discovered list. Hanya tampilkan yang sudah ditemukan.
func update_weakness_display(actual_weaknesses: Array, discovered: Array) -> void:
	var types = DamageType.OFFENSIVE_TYPES
	var children = weakness_slots.get_children()
	for i in range(min(types.size(), children.size())):
		var label = children[i] as Label
		if label == null:
			continue
		var t = types[i]
		if t in discovered and t in actual_weaknesses:
			label.text = DamageType.DISPLAY_NAMES[t]
			label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.1, 1))
		else:
			label.text = "?"
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
