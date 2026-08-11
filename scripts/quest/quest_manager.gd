extends Node

## QuestManager — Autoload singleton untuk mengelola semua runtime quest state.
## Tidak bergantung pada Player, NPC, atau UI.

enum QuestState { NOT_STARTED, ACTIVE, COMPLETED }

signal quest_started(quest_id: String, title: String)
signal quest_updated(quest_id: String, new_objective: String)
signal quest_completed(quest_id: String, title: String)

# Internal state dictionaries
var _quests: Dictionary = {}       # quest_id -> QuestData
var _states: Dictionary = {}       # quest_id -> QuestState
var _obj_indices: Dictionary = {}  # quest_id -> int (current objective index)


func _ready() -> void:
	# Daftarkan semua quest yang ada
	_load_and_register("res://data/quests/whispers_beneath_forest.tres")


func _load_and_register(path: String) -> void:
	if ResourceLoader.exists(path):
		var quest = load(path) as QuestData
		if quest:
			register_quest(quest)
	else:
		push_warning("QuestManager: Quest resource not found at '%s'" % path)


func register_quest(quest: QuestData) -> void:
	if quest == null or quest.quest_id == "":
		return
	_quests[quest.quest_id] = quest
	_states[quest.quest_id] = QuestState.NOT_STARTED
	_obj_indices[quest.quest_id] = 0


func start_quest(quest_id: String) -> void:
	if not _quests.has(quest_id):
		push_warning("QuestManager: Trying to start unregistered quest '%s'" % quest_id)
		return
	if _states[quest_id] != QuestState.NOT_STARTED:
		return  # Jangan mulai quest yang sudah aktif atau selesai
	_states[quest_id] = QuestState.ACTIVE
	_obj_indices[quest_id] = 0
	var quest: QuestData = _quests[quest_id]
	quest_started.emit(quest_id, quest.title)


func advance_quest(quest_id: String) -> void:
	if not _quests.has(quest_id):
		return
	if _states[quest_id] != QuestState.ACTIVE:
		return
	var quest: QuestData = _quests[quest_id]
	var next_idx: int = _obj_indices[quest_id] + 1
	if next_idx >= quest.objectives.size():
		complete_quest(quest_id)
	else:
		_obj_indices[quest_id] = next_idx
		quest_updated.emit(quest_id, quest.objectives[next_idx])


func complete_quest(quest_id: String) -> void:
	if not _quests.has(quest_id):
		return
	if _states[quest_id] != QuestState.ACTIVE:
		return  # Jangan selesaikan quest yang belum aktif atau sudah selesai
	_states[quest_id] = QuestState.COMPLETED
	var quest: QuestData = _quests[quest_id]
	quest_completed.emit(quest_id, quest.title)


func get_quest_state(quest_id: String) -> QuestState:
	if not _states.has(quest_id):
		return QuestState.NOT_STARTED
	return _states[quest_id]


func get_current_objective(quest_id: String) -> String:
	if not _quests.has(quest_id):
		return ""
	var quest: QuestData = _quests[quest_id]
	var idx: int = _obj_indices.get(quest_id, 0)
	if idx < quest.objectives.size():
		return quest.objectives[idx]
	return ""


func get_objective_index(quest_id: String) -> int:
	return _obj_indices.get(quest_id, 0)
