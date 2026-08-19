extends CanvasLayer

## TransitionManager — Autoload untuk transisi fade sederhana antar scene.

@onready var color_rect: ColorRect = $ColorRect

var _is_transitioning: bool = false

func _ready() -> void:
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.hide()


func _input(_event: InputEvent) -> void:
	if _is_transitioning:
		get_viewport().set_input_as_handled()

func transition_to_scene(path: String) -> bool:
	if _is_transitioning:
		push_warning("[TransitionManager] Transition already in progress. Ignoring request to: " + path)
		return false
		
	if not ResourceLoader.exists(path):
		push_error("[TransitionManager] Cannot transition to missing scene: " + path)
		return false
		
	_is_transitioning = true
	get_tree().root.gui_disable_input = true
	
	color_rect.show()
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.4)
	await tween.finished
	
	# Pindah scene
	var err = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("[TransitionManager] Failed to change scene to " + path + " with error code: " + str(err))
		# Recovery
		tween = create_tween()
		tween.tween_property(color_rect, "color:a", 0.0, 0.4)
		await tween.finished
		color_rect.hide()
		get_tree().root.gui_disable_input = false
		_is_transitioning = false
		return false
	
	# Tunggu satu frame agar scene baru selesai _ready
	await get_tree().process_frame
	
	# Fade from black
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 0.4)
	await tween.finished
	
	color_rect.hide()
	
	get_tree().root.gui_disable_input = false
	_is_transitioning = false
	
	# Reset flag transition di GameManager jika ada
	if GameManager.is_transitioning:
		GameManager.is_transitioning = false
		
	return true
