class_name Combatant
extends RefCounted

## Kelas runtime untuk membungkus CombatantData dan menyimpan state seperti HP/MP/Status.

var base_data: CombatantData
var runtime_name: String = ""
var current_hp: int

func get_display_name() -> String:
	return runtime_name if runtime_name != "" else base_data.display_name
var current_mp: int

var is_defending: bool = false

## Runtime — weakness types yang sudah ditemukan selama battle ini. Reset setiap battle baru.
var discovered_weaknesses: Array = []

## Runtime — Shield & Break state. Tidak disimpan ke Resource.
var current_shield: int = 0
var is_broken: bool = false
var break_skips_remaining: int = 0  # jumlah giliran yang tersisa untuk diskip

var current_break_bonus: int = BreakBonus.Type.NONE


func _init(data: CombatantData) -> void:
	base_data = data
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
# EFFECTIVE STATS
# ==============================================================

func get_effective_defense() -> int:
	var def = base_data.defense
	if is_broken and current_break_bonus == BreakBonus.Type.ARMOR_SHATTER:
		var multiplier = 1.0
		match base_data.tier:
			CombatantData.EnemyTier.NORMAL: multiplier = 0.80
			CombatantData.EnemyTier.MINI_BOSS: multiplier = 0.85
			CombatantData.EnemyTier.BOSS: multiplier = 0.90
		def = max(0, roundi(def * multiplier))
	return def

func get_effective_speed() -> int:
	var spd = base_data.speed
	if is_broken and current_break_bonus == BreakBonus.Type.DISORIENT:
		var multiplier = 1.0
		match base_data.tier:
			CombatantData.EnemyTier.NORMAL: multiplier = 0.75
			CombatantData.EnemyTier.MINI_BOSS: multiplier = 0.85
			CombatantData.EnemyTier.BOSS: multiplier = 0.90
		spd = max(1, roundi(spd * multiplier))
	return spd
