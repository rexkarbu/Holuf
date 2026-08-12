class_name VictoryRewards
extends RefCounted

## Helper class untuk memproses victory rewards dan menampilkan UI

static func process_and_show(battle_controller, players: Array[Combatant], enemies: Array[Combatant]) -> void:
	# Calculate total rewards
	var total_exp: int = 0
	var total_gold: int = 0
	
	for enemy in enemies:
		total_exp += enemy.base_data.exp_reward
		total_gold += enemy.base_data.gold_reward
	
	# Grant rewards through PartyManager
	var level_up_messages = PartyManager.grant_rewards(total_exp, total_gold)
	
	# Show UI
	battle_controller.ui.show_victory_rewards(total_exp, total_gold, level_up_messages, players)
	battle_controller.ui.set_hint("Press ENTER to return")
