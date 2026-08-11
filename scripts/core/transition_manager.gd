extends CanvasLayer

## TransitionManager — Autoload untuk transisi fade sederhana antar scene.

@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.hide()


func transition_to_scene(path: String) -> void:
	color_rect.show()
	
	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.4)
	await tween.finished
	
	# Pindah scene
	get_tree().change_scene_to_file(path)
	
	# Tunggu satu frame agar scene baru selesai _ready
	await get_tree().process_frame
	
	# Fade from black
	tween = create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, 0.4)
	await tween.finished
	
	color_rect.hide()
	
	# Reset flag transition di GameManager jika ada
	if GameManager.is_transitioning:
		GameManager.is_transitioning = false
