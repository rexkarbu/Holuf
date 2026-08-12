extends Area2D
class_name EncounterZone

## EncounterZone — Menandakan area di mana Random Encounters bisa terjadi.
## Harus memiliki collision shape.

@export var encounter_table: EncounterTable

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		EncounterManager.set_table(encounter_table)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Opsional: Bisa dikosongkan agar jika keluar area, encounter tidak lanjut.
		# Namun untuk saat ini kita reset tabel jika keluar ke area kosong.
		EncounterManager.set_table(null)
