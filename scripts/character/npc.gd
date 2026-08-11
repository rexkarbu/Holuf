extends StaticBody2D

## NPC — mewakili non-player character di dunia.
## Mendukung dialogue standar dan conditional dialogue berbasis quest state.

@export var npc_name: String = "NPC"
@export var dialogue_resource: DialogueResource

# Isi ini jika NPC ini mengelola sebuah quest
@export var managed_quest_id: String = ""
@export var dialogue_quest_active_obj1: DialogueResource  # Ketika objective 1 sedang aktif
@export var dialogue_quest_return: DialogueResource        # Ketika objective 2 (return to NPC) aktif
@export var dialogue_quest_completed: DialogueResource     # Setelah quest selesai

@onready var interaction_area: Interactable = $InteractionArea


func _ready() -> void:
	interaction_area.interacted.connect(_on_interacted)
	interaction_area.object_name = npc_name
	interaction_area.prompt_action = "talk"


func _on_interacted(_player: CharacterBody2D) -> void:
	var dialogue_to_use := _get_dialogue()
	if dialogue_to_use == null:
		return

	# Jika ini adalah dialogue return quest, complete quest setelah dialogue selesai
	if managed_quest_id != "" and dialogue_to_use == dialogue_quest_return:
		DialogueManager.dialogue_ended.connect(_on_return_dialogue_ended, CONNECT_ONE_SHOT)

	DialogueManager.start_dialogue(dialogue_to_use)


func _get_dialogue() -> DialogueResource:
	# Jika tidak ada managed_quest_id, gunakan dialogue standar
	if managed_quest_id == "":
		return dialogue_resource

	var state = QuestManager.get_quest_state(managed_quest_id)
	match state:
		QuestManager.QuestState.NOT_STARTED:
			return dialogue_resource

		QuestManager.QuestState.ACTIVE:
			var obj_idx = QuestManager.get_objective_index(managed_quest_id)
			if obj_idx == 0:
				# Objective pertama — tunjukkan dialogue aktif jika ada
				return dialogue_quest_active_obj1 if dialogue_quest_active_obj1 else dialogue_resource
			else:
				# Objective selanjutnya (Return to NPC) — tunjukkan dialogue return
				return dialogue_quest_return if dialogue_quest_return else dialogue_resource

		QuestManager.QuestState.COMPLETED:
			return dialogue_quest_completed if dialogue_quest_completed else dialogue_resource

		_:
			return dialogue_resource


func _on_return_dialogue_ended() -> void:
	QuestManager.complete_quest(managed_quest_id)
