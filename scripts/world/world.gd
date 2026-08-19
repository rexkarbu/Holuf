extends Node2D

## World — mengelola state dan logika dunia/map.
## M70: Setiap lokasi world menyediakan camera_bounds-nya sendiri sebagai
## sumber otoritatif batas kamera. Main membaca properti ini setelah swap world.

## Batas kamera untuk lokasi ini, dalam koordinat lokal root World.
## Nilai ini menjadi dasar limit Camera2D Player.
## Size.x > 0 dan size.y > 0 wajib untuk batas yang valid.
@export var camera_bounds: Rect2 = Rect2(0, 0, 0, 0)

func _ready() -> void:
	pass
