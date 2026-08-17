class_name SkillData
extends Resource

## SkillData — Data statis untuk sebuah kemampuan (skill).

enum TargetType { ENEMY, ALLY, ALL_ENEMIES, ALL_ALLIES, SELF }
enum ScalingType { PHYSICAL, MAGIC }
enum ConditionType { NONE, TARGET_BROKEN, TARGET_NOT_ACTED }
enum CostType { MP, HP_PERCENT, NONE }

@export var skill_id: String = ""
@export var display_name: String = "Skill"
@export var required_level: int = 1
@export var cost_type: CostType = CostType.MP
@export var mp_cost: int = 0
@export var hp_cost_percent: float = 0.0
@export var damage_type: int = DamageType.Type.SWORD  ## Nilai dari DamageType.Type
@export var target_type: TargetType = TargetType.ENEMY
@export var scaling_type: ScalingType = ScalingType.PHYSICAL
@export var power: float = 1.0

@export_group("Condition & Bonus")
@export var condition_type: ConditionType = ConditionType.NONE
@export var conditional_power_multiplier: float = 1.0

@export_group("Effects")
@export var effects: Array[SkillEffectData] = []
