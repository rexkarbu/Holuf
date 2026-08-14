class_name CharacterIdentity

## CharacterIdentity — Enum terpusat untuk identitas karakter playable Holuf.
## Milestone 24: Character Identity Foundation.

# ==============================================================
# RACE — 5 playable race di dunia Holuf
# ==============================================================
enum Race {
	HUMAN,       # Aren, Aelia, Doran, Neria, Katsura, Kaelis
	ELF,         # Lyra, Sylven
	BEAST        # Torga, Orin
}

# ==============================================================
# WEAPON TYPE — 10 jenis senjata utama
# ==============================================================
enum WeaponType {
	SWORD,       # Aren
	BOW,         # Aelia, Sylven
	DAGGER,      # Lyra
	SPEAR,       # Neria, Kaelis
	AXE,         # Torga
	LONGSWORD,   # Orin
	CLAYMORE,    # Doran
	STAFF,       # Neria
	KATANA,      # Katsura
	MAGICBOOK    # Aelia
}

# ==============================================================
# ELEMENT AFFINITY — 6 elemen + Raw/Neutral
# ==============================================================
enum ElementAffinity {
	RAW,         # Aren
	FIRE,        # Doran, Orin, Aren (secondary)
	WATER,       # Neria
	ICE,         # Lyra, Katsura
	LIGHTNING,   # Kaelis
	WIND,        # Aelia, Sylven
	EARTH        # Torga
}

# ==============================================================
# DISPLAY HELPERS
# ==============================================================

static func race_name(race: Race) -> String:
	match race:
		Race.HUMAN: return "Human"
		Race.ELF: return "Elf"
		Race.BEAST: return "Beast"
	return "Unknown"

static func weapon_name(weapon: WeaponType) -> String:
	match weapon:
		WeaponType.SWORD: return "Sword"
		WeaponType.BOW: return "Bow"
		WeaponType.DAGGER: return "Dagger"
		WeaponType.SPEAR: return "Spear"
		WeaponType.AXE: return "Axe"
		WeaponType.LONGSWORD: return "Longsword"
		WeaponType.CLAYMORE: return "Claymore"
		WeaponType.STAFF: return "Staff"
		WeaponType.KATANA: return "Katana"
		WeaponType.MAGICBOOK: return "Magicbook"
	return "Unknown"

static func affinity_name(affinity: ElementAffinity) -> String:
	match affinity:
		ElementAffinity.RAW: return "Raw"
		ElementAffinity.FIRE: return "Fire"
		ElementAffinity.WATER: return "Water"
		ElementAffinity.ICE: return "Ice"
		ElementAffinity.LIGHTNING: return "Lightning"
		ElementAffinity.WIND: return "Wind"
		ElementAffinity.EARTH: return "Earth"
	return "Unknown"
