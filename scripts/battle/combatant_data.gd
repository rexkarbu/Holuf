class_name CombatantData
extends Resource

## Data statis (base stats) untuk karakter atau musuh.
enum EnemyTier { NORMAL, MINI_BOSS, BOSS }

@export var display_name: String = "Combatant"
@export var tier: EnemyTier = EnemyTier.NORMAL

@export var max_hp: int = 100
@export var max_mp: int = 40
@export var attack: int = 10
@export var defense: int = 5
@export var magic_attack: int = 10
@export var magic_defense: int = 5
@export var speed: int = 10

@export_group("Rewards (Enemies)")
@export var exp_reward: int = 0
@export var gold_reward: int = 0

@export_group("Stat Growth (Playable)")
@export var hp_growth: int = 5
@export var mp_growth: int = 0
@export var attack_growth: int = 1
@export var defense_growth: int = 1
@export var magic_attack_growth: int = 1
@export var magic_defense_growth: int = 1
@export var speed_growth: int = 1

@export_group("Skills & Weaknesses")
@export var skills: Array = []
@export var beast_skill: SkillData

## Array of DamageType.Type integers representing this combatant's weaknesses.
@export var weaknesses: Array = []

## Maximum Shield points. 0 means no shield mechanic for this combatant.
@export var max_shield: int = 0

## Mendapatkan damage multiplier ketika karakter ini dalam status Broken.
func get_break_multiplier() -> float:
	match tier:
		EnemyTier.MINI_BOSS:
			return 1.20
		EnemyTier.BOSS:
			return 1.10
		EnemyTier.NORMAL, _:
			return 1.30





