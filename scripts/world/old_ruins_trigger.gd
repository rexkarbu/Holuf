extends Area2D

## OldRuinsTrigger — memicu kemajuan quest ketika Player memasuki area reruntuhan.
## Hanya mengadvance quest jika quest sedang aktif dan objective saat ini adalah objective pertama.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var quest_id := "whispers_beneath_forest"
	var state := QuestManager.get_quest_state(quest_id)
	var obj_idx := QuestManager.get_objective_index(quest_id)

	# Hanya advance jika: quest aktif DAN sedang di objective pertama
	if state == QuestManager.QuestState.ACTIVE and obj_idx == 0:
		QuestManager.advance_quest(quest_id)
