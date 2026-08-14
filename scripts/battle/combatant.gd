class_name Combatant
extends RefCounted

## Kelas runtime untuk membungkus CombatantData dan menyimpan state seperti HP/MP/Status.

var base_data: CombatantData
var runtime_name: String = ""
var current_hp: int
var current_mp: int

var is_defending: bool = false

# ==============================================================
# BOOST POINTS (M23) — Battle-only resource
# ==============================================================
var current_bp: int = 1  # Starts at 1 for all combatants
var selected_boost_level: int = 0  # 0-3, player's current selection
var natural_turns_started: int = 0 # Counter for natural scheduled turns
var has_acted_this_round: bool = false # Tracks if natural turn has resolved or been skipped

func get_display_name() -> String:
	return runtime_name if runtime_name != "" else base_data.display_name

## Runtime — weakness types yang sudah ditemukan selama battle ini. Reset setiap battle baru.
var discovered_weaknesses: Array = []

## Runtime — active skill effects (Buffs/Debuffs/Stances)
## Array of Dictionary: { "effect": SkillEffectData, "duration": int, "is_new": bool }
var active_effects: Array = []

## Runtime — Shield & Break state. Tidak disimpan ke Resource.
var current_shield: int = 0
var is_broken: bool = false
var break_skips_remaining: int = 0  # jumlah giliran yang tersisa untuk diskip

var current_break_bonus: int = BreakBonus.Type.NONE


func _init(data: CombatantData, char_id: String = "") -> void:
	base_data = data
	character_id = char_id  # Store for effective stat calculations
	
	# M21 PATCH: Initialize HP/MP from persistent state, NOT max values
	if char_id != "" and PartyManager.character_progress.has(char_id):
		var progress = PartyManager.character_progress[char_id]
		
		# Read persistent current HP/MP
		current_hp = progress.current_hp
		current_mp = progress.current_mp
		
		# Safety clamp: ensure values don't exceed effective max (including equipment)
		var level = progress.level
		var level_bonus = level - 1
		var base_max_hp = data.max_hp + (data.hp_growth * level_bonus)
		var base_max_mp = data.max_mp + (data.mp_growth * level_bonus)
		var effective_max_hp = base_max_hp + EquipmentManager.get_stat_bonus(char_id, "max_hp")
		var effective_max_mp = base_max_mp + EquipmentManager.get_stat_bonus(char_id, "max_mp")
		
		current_hp = clamp(current_hp, 0, effective_max_hp)
		current_mp = clamp(current_mp, 0, effective_max_mp)
	else:
		# Enemy or non-tracked combatant: use max values
		current_hp = data.max_hp
		current_mp = data.max_mp
	
	current_shield = data.max_shield


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
	var effective_max_mp = get_effective_max_mp()
	if current_mp > effective_max_mp:
		current_mp = effective_max_mp


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
	var base = base_data.max_hp + (base_data.hp_growth * level_bonus)
	return base + EquipmentManager.get_stat_bonus(character_id, "max_hp")

func get_effective_max_mp() -> int:
	var level_bonus = get_level() - 1
	var base = base_data.max_mp + (base_data.mp_growth * level_bonus)
	return base + EquipmentManager.get_stat_bonus(character_id, "max_mp")

func get_effective_attack() -> int:
	var level_bonus = get_level() - 1
	var base = base_data.attack + (base_data.attack_growth * level_bonus)
	base += EquipmentManager.get_stat_bonus(character_id, "atk")
	
	var mod = 1.0
	for dict in active_effects:
		var e: SkillEffectData = dict["effect"]
		if e.effect_type == SkillEffectData.Type.ATK_UP and e.value > mod: mod = e.value
		if e.effect_type == SkillEffectData.Type.ATK_DOWN and e.value < mod: mod = e.value
	return max(1, roundi(base * mod))

func get_effective_magic_attack() -> int:
	var level_bonus = get_level() - 1
	var base = base_data.magic_attack + (base_data.magic_attack_growth * level_bonus)
	base += EquipmentManager.get_stat_bonus(character_id, "mag_atk")
	
	var mod = 1.0
	for dict in active_effects:
		var e: SkillEffectData = dict["effect"]
		if e.effect_type == SkillEffectData.Type.MAG_UP and e.value > mod: mod = e.value
		if e.effect_type == SkillEffectData.Type.MAG_DOWN and e.value < mod: mod = e.value
	return max(1, roundi(base * mod))

func get_effective_defense() -> int:
	var level_bonus = get_level() - 1
	var def = base_data.defense + (base_data.defense_growth * level_bonus)
	def += EquipmentManager.get_stat_bonus(character_id, "def")
	
	var mod = 1.0
	for dict in active_effects:
		var e: SkillEffectData = dict["effect"]
		if e.effect_type == SkillEffectData.Type.DEF_UP and e.value > mod: mod = e.value
		if e.effect_type == SkillEffectData.Type.DEF_DOWN and e.value < mod: mod = e.value
	def = max(1, roundi(def * mod))
	
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
	var base = base_data.magic_defense + (base_data.magic_defense_growth * level_bonus)
	base += EquipmentManager.get_stat_bonus(character_id, "mag_def")
	
	var mod = 1.0
	for dict in active_effects:
		var e: SkillEffectData = dict["effect"]
		if e.effect_type == SkillEffectData.Type.MAG_UP and e.value > mod: mod = e.value
		if e.effect_type == SkillEffectData.Type.MAG_DOWN and e.value < mod: mod = e.value
	return max(1, roundi(base * mod))

func get_effective_speed() -> int:
	var level_bonus = get_level() - 1
	var spd = base_data.speed + (base_data.speed_growth * level_bonus)
	spd += EquipmentManager.get_stat_bonus(character_id, "spd")
	
	var mod = 1.0
	for dict in active_effects:
		var e: SkillEffectData = dict["effect"]
		if e.effect_type == SkillEffectData.Type.SPD_UP and e.value > mod: mod = e.value
		if e.effect_type == SkillEffectData.Type.SPD_DOWN and e.value < mod: mod = e.value
	spd = max(1, roundi(spd * mod))
	
	if is_broken and current_break_bonus == BreakBonus.Type.DISORIENT:
		var multiplier = 1.0
		match base_data.tier:
			CombatantData.EnemyTier.NORMAL: multiplier = 0.75
			CombatantData.EnemyTier.MINI_BOSS: multiplier = 0.85
			CombatantData.EnemyTier.BOSS: multiplier = 0.90
		spd = max(1, roundi(spd * multiplier))
	return spd
