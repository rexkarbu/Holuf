extends CanvasLayer

## InteractionUI — mengelola tampilan teks interaksi dan dialogue box sederhana.

@onready var prompt_label: Label = $Control/PromptLabel
@onready var dialogue_panel: PanelContainer = $Control/DialoguePanel
@onready var dialogue_text_label: RichTextLabel = $Control/DialoguePanel/MarginContainer/VBoxContainer/DialogueText
@onready var choices_container: VBoxContainer = $Control/DialoguePanel/MarginContainer/VBoxContainer/ChoicesContainer
@onready var next_hint: Label = $Control/DialoguePanel/NextHint

var current_speaker: String = ""

func _ready() -> void:
	prompt_label.hide()
	dialogue_panel.hide()
	
	# Cari player di scene tree dan hubungkan sinyal interaksi
	await get_tree().process_frame
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player:
		player.interactable_detected.connect(_on_player_interactable_detected)
		player.interactable_undetected.connect(_on_player_interactable_undetected)
		
	# Hubungkan ke DialogueManager signals
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_node_changed.connect(_on_dialogue_node_changed)
	DialogueManager.dialogue_choice_selection_changed.connect(_on_dialogue_choice_selection_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_player_interactable_detected(interactable: Interactable) -> void:
	# Munculkan petunjuk tombol E
	var key_text = "E"
	prompt_label.text = "[Press %s to %s %s]" % [key_text, interactable.prompt_action, interactable.object_name]
	prompt_label.show()


func _on_player_interactable_undetected() -> void:
	# Sembunyikan prompt ketika menjauh
	if not DialogueManager.is_dialogue_active:
		prompt_label.hide()
		dialogue_panel.hide()


func _on_dialogue_started(speaker_name: String) -> void:
	current_speaker = speaker_name
	prompt_label.hide()
	dialogue_panel.show()


func _on_dialogue_node_changed(node: DialogueNode) -> void:
	var speaker = node.speaker_name if node.speaker_name != "" else current_speaker
	dialogue_text_label.text = "[b]%s[/b]\n\n%s" % [speaker, node.text]
	
	# Bersihkan daftar pilihan sebelumnya
	for child in choices_container.get_children():
		child.queue_free()
		
	if node.choices.size() > 0:
		next_hint.hide() # Sembunyikan [E] Next jika ada pilihan
		var i = 0
		for choice in node.choices:
			var label = Label.new()
			label.set_meta("choice_text", choice.text)
			label.text = ("> " if i == 0 else "   ") + choice.text
			choices_container.add_child(label)
			i += 1
	else:
		next_hint.show()


func _on_dialogue_choice_selection_changed(index: int) -> void:
	var i = 0
	for child in choices_container.get_children():
		if child is Label:
			var asli = child.get_meta("choice_text", "")
			if i == index:
				child.text = "> " + asli
			else:
				child.text = "   " + asli
		i += 1


func _on_dialogue_ended() -> void:
	dialogue_panel.hide()
