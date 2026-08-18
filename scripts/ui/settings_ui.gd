extends CanvasLayer

## SettingsUI — M29: UI Settings Foundation.
## process_mode = PROCESS_MODE_ALWAYS agar merespon input saat dipause.

var bg: ColorRect
var cat_vbox: VBoxContainer
var content_vbox: VBoxContainer
var desc_label: Label
var _active_category: String = ""

# Data Option
var _options = {
	"GAME": [
		{"id": "text_speed", "name": "Text Speed", "type": "dropdown", "items": ["Slow", "Normal", "Fast"], "desc": "Speed of text rendering in dialogue."},
		{"id": "remember_cursor", "name": "Battle Cursor", "type": "dropdown", "items": ["Revert", "Remember"], "desc": "Behavior of the cursor in battle menus."}
	],
	"GRAPHICS": [
		{"id": "display_mode", "name": "Display Mode", "type": "dropdown", "items": ["Windowed", "Borderless", "Fullscreen"], "desc": "Set the window display mode."},
		{"id": "resolution", "name": "Resolution", "type": "dropdown", "items": ["1280x720", "1600x900", "1920x1080"], "desc": "Screen resolution. Applicable in Windowed/Borderless."},
		{"id": "vsync", "name": "VSync", "type": "dropdown", "items": ["Off", "On"], "desc": "Synchronizes the game's frame output with the display refresh rate."},
		{"id": "fps_limit", "name": "FPS Limit", "type": "dropdown", "items": ["Unlimited", "30", "60", "120"], "desc": "Maximum frames per second."},
		{"id": "brightness", "name": "Brightness", "type": "slider", "min": 0.5, "max": 1.5, "step": 0.1, "desc": "Adjust global screen brightness."}
	],
	"AUDIO": [
		{"id": "vol_master", "name": "Master Volume", "type": "slider", "min": 0, "max": 100, "step": 5, "desc": "Overall game volume."},
		{"id": "vol_music", "name": "Music Volume", "type": "slider", "min": 0, "max": 100, "step": 5, "desc": "Background music volume."},
		{"id": "vol_sfx", "name": "SFX Volume", "type": "slider", "min": 0, "max": 100, "step": 5, "desc": "Sound effects volume."}
	],
	"CONTROLS": [
		{"id": "placeholder", "name": "Key Rebinding", "type": "label", "text": "Coming Later", "desc": "Control mapping will be available soon."}
	]
}

# Resolutions map
var res_map = [Vector2(1280, 720), Vector2(1600, 900), Vector2(1920, 1080)]
var fps_map = [0, 30, 60, 120]

func _init() -> void:
	layer = 150
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _ready() -> void:
	_select_category("GAME")

func _build_ui() -> void:
	bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.12, 0.98)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var title = Label.new()
	title.text = "SETTINGS"
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	title.position = Vector2(0, 30)
	title.size = Vector2(1280, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	var hint = Label.new()
	hint.text = "[X/Back] Close and Save   [Enter/Click] Interact"
	hint.add_theme_font_size_override("font_size", 16)
	hint.position = Vector2(0, 680)
	hint.size = Vector2(1280, 30)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)
	
	var hbox = HBoxContainer.new()
	hbox.position = Vector2(140, 120)
	hbox.size = Vector2(1000, 500)
	hbox.add_theme_constant_override("separation", 50)
	add_child(hbox)
	
	# Left Category
	var left_panel = VBoxContainer.new()
	left_panel.custom_minimum_size = Vector2(250, 0)
	left_panel.add_theme_constant_override("separation", 20)
	hbox.add_child(left_panel)
	
	for cat in ["GAME", "GRAPHICS", "AUDIO", "CONTROLS"]:
		var btn = Button.new()
		btn.text = cat
		btn.add_theme_font_size_override("font_size", 24)
		btn.custom_minimum_size = Vector2(0, 50)
		btn.pressed.connect(func(): _select_category(cat))
		left_panel.add_child(btn)
		
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_panel.add_child(spacer)
	
	var btn_defaults = Button.new()
	btn_defaults.text = "RESTORE DEFAULTS"
	btn_defaults.add_theme_font_size_override("font_size", 20)
	btn_defaults.custom_minimum_size = Vector2(0, 50)
	btn_defaults.pressed.connect(_on_restore_defaults)
	left_panel.add_child(btn_defaults)
	
	# Right Content
	var right_panel = VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(right_panel)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_panel.add_child(scroll)
	
	content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 25)
	scroll.add_child(content_vbox)
	
	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 2)
	sep.color = Color(0.4, 0.4, 0.4)
	right_panel.add_child(sep)
	
	desc_label = Label.new()
	desc_label.custom_minimum_size = Vector2(0, 60)
	desc_label.add_theme_font_size_override("font_size", 18)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	right_panel.add_child(desc_label)

func _select_category(cat: String) -> void:
	_active_category = cat
	for child in content_vbox.get_children():
		child.queue_free()
	
	desc_label.text = ""
	
	var opt_list = _options[cat]
	for opt in opt_list:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var lbl = Label.new()
		lbl.text = opt["name"]
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.custom_minimum_size = Vector2(250, 0)
		row.add_child(lbl)
		
		var val_node = _create_control_for_option(opt)
		if val_node:
			val_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			# Mouse hover event untuk merubah description
			val_node.mouse_entered.connect(func(): desc_label.text = opt["desc"])
			val_node.focus_entered.connect(func(): desc_label.text = opt["desc"])
			row.add_child(val_node)
			
		content_vbox.add_child(row)

func _create_control_for_option(opt: Dictionary) -> Control:
	if opt["type"] == "label":
		var lbl = Label.new()
		lbl.text = opt["text"]
		lbl.add_theme_font_size_override("font_size", 22)
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		lbl.focus_mode = Control.FOCUS_ALL # Boleh difocus agar deskripsi tampil
		return lbl
		
	elif opt["type"] == "dropdown":
		var ob = OptionButton.new()
		for item in opt["items"]:
			ob.add_item(item)
		
		_apply_current_value_to_dropdown(opt["id"], ob)
		ob.item_selected.connect(func(idx): _on_option_changed(opt["id"], idx))
		return ob
		
	elif opt["type"] == "slider":
		var hb = HBoxContainer.new()
		var sl = HSlider.new()
		sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		sl.min_value = opt["min"]
		sl.max_value = opt["max"]
		sl.step = opt["step"]
		
		var val_lbl = Label.new()
		val_lbl.custom_minimum_size = Vector2(60, 0)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		_apply_current_value_to_slider(opt["id"], sl, val_lbl)
		sl.value_changed.connect(func(val): _on_slider_changed(opt["id"], val, val_lbl))
		
		hb.add_child(sl)
		hb.add_child(val_lbl)
		# Forward hover/focus signals dari slider ke container
		sl.mouse_entered.connect(func(): hb.emit_signal("mouse_entered"))
		sl.focus_entered.connect(func(): hb.emit_signal("focus_entered"))
		
		return hb
		
	return null

func _apply_current_value_to_dropdown(id: String, ob: OptionButton) -> void:
	var val = SettingsManager.get_setting(id)
	
	if id == "resolution":
		var res = val as Vector2
		var idx = res_map.find(res)
		ob.selected = idx if idx >= 0 else 0
	elif id == "fps_limit":
		var fps = val as int
		var idx = fps_map.find(fps)
		ob.selected = idx if idx >= 0 else 0
	elif id == "vsync":
		ob.selected = 1 if val else 0
	else:
		# Enums map directly to index
		ob.selected = val as int

func _apply_current_value_to_slider(id: String, sl: HSlider, lbl: Label) -> void:
	var val = SettingsManager.get_setting(id)
	sl.value = val
	lbl.text = str(val)

func _on_option_changed(id: String, idx: int) -> void:
	var new_val = idx
	
	if id == "resolution":
		new_val = res_map[idx]
	elif id == "fps_limit":
		new_val = fps_map[idx]
	elif id == "vsync":
		new_val = (idx == 1)
		
	SettingsManager.set_setting(id, new_val)
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

func _on_slider_changed(id: String, val: float, lbl: Label) -> void:
	lbl.text = str(val)
	SettingsManager.set_setting(id, val)
	SettingsManager.apply_all_settings()
	SettingsManager.save_settings()

func _on_restore_defaults() -> void:
	SettingsManager.restore_defaults()
	_select_category(_active_category) # Refresh UI

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
