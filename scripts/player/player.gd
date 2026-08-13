extends CharacterBody2D

## Player — menangani input movement, physics, dan interaksi.
## Camera2D sebagai child mengikuti player secara otomatis.

signal interactable_detected(interactable: Interactable)
signal interactable_undetected()

@export var move_speed: float = 150.0

@onready var interaction_detector: Area2D = $InteractionDetector

var current_interactable: Interactable = null
var is_locked: bool = false

# M25: Debug save/load feedback
var _save_feedback_label: Label = null
var _feedback_timer: float = 0.0


func _ready() -> void:
	add_to_group("player")
	# Hubungkan sinyal dari DialogueManager
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	PartyManager.party_ui_toggled.connect(_on_party_ui_toggled)
	# M25: Setup feedback label
	_setup_save_feedback()


func _physics_process(_delta: float) -> void:
	# M25: Feedback timer tick
	if _feedback_timer > 0.0:
		_feedback_timer -= _delta
		if _feedback_timer <= 0.0 and _save_feedback_label:
			_save_feedback_label.visible = false

	if is_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# --- MOVEMENT LOGIC ---
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")

	if direction.length() > 0.0:
		direction = direction.normalized()

	velocity = direction * move_speed
	var old_pos = global_position
	move_and_slide()
	var walked = global_position.distance_to(old_pos)
	if walked > 0.0:
		EncounterManager.add_distance(walked)

	# --- INTERACTION DETECTION ---
	_update_interaction()


func _unhandled_input(event: InputEvent) -> void:
	# M25: Debug Save (B)
	if event.is_action_pressed("debug_save_game"):
		get_viewport().set_input_as_handled()
		if SaveManager.save_game(self):
			_show_save_feedback("Game Saved!")
		else:
			_show_save_feedback("Save Failed!")
		return

	# M25: Debug Load (N)
	if event.is_action_pressed("debug_load_game"):
		get_viewport().set_input_as_handled()
		if not SaveManager.has_save():
			_show_save_feedback("No save data found.")
			return
		var ok = SaveManager.load_game()
		if not ok:
			_show_save_feedback("Load Failed!")
		return

	if event.is_action_pressed("party_menu"):
		if not is_locked and PartyManager.ui_instance == null:
			PartyManager.open_party_ui()
			get_viewport().set_input_as_handled()
		elif PartyManager.ui_instance != null:
			# Esc or P will be handled by UI, but we can also close it here if P is pressed again
			# Actually PartyUI handles ESC, but let's let PartyUI handle closing itself via P too or handle it here
			pass

	if is_locked:
		return

	if event.is_action_pressed("interact"):
		if current_interactable != null:
			current_interactable.interact(self)


func _update_interaction() -> void:
	var overlaps := interaction_detector.get_overlapping_areas()
	var closest_interactable: Interactable = null
	var min_distance := INF

	for area in overlaps:
		if area is Interactable:
			var dist := global_position.distance_to(area.global_position)
			if dist < min_distance:
				min_distance = dist
				closest_interactable = area

	if closest_interactable != current_interactable:
		current_interactable = closest_interactable
		if current_interactable != null:
			interactable_detected.emit(current_interactable)
		else:
			interactable_undetected.emit()


func _on_dialogue_started(_speaker_name: String) -> void:
	is_locked = true
	# Bersihkan deteksi interactable ketika mulai dialog agar prompt hilang
	current_interactable = null
	interactable_undetected.emit()


func _on_dialogue_ended() -> void:
	is_locked = false

func _on_party_ui_toggled(is_open: bool) -> void:
	is_locked = is_open
	if is_open:
		current_interactable = null
		interactable_undetected.emit()

# ==============================================================
# M25 — SAVE/LOAD FEEDBACK
# ==============================================================

func _setup_save_feedback() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 200
	add_child(canvas)

	_save_feedback_label = Label.new()
	_save_feedback_label.visible = false
	_save_feedback_label.add_theme_font_size_override("font_size", 24)
	_save_feedback_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.5))
	_save_feedback_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_save_feedback_label.position = Vector2(-160, 30)
	_save_feedback_label.size = Vector2(320, 40)
	_save_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	canvas.add_child(_save_feedback_label)

func _show_save_feedback(msg: String) -> void:
	if _save_feedback_label:
		_save_feedback_label.text = msg
		_save_feedback_label.visible = true
		_feedback_timer = 2.5
