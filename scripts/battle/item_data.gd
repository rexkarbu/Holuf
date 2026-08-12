class_name ItemData
extends Resource

## ItemData — Data-driven item definition for Holuf inventory system.

enum ItemType {
	CONSUMABLE,
	KEY_ITEM,
	MATERIAL
}

enum TargetType {
	ONE_LIVING_ALLY,
	ALL_LIVING_ALLIES,
	ONE_DEAD_ALLY,
	SELF,
	ONE_ENEMY,
	ALL_ENEMIES
}

enum EffectType {
	NONE,
	HEAL_HP,
	RESTORE_MP,
	REVIVE,
	CURE_STATUS,
	DAMAGE
}

@export var item_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var target_type: TargetType = TargetType.ONE_LIVING_ALLY
@export var effect_type: EffectType = EffectType.NONE
@export var power: int = 0
@export var usable_in_battle: bool = true
@export var stack_limit: int = 99
