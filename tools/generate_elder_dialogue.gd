extends SceneTree

func _init() -> void:
	var res = DialogueResource.new()
	res.start_id = "node1"
	
	var node1 = DialogueNode.new()
	node1.id = "node1"
	node1.speaker_name = "Elder"
	node1.text = "Welcome, traveler."
	node1.next_id = "node2"
	
	var node2 = DialogueNode.new()
	node2.id = "node2"
	node2.speaker_name = "Elder"
	node2.text = "You should not venture too deep into the forest."
	node2.next_id = "node3"
	
	var node3 = DialogueNode.new()
	node3.id = "node3"
	node3.speaker_name = "Elder"
	node3.text = "Something ancient has awakened beneath these lands."
	node3.next_id = "node4"
	
	var node4 = DialogueNode.new()
	node4.id = "node4"
	node4.speaker_name = "Elder"
	node4.text = "What will you do?"
	
	var choice1 = DialogueChoice.new()
	choice1.text = "Tell me more."
	choice1.next_id = "node5"
	
	var choice2 = DialogueChoice.new()
	choice2.text = "I will investigate."
	choice2.next_id = "node6"
	
	var choice3 = DialogueChoice.new()
	choice3.text = "I should leave."
	choice3.next_id = "node7"
	
	node4.choices = [choice1, choice2, choice3]
	node4.next_id = ""
	
	var node5 = DialogueNode.new()
	node5.id = "node5"
	node5.speaker_name = "Elder"
	node5.text = "Few remember what lies beneath the old ruins."
	node5.next_id = ""
	
	var node6 = DialogueNode.new()
	node6.id = "node6"
	node6.speaker_name = "Elder"
	node6.text = "Then you will need courage. The forest does not forgive the careless."
	node6.next_id = ""
	
	var node7 = DialogueNode.new()
	node7.id = "node7"
	node7.speaker_name = "Elder"
	node7.text = "Perhaps that is wise."
	node7.next_id = ""
	
	res.nodes = [node1, node2, node3, node4, node5, node6, node7]
	
	var err = ResourceSaver.save(res, "res://data/characters/elder_dialogue.tres")
	if err == OK:
		print("SUCCESS: elder_dialogue.tres generated!")
	else:
		print("ERROR: Failed to save resource!")
		
	quit()
