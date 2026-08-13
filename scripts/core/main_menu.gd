extends Control

## MainMenu — M26: Entry point game Holuf.
## Menampilkan pilihan: New Game, Continue, Load Game, Settings, Credits, Quit.
## UI placeholder sederhana, mudah diganti art final nanti.

var _is_loading: bool = false

# Button references
var _btn_new_game: Button
var _btn_continue: Button
var _btn_load: Button
var _btn_settings: Button
var _btn_credits: Button
var _btn_quit: Button

# Load Game panel
var _load_panel: PanelContainer
var _load_slot_label: Label
var _btn_load_slot: Button

func _ready() -> void:
	_build_ui()
	_refresh_save_state()

# ==============================================================
# BUILD UI
# ==============================================================

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	# Dark background
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Center container for menu
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.custom_minimum_size = Vector2(320, 0)
	center.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "HOLUF"
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 32)
	vbox.add_child(spacer)

	# Buttons
	_btn_new_game  = _make_button("NEW GAME",  vbox)
	_btn_continue  = _make_button("CONTINUE",  vbox)
	_btn_load      = _make_button("LOAD GAME", vbox)
	_btn_settings  = _make_button("SETTINGS",  vbox)
	_btn_credits   = _make_button("CREDITS",   vbox)
	_btn_quit      = _make_button("QUIT",       vbox)

	_btn_credits.disabled = true
	_btn_credits.text += " (Coming Later)"
	
	_btn_new_game.pressed.connect(_on_new_game)
	_btn_continue.pressed.connect(_on_continue)
	_btn_load.pressed.connect(_on_load_menu)
	_btn_settings.pressed.connect(_on_settings_pressed)
	_btn_quit.pressed.connect(_on_quit)

	# Load Game panel (hidden)
	_load_panel = _build_load_panel()
	add_child(_load_panel)
	_load_panel.hide()

func _make_button(label: String, parent: Node) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_size_override("font_size", 22)
	btn.custom_minimum_size = Vector2(320, 52)
	parent.add_child(btn)
	return btn

func _build_load_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)

	var dark := ColorRect.new()
	dark.color = Color(0, 0, 0, 0.85)
	dark.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(dark)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.custom_minimum_size = Vector2(380, 0)
	center.add_child(vbox)

	var header := Label.new()
	header.text = "LOAD GAME"
	header.add_theme_font_size_override("font_size", 36)
	header.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	_load_slot_label = Label.new()
	_load_slot_label.text = "SAVE 01"
	_load_slot_label.add_theme_font_size_override("font_size", 20)
	_load_slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_load_slot_label)

	_btn_load_slot = _make_button("LOAD", vbox)
	_btn_load_slot.pressed.connect(_on_continue)  # Same pipeline as Continue

	var btn_back := _make_button("BACK", vbox)
	btn_back.pressed.connect(_on_load_back)

	return panel

# ==============================================================
# SAVE STATE
# ==============================================================

func _refresh_save_state() -> void:
	var has_save := SaveManager.has_save()
	_btn_continue.disabled = not has_save

	if _load_slot_label:
		if has_save:
			_load_slot_label.text = "SAVE 01"
			_btn_load_slot.disabled = false
		else:
			_load_slot_label.text = "No save data found."
			_btn_load_slot.disabled = true

	# Set initial focus
	if has_save:
		_btn_continue.grab_focus()
	else:
		_btn_new_game.grab_focus()

# ==============================================================
# BUTTON HANDLERS
# ==============================================================

func _on_new_game() -> void:
	if _is_loading: return
	_is_loading = true
	_set_buttons_disabled(true)
	SaveManager.start_new_game()

func _on_continue() -> void:
	if _is_loading: return
	if not SaveManager.has_save(): return
	_is_loading = true
	_set_buttons_disabled(true)
	var ok := SaveManager.load_game()
	if not ok:
		# Load failed — stay on menu
		_is_loading = false
		_set_buttons_disabled(false)
		_load_panel.hide()

func _on_load_menu() -> void:
	if _is_loading: return
	_load_panel.show()
	if _btn_load_slot and not _btn_load_slot.disabled:
		_btn_load_slot.grab_focus()

func _on_load_back() -> void:
	if _is_loading: return
	_load_panel.hide()
	_refresh_save_state()

func _on_settings_pressed() -> void:
	if _is_loading: return
	if not has_node("SettingsUI"):
		var SettingsUI = load("res://scenes/ui/settings_ui.tscn")
		var inst = SettingsUI.instantiate()
		inst.name = "SettingsUI"
		inst.tree_exited.connect(_on_settings_closed)
		add_child(inst)
		# Hide the center container (Main Menu content) while Settings is open
		get_child(1).hide() # center container is child index 1 (after bg ColorRect)

func _on_settings_closed() -> void:
	get_child(1).show()
	_btn_settings.grab_focus()

func _on_quit() -> void:
	get_tree().quit()

# ==============================================================
# HELPERS
# ==============================================================

func _set_buttons_disabled(val: bool) -> void:
	_btn_new_game.disabled = val
	_btn_continue.disabled = val or not SaveManager.has_save()
	_btn_load.disabled = val
	_btn_quit.disabled = val

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _load_panel.visible:
		get_viewport().set_input_as_handled()
		_on_load_back()
