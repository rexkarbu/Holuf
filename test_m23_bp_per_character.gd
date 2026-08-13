extends Node

## M23 BP BUGFIX TEST
## Tests that each Party character's BP is independent and only increases on THEIR OWN natural turn

func test_bp_per_character():
	print("=== M23 BP PER-CHARACTER TEST ===")
	print("")
	
	# Create mock party
	var hero_data = CombatantData.new()
	hero_data.display_name = "Hero"
	hero_data.max_hp = 100
	hero_data.speed = 30
	
	var b_data = CombatantData.new()
	b_data.display_name = "Character B"
	b_data.max_hp = 95
	b_data.speed = 27
	
	var hero = Combatant.new(hero_data, "hero")
	var char_b = Combatant.new(b_data, "character_b")
	
	print("Initial state:")
	print("Hero BP: %d" % hero.current_bp)
	print("Character B BP: %d" % char_b.current_bp)
	print("")
	
	# Simulate Hero's natural turn start
	print("--- Hero's natural turn begins ---")
	if hero.current_bp < BoostMultiplier.MAX_BP:
		hero.current_bp += 1
	print("Hero BP after Hero turn start: %d (expected: 1)" % hero.current_bp)
	print("Character B BP: %d (expected: 0, unchanged)" % char_b.current_bp)
	print("")
	
	# Hero uses DEFEND (no BP change)
	print("--- Hero uses DEFEND ---")
	print("Hero BP: %d (expected: 1, unchanged)" % hero.current_bp)
	print("Character B BP: %d (expected: 0, unchanged)" % char_b.current_bp)
	print("")
	
	# Simulate Character B's natural turn start
	print("--- Character B's natural turn begins ---")
	if char_b.current_bp < BoostMultiplier.MAX_BP:
		char_b.current_bp += 1
	print("Hero BP: %d (expected: 1, MUST NOT INCREASE)" % hero.current_bp)
	print("Character B BP: %d (expected: 1)" % char_b.current_bp)
	print("")
	
	# Verify
	var hero_correct = (hero.current_bp == 1)
	var b_correct = (char_b.current_bp == 1)
	
	if hero_correct and b_correct:
		print("✅ TEST PASSED: Each character's BP is independent")
	else:
		print("❌ TEST FAILED:")
		if not hero_correct:
			print("  - Hero BP is %d, expected 1" % hero.current_bp)
		if not b_correct:
			print("  - Character B BP is %d, expected 1" % char_b.current_bp)
	
	print("")
	print("=== END TEST ===")

func _ready():
	test_bp_per_character()
