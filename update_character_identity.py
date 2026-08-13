"""
M24 — Update all 10 party CharacterData .tres files with real names and identity data.
character_id keys are NOT changed (they serve as stable resource/progression keys).
"""

import os

SCRIPT_PATH = "res://scripts/party/character_data.gd"

# Enum values as integers per CharacterIdentity enum order
# Race: HUMAN=0, ELF=1, BEAST=2, DWARF=3, ONI=4
# WeaponType: SWORD=0, BOW=1, DAGGER=2, SPEAR=3, AXE=4, LONGSWORD=5, CLAYMORE=6, STAFF=7, KATANA=8, MAGICBOOK=9
# ElementAffinity: RAW=0, FIRE=1, WATER=2, ICE=3, LIGHTNING=4, WIND=5, EARTH=6

CHARACTERS = {
    "hero": {
        "display_name": "Aren",
        "race": 0,        # HUMAN
        "weapon_type": 0, # SWORD
        "element_affinity": 0  # RAW
    },
    "character_b": {
        "display_name": "Aelia",
        "race": 0,        # HUMAN
        "weapon_type": 1, # BOW
        "element_affinity": 5  # WIND
    },
    "character_c": {
        "display_name": "Lyra",
        "race": 1,        # ELF
        "weapon_type": 2, # DAGGER
        "element_affinity": 3  # ICE
    },
    "character_d": {
        "display_name": "Neria",
        "race": 1,        # ELF
        "weapon_type": 3, # SPEAR
        "element_affinity": 2  # WATER
    },
    "character_e": {
        "display_name": "Torga",
        "race": 2,        # BEAST
        "weapon_type": 4, # AXE
        "element_affinity": 6  # EARTH
    },
    "character_f": {
        "display_name": "Kaelis",
        "race": 2,        # BEAST
        "weapon_type": 5, # LONGSWORD
        "element_affinity": 4  # LIGHTNING
    },
    "character_g": {
        "display_name": "Doran",
        "race": 3,        # DWARF
        "weapon_type": 6, # CLAYMORE
        "element_affinity": 1  # FIRE
    },
    "character_h": {
        "display_name": "Orin",
        "race": 3,        # DWARF
        "weapon_type": 7, # STAFF
        "element_affinity": 6  # EARTH
    },
    "character_i": {
        "display_name": "Katsura",
        "race": 4,        # ONI
        "weapon_type": 8, # KATANA
        "element_affinity": 0  # RAW
    },
    "character_j": {
        "display_name": "Sylven",
        "race": 4,        # ONI
        "weapon_type": 9, # MAGICBOOK
        "element_affinity": 3  # ICE
    },
}

BASE_DIR = r"d:\project\game\holuf\holuf\data\party"

for char_id, data in CHARACTERS.items():
    filepath = os.path.join(BASE_DIR, char_id + ".tres")
    
    content = f"""[gd_resource type="Resource" script_class="CharacterData" load_steps=2 format=3]

[ext_resource type="Script" path="{SCRIPT_PATH}" id="1_script"]

[resource]
script = ExtResource("1_script")
character_id = "{char_id}"
display_name = "{data['display_name']}"
race = {data['race']}
weapon_type = {data['weapon_type']}
element_affinity = {data['element_affinity']}
"""
    with open(filepath, "w", newline="\n") as f:
        f.write(content)
    print(f"  Updated: {char_id}.tres -> {data['display_name']}")

print("\nAll 10 CharacterData .tres files updated successfully.")
