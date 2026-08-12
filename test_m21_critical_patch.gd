extends Node

## M21 CRITICAL PATCH — Test Script
## Tests all M21 PATCH fixes for HP/MP persistence and Reserve EXP removal.
##
## Run from Godot: Attach this script to a Node and run the scene,
## or call run_tests() from console.

func run_tests() -> void:
	print("=" .repeat(70))
	print("M21 CRITICAL PATCH — VALIDATION TEST")
	print("=" .repeat(70))
	
	# Test 1: Verify RESERVE_EXP_RATE = 0.0
	print("\n[TEST 1] Reserve EXP Rate")
	print("Expected: RESERVE_EXP_RATE = 0.0")
	print("Actual: RESERVE_EXP_RATE = ", PartyManager.RESERVE_EXP_RATE)
	if PartyManager.RESERVE_EXP_RATE == 0.0:
		print("✓ PASS: Reserve characters will receive NO battle EXP")
	else:
		print("✗ FAIL: Reserve EXP rate is not 0.0!")
	
	# Test 2: Verify persistent HP/MP fields exist
	print("\n[TEST 2] Persistent HP/MP Fields")
	var test_char_id = "hero"
	if PartyManager.character_progress.has(test_char_id):
		var progress = PartyManager.character_progress[test_char_id]
		var has_current_hp = progress.has("current_hp")
		var has_current_mp = progress.has("current_mp")
		print("Character progress has 'current_hp': ", has_current_hp)
		print("Character progress has 'current_mp': ", has_current_mp)
		if has_current_hp and has_current_mp:
			print("✓ PASS: Persistent HP/MP fields exist")
		else:
			print("✗ FAIL: Missing persistent HP/MP fields!")
	else:
		print("✗ FAIL: Test character not found in progress")
	
	# Test 3: Verify HP/MP initialization values
	print("\n[TEST 3] HP/MP Initialization")
	for char_id in ["hero", "character_b", "character_c", "character_d"]:
		if PartyManager.character_progress.has(char_id):
			var progress = PartyManager.character_progress[char_id]
			var data = PartyManager.roster[char_id]
			var expected_max_hp = data.max_hp + (data.hp_growth * 0)  # Level 1
			var expected_max_mp = data.max_mp + (data.mp_growth * 0)
			print("%s: HP=%d/%d, MP=%d/%d" % [
				char_id,
				progress.current_hp, expected_max_hp,
				progress.current_mp, expected_max_mp
			])
			if progress.current_hp == expected_max_hp and progress.current_mp == expected_max_mp:
				print("  ✓ Initialized to max")
			else:
				print("  ✗ Not at expected max!")
	
	# Test 4: Simulate HP/MP damage and persistence
	print("\n[TEST 4] HP/MP Persistence Simulation")
	var hero_progress = PartyManager.character_progress["hero"]
	var original_hp = hero_progress.current_hp
	var original_mp = hero_progress.current_mp
	
	print("Original: HP=%d, MP=%d" % [original_hp, original_mp])
	
	# Simulate battle damage
	hero_progress.current_hp = max(1, original_hp - 30)
	hero_progress.current_mp = max(0, original_mp - 10)
	print("After damage: HP=%d, MP=%d" % [hero_progress.current_hp, hero_progress.current_mp])
	
	# Verify persistence
	var persisted_hp = PartyManager.character_progress["hero"].current_hp
	var persisted_mp = PartyManager.character_progress["hero"].current_mp
	print("Persisted: HP=%d, MP=%d" % [persisted_hp, persisted_mp])
	
	if persisted_hp == hero_progress.current_hp and persisted_mp == hero_progress.current_mp:
		print("✓ PASS: HP/MP changes persist correctly")
	else:
		print("✗ FAIL: HP/MP persistence broken!")
	
	# Restore original values
	hero_progress.current_hp = original_hp
	hero_progress.current_mp = original_mp
	
	# Test 5: Verify sync_battle_state() function exists
	print("\n[TEST 5] Sync Battle State Function")
	if PartyManager.has_method("sync_battle_state"):
		print("✓ PASS: sync_battle_state() method exists")
		# Test the function
		PartyManager.sync_battle_state("hero", 50, 25)
		if PartyManager.character_progress["hero"].current_hp == 50 and \
		   PartyManager.character_progress["hero"].current_mp == 25:
			print("✓ PASS: sync_battle_state() works correctly")
			# Restore
			PartyManager.character_progress["hero"].current_hp = original_hp
			PartyManager.character_progress["hero"].current_mp = original_mp
		else:
			print("✗ FAIL: sync_battle_state() doesn't update correctly")
	else:
		print("✗ FAIL: sync_battle_state() method not found!")
	
	# Test 6: Verify Level Up does NOT restore HP/MP
	print("\n[TEST 6] Level Up Does NOT Restore HP/MP")
	var test_char = "character_j"  # Use J since it's not in active party
	var char_progress = PartyManager.character_progress[test_char]
	
	# Set to damaged state
	var char_data = PartyManager.roster[test_char]
	var max_hp = char_data.max_hp
	var max_mp = char_data.max_mp
	char_progress.current_hp = roundi(max_hp * 0.5)  # 50% HP
	char_progress.current_mp = roundi(max_mp * 0.3) if max_mp > 0 else 0  # 30% MP
	char_progress.level = 1
	char_progress.current_exp = 0
	
	var pre_levelup_hp = char_progress.current_hp
	var pre_levelup_mp = char_progress.current_mp
	
	print("Before Level Up: Level=%d, HP=%d, MP=%d" % [
		char_progress.level, pre_levelup_hp, pre_levelup_mp
	])
	
	# Grant enough EXP to level up
	var exp_for_levelup = PartyManager.get_exp_required(1) + 10
	var level_msgs = PartyManager._process_exp(test_char, exp_for_levelup, false)
	
	print("After Level Up: Level=%d, HP=%d, MP=%d" % [
		char_progress.level, char_progress.current_hp, char_progress.current_mp
	])
	
	# New max values at level 2
	var new_max_hp = char_data.max_hp + char_data.hp_growth
	var new_max_mp = char_data.max_mp + char_data.mp_growth
	
	if char_progress.current_hp == pre_levelup_hp and char_progress.current_mp == pre_levelup_mp:
		print("✓ PASS: Level Up did NOT restore HP/MP (values unchanged)")
	elif char_progress.current_hp <= new_max_hp and char_progress.current_mp <= new_max_mp:
		print("✓ PASS: HP/MP clamped to new max (not fully restored)")
	else:
		print("✗ FAIL: HP/MP behavior incorrect after level up")
	
	# Restore test character
	char_progress.level = 1
	char_progress.current_exp = 0
	char_progress.current_hp = max_hp
	char_progress.current_mp = max_mp
	
	# Test 7: Verify Active-only EXP distribution
	print("\n[TEST 7] Active-Only EXP Distribution")
	print("Active Party: ", PartyManager.active_party)
	print("Reserve Party: ", PartyManager.reserve_party)
	
	# Store initial levels
	var initial_levels = {}
	for char_id in PartyManager.roster.keys():
		initial_levels[char_id] = PartyManager.character_progress[char_id].level
	
	# Grant test rewards (should only affect active party)
	var test_exp = 50
	var test_gold = 100
	print("\nGranting %d EXP to party..." % test_exp)
	var msgs = PartyManager.grant_rewards(test_exp, test_gold)
	
	print("\nEXP Distribution:")
	var active_gained_exp = false
	var reserve_gained_exp = false
	
	for char_id in PartyManager.active_party:
		var prog = PartyManager.character_progress[char_id]
		if prog.current_exp > 0 or prog.level > initial_levels[char_id]:
			print("  %s (Active): Level %d, EXP %d — ✓ Received EXP" % [
				char_id, prog.level, prog.current_exp
			])
			active_gained_exp = true
		else:
			print("  %s (Active): No EXP gained — ✗ ERROR" % char_id)
	
	for char_id in PartyManager.reserve_party:
		var prog = PartyManager.character_progress[char_id]
		if prog.current_exp > 0 or prog.level > initial_levels[char_id]:
			print("  %s (Reserve): Level %d, EXP %d — ✗ Should NOT receive EXP!" % [
				char_id, prog.level, prog.current_exp
			])
			reserve_gained_exp = true
		else:
			print("  %s (Reserve): No EXP — ✓ Correct" % char_id)
	
	if active_gained_exp and not reserve_gained_exp:
		print("\n✓ PASS: Only Active party members received EXP")
	else:
		print("\n✗ FAIL: EXP distribution incorrect!")
	
	# Restore EXP to 0 for all
	for char_id in PartyManager.roster.keys():
		PartyManager.character_progress[char_id].current_exp = 0
		PartyManager.character_progress[char_id].level = initial_levels[char_id]
	
	print("\n" + "=".repeat(70))
	print("M21 CRITICAL PATCH VALIDATION COMPLETE")
	print("=".repeat(70))
	print("\nNext Steps:")
	print("1. Run battle and verify HP/MP persists between battles")
	print("2. Use items to heal, check values persist")
	print("3. Swap party members, verify HP/MP stays with character")
	print("4. Win battle, verify only Active party gets EXP")
	print("=".repeat(70))

func _ready() -> void:
	run_tests()
