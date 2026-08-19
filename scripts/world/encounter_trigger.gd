extends Area2D

## BattleEncounterTrigger — memicu battle encounter ketika Player memasukinya.
## Menyediakan SCRIPTED BATTLE PLACEMENT yang memiliki explicit EnemyFormation.

@export var encounter_id: StringName = &"placeholder_battle_1"
@export var formation: EnemyFormation
@export var is_repeatable: bool = false
@export var is_enabled: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not is_enabled:
		return
	if not body.is_in_group("player"):
		return
		
	# Jangan memicu battle jika sedang dialog
	if DialogueManager.current_node != null:
		return
		
	if GameManager.is_transitioning:
		return
		
	if encounter_id == &"":
		push_warning("[EncounterTrigger] Invalid encounter_id (empty) di " + str(get_path()))
		return
		
	if formation == null:
		if encounter_id == &"placeholder_battle_1":
			pass # Legacy prototype exception
		else:
			push_warning("[EncounterTrigger] Invalid formation (null) untuk encounter_id produksi: " + str(encounter_id))
			return
			
	if not is_repeatable and encounter_id in GameManager.consumed_encounters:
		return
		
	if formation != null:
		GameManager.pending_formation = formation
		
	# Mulai battle dan berikan posisi player untuk return
	GameManager.start_battle(encounter_id, body.global_position, is_repeatable)
