extends Node2D

## Main — entry point game HOLUF.
## Bertanggung jawab sebagai root scene dan mengatur komponen utama:
## World dan Player. Jangan tambahkan logika gameplay di sini.

@onready var player = $Player

func _ready() -> void:
	# M25: Jika ada pending load dari SaveManager, apply sekarang
	if SaveManager._has_pending_load:
		SaveManager.apply_pending_load(player)
	elif GameManager.player_return_position != Vector2.ZERO:
		player.global_position = GameManager.player_return_position
