extends SceneTree

func _init():
	print("--- TEST ENCOUNTER SYSTEM ---")
	
	# Load table
	var table = load("res://data/battle/tables/forest_table.tres")
	if not table:
		print("FAILED: forest_table.tres not found")
		quit()
		return
		
	print("Loaded forest_table.tres with ", table.formations.size(), " formations")
	
	# Load EncounterManager
	var EncounterManager = load("res://scripts/world/encounter_manager.gd").new()
	# Inject random function test
	EncounterManager.set_table(table)
	EncounterManager.debug_mode = EncounterManager.DebugMode.FAST # 50-100 threshold
	EncounterManager._ready()
	
	print("Threshold generated: ", EncounterManager.next_threshold)
	
	# Simulate walk
	for i in range(20):
		print("Walking 10px...")
		EncounterManager.add_distance(10.0)
		if EncounterManager.is_locked:
			print("SUCCESS: Encounter triggered at distance ", EncounterManager.distance_walked)
			break
			
	quit()
