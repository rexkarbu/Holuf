class_name ClimbableLedge
extends Interactable

## M73: Komponen tangga / tebing sekali jalan (lower -> upper).
## Menggunakan sistem Interactable standar (E / Enter).

@export var climb_duration: float = 1.0

@onready var climb_start: Marker2D = $ClimbStart
@onready var climb_end: Marker2D = $ClimbEnd

func _ready() -> void:
	if object_name == "Object" or object_name == "":
		object_name = "ledge"
	if prompt_action == "interact" or prompt_action == "":
		prompt_action = "climb"

func interact(player: CharacterBody2D) -> void:
	if GameManager.is_transitioning:
		return
	if DialogueManager.is_dialogue_active:
		return
	if player.get("is_locked") == true:
		return
	if player.get("is_traversing_ledge") == true:
		return
		
	if player.global_position.distance_to(climb_end.global_position) < player.global_position.distance_to(climb_start.global_position):
		return
		
	# Call base Interactable signal
	super.interact(player)
	
	if player.has_method("begin_ledge_traversal"):
		player.begin_ledge_traversal(climb_start.global_position, climb_end.global_position, climb_duration)
