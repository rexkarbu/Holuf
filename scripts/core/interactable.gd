class_name Interactable
extends Area2D

## Base class untuk semua objek yang bisa diinteraksi di HOLUF.
## Menangani daur hidup interaksi dasar dan pesan prompt.

signal interacted(player: CharacterBody2D)

@export var object_name: String = "Object"
@export var prompt_action: String = "interact" # e.g. "talk", "open", "read"

func interact(player: CharacterBody2D) -> void:
	interacted.emit(player)
