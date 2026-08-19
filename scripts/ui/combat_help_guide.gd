extends Control
const CombatHelpContent = preload("res://scripts/ui/combat_help_content.gd")


signal closed

@onready var topic_list: ItemList = $MainPanel/HBox/TopicList
@onready var title_label: Label = $MainPanel/HBox/ContentPanel/VBox/TopicTitle
@onready var body_label: Label = $MainPanel/HBox/ContentPanel/VBox/TopicBody
@onready var main_panel: Panel = $MainPanel
@onready var hbox: HBoxContainer = $MainPanel/HBox
@onready var content_panel: Panel = $MainPanel/HBox/ContentPanel
@onready var close_hint: Label = $MainPanel/HBox/ContentPanel/VBox/CloseHint

var contextual_mode := false
var core_topics = ["attack", "skill", "weakness", "break", "boost", "defend", "item", "flee"]
var special_topics = ["counter", "beast"]

func _ready() -> void:
	hide()
	topic_list.item_selected.connect(_on_topic_selected)
	close_hint.text = "Press ESC or H to close"

func open_full_guide() -> void:
	contextual_mode = false
	topic_list.show()
	topic_list.clear()
	main_panel.set_anchors_preset(Control.PRESET_CENTER)
	main_panel.custom_minimum_size = Vector2(800, 500)
	main_panel.size = Vector2(800, 500)
	
	topic_list.add_item("--- CORE COMBAT ---", null, false)
	for t in core_topics:
		var data = CombatHelpContent.get_topic(t)
		topic_list.add_item("  " + data["title"])
		topic_list.set_item_metadata(topic_list.item_count - 1, t)
		
	topic_list.add_item("", null, false)
	topic_list.add_item("--- SPECIAL ---", null, false)
	for t in special_topics:
		var data = CombatHelpContent.get_topic(t)
		topic_list.add_item("  " + data["title"])
		topic_list.set_item_metadata(topic_list.item_count - 1, t)
	
	show()
	# Ensure we capture input by taking focus
	set_process_unhandled_input(true)
	topic_list.grab_focus()
	_select_first_valid_topic()

func open_topic(topic_id: StringName, is_contextual: bool = true) -> void:
	contextual_mode = is_contextual
	
	if contextual_mode:
		topic_list.hide()
		main_panel.custom_minimum_size = Vector2(600, 250)
		main_panel.size = Vector2(600, 250)
		close_hint.text = "Press ENTER, ESC, or H to dismiss"
	else:
		topic_list.show()
		close_hint.text = "Press ESC or H to close"
	
	var data = CombatHelpContent.get_topic(topic_id)
	title_label.text = data["title"]
	body_label.text = data["body"]
	
	show()
	set_process_unhandled_input(true)
	grab_focus()

func _select_first_valid_topic() -> void:
	for i in range(topic_list.item_count):
		if topic_list.get_item_metadata(i) != null:
			topic_list.select(i)
			_on_topic_selected(i)
			return

func _on_topic_selected(index: int) -> void:
	var meta = topic_list.get_item_metadata(index)
	if meta != null:
		var data = CombatHelpContent.get_topic(meta)
		title_label.text = data["title"]
		body_label.text = data["body"]

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("combat_help") or event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		close_guide()
	elif contextual_mode and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		close_guide()

func close_guide() -> void:
	hide()
	set_process_unhandled_input(false)
	closed.emit()
