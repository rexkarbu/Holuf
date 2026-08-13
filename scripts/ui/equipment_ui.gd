extends CanvasLayer

## EquipmentUI — M30: Equipment System Foundation.
## UI untuk melihat dan mengganti equipment semua 10 karakter.
## Diakses dari Pause Menu. World tetap paused saat UI ini terbuka.
##
## Layout:
##   Kiri: daftar semua karakter (Active + Reserve)
##   Tengah: slot Weapon/Armor/Accessory + daftar item compatible
##   Kanan: effective stats karakter

# ==============================================================
# NODES
# ==============================================================

var _bg: ColorRect
var _char_list: VBoxContainer
var _slot_panel: VBoxContainer
var _item_list: VBoxContainer
var _stats_label: Label
var _desc_label: Label
var _hint_label: Label

# Tombol slot yang bisa difokus
var _btn_weapon: Button
var _btn_armor: Button
var _btn_accessory: Button

var _selected_char_id: String = ""
var _selected_slot: String = ""

# Semua karakter dalam urutan
const ALL_CHARS: Array = [
	"hero", "character_b", "character_c", "character_d", "character_e",
	"character_f", "character_g", "character_h", "character_i", "character_j"
]

var _char_buttons: Dictionary = {}  # char_id → Button
var _item_buttons: Array = []       # list tombol item

# ==============================================================
# READY
# ==============================================================

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100

	_build_ui()

	# Pilih karakter pertama secara default
	if ALL_CHARS.size() > 0:
		_select_character(ALL_CHARS[0])
	
	# Fokus ke tombol karakter pertama
	if _char_buttons.has(ALL_CHARS[0]):
		_char_buttons[ALL_CHARS[0]].grab_focus()

# ==============================================================
# BUILD UI
# ==============================================================

func _build_ui() -> void:
	# Background overlay
	_bg = ColorRect.new()
	_bg.color = Color(0.05, 0.05, 0.1, 0.95)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	# Title
	var title = Label.new()
	title.text = "EQUIPMENT"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 16)
	title.size = Vector2(1280, 50)
	add_child(title)

	# 3-column layout
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	hbox.position = Vector2(0, 68)
	hbox.size = Vector2(1280, 560)
	add_child(hbox)

	# --- LEFT PANEL: Character list ---
	var left = _make_panel(240, Color(0.1, 0.1, 0.15, 0.9))
	hbox.add_child(left)

	var left_title = _make_label("PARTY", 16, Color(0.7, 0.7, 0.9))
	left_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(left_title)
	_add_separator(left)

	_char_list = VBoxContainer.new()
	_char_list.add_theme_constant_override("separation", 4)
	_char_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(_char_list)

	_populate_char_list()

	# --- CENTER PANEL: Slots + item list ---
	var center = _make_panel(500, Color(0.08, 0.08, 0.12, 0.9))
	hbox.add_child(center)

	var slot_title = _make_label("EQUIPMENT SLOTS", 16, Color(0.7, 0.7, 0.9))
	slot_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(slot_title)
	_add_separator(center)

	_slot_panel = VBoxContainer.new()
	_slot_panel.add_theme_constant_override("separation", 6)
	center.add_child(_slot_panel)

	_btn_weapon    = _make_slot_button("Weapon",    EquipmentManager.SLOT_WEAPON)
	_btn_armor     = _make_slot_button("Armor",     EquipmentManager.SLOT_ARMOR)
	_btn_accessory = _make_slot_button("Accessory", EquipmentManager.SLOT_ACCESSORY)
	_slot_panel.add_child(_btn_weapon)
	_slot_panel.add_child(_btn_armor)
	_slot_panel.add_child(_btn_accessory)

	_add_separator(center)

	var item_title = _make_label("AVAILABLE ITEMS", 14, Color(0.7, 0.7, 0.9))
	center.add_child(item_title)

	_item_list = VBoxContainer.new()
	_item_list.add_theme_constant_override("separation", 4)
	_item_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(_item_list)

	# Unequip button
	var btn_unequip = Button.new()
	btn_unequip.text = "[ UNEQUIP ]"
	btn_unequip.add_theme_font_size_override("font_size", 16)
	btn_unequip.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	btn_unequip.custom_minimum_size = Vector2(0, 40)
	btn_unequip.pressed.connect(_on_unequip_pressed)
	center.add_child(btn_unequip)

	# Description
	_add_separator(center)
	_desc_label = _make_label("", 13, Color(0.75, 0.75, 0.75))
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.custom_minimum_size = Vector2(0, 40)
	center.add_child(_desc_label)

	# --- RIGHT PANEL: Stats ---
	var right = _make_panel(280, Color(0.06, 0.1, 0.06, 0.9))
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right)

	var stat_title = _make_label("EFFECTIVE STATS", 16, Color(0.7, 0.9, 0.7))
	stat_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(stat_title)
	_add_separator(right)

	_stats_label = _make_label("", 18, Color(0.9, 0.95, 0.9))
	_stats_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(_stats_label)

	# Hint bar
	_hint_label = Label.new()
	_hint_label.text = "[Esc/Back] Close     [Enter/Click] Select"
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint_label.position = Vector2(0, -36)
	_hint_label.size = Vector2(1280, 36)
	add_child(_hint_label)

# ==============================================================
# POPULATE
# ==============================================================

func _populate_char_list() -> void:
	for child in _char_list.get_children():
		child.queue_free()
	_char_buttons.clear()

	# Active party label
	var active_lbl = _make_label("— Active —", 13, Color(0.6, 0.8, 0.6))
	active_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_char_list.add_child(active_lbl)

	for cid in PartyManager.active_party:
		_char_list.add_child(_make_char_button(cid))

	# Reserve label
	var reserve_lbl = _make_label("— Reserve —", 13, Color(0.7, 0.7, 0.7))
	reserve_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_char_list.add_child(reserve_lbl)

	for cid in PartyManager.reserve_party:
		_char_list.add_child(_make_char_button(cid))

func _make_char_button(char_id: String) -> Button:
	var cdata = PartyManager.roster.get(char_id) as CharacterData
	var btn = Button.new()
	btn.text = cdata.display_name if cdata else char_id
	btn.add_theme_font_size_override("font_size", 18)
	btn.custom_minimum_size = Vector2(0, 40)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(func(): _select_character(char_id))
	_char_buttons[char_id] = btn
	return btn

func _make_slot_button(label: String, slot_key: String) -> Button:
	var btn = Button.new()
	btn.add_theme_font_size_override("font_size", 17)
	btn.custom_minimum_size = Vector2(0, 46)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(func(): _select_slot(slot_key))
	return btn

func _refresh_slot_labels() -> void:
	if _selected_char_id == "":
		return
	var slots = [
		[_btn_weapon,    EquipmentManager.SLOT_WEAPON,    "Weapon"],
		[_btn_armor,     EquipmentManager.SLOT_ARMOR,     "Armor"],
		[_btn_accessory, EquipmentManager.SLOT_ACCESSORY, "Accessory"]
	]
	for entry in slots:
		var btn: Button = entry[0]
		var slot: String = entry[1]
		var label: String = entry[2]
		var eq = EquipmentManager.get_equipped(_selected_char_id, slot)
		if eq:
			btn.text = "%s:  %s" % [label, eq.display_name]
		else:
			btn.text = "%s:  (empty)" % label

func _refresh_item_list() -> void:
	for child in _item_list.get_children():
		child.queue_free()
	_item_buttons.clear()

	if _selected_char_id == "" or _selected_slot == "":
		var hint = _make_label("← Select a slot to see available items", 14, Color(0.5, 0.5, 0.5))
		_item_list.add_child(hint)
		return

	var items = EquipmentManager.get_equippable_for_slot(_selected_char_id, _selected_slot)
	if items.is_empty():
		var hint = _make_label("No compatible items available.", 14, Color(0.55, 0.55, 0.55))
		_item_list.add_child(hint)
		return

	for eq_data in items:
		eq_data = eq_data as EquipmentData
		var available = EquipmentManager.get_available_quantity(eq_data.equipment_id)
		var currently_equipped = (EquipmentManager.get_equipped_id(_selected_char_id, _selected_slot) == eq_data.equipment_id)
		
		var btn = Button.new()
		btn.add_theme_font_size_override("font_size", 15)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 36)
		
		var suffix = " [equipped]" if currently_equipped else " (x%d)" % available
		btn.text = "  %s%s" % [eq_data.display_name, suffix]
		
		if currently_equipped:
			btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
		
		# Capture eq_data for closure
		var eid = eq_data.equipment_id
		btn.pressed.connect(func(): _on_item_selected(eid))
		btn.mouse_entered.connect(func(): _show_desc(eid))
		btn.focus_entered.connect(func(): _show_desc(eid))
		
		_item_list.add_child(btn)
		_item_buttons.append(btn)

func _refresh_stats() -> void:
	if _selected_char_id == "":
		_stats_label.text = ""
		return

	var cdata = PartyManager.roster.get(_selected_char_id) as CharacterData
	var char_name = cdata.display_name if cdata else _selected_char_id

	var prog = PartyManager.character_progress.get(_selected_char_id)
	var level = prog.level if prog else 1

	# Hitung effective stats
	var combat_path = "res://data/battle/" + _selected_char_id + ".tres"
	if not ResourceLoader.exists(combat_path):
		_stats_label.text = "No combat data."
		return

	var comb_data = load(combat_path) as CombatantData
	var lb = level - 1  # level_bonus

	var base_hp  = comb_data.max_hp  + comb_data.hp_growth  * lb
	var base_mp  = comb_data.max_mp  + comb_data.mp_growth  * lb
	var base_atk = comb_data.attack  + comb_data.attack_growth * lb
	var base_def = comb_data.defense + comb_data.defense_growth * lb
	var base_mag = comb_data.magic_attack  + comb_data.magic_attack_growth * lb
	var base_mdf = comb_data.magic_defense + comb_data.magic_defense_growth * lb
	var base_spd = comb_data.speed  + comb_data.speed_growth * lb

	var eq_hp  = EquipmentManager.get_stat_bonus(_selected_char_id, "max_hp")
	var eq_mp  = EquipmentManager.get_stat_bonus(_selected_char_id, "max_mp")
	var eq_atk = EquipmentManager.get_stat_bonus(_selected_char_id, "atk")
	var eq_def = EquipmentManager.get_stat_bonus(_selected_char_id, "def")
	var eq_mag = EquipmentManager.get_stat_bonus(_selected_char_id, "mag_atk")
	var eq_mdf = EquipmentManager.get_stat_bonus(_selected_char_id, "mag_def")
	var eq_spd = EquipmentManager.get_stat_bonus(_selected_char_id, "spd")

	var cur_hp = prog.current_hp if prog else base_hp
	var cur_mp = prog.current_mp if prog else base_mp

	_stats_label.text = (
		"%s  (Lv.%d)\n\n" % [char_name, level] +
		"HP     %d / %d\n" % [cur_hp, base_hp + eq_hp] +
		"MP     %d / %d\n\n" % [cur_mp, base_mp + eq_mp] +
		"ATK    %d%s\n" % [base_atk + eq_atk, " (+%d)" % eq_atk if eq_atk != 0 else ""] +
		"DEF    %d%s\n" % [base_def + eq_def, " (+%d)" % eq_def if eq_def != 0 else ""] +
		"MAG    %d%s\n" % [base_mag + eq_mag, " (+%d)" % eq_mag if eq_mag != 0 else ""] +
		"MDEF   %d%s\n" % [base_mdf + eq_mdf, " (+%d)" % eq_mdf if eq_mdf != 0 else ""] +
		"SPD    %d%s\n" % [base_spd + eq_spd, " (+%d)" % eq_spd if eq_spd != 0 else ""]
	)

# ==============================================================
# SELECTION LOGIC
# ==============================================================

func _select_character(char_id: String) -> void:
	_selected_char_id = char_id
	_selected_slot = ""

	# Highlight karakter yang dipilih
	for cid in _char_buttons:
		var btn = _char_buttons[cid] as Button
		if cid == char_id:
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		else:
			btn.remove_theme_color_override("font_color")

	_refresh_slot_labels()
	_refresh_item_list()
	_refresh_stats()

func _select_slot(slot_key: String) -> void:
	_selected_slot = slot_key
	_refresh_slot_labels()
	_refresh_item_list()

	# Fokus ke item pertama di list jika ada
	if _item_buttons.size() > 0:
		_item_buttons[0].grab_focus()

func _on_item_selected(equipment_id: String) -> void:
	if _selected_char_id == "" or _selected_slot == "":
		return

	EquipmentManager.equip(_selected_char_id, equipment_id)
	_refresh_slot_labels()
	_refresh_item_list()
	_refresh_stats()

func _on_unequip_pressed() -> void:
	if _selected_char_id == "" or _selected_slot == "":
		return

	EquipmentManager.unequip(_selected_char_id, _selected_slot)
	_refresh_slot_labels()
	_refresh_item_list()
	_refresh_stats()

func _show_desc(equipment_id: String) -> void:
	var eq = EquipmentManager.get_equipment_data(equipment_id)
	if eq:
		_desc_label.text = eq.description

# ==============================================================
# INPUT
# ==============================================================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()

# ==============================================================
# UI HELPERS
# ==============================================================

func _make_panel(min_width: int, color: Color) -> VBoxContainer:
	var vb = VBoxContainer.new()
	vb.custom_minimum_size = Vector2(min_width, 0)
	vb.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_theme_constant_override("separation", 6)

	var bg = ColorRect.new()
	bg.color = color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.add_child(bg)

	# Margin container
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var inner = VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	inner.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(inner)
	vb.add_child(margin)

	return inner

func _make_label(text: String, size: int, color: Color) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	return lbl

func _add_separator(parent: Node) -> void:
	var sep = HSeparator.new()
	sep.add_theme_color_override("color", Color(0.3, 0.3, 0.4, 0.6))
	parent.add_child(sep)
