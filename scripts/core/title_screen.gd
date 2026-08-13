extends Control

## TitleScreen — M28: Entry point game Holuf.
## Menunggu input "Press Any Key" sebelum masuk ke Main Menu.

var _is_transitioning: bool = false
var _prompt_label: Label
var _pulse_tween: Tween

func _ready() -> void:
	# BGM bisa ditambahkan di sini nantinya
	_build_ui()
	_start_pulse()

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Background placeholder
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.02, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var title = Label.new()
	title.text = "HOLUF"
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.position = Vector2(-200, -150)
	title.size = Vector2(400, 100)
	add_child(title)
	
	_prompt_label = Label.new()
	_prompt_label.text = "PRESS ANY KEY"
	_prompt_label.add_theme_font_size_override("font_size", 28)
	_prompt_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.set_anchors_preset(Control.PRESET_CENTER)
	_prompt_label.position = Vector2(-200, 50)
	_prompt_label.size = Vector2(400, 50)
	add_child(_prompt_label)

func _start_pulse() -> void:
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(_prompt_label, "modulate:a", 0.3, 1.0)
	_pulse_tween.tween_property(_prompt_label, "modulate:a", 1.0, 1.0)

func _input(event: InputEvent) -> void:
	if _is_transitioning:
		get_viewport().set_input_as_handled()
		return
		
	var is_valid_input = false
	
	if event is InputEventKey:
		# Abaikan echo supaya holding key tidak spam
		if event.pressed and not event.echo:
			is_valid_input = true
			
	elif event is InputEventMouseButton:
		if event.pressed:
			is_valid_input = true
			
	elif event is InputEventJoypadButton:
		if event.pressed:
			is_valid_input = true
			
	if is_valid_input:
		_is_transitioning = true
		get_viewport().set_input_as_handled()
		TransitionManager.transition_to_scene("res://scenes/main/main_menu.tscn")
