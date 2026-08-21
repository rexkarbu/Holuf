extends Node2D

## CaeloraTestHarness — Standalone test runner untuk pengujian traversal M76.
## Memungkinkan menjalankan pengujian in-game langsung (F6) tanpa mengedit project.godot atau main.tscn.

@export_file("*.tscn") var initial_world_scene: String = "res://scenes/world/elaris/caelora.tscn"
@export var initial_spawn_id: String = "spawn_default"

@onready var player: CharacterBody2D = $Player
@onready var world_container: Node2D = $WorldContainer

var current_world: Node2D = null


func _ready() -> void:
	# 1. Muat world scene
	if ResourceLoader.exists(initial_world_scene):
		var packed := load(initial_world_scene) as PackedScene
		if packed:
			current_world = packed.instantiate() as Node2D
			world_container.add_child(current_world)

	if current_world == null:
		push_error("[CaeloraTestHarness] Gagal memuat initial_world_scene: " + initial_world_scene)
		return

	# 2. Temukan spawn marker
	var spawn := _find_spawn_marker(current_world, initial_spawn_id)
	if spawn:
		player.global_position = spawn.global_position
	else:
		var fallback_spawn := _find_first_spawn_marker(current_world)
		if fallback_spawn:
			player.global_position = fallback_spawn.global_position
			push_warning("[CaeloraTestHarness] Marker '" + initial_spawn_id + "' tidak ditemukan, fallback ke: " + fallback_spawn.spawn_id)

	# 3. Terapkan API Kamera M70
	if current_world and "camera_bounds" in current_world:
		var bounds: Rect2 = current_world.camera_bounds
		if bounds.has_area():
			player.configure_camera_bounds(bounds)
			player.reset_camera_after_teleport()


func _find_spawn_marker(node: Node, id: String) -> SpawnMarker:
	if node is SpawnMarker and node.spawn_id == id:
		return node as SpawnMarker
	for child in node.get_children():
		var res := _find_spawn_marker(child, id)
		if res:
			return res
	return null


func _find_first_spawn_marker(node: Node) -> SpawnMarker:
	if node is SpawnMarker:
		return node as SpawnMarker
	for child in node.get_children():
		var res := _find_first_spawn_marker(child)
		if res:
			return res
	return null
