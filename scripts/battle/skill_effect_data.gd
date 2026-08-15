class_name SkillEffectData
extends Resource

## SkillEffectData — Fondasi untuk effect yang bisa diterapkan oleh skill.

enum Type {
	NONE,
	ATK_UP,
	ATK_DOWN,
	DEF_UP,
	DEF_DOWN,
	MAG_UP,
	MAG_DOWN,
	SPD_UP,
	SPD_DOWN,
	CLEANSE,
	DEFENSIVE_STANCE,
	COUNTER_STANCE,
	SELF_HEAL
}

enum EffectTarget {
	TARGET,
	CASTER
}

@export var effect_type: Type = Type.NONE
@export var effect_target: EffectTarget = EffectTarget.TARGET
@export var value: float = 0.0
@export var duration: int = 1
@export_range(0.0, 1.0) var chance: float = 1.0
