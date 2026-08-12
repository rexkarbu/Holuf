import sys

path = "d:/project/game/holuf/holuf/scripts/party/party_manager.gd"

with open(path, "r") as f:
    content = f.read()

# 1. Add constants and variables at the top
replacement1 = """var ui_instance: Node = null

const MIN_ACTIVE: int = 1
const MAX_ACTIVE: int = 4

# --- PROGRESSION STATE ---
const ACTIVE_EXP_RATE: float = 1.0
const RESERVE_EXP_RATE: float = 0.75
const MAX_LEVEL: int = 99

var party_gold: int = 0
var character_progress: Dictionary = {}
"""
content = content.replace("var ui_instance: Node = null\n\nconst MIN_ACTIVE: int = 1\nconst MAX_ACTIVE: int = 4\n", replacement1)

# 2. Initialize progress in _ready()
replacement2 = """	for cid in paths:
		var res = load("res://data/party/" + cid + ".tres")
		if res:
			roster[cid] = res
			character_progress[cid] = {"level": 1, "current_exp": 0, "needs_full_heal": false}"""
content = content.replace("""	for cid in paths:
		var res = load("res://data/party/" + cid + ".tres")
		if res:
			roster[cid] = res""", replacement2)

# 3. Add methods at the bottom
progression_methods = """
# ==============================================================================
# PROGRESSION SYSTEM (MILESTONE 20)
# ==============================================================================

func get_exp_required(level: int) -> int:
	if level >= MAX_LEVEL: return 9999999
	return 100 + ((level - 1) * 50)

func grant_rewards(total_exp: int, total_gold: int) -> Array[String]:
	party_gold += total_gold
	var messages: Array[String] = []
	
	# Active members
	for cid in active_party:
		var msgs = _process_exp(cid, total_exp, true)
		messages.append_array(msgs)
		
	# Reserve members
	var reserve_exp = roundi(float(total_exp) * RESERVE_EXP_RATE)
	for cid in reserve_party:
		var msgs = _process_exp(cid, reserve_exp, false)
		messages.append_array(msgs)
		
	return messages

func _process_exp(char_id: String, exp_amount: int, is_active: bool) -> Array[String]:
	var msgs: Array[String] = []
	var progress = character_progress[char_id]
	var display_name = roster[char_id].display_name
	
	if progress.level >= MAX_LEVEL: return msgs
	
	progress.current_exp += exp_amount
	var exp_req = get_exp_required(progress.level)
	
	while progress.current_exp >= exp_req and progress.level < MAX_LEVEL:
		progress.current_exp -= exp_req
		progress.level += 1
		progress.needs_full_heal = true # Flags combatant to fully restore HP/MP on next load
		
		var msg = display_name + " reached Level " + str(progress.level) + "!"
		if not is_active:
			msg += " (Reserve)"
		msgs.append(msg)
		
		if progress.level >= MAX_LEVEL:
			progress.current_exp = 0
			break
			
		exp_req = get_exp_required(progress.level)
		
	return msgs

# --- DEBUG HELPERS ---
func grant_test_exp(char_id: String, amount: int) -> void:
	if char_id in character_progress:
		var is_active = char_id in active_party
		var msgs = _process_exp(char_id, amount, is_active)
		for m in msgs:
			print("[DEBUG] " + m)

func grant_test_gold(amount: int) -> void:
	party_gold += amount
	print("[DEBUG] Party Gold is now: " + str(party_gold))
"""

content = content + progression_methods

with open(path, "w") as f:
    f.write(content)
print("Updated party_manager.gd")
