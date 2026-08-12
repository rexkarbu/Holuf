class_name Combatant
extends RefCounted

## Kelas runtime untuk membungkus CombatantData dan menyimpan state seperti HP/MP/Status.

var base_data: CombatantData
var runtime_name: String = ""
var current_hp: int
var current_mp: int

var is_defending: bool = false

func get_display_name() -> String:
	return runtime_name if runtime_name != "" else base_data.display_name

## Runtime — weakness types yang sudah ditemukan selama battle ini. Reset setiap battle baru.
var discovered_weaknesses: Array = []

## Runtime — Shield & Break state. Tidak disimpan ke Resource.
var current_shield: int = 0
var is_broken: bool = false
var break_skips_remaining: int = 0  # jumlah giliran yang tersisa untuk diskip

var current_break_bonus: int = BreakBonus.Type.NONE


func _init(data: CombatantData, char_id: String = "") -> void:
	base_data = data
	character_id = char_id  # Store for effective stat calculations
	
	# Apply level-based stat growth if this is a player character
	var level = 1
	if char_id != "" and PartyManager.character_progress.has(char_id):
		level = PartyManager.character_progress[char_id].level
	
	var level_bonus = level - 1
	var effective_max_hp = data.max_hp + (data.hp_growth * level_bonus)
	var effective_max_mp = data.max_mp + (data.mp_growth * level_bonus)
	
	current_hp = effective_max_hp
	current_mp = effective_max_mp
	current_shield = data.max_shield
	
	# Check if character needs full heal from level up (HP ONLY, not MP per design rule)
	if char_id != "" and PartyManager.character_progress.has(char_id):
		if PartyManager.character_progress[char_id].needs_full_heal:
			current_hp = effective_max_hp
			# MP is NOT restored on level up (design rule for M21)
			PartyManager.character_progress[char_id].needs_full_heal = false


## Mengurangi HP berdasarkan damage. Mengembalikan damage aktual yang diterima.
func take_damage(amount: int) -> int:
	var old_hp = current_hp
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	return old_hp - current_hp


func is_dead() -> bool:
	return current_hp <= 0


func can_spend_mp(amount: int) -> bool:
	return current_mp >= amount


func spend_mp(amount: int) -> void:
	current_mp -= amount
	if current_mp < 0:
		current_mp = 0


func restore_mp(amount: int) -> void:
	current_mp += amount
	if current_mp > base_data.max_mp:
		current_mp = base_data.max_mp


## Proses weakness hit ke Shield.
## Mengembalikan true jika Break baru saja dipicu (shield baru mencapai 0).
## JANGAN panggil jika is_broken == true atau max_shield == 0.
func process_shield_hit() -> bool:
	current_shield = max(0, current_shield - 1)
	return current_shield <= 0


## Recovery dari Break. Dipanggil pada giliran Enemy setelah skip action selesai.
func recover_from_break() -> void:
	is_broken = false
	break_skips_remaining = 0
	current_shield = base_data.max_shield
	current_break_bonus = BreakBonus.Type.NONE


# ==============================================================
# EFFECTIVE STATS (with Level Growth)
# ==============================================================

## Character ID for level-based stat calculation (empty for enemies)
var character_id: String = ""

func get_level() -> int:
	if character_id != "" and PartyManager.character_progress.has(character_id):
		return PartyManager.character_progress[character_id].level
	return 1

func get_effective_max_hp() -> int:
	var level_bonus = get_level() - 1
	return base_data.max_hp + (base_data.hp_growth * level_bonus)

func get_effective_max_mp() -> int:
	var level_bonus = get_level() - 1
	return base_data.max_mp + (base_data.mp_growth * level_bonus)

func get_effective_attack() -> int:
	var level_bonus = get_level() - 1
	return base_data.attack + (base_data.attack_growth * level_bonus)

func get_effective_magic_attack() -> int:
	var level_bonus = get_level() - 1
	return base_data.magic_attack + (base_data.magic_attack_growth * level_bonus)

func get_effective_defense() -> int:
	var level_bonus = get_level() - 1
	var def = base_data.defense + (base_data.defense_growth * level_bonus)
	
	if is_broken and current_break_bonus == BreakBonus.Type.ARMOR_SHATTER:
		var multiplier = 1.0
		match base_data.tier:
			CombatantData.EnemyTier.NORMAL: multiplier = 0.80
			CombatantData.EnemyTier.MINI_BOSS: multiplier = 0.85
			CombatantData.EnemyTier.BOSS: multiplier = 0.90
		def = max(0, roundi(def * multiplier))
	return def

func get_effective_magic_defense() -> int:
	var level_bonus = get_level() - 1
	return base_data.magic_defense + (base_data.magic_defense_growth * level_bonus)

func get_effective_speed() -> int:
	var level_bonus = get_level() - 1
	var spd = base_data.speed + (base_data.speed_growth * level_bonus)
	
	if is_broken and current_break_bonus == BreakBonus.Type.DISORIENT:
		var multiplier = 1.0
		match base_data.tier:
			CombatantData.EnemyTier.NORMAL: multiplier = 0.75
			CombatantData.EnemyTier.MINI_BOSS: multiplier = 0.85
			CombatantData.EnemyTier.BOSS: multiplier = 0.90
		spd = max(1, roundi(spd * multiplier))
	return spd
