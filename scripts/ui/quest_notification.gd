extends CanvasLayer

## QuestNotification — menampilkan notifikasi singkat saat quest dimulai, diupdate, atau selesai.

@onready var notif_panel: PanelContainer = $NotifPanel
@onready var notif_type: Label = $NotifPanel/MarginContainer/VBoxContainer/NotifType
@onready var notif_title: Label = $NotifPanel/MarginContainer/VBoxContainer/NotifTitle

var _is_showing: bool = false


func _ready() -> void:
	notif_panel.hide()
	QuestManager.quest_started.connect(_on_quest_started)
	QuestManager.quest_updated.connect(_on_quest_updated)
	QuestManager.quest_completed.connect(_on_quest_completed)


func _on_quest_started(_quest_id: String, title: String) -> void:
	_show_notif("QUEST STARTED", title)


func _on_quest_updated(_quest_id: String, new_objective: String) -> void:
	_show_notif("OBJECTIVE UPDATED", new_objective)


func _on_quest_completed(_quest_id: String, title: String) -> void:
	_show_notif("QUEST COMPLETE", title)


func _show_notif(type_text: String, title_text: String) -> void:
	notif_type.text = type_text
	notif_title.text = title_text
	notif_panel.show()
	_is_showing = true
	await get_tree().create_timer(3.0).timeout
	notif_panel.hide()
	_is_showing = false
