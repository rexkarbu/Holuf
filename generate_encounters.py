import os

formations_dir = "d:/project/game/holuf/holuf/data/battle/formations"
tables_dir = "d:/project/game/holuf/holuf/data/battle/tables"
os.makedirs(formations_dir, exist_ok=True)
os.makedirs(tables_dir, exist_ok=True)

wolf_ext = '[ext_resource type="Resource" uid="uid://wolf_data_01" path="res://data/battle/wolf.tres" id="2_wolf"]'
beast_ext = '[ext_resource type="Resource" uid="uid://combatant_beast01" path="res://data/battle/forest_beast.tres" id="3_beast"]'
script_ext = '[ext_resource type="Script" path="res://scripts/world/enemy_formation.gd" id="1_script"]'

def write_formation(filename, f_id, weight, enemies_str, exts):
    content = f"""[gd_resource type="Resource" script_class="EnemyFormation" load_steps={len(exts)+1} format=3]

{chr(10).join(exts)}

[resource]
script = ExtResource("1_script")
formation_id = "{f_id}"
enemies = Array[Resource]({enemies_str})
weight = {weight}
"""
    with open(os.path.join(formations_dir, filename), "w") as f:
        f.write(content)

write_formation("forest_wolf.tres", "forest_wolf", 40, "[ExtResource(\"2_wolf\")]", [script_ext, wolf_ext])
write_formation("forest_beast.tres", "forest_beast", 30, "[ExtResource(\"3_beast\")]", [script_ext, beast_ext])
write_formation("forest_wolf_x2.tres", "forest_wolf_x2", 20, "[ExtResource(\"2_wolf\"), ExtResource(\"2_wolf\")]", [script_ext, wolf_ext])
write_formation("forest_beast_wolf.tres", "forest_beast_wolf", 10, "[ExtResource(\"3_beast\"), ExtResource(\"2_wolf\")]", [script_ext, wolf_ext, beast_ext])

# Now generate EncounterTable
f_wolf = '[ext_resource type="Resource" path="res://data/battle/formations/forest_wolf.tres" id="2_f_wolf"]'
f_beast = '[ext_resource type="Resource" path="res://data/battle/formations/forest_beast.tres" id="3_f_beast"]'
f_wolf_x2 = '[ext_resource type="Resource" path="res://data/battle/formations/forest_wolf_x2.tres" id="4_f_wolf_x2"]'
f_beast_wolf = '[ext_resource type="Resource" path="res://data/battle/formations/forest_beast_wolf.tres" id="5_f_beast_wolf"]'
table_script = '[ext_resource type="Script" path="res://scripts/world/encounter_table.gd" id="1_script"]'

table_content = f"""[gd_resource type="Resource" script_class="EncounterTable" load_steps=6 format=3]

{table_script}
{f_wolf}
{f_beast}
{f_wolf_x2}
{f_beast_wolf}

[resource]
script = ExtResource("1_script")
min_distance = 450.0
max_distance = 850.0
formations = Array[Resource]([ExtResource("2_f_wolf"), ExtResource("3_f_beast"), ExtResource("4_f_wolf_x2"), ExtResource("5_f_beast_wolf")])
"""

with open(os.path.join(tables_dir, "forest_table.tres"), "w") as f:
    f.write(table_content)

print("Created data files")
