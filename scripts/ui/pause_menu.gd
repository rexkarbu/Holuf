extends CanvasLayer

## PauseMenu — M27: Pause Menu Foundation.
## Hanya digunakan di world/exploration.
## process_mode diset ke PROCESS_MODE_ALWAYS agar menerima input saat paused.

var _panel: Control
var _btn_resume: Button
var _btn_party: Button
var _btn_inventory: Button
var _btn_equipment: Button
var _btn_quest: Button
var _btn_combat_guide: Button
var _btn_settings: Button
var _btn_return: Button

var _confirm_dialog: ConfirmationDialog

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 50
	
	_build_ui()
	hide() # Tersembunyi secara default
	
	PartyManager.party_ui_toggled.connect(_on_party_ui_toggled)

# ==============================================================
# BUILD UI
# ==============================================================

func _build_ui() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)
	
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(overlay)
	
	var title = Label.new()
	title.text = "PAUSED"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 50)
	title.size = Vector2(1280, 60)
	_panel.add_child(title)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	vbox.custom_minimum_size = Vector2(300, 0)
	center.add_child(vbox)
	
	_btn_resume     = _make_button("RESUME", vbox)
	_btn_party      = _make_button("PARTY", vbox)
	_btn_inventory  = _make_button("INVENTORY", vbox)
	_btn_equipment  = _make_button("EQUIPMENT", vbox)
	_btn_quest      = _make_button("QUEST", vbox)
	_btn_combat_guide = _make_button("COMBAT GUIDE", vbox)
	_btn_settings   = _make_button("SETTINGS", vbox)
	_btn_return     = _make_button("RETURN TO MAIN MENU", vbox)
	
	# M30: Equipment sekarang aktif
	# M27: Quest masih placeholder
	_btn_combat_guide.pressed.connect(_on_combat_guide_pressed)
	_btn_quest.disabled = true
	_btn_quest.text += " (Coming Later)"
	
	_btn_resume.pressed.connect(_on_resume_pressed)
	_btn_party.pressed.connect(_on_party_pressed)
	_btn_inventory.pressed.connect(_on_inventory_pressed)
	_btn_equipment.pressed.connect(_on_equipment_pressed)
	_btn_settings.pressed.connect(_on_settings_pressed)
	_btn_return.pressed.connect(_on_return_pressed)
	
	_build_confirmation()

func _make_button(lbl: String, parent: Node) -> Button:
	var btn = Button.new()
	btn.text = lbl
	btn.add_theme_font_size_override("font_size", 22)
	btn.custom_minimum_size = Vector2(300, 50)
	parent.add_child(btn)
	return btn

func _build_confirmation() -> void:
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Return to Main Menu?"
	_confirm_dialog.dialog_text = "Unsaved progress since your last save will be lost."
	_confirm_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	_confirm_dialog.size = Vector2(400, 150)
	add_child(_confirm_dialog)
	
	_confirm_dialog.confirmed.connect(_on_return_confirmed)

# ==============================================================
# INPUT & TOGGLE
# ==============================================================

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		if visible:
			# Jika child UI terbuka, abaikan input ESC agar tidak menutup pause menu
			if has_node("SettingsUI") or has_node("EquipmentUI") or has_node("InventoryUI") or has_node("CombatHelpGuide"):
				return
			
			# Jika Confirmation terbuka, ui_cancel akan menutup dialog itu otomatis,
			# tapi ESC jangan menutup menu pause.
			if _confirm_dialog.visible:
				return
				
			if PartyManager.ui_instance != null:
				return
			
			get_viewport().set_input_as_handled()
			_close_pause()
		else:
			# Jangan pause jika ada modal lain terbuka
			if not _can_open_pause():
				return
			
			get_viewport().set_input_as_handled()
			_open_pause()

func _can_open_pause() -> bool:
	# Cek apakah Dialogue sedang aktif
	if DialogueManager.is_dialogue_active:
		return false
	
	# Cek apakah sedang transisi scene
	if GameManager.is_transitioning:
		return false
	
	# Cek apakah Party UI sudah terbuka (ini sbg pengaman tambahan)
	if PartyManager.ui_instance != null:
		return false
	
	return true

func _open_pause() -> void:
	show()
	get_tree().paused = true
	_btn_resume.grab_focus()

func _close_pause() -> void:
	hide()
	get_tree().paused = false

func _on_party_ui_toggled(is_open: bool) -> void:
	if is_open:
		_panel.process_mode = Node.PROCESS_MODE_DISABLED
		var focused = get_viewport().gui_get_focus_owner()
		if focused and _panel.is_ancestor_of(focused):
			focused.release_focus()
	else:
		_panel.process_mode = Node.PROCESS_MODE_INHERIT
		if visible:
			_btn_party.grab_focus()

# ==============================================================
# BUTTON HANDLERS
# ==============================================================

func _on_resume_pressed() -> void:
	_close_pause()

func _on_party_pressed() -> void:
	PartyManager.open_party_ui()

func _on_inventory_pressed() -> void:
	if not has_node("InventoryUI"):
		var inv_ui = load("res://scripts/ui/inventory_ui.gd")
		var inst = inv_ui.new()
		inst.name = "InventoryUI"
		inst.tree_exited.connect(_on_inventory_closed)
		add_child(inst)
		_panel.hide()

func _on_settings_pressed() -> void:
	if not has_node("SettingsUI"):
		var SettingsUI = load("res://scenes/ui/settings_ui.tscn")
		var inst = SettingsUI.instantiate()
		inst.name = "SettingsUI"
		inst.tree_exited.connect(_on_settings_closed)
		add_child(inst)
		_panel.hide()

func _on_equipment_pressed() -> void:
	if not has_node("EquipmentUI"):
		var eq_ui = load("res://scripts/ui/equipment_ui.gd")
		var inst = eq_ui.new()
		inst.name = "EquipmentUI"
		inst.tree_exited.connect(_on_equipment_closed)
		add_child(inst)
		_panel.hide()

func _on_equipment_closed() -> void:
	_panel.show()
	_btn_equipment.grab_focus()

func _on_inventory_closed() -> void:
	_panel.show()
	_btn_inventory.grab_focus()

func _on_settings_closed() -> void:
	_panel.show()
	_btn_settings.grab_focus()

func _on_return_pressed() -> void:
	_confirm_dialog.popup_centered()

func _on_return_confirmed() -> void:
	_close_pause()
	TransitionManager.transition_to_scene("res://scenes/main/main_menu.tscn")

func _on_combat_guide_pressed() -> void:
	if not has_node("CombatHelpGuide"):
		var guide_scene = load("res://scenes/ui/combat_help_guide.tscn")
		var inst = guide_scene.instantiate()
		inst.name = "CombatHelpGuide"
		inst.closed.connect(_on_combat_guide_closed)
		add_child(inst)
		_panel.hide()
		inst.open_full_guide()

func _on_combat_guide_closed() -> void:
	_panel.show()
	_btn_combat_guide.grab_focus()
	if has_node("CombatHelpGuide"):
		get_node("CombatHelpGuide").queue_free()

