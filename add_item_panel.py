#!/usr/bin/env python3
"""
Helper script to add ItemPanel to battle_ui scene
"""

import re

BATTLE_UI_SCENE = "scenes/battle/battle.tscn"

# Read the scene file
with open(BATTLE_UI_SCENE, 'r', encoding='utf-8') as f:
    content = f.read()

# Find SkillPanel node definition
skill_panel_match = re.search(
    r'\[node name="SkillPanel".*?\n(.*?)\n\n\[node',
    content,
    re.DOTALL
)

if not skill_panel_match:
    print("ERROR: Could not find SkillPanel in battle_ui.tscn")
    exit(1)

skill_panel_content = skill_panel_match.group(0)

# Check if ItemPanel already exists
if '[node name="ItemPanel"' in content:
    print("ItemPanel already exists in battle_ui.tscn")
else:
    # Create ItemPanel by duplicating SkillPanel
    item_panel_content = skill_panel_content.replace('SkillPanel', 'ItemPanel')
    item_panel_content = item_panel_content.replace('skill_vbox', 'item_vbox')
    
    # Insert ItemPanel after SkillPanel
    insertion_point = skill_panel_match.end()
    content = content[:insertion_point] + "\n" + item_panel_content + content[insertion_point:]
    
    print("[OK] Added ItemPanel to battle.tscn")

# Update CommandPanel to have 4 commands
# Find CommandPanel VBoxContainer children section
command_section_match = re.search(
    r'\[node name="CommandPanel".*?\n.*?\[node name="VBoxContainer".*?\n(.*?)\n\[node name="(?!Attack|Skill|Defend)',
    content,
    re.DOTALL
)

if command_section_match:
    vbox_content = command_section_match.group(1)
    
    # Check if "Item" label already exists
    if '[node name="Item"' not in vbox_content:
        # Find the last command label (should be "Defend")
        defend_match = re.search(
            r'(\[node name="Defend".*?\ntext = "  DEFEND")',
            vbox_content
        )
        
        if defend_match:
            # Create Item label by duplicating Defend structure
            item_label = defend_match.group(1).replace('Defend', 'Item').replace('DEFEND', 'ITEM')
            
            # Insert Item before Defend
            new_vbox = vbox_content.replace(
                defend_match.group(1),
                item_label + '\n\n' + defend_match.group(1)
            )
            
            content = content.replace(vbox_content, new_vbox)
            print("[OK] Added 'Item' command label to CommandPanel")
        else:
            print("WARNING: Could not find Defend label to duplicate")
    else:
        print("Item command label already exists")
else:
    print("WARNING: Could not find CommandPanel VBoxContainer section")

# Write back
with open(BATTLE_UI_SCENE, 'w', encoding='utf-8') as f:
    f.write(content)

print("\n[SUCCESS] Battle UI scene updated successfully!")
print("\nNext steps:")
print("1. Open Godot Editor")
print("2. Open scenes/battle/battle_ui.tscn")
print("3. Verify ItemPanel exists (duplicate of SkillPanel)")
print("4. Verify CommandPanel has 4 labels: Attack, Skill, Item, Defend")
print("5. Save scene if needed")
