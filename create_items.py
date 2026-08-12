#!/usr/bin/env python3
"""Generate Godot .tres item resources for Milestone 21"""

items = [
    {
        "filename": "healing_potion.tres",
        "item_id": "healing_potion",
        "display_name": "Healing Potion",
        "description": "Restores 50 HP to one living ally.",
        "item_type": 0,  # CONSUMABLE
        "target_type": 0,  # ONE_LIVING_ALLY
        "effect_type": 1,  # HEAL_HP
        "power": 50,
        "usable_in_battle": True,
        "stack_limit": 99
    },
    {
        "filename": "spirit_tonic.tres",
        "item_id": "spirit_tonic",
        "display_name": "Spirit Tonic",
        "description": "Restores 20 MP to one living ally.",
        "item_type": 0,  # CONSUMABLE
        "target_type": 0,  # ONE_LIVING_ALLY
        "effect_type": 2,  # RESTORE_MP
        "power": 20,
        "usable_in_battle": True,
        "stack_limit": 99
    }
]

for item in items:
    content = f'''[gd_resource type="Resource" script_class="ItemData" load_steps=2 format=3 uid="uid://{''.join([hex(ord(c))[2:] for c in item['item_id'][:8]])}"]

[ext_resource type="Script" path="res://scripts/battle/item_data.gd" id="1_item"]

[resource]
script = ExtResource("1_item")
item_id = "{item['item_id']}"
display_name = "{item['display_name']}"
description = "{item['description']}"
item_type = {item['item_type']}
target_type = {item['target_type']}
effect_type = {item['effect_type']}
power = {item['power']}
usable_in_battle = {'true' if item['usable_in_battle'] else 'false'}
stack_limit = {item['stack_limit']}
'''
    
    filepath = f"data/items/{item['filename']}"
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Created {filepath}")

print("\nAll item resources created successfully!")
