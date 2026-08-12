class_name EnemyFormation
extends Resource

## EnemyFormation — Definisi untuk satu kelompok musuh (satu battle).

@export var formation_id: String = ""
@export var enemies: Array[CombatantData] = []
@export var weight: int = 10
