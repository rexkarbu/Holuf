class_name DialogueNode
extends Resource

## Node untuk satu blok percakapan yang mungkin memiliki percabangan

@export var id: String = ""
@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var choices: Array[DialogueChoice] = []
@export var next_id: String = ""
