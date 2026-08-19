extends CharacterBody2D

## Player — menangani input movement, physics, dan interaksi.
## Camera2D sebagai child mengikuti player secara otomatis.
## M70: Menyediakan API kamera untuk konfigurasi batas dan reset smoothing.

signal interactable_detected(interactable: Interactable)
signal interactable_undetected()

@export var move_speed: float = 150.0

@onready var interaction_detector: Area2D = $InteractionDetector
@onready var _camera: Camera2D = $Camera2D

var current_interactable: Interactable = null
var is_locked: bool = false
var facing: StringName = &"down"

# M25: Debug save/load feedback
var _save_feedback_label: Label = null
var _feedback_timer: Timer = null


func _ready() -> void:
	add_to_group("player")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	# Hubungkan sinyal dari DialogueManager
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	PartyManager.party_ui_toggled.connect(_on_party_ui_toggled)
	# M25: Setup feedback label
	_setup_save_feedback()
	# M70: Zoom lock — pastikan zoom tidak mewarisi nilai editor yang berbeda
	_camera.zoom = Vector2.ONE


func _physics_process(_delta: float) -> void:
	if is_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# --- MOVEMENT LOGIC ---
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction.length_squared() > 0.0:
		if abs(direction.x) > abs(direction.y):
			facing = &"right" if direction.x > 0 else &"left"
		else:
			facing = &"down" if direction.y > 0 else &"up"

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
# M70 — CAMERA API
# ==============================================================

## Konfigurasi batas Camera2D berdasarkan Rect2 yang diberikan oleh world aktif.
## Harus dipanggil oleh Main setelah setiap world swap, load, atau battle return,
## SETELAH player.global_position sudah diset ke posisi spawn yang benar.
func configure_camera_bounds(bounds: Rect2) -> void:
	if not is_node_ready():
		await ready
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		push_warning("[Player/Camera] camera_bounds tidak valid dari world aktif (size=%s). Menggunakan fallback: limit tidak terbatas." % str(bounds.size))
		# Fallback aman: nonaktifkan limit finite agar tidak mewarisi batas world sebelumnya.
		# Menggunakan nilai default Godot Camera2D (limit besar / tidak terbatas).
		_camera.limit_left   = -10000000
		_camera.limit_top    = -10000000
		_camera.limit_right  =  10000000
		_camera.limit_bottom =  10000000
		return
	# Konversi Rect2 lokal world ke koordinat global.
	# Karena world_node selalu di-add sebagai child of Main (Node2D di (0,0)),
	# dan tidak pernah di-rotate/scale, koordinat lokal = global.
	# Jika arsitektur berubah, tambahkan konversi global_transform di sini.
	_camera.limit_left   = int(bounds.position.x)
	_camera.limit_top    = int(bounds.position.y)
	_camera.limit_right  = int(bounds.position.x + bounds.size.x)
	_camera.limit_bottom = int(bounds.position.y + bounds.size.y)


## Reset smoothing kamera setelah teleport (SpawnMarker arrival, load, battle return).
## Mencegah kamera meluncur secara visual dari posisi world lama.
## Harus dipanggil SETELAH configure_camera_bounds dan SETELAH player.global_position diset.
func reset_camera_after_teleport() -> void:
	if not is_node_ready():
		await ready
	# Godot 4 Camera2D: memanggil reset_smoothing() menghapus posisi internal
	# smoothing sehingga kamera langsung snap ke posisi player saat ini.
	_camera.reset_smoothing()


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

	_feedback_timer = Timer.new()
	_feedback_timer.one_shot = true
	_feedback_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_feedback_timer.timeout.connect(_on_feedback_timeout)
	add_child(_feedback_timer)

func _show_save_feedback(msg: String) -> void:
	if _save_feedback_label:
		_save_feedback_label.text = msg
		_save_feedback_label.visible = true
		_feedback_timer.start(2.5)

func _on_feedback_timeout() -> void:
	if _save_feedback_label:
		_save_feedback_label.visible = false
