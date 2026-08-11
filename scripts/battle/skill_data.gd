class_name SkillData
extends Resource

enum SkillType { PHYSICAL, FIRE, ICE, LIGHTNING, HEALING }
enum TargetType { SELF, ENEMY }
enum ScalingType { PHYSICAL, MAGIC }

@export var skill_id: String = ""
@export var display_name: String = "Skill"
@export var mp_cost: int = 0
@export var skill_type: SkillType = SkillType.PHYSICAL
@export var target_type: TargetType = TargetType.ENEMY
@export var scaling_type: ScalingType = ScalingType.PHYSICAL
@export var power: float = 1.0
