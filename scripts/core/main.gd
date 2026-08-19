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
		var saved_location: String = SaveManager._pending_data.get("world", {}).get("location_scene", "")
		if saved_location != "" and ResourceLoader.exists(saved_location):
			# Swap ke lokasi yang disimpan sebelum apply koordinat
			var swapped := _swap_world(saved_location)
			if not swapped:
				push_error("[Main] Gagal swap ke saved location: " + saved_location)
				# Tetap lanjutkan dengan world default yang terpasang
		# SaveManager.apply_pending_load menangani koordinat X/Y dan current_world_scene
		SaveManager.apply_pending_load(player)
		return

	# 2. M67 TARGET SPAWN — Transisi lokasi baru (preflight sudah dilakukan di TransitionZone)
	if GameManager.target_world_scene != "":
		var scene_to_load := GameManager.target_world_scene
		var spawn_id_to_find := GameManager.target_spawn_id

		# Swap jika bukan scene dunia default yang sudah terpasang
		if scene_to_load != GameManager.DEFAULT_WORLD_SCENE:
			var swapped := _swap_world(scene_to_load)
			if not swapped:
				push_error("[Main] Gagal swap ke target world scene: " + scene_to_load)
				# Jangan update current_world_scene dengan lokasi yang gagal di-load
				GameManager.target_world_scene = ""
				GameManager.target_spawn_id = ""
				return

		# HANYA update current_world_scene setelah swap berhasil
		GameManager.current_world_scene = scene_to_load

		# Temukan SpawnMarker
		if spawn_id_to_find != "":
			var spawn := _find_spawn_marker(world_node, spawn_id_to_find)
			if spawn:
				player.global_position = spawn.global_position
			else:
				# Preflight seharusnya sudah mencegah ini — ini hanya path defensif
				push_error("[Main] SpawnMarker tidak ditemukan (defensive): " + spawn_id_to_find)
				# Jangan pindahkan pemain ke Vector2.ZERO
				# Jangan simpan lokasi yang gagal sebagai current
				GameManager.current_world_scene = GameManager.DEFAULT_WORLD_SCENE

		# Konsumsi state transisi tertunda dalam semua kasus
		GameManager.target_world_scene = ""
		GameManager.target_spawn_id = ""
		return

	# 3. BATTLE RETURN — Kembali dari pertarungan ke lokasi aktif sebelumnya
	if GameManager.player_return_position != Vector2.ZERO:
		# Pastikan lokasi dunia yang benar ter-load (mungkin bukan default)
		if GameManager.current_world_scene != GameManager.DEFAULT_WORLD_SCENE:
			var swapped := _swap_world(GameManager.current_world_scene)
			if not swapped:
				push_error("[Main] Gagal swap ke current world scene saat battle return: " + GameManager.current_world_scene)
				# Fallback ke default — lebih aman daripada crash
				GameManager.current_world_scene = GameManager.DEFAULT_WORLD_SCENE
		player.global_position = GameManager.player_return_position
		return

	# 4. DEFAULT — New game atau boot pertama
	# world_node sudah terpasang sebagai world.tscn di .tscn file
	GameManager.current_world_scene = GameManager.DEFAULT_WORLD_SCENE


func _swap_world(new_scene_path: String) -> bool:
	## Ganti node World dengan scene lokasi baru secara transaksional.
	## Membuktikan scene dapat dimuat sebelum menghapus yang lama.
	## Mengembalikan true jika berhasil, false jika gagal (lama tetap aman).

	# 1. Validasi resource ada
	if not ResourceLoader.exists(new_scene_path):
		push_error("[Main] _swap_world: scene tidak ditemukan: " + new_scene_path)
		return false

	# 2. Muat PackedScene
	var packed := load(new_scene_path) as PackedScene
	if packed == null:
		push_error("[Main] _swap_world: gagal memuat PackedScene: " + new_scene_path)
		return false

	# 3. Instantiasi terlebih dahulu sebelum membebaskan yang lama
	var new_node := packed.instantiate()
	if new_node == null:
		push_error("[Main] _swap_world: instantiate() gagal untuk: " + new_scene_path)
		return false

	# 4. HANYA SEKARANG hapus world lama
	world_node.queue_free()

	# 5. Tambahkan world baru
	world_node = new_node
	add_child(world_node)
	move_child(world_node, 0)

	return true


func _find_spawn_marker(node: Node, id: String) -> Marker2D:
	if node is SpawnMarker and node.spawn_id == id:
		return node
	for child in node.get_children():
		var found := _find_spawn_marker(child, id)
		if found:
			return found
	return null
