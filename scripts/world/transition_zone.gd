extends Area2D
class_name TransitionZone

## TransitionZone — Komponen generik untuk batas transisi lokasi bermakna.
## HANYA gunakan untuk perpindahan antar LOKASI yang berbeda,
## bukan untuk distrik dalam kota yang sama (lihat Seamless Place Rule).

@export_file("*.tscn") var destination_scene_path: String = ""
@export var target_spawn_id: String = ""

## Jika false, zona ini tidak memproses transisi (untuk digunakan M71 story-lock).
@export var is_enabled: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not is_enabled:
		return
	if not body.is_in_group("player"):
		return
	if destination_scene_path == "":
		push_error("[TransitionZone] Tidak ada destination_scene_path pada: " + name)
		return
	if GameManager.is_transitioning:
		return

	GameManager.is_transitioning = true
	GameManager.target_world_scene = destination_scene_path
	GameManager.target_spawn_id = target_spawn_id

	var success = await TransitionManager.transition_to_scene("res://scenes/main/main.tscn")
	if not success:
		# Kembalikan state agar tidak terjebak
		GameManager.is_transitioning = false
		GameManager.target_world_scene = ""
		GameManager.target_spawn_id = ""
