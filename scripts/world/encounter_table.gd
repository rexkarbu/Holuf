class_name EncounterTable
extends Resource

## EncounterTable — Daftar formation yang mungkin muncul di suatu zona, dengan jarak thresholdnya.

@export var min_distance: float = 450.0
@export var max_distance: float = 850.0
@export var formations: Array[EnemyFormation] = []
