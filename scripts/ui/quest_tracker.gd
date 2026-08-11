extends CanvasLayer

## QuestTracker — menampilkan quest aktif dan objective saat ini di pojok kiri atas.

@onready var quest_panel: PanelContainer = $QuestPanel
@onready var title_label: Label = $QuestPanel/MarginContainer/VBoxContainer/QuestTitle
@onready var objective_label: Label = $QuestPanel/MarginContainer/VBoxContainer/ObjectiveLabel


func _ready() -> void:
	quest_panel.hide()
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_updated.connect(_on_quest_updated)
	QuestManager.quest_completed.connect(_on_quest_completed)


func _on_quest_started(quest_id: String, title: String) -> void:
	title_label.text = title
	objective_label.text = "• " + QuestManager.get_current_objective(quest_id)
	quest_panel.show()


func _on_quest_updated(_quest_id: String, new_objective: String) -> void:
	objective_label.text = "• " + new_objective


func _on_quest_completed(_quest_id: String, _title: String) -> void:
	# Sembunyikan tracker setelah 3 detik saat quest selesai
	await get_tree().create_timer(3.0).timeout
	quest_panel.hide()
