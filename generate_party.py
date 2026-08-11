import os

path = 'data/party'
os.makedirs(path, exist_ok=True)

names = [
    ('hero', 'Hero'),
    ('character_b', 'Character B'),
    ('character_c', 'Character C'),
    ('character_d', 'Character D'),
    ('character_e', 'Character E'),
    ('character_f', 'Character F'),
    ('character_g', 'Character G'),
    ('character_h', 'Character H'),
    ('character_i', 'Character I'),
    ('character_j', 'Character J')
]

template = """[gd_resource type="Resource" script_class="CharacterData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/party/character_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
character_id = "{id}"
display_name = "{name}"
"""

for cid, name in names:
    with open(f'{path}/{cid}.tres', 'w') as f:
        f.write(template.format(id=cid, name=name))
