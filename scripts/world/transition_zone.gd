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
	if GameManager.is_transitioning:
		return

	# === PREFLIGHT: Validasi sebelum meninggalkan lokasi saat ini ===

	# 1. target_spawn_id wajib untuk TransitionZone generik
	if target_spawn_id == "":
		push_error("[TransitionZone] target_spawn_id kosong pada: " + name + " — transisi dibatalkan.")
		return

	# 2. Pastikan path tidak kosong
	if destination_scene_path == "":
		push_error("[TransitionZone] destination_scene_path kosong pada: " + name)
		return

	# 3. Pastikan scene tujuan ada di disk
	if not ResourceLoader.exists(destination_scene_path):
		push_error("[TransitionZone] destination_scene_path tidak ditemukan: " + destination_scene_path)
		return

	# 4. Muat PackedScene tujuan
	var packed := load(destination_scene_path) as PackedScene
	if packed == null:
		push_error("[TransitionZone] Gagal memuat sebagai PackedScene: " + destination_scene_path)
		return

	# 5. Verifikasi SpawnMarker dengan ID yang diminta ada di scene tujuan
	var preview := packed.instantiate()
	var found_spawn := _find_spawn_in_preview(preview, target_spawn_id)
	preview.queue_free()
	if not found_spawn:
		push_error("[TransitionZone] SpawnMarker '" + target_spawn_id + "' tidak ditemukan di: " + destination_scene_path)
		return

	# === PREFLIGHT LULUS — Mulai transisi ===
	GameManager.is_transitioning = true
	GameManager.target_world_scene = destination_scene_path
	GameManager.target_spawn_id = target_spawn_id

	var success = await TransitionManager.transition_to_scene("res://scenes/main/main.tscn")
	if not success:
		# Kembalikan state agar tidak terjebak
		GameManager.is_transitioning = false
		GameManager.target_world_scene = ""
		GameManager.target_spawn_id = ""


func _find_spawn_in_preview(node: Node, id: String) -> bool:
	## Cari SpawnMarker secara rekursif dalam preview sementara.
	if node.get_script() != null:
		# Cek melalui properti exported spawn_id
		if node.get("spawn_id") != null and node.get("spawn_id") == id:
			return true
	for child in node.get_children():
		if _find_spawn_in_preview(child, id):
			return true
	return false
