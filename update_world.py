import sys

with open("d:/project/game/holuf/holuf/scenes/world/world.tscn", "r") as f:
    content = f.read()

# Replace load_steps=17 with load_steps=22
content = content.replace("load_steps=17", "load_steps=22")

# Inject ext_resources
ext_inject = """[ext_resource type="Script" path="res://scripts/world/encounter_trigger.gd" id="4_encounter_trigger"]
[ext_resource type="Script" path="res://scripts/world/encounter_zone.gd" id="5_encounter_zone"]
[ext_resource type="Script" path="res://scripts/world/safe_zone.gd" id="6_safe_zone"]
[ext_resource type="Resource" path="res://data/battle/tables/forest_table.tres" id="7_forest_table"]"""

content = content.replace('[ext_resource type="Script" path="res://scripts/world/encounter_trigger.gd" id="4_encounter_trigger"]', ext_inject)

# Inject sub_resources
sub_inject = """[sub_resource type="RectangleShape2D" id="RectangleShape2D_EncounterTrigger"]
size = Vector2(200, 200)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_ForestZone"]
size = Vector2(2000, 2000)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_SafeZone"]
size = Vector2(600, 600)"""

content = content.replace("""[sub_resource type="RectangleShape2D" id="RectangleShape2D_EncounterTrigger"]
size = Vector2(200, 200)""", sub_inject)

# Inject nodes at the bottom
node_inject = """
[node name="ForestEncounterZone" type="Area2D" parent="."]
position = Vector2(1000, 1000)
collision_layer = 0
collision_mask = 1
script = ExtResource("5_encounter_zone")
encounter_table = ExtResource("7_forest_table")

[node name="CollisionShape2D" type="CollisionShape2D" parent="ForestEncounterZone"]
shape = SubResource("RectangleShape2D_ForestZone")
debug_color = Color(0.1, 0.9, 0.1, 0.1)

[node name="StartSafeZone" type="Area2D" parent="."]
position = Vector2(1000, 1000)
collision_layer = 0
collision_mask = 1
script = ExtResource("6_safe_zone")

[node name="CollisionShape2D" type="CollisionShape2D" parent="StartSafeZone"]
shape = SubResource("RectangleShape2D_SafeZone")
debug_color = Color(0.1, 0.1, 0.9, 0.2)
"""

content += node_inject

with open("d:/project/game/holuf/holuf/scenes/world/world.tscn", "w") as f:
    f.write(content)

print("Updated world.tscn")
