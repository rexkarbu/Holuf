class_name DropDownLedge
extends Interactable

## M74: Komponen tebing sekali jalan (upper -> lower) dengan Interaction.

@export var drop_duration: float = 1.0

@onready var drop_start: Marker2D = $DropStart
@onready var drop_end: Marker2D = $DropEnd

func _ready() -> void:
	if object_name == "Object" or object_name == "":
		object_name = "ledge"
	if prompt_action == "interact" or prompt_action == "":
		prompt_action = "drop down from"

func interact(player: CharacterBody2D) -> void:
	if GameManager.is_transitioning:
		return
	if DialogueManager.is_dialogue_active:
		return
	if player.get("is_locked") == true:
		return
	if player.get("is_traversing_ledge") == true:
		return
		
	var start_pos = drop_start.global_position
	var end_pos = drop_end.global_position
	
	# Pengecekan M74: Hanya boleh diakses dari sisi atas (DropStart)
	if player.global_position.distance_to(end_pos) < player.global_position.distance_to(start_pos):
		return
		
	# M74 Safe Landing Resolution
	var travel_dir = (end_pos - start_pos).normalized()
	if not player.has_method("resolve_ledge_landing"):
		push_error("[DropDownLedge] Player kehilangan API resolve_ledge_landing M74.")
		return
		
	var resolved_target = player.resolve_ledge_landing(end_pos, travel_dir, 8.0, 32.0)
	
	if typeof(resolved_target) == TYPE_NIL:
		push_error("[DropDownLedge] Tidak ada pendaratan aman. Traversal ditolak.")
		return
		
	if typeof(resolved_target) == TYPE_VECTOR2 and not resolved_target.is_equal_approx(end_pos):
		push_warning("[DropDownLedge] Authored target terblokir. Menggunakan target resolusi arah: " + str(resolved_target))
		
	# Call base Interactable signal (hanya setelah preflight valid)
	super.interact(player)
	
	if player.has_method("begin_ledge_traversal"):
		player.begin_ledge_traversal(start_pos, resolved_target, drop_duration)
