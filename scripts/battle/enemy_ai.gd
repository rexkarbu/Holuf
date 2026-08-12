class_name EnemyAI
extends RefCounted

## EnemyAI — Helper class untuk menentukan action dan target musuh
## Tidak menangani eksekusi damage atau turn flow.

enum Mode { RANDOM, FORCE_BASIC_ATTACK, FORCE_SKILL }

const SKILL_CHANCE: float = 0.30

## Mengembalikan Dictionary { "type": "basic_attack" | "skill", "skill": SkillData | null }
static func choose_action(enemy: Combatant, mode: int = Mode.RANDOM) -> Dictionary:
	var skills = enemy.base_data.skills
	
	if mode == Mode.FORCE_BASIC_ATTACK:
		return { "type": "basic_attack", "skill": null }
		
	if mode == Mode.FORCE_SKILL and skills.size() > 0:
		var random_skill = skills[randi() % skills.size()]
		return { "type": "skill", "skill": random_skill }
		
	if mode == Mode.RANDOM and skills.size() > 0:
		if randf() < SKILL_CHANCE:
			var random_skill = skills[randi() % skills.size()]
			return { "type": "skill", "skill": random_skill }
			
	return { "type": "basic_attack", "skill": null }

## Mengembalikan target Combatant yang valid (hidup), atau null jika tidak ada.
static func choose_target(players: Array) -> Combatant:
	var living_players: Array = []
	for p in players:
		if not p.is_dead():
			living_players.append(p)
			
	if living_players.size() == 0:
		return null
		
	var target_index = randi() % living_players.size()
	return living_players[target_index]
