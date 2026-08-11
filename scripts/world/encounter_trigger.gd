extends Area2D

## BattleEncounterTrigger — memicu battle encounter ketika Player memasukinya.
## Hanya memicu battle jika DialogueManager tidak sedang aktif dan GameManager tidak sedang transisi.

@export var encounter_id: String = "placeholder_battle_1"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	# Jangan memicu battle jika sedang dialog
	if DialogueManager.current_node != null:
		return
		
	# Mulai battle dan berikan posisi player untuk return
	GameManager.start_battle(encounter_id, body.global_position)
