class_name DamageType

## DamageType — enum terpusat untuk semua tipe damage dalam sistem pertempuran Holuf.
## Urutan enum ini juga menentukan urutan slot pada Weakness UI.

enum Type {
	# Existing (DO NOT REORDER/RENUMBER)
	SWORD = 0,
	BOW = 1,
	FIRE = 2,
	ICE = 3,
	LIGHTNING = 4,
	HEALING = 5,
	
	# New Weapon Types
	DAGGER = 6,
	SPEAR = 7,
	AXE = 8,
	LONGSWORD = 9,
	CLAYMORE = 10,
	STAFF = 11,
	KATANA = 12,
	MAGICBOOK = 13,
	
	# New Elemental Types
	WATER = 14,
	WIND = 15,
	EARTH = 16,
	
	# Utility
	NONE = 17
}

## Semua offensive type yang ditampilkan sebagai slot di Weakness UI.
const OFFENSIVE_TYPES: Array[int] = [
	Type.SWORD, Type.BOW, Type.DAGGER, Type.SPEAR, Type.AXE, 
	Type.LONGSWORD, Type.CLAYMORE, Type.STAFF, Type.KATANA, Type.MAGICBOOK,
	Type.FIRE, Type.ICE, Type.LIGHTNING, Type.WATER, Type.WIND, Type.EARTH
]

## Nama tampilan untuk setiap type.
const DISPLAY_NAMES: Dictionary = {
	Type.SWORD: "SWORD",
	Type.BOW: "BOW",
	Type.FIRE: "FIRE",
	Type.ICE: "ICE",
	Type.LIGHTNING: "LIGHTNING",
	Type.HEALING: "HEALING",
	Type.DAGGER: "DAGGER",
	Type.SPEAR: "SPEAR",
	Type.AXE: "AXE",
	Type.LONGSWORD: "LONGSWORD",
	Type.CLAYMORE: "CLAYMORE",
	Type.STAFF: "STAFF",
	Type.KATANA: "KATANA",
	Type.MAGICBOOK: "MAGICBOOK",
	Type.WATER: "WATER",
	Type.WIND: "WIND",
	Type.EARTH: "EARTH",
	Type.NONE: "NONE"
}
