extends Marker2D
class_name SpawnMarker

@export var spawn_id: String = ""

func _ready() -> void:
	if spawn_id == "":
		push_warning("[SpawnMarker] SpawnMarker at " + str(global_position) + " is missing a spawn_id.")
