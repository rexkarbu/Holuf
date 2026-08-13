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
