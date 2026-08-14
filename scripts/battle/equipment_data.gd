class_name EquipmentData
extends Resource

## EquipmentData — Data statis untuk satu jenis equipment.
## M31: Equipment System Core.
##
## Gunakan equipment_id sebagai Save key (bukan display_name).
## stat_bonuses key: "max_hp", "max_mp", "atk", "def", "mag_atk", "mag_def", "spd"

# ==============================================================
# SLOT TYPE
# M31: 4 slot — Weapon, Head, Body, Accessory
# ==============================================================

enum SlotType {
	WEAPON,     # 0
	HEAD,       # 1
	BODY,       # 2
	ACCESSORY   # 3
}

# ==============================================================
# FIELDS
# ==============================================================

@export var equipment_id: String = ""
@export var display_name: String = ""
@export var description: String = ""

@export_group("Slot")
@export var slot_type: SlotType = SlotType.WEAPON

## weapon_type — data-field untuk future-proofing (weapon restriction M32+).
## M31: TIDAK dipakai untuk validasi. Semua karakter boleh pakai semua weapon.
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

## Cek apakah equipment ini bisa dipakai di slot tertentu (berbasis slot_type saja).
## M32: Weapon Type restriction.
func is_compatible_with(char_data: CharacterData) -> bool:
	if slot_type != SlotType.WEAPON:
		return true # Non-weapon is universal
		
	if char_data.allowed_weapon_types.is_empty():
		return true # Unrestricted fallback
		
	return char_data.allowed_weapon_types.has(weapon_type)
