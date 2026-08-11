class_name QuestData
extends Resource

## QuestData — menyimpan konten/data sebuah quest.
## Runtime state disimpan di QuestManager, bukan di sini.

@export var quest_id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var objectives: Array[String] = []
