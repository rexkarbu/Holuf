extends Area2D
class_name SafeZone

## SafeZone — Menimpa EncounterZone dan mematikan random encounters selama player ada di dalamnya.

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		EncounterManager.set_encounters_enabled(false)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		EncounterManager.set_encounters_enabled(true)
