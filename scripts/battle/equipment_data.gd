class_name EquipmentData
extends Resource

## EquipmentData — Data statis untuk satu jenis equipment.
## M30: Equipment System Foundation.
##
## Gunakan equipment_id sebagai Save key (bukan display_name).
## stat_bonuses key: "max_hp", "max_mp", "atk", "def", "mag_atk", "mag_def", "spd"

# ==============================================================
# SLOT TYPE
# ==============================================================

enum SlotType {
	WEAPON,
	ARMOR,
	ACCESSORY
}

# ==============================================================
# FIELDS
# ==============================================================

@export var equipment_id: String = ""
@export var display_name: String = ""
@export var description: String = ""

@export_group("Slot")
@export var slot_type: SlotType = SlotType.WEAPON

## Hanya relevan jika slot_type == WEAPON.
## Weapon hanya bisa dipasang oleh karakter dengan weapon_type yang sama.
@export var weapon_type: CharacterIdentity.WeaponType = CharacterIdentity.WeaponType.SWORD

@export_group("Stat Bonuses")
@export var bonus_max_hp: int = 0
@export var bonus_max_mp: int = 0
@export var bonus_atk: int = 0
@export var bonus_def: int = 0
@export var bonus_mag_atk: int = 0
@export var bonus_mag_def: int = 0
@export var bonus_spd: int = 0

# ==============================================================
# HELPERS
# ==============================================================

## Mengembalikan Dictionary stat bonus.
## Key: "max_hp", "max_mp", "atk", "def", "mag_atk", "mag_def", "spd"
func get_stat_bonuses() -> Dictionary:
	return {
		"max_hp":  bonus_max_hp,
		"max_mp":  bonus_max_mp,
		"atk":     bonus_atk,
		"def":     bonus_def,
		"mag_atk": bonus_mag_atk,
		"mag_def": bonus_mag_def,
		"spd":     bonus_spd,
	}

## Cek apakah equipment ini bisa dipakai oleh karakter berdasarkan weapon_type mereka.
## Armor dan Accessory selalu valid. Weapon hanya valid jika weapon_type cocok.
func is_compatible_with(char_data: CharacterData) -> bool:
	if slot_type != SlotType.WEAPON:
		return true  # Armor & Accessory universal
	return weapon_type == char_data.weapon_type
