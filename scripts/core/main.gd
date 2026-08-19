extends Node2D

## Main — entry point game HOLUF.
## Bertanggung jawab sebagai root scene dan mengatur komponen utama:
## World dan Player. Jangan tambahkan logika gameplay di sini.

@onready var player = $Player
@onready var world_node = $World

func _ready() -> void:
	# M67: Tentukan scene lokasi dunia yang akan diaktifkan.
	# Prioritas: Manual Load → Target World Transition → Battle Return → Default

	# 1. MANUAL SAVE PENDING LOAD — SaveManager mendominasi seluruhnya
	if SaveManager._has_pending_load:
		var saved_location = SaveManager._pending_data.get("world", {}).get("location_scene", "")
		if saved_location != "" and ResourceLoader.exists(saved_location):
			_swap_world(saved_location)
		# SaveManager.apply_pending_load menangani posisi koordinat
		SaveManager.apply_pending_load(player)
		return

	# 2. M67 TARGET SPAWN — Transisi lokasi baru
	if GameManager.target_world_scene != "":
		var scene_to_load = GameManager.target_world_scene
		var spawn_id_to_find = GameManager.target_spawn_id
		
		# Swap jika bukan scene dunia default yang sudah terpasang
		if scene_to_load != GameManager.DEFAULT_WORLD_SCENE:
			_swap_world(scene_to_load)
		
		# Update lokasi aktif
		GameManager.current_world_scene = scene_to_load
		
		# Temukan SpawnMarker
		if spawn_id_to_find != "":
			var spawn = _find_spawn_marker(world_node, spawn_id_to_find)
			if spawn:
				player.global_position = spawn.global_position
			else:
				push_error("[Main] SpawnMarker tidak ditemukan dengan id: " + spawn_id_to_find)
				# Jangan pindahkan pemain ke Vector2.ZERO — biarkan di posisi bawaan editor
		
		# Konsumsi state transisi tertunda
		GameManager.target_world_scene = ""
		GameManager.target_spawn_id = ""
		return

	# 3. BATTLE RETURN — Kembali dari pertarungan ke lokasi aktif sebelumnya
	if GameManager.player_return_position != Vector2.ZERO:
		# Pastikan lokasi dunia yang benar ter-load (mungkin bukan default)
		if GameManager.current_world_scene != GameManager.DEFAULT_WORLD_SCENE:
			_swap_world(GameManager.current_world_scene)
		player.global_position = GameManager.player_return_position
		return

	# 4. DEFAULT — New game atau boot pertama
	# world_node sudah terpasang sebagai world.tscn di .tscn file
	GameManager.current_world_scene = GameManager.DEFAULT_WORLD_SCENE


func _swap_world(new_scene_path: String) -> void:
	## Ganti node World dengan scene lokasi baru.
	world_node.queue_free()
	var packed = load(new_scene_path)
	if packed == null:
		push_error("[Main] Gagal memuat scene lokasi: " + new_scene_path)
		# Buat node kosong sebagai fallback aman
		world_node = Node2D.new()
		add_child(world_node)
		move_child(world_node, 0)
		return
	world_node = packed.instantiate()
	add_child(world_node)
	move_child(world_node, 0)


func _find_spawn_marker(node: Node, id: String) -> Marker2D:
	if node is SpawnMarker and node.spawn_id == id:
		return node
	for child in node.get_children():
		var found = _find_spawn_marker(child, id)
		if found:
			return found
	return null
