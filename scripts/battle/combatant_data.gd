class_name CombatantData
extends Resource

## Data statis (base stats) untuk karakter atau musuh.

@export var display_name: String = "Combatant"
@export var max_hp: int = 100
@export var max_mp: int = 40
@export var attack: int = 10
@export var defense: int = 5
@export var magic_attack: int = 10
@export var magic_defense: int = 5
@export var speed: int = 10

@export var skills: Array = []

## Array of DamageType.Type integers representing this combatant's weaknesses.
@export var weaknesses: Array = []



