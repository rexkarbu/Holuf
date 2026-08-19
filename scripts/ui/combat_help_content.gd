class_name CombatHelpContent
extends RefCounted

const TOPICS: Dictionary = {
	"attack": {
		"title": "Attack",
		"body": "Performs a basic attack using the character's weapon.\nDamage is based on physical Attack vs Defense."
	},
	"skill": {
		"title": "Skill",
		"body": "Special abilities that cost MP or HP.\nEffects vary from damage to healing and buffs."
	},
	"weakness": {
		"title": "Weakness",
		"body": "Enemies have hidden weaknesses to specific damage types.\nHitting a weakness reveals it permanently.\nWeakness hits deal extra damage and reduce Shield."
	},
	"break": {
		"title": "BREAK & Broken",
		"body": "Reducing an enemy's Shield to 0 triggers BREAK.\nBroken enemies skip their next turns and take increased damage."
	},
	"boost": {
		"title": "Boost",
		"body": "After a character's first turn, they gain BP as later turns begin.\nSpend BP to multiply the power of compatible Attacks and Skills."
	},
	"defend": {
		"title": "Defend",
		"body": "Reduces all incoming damage by 50% until your next turn.\nCosts one turn and cannot be Boosted."
	},
	"item": {
		"title": "Item",
		"body": "Uses a consumable from the party's shared inventory.\nCannot be Boosted."
	},
	"flee": {
		"title": "Flee",
		"body": "Attempts to escape the battle.\nEscape can fail, which consumes your turn.\nSome battles do not allow fleeing."
	},
	"counter": {
		"title": "Counter",
		"body": "When hit while a Counter stance is active, the character immediately retaliates with a basic attack.\nUsing the counter consumes the stance."
	},
	"beast": {
		"title": "BEAST",
		"body": "A special character-specific ability.\nCosts MP and can only be used once per character per battle."
	}
}

static func get_topic(topic_id: StringName) -> Dictionary:
	return TOPICS.get(str(topic_id), {"title": "Unknown Topic", "body": "This topic does not exist."})
