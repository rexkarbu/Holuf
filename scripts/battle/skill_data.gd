class_name SkillData
extends Resource

## SkillData — Data statis untuk sebuah kemampuan (skill).

enum TargetType { ENEMY, ALLY, ALL_ENEMIES, ALL_ALLIES }
enum ScalingType { PHYSICAL, MAGIC }

@export var skill_id: String = ""
@export var display_name: String = "Skill"
@export var mp_cost: int = 0
@export var damage_type: int = DamageType.Type.SWORD  ## Nilai dari DamageType.Type
@export var target_type: TargetType = TargetType.ENEMY
@export var scaling_type: ScalingType = ScalingType.PHYSICAL
@export var power: float = 1.0
