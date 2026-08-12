#!/usr/bin/env python3
"""Patch battle_controller.gd untuk menambahkan reward system dan effective stats"""

import re

def apply_patches():
    filepath = "scripts/battle/battle_controller.gd"
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Patch 1: Update _update_all_hp_mp_ui untuk gunakan effective stats
    old_hp_mp = """func _update_all_hp_mp_ui() -> void:
\tfor i in range(players.size()):
\t\tvar p = players[i]
\t\tui.update_player_hp(i, p.current_hp, p.base_data.max_hp)
\tfor i in range(players.size()):
\t\tvar p = players[i]
\t\tui.update_player_mp(i, p.current_mp, p.base_data.max_mp)"""
    
    new_hp_mp = """func _update_all_hp_mp_ui() -> void:
\tfor i in range(players.size()):
\t\tvar p = players[i]
\t\tvar max_hp = p.get_effective_max_hp() if p.has_method("get_effective_max_hp") else p.base_data.max_hp
\t\tvar max_mp = p.get_effective_max_mp() if p.has_method("get_effective_max_mp") else p.base_data.max_mp
\t\tui.update_player_hp(i, p.current_hp, max_hp)
\t\tui.update_player_mp(i, p.current_mp, max_mp)"""
    
    content = content.replace(old_hp_mp, new_hp_mp)
    
    # Patch 2: Update _process_skill_heal untuk gunakan effective stats
    old_heal = """\tvar base_heal: int
\tif skill.scaling_type == SkillData.ScalingType.PHYSICAL:
\t\tbase_heal = current_combatant.base_data.attack
\telse:
\t\tbase_heal = current_combatant.base_data.magic_attack
\t
\tvar heal_amount = max(1, roundi(float(base_heal) * skill.power))
\tvar old_hp = target.current_hp
\ttarget.current_hp = min(target.current_hp + heal_amount, target.base_data.max_hp)"""
    
    new_heal = """\tvar base_heal: int
\tif skill.scaling_type == SkillData.ScalingType.PHYSICAL:
\t\tbase_heal = current_combatant.get_effective_attack() if current_combatant.has_method("get_effective_attack") else current_combatant.base_data.attack
\telse:
\t\tbase_heal = current_combatant.get_effective_magic_attack() if current_combatant.has_method("get_effective_magic_attack") else current_combatant.base_data.magic_attack
\t
\tvar heal_amount = max(1, roundi(float(base_heal) * skill.power))
\tvar old_hp = target.current_hp
\tvar target_max_hp = target.get_effective_max_hp() if target.has_method("get_effective_max_hp") else target.base_data.max_hp
\ttarget.current_hp = min(target.current_hp + heal_amount, target_max_hp)"""
    
    content = content.replace(old_heal, new_heal)
    
    # Patch 3: Update Victory state untuk process rewards
    old_victory = """\t\tState.VICTORY:
\t\t\tui.set_turn_title("VICTORY")
\t\t\tui.add_log("All enemies defeated!")
\t\t\tui.show_commands(false)
\t\t\tui.show_skills(false)
\t\t\tui.clear_enemy_target_indicator(enemies)
\t\t\tui.set_hint("Press ENTER to return")"""
    
    new_victory = """\t\tState.VICTORY:
\t\t\tui.set_turn_title("VICTORY")
\t\t\tui.add_log("All enemies defeated!")
\t\t\tui.show_commands(false)
\t\t\tui.show_skills(false)
\t\t\tui.clear_enemy_target_indicator(enemies)
\t\t\t_process_victory_rewards()"""
    
    content = content.replace(old_victory, new_victory)
    
    # Patch 4: Add _process_victory_rewards function at end
    if "_process_victory_rewards" not in content:
        addition = """
# ==============================================================
# VICTORY REWARDS (MILESTONE 20)
# ==============================================================

var rewards_processed: bool = false

func _process_victory_rewards() -> void:
\tif rewards_processed:
\t\treturn
\trewards_processed = true
\t
\t# Calculate total rewards
\tvar total_exp: int = 0
\tvar total_gold: int = 0
\t
\tfor enemy in enemies:
\t\ttotal_exp += enemy.base_data.exp_reward
\t\ttotal_gold += enemy.base_data.gold_reward
\t
\t# Grant rewards through PartyManager
\tvar level_up_messages = PartyManager.grant_rewards(total_exp, total_gold)
\t
\t# Show reward UI
\tui.show_victory_rewards(total_exp, total_gold, level_up_messages, players)
\tui.set_hint("Press ENTER to return")
"""
        content = content.rstrip() + "\n" + addition
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("SUCCESS: battle_controller.gd patched successfully!")

if __name__ == "__main__":
    apply_patches()
