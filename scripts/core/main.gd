extends Node2D

## Main — entry point game HOLUF.
## Bertanggung jawab sebagai root scene dan mengatur komponen utama:
## World dan Player. Jangan tambahkan logika gameplay di sini.

@onready var player = $Player

func _ready() -> void:
	if GameManager.player_return_position != Vector2.ZERO:
		player.global_position = GameManager.player_return_position
