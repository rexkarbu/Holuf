#!/usr/bin/env python3
"""
M22: Replace all get_tree().create_timer() calls with BattleSpeed.wait() in BattleController
"""

import re

def apply_battle_speed():
    filepath = "scripts/battle/battle_controller.gd"
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace pattern: await get_tree().create_timer(X).timeout -> await BattleSpeed.wait(X)
    pattern = r'await get_tree\(\)\.create_timer\(([^)]+)\)\.timeout'
    replacement = r'await BattleSpeed.wait(\1)'
    
    new_content = re.sub(pattern, replacement, content)
    
    # Count replacements
    old_count = content.count('get_tree().create_timer')
    new_count = new_content.count('get_tree().create_timer')
    replacements = old_count - new_count
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"[OK] Applied Battle Speed to {filepath}")
    print(f"  Replaced {replacements} timer calls with BattleSpeed.wait()")
    print(f"  Battle delays will now respect x1/x2 speed multiplier")
    
    return replacements

if __name__ == "__main__":
    apply_battle_speed()
