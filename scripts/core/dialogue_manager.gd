extends Node

## DialogueManager — Singleton pengatur alur dialog global.
## Mendukung sistem percabangan dialog (branching choices).

signal dialogue_started(speaker_name: String)
signal dialogue_node_changed(node: DialogueNode)
signal dialogue_choice_selection_changed(index: int)
signal dialogue_ended()

var active_dialogue: DialogueResource = null
var current_node: DialogueNode = null
var is_dialogue_active: bool = false

var in_choice_selection: bool = false
var selected_choice_index: int = 0

func _input(event: InputEvent) -> void:
	if not is_dialogue_active:
		return
		
	if in_choice_selection:
		if event.is_action_pressed("ui_up"):
			get_viewport().set_input_as_handled()
			selected_choice_index -= 1
			if selected_choice_index < 0:
				selected_choice_index = current_node.choices.size() - 1
			dialogue_choice_selection_changed.emit(selected_choice_index)
		elif event.is_action_pressed("ui_down"):
			get_viewport().set_input_as_handled()
			selected_choice_index += 1
			if selected_choice_index >= current_node.choices.size():
				selected_choice_index = 0
			dialogue_choice_selection_changed.emit(selected_choice_index)
		elif event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			select_choice(selected_choice_index)
	else:
		if event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			advance_dialogue()

func start_dialogue(dialogue: DialogueResource) -> void:
	if dialogue == null or dialogue.nodes.size() == 0:
		return
		
	active_dialogue = dialogue
	current_node = active_dialogue.get_node_by_id(active_dialogue.start_id)
	if current_node == null:
		# Fallback to first node
		current_node = active_dialogue.nodes[0]
		
	is_dialogue_active = true
	
	dialogue_started.emit(current_node.speaker_name)
	_apply_current_node()

func advance_dialogue() -> void:
	if current_node == null:
		end_dialogue()
		return
		
	if current_node.choices.size() > 0:
		return
		
	if current_node.next_id == "":
		end_dialogue()
	else:
		current_node = active_dialogue.get_node_by_id(current_node.next_id)
		_apply_current_node()

func select_choice(index: int) -> void:
	if current_node == null or index < 0 or index >= current_node.choices.size():
		return
		
	var choice = current_node.choices[index]
	
	# Jalankan action opsional sebelum navigasi
	_execute_choice_action(choice)
	
	if choice.next_id == "":
		end_dialogue()
	else:
		current_node = active_dialogue.get_node_by_id(choice.next_id)
		_apply_current_node()

func _execute_choice_action(choice: DialogueChoice) -> void:
	match choice.action:
		"start_quest":
			QuestManager.start_quest(choice.action_data)
		"advance_quest":
			QuestManager.advance_quest(choice.action_data)
		"complete_quest":
			QuestManager.complete_quest(choice.action_data)
		"":
			pass  # Tidak ada aksi
		_:
			push_warning("DialogueManager: Aksi pilihan tidak dikenal '%s'" % choice.action)


func _apply_current_node() -> void:
	if current_node == null:
		end_dialogue()
		return
		
	if current_node.choices.size() > 0:
		in_choice_selection = true
		selected_choice_index = 0
	else:
		in_choice_selection = false
		
	dialogue_node_changed.emit(current_node)
	if in_choice_selection:
		dialogue_choice_selection_changed.emit(selected_choice_index)

func end_dialogue() -> void:
	is_dialogue_active = false
	active_dialogue = null
	current_node = null
	in_choice_selection = false
	dialogue_ended.emit()
