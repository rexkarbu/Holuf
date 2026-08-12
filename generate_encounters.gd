extends SceneTree

func _init():
	var dir = DirAccess.open("res://data/battle")
	if not dir.dir_exists("formations"):
		dir.make_dir("formations")
	
	var wolf = load("res://data/battle/wolf.tres")
	var beast = load("res://data/battle/forest_beast.tres")
	
	var f1 = EnemyFormation.new()
	f1.formation_id = "forest_wolf"
	f1.weight = 40
	f1.enemies = [wolf]
	ResourceSaver.save(f1, "res://data/battle/formations/forest_wolf.tres")
	
	var f2 = EnemyFormation.new()
	f2.formation_id = "forest_beast"
	f2.weight = 30
	f2.enemies = [beast]
	ResourceSaver.save(f2, "res://data/battle/formations/forest_beast.tres")
	
	var f3 = EnemyFormation.new()
	f3.formation_id = "forest_wolf_x2"
	f3.weight = 20
	f3.enemies = [wolf, wolf]
	ResourceSaver.save(f3, "res://data/battle/formations/forest_wolf_x2.tres")
	
	var f4 = EnemyFormation.new()
	f4.formation_id = "forest_beast_wolf"
	f4.weight = 10
	f4.enemies = [beast, wolf]
	ResourceSaver.save(f4, "res://data/battle/formations/forest_beast_wolf.tres")
	
	if not dir.dir_exists("tables"):
		dir.make_dir("tables")
	
	var table = EncounterTable.new()
	table.min_distance = 450.0
	table.max_distance = 850.0
	table.formations = [f1, f2, f3, f4]
	ResourceSaver.save(table, "res://data/battle/tables/forest_table.tres")
	
	print("Encounter resources generated.")
	quit()
