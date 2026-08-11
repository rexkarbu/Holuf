class_name DialogueResource
extends Resource

## DialogueResource — merepresentasikan struktur percakapan bercabang.
## Menyimpan daftar DialogueNode.

@export var start_id: String = "start"
@export var nodes: Array[DialogueNode] = []

func get_node_by_id(id: String) -> DialogueNode:
	for node in nodes:
		if node.id == id:
			return node
	return null
