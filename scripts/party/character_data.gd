class_name CharacterData
extends Resource

## CharacterData — Data identitas karakter (Roster/Party System).
## Terpisah dari logika pertempuran agar modular.
## M24: Ditambahkan race, weapon_type, element_affinity.

@export var character_id: String = ""
@export var display_name: String = ""

@export_group("Identity")
@export var race: CharacterIdentity.Race = CharacterIdentity.Race.HUMAN
@export var weapon_type: CharacterIdentity.WeaponType = CharacterIdentity.WeaponType.SWORD
@export var element_affinity: CharacterIdentity.ElementAffinity = CharacterIdentity.ElementAffinity.RAW

@export_group("Equipment & Compatibility")
## Array dari tipe senjata yang boleh digunakan karakter ini.
## Jika kosong, karakter ini unrestricted (bisa menggunakan semua senjata).
@export var allowed_weapon_types: Array[CharacterIdentity.WeaponType] = []
