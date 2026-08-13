class_name CharacterIdentity

## CharacterIdentity — Enum terpusat untuk identitas karakter playable Holuf.
## Milestone 24: Character Identity Foundation.

# ==============================================================
# RACE — 5 playable race di dunia Holuf
# ==============================================================
enum Race {
	HUMAN,       # Aren, Aelia
	ELF,         # Lyra, Neria
	BEAST,       # Torga, Kaelis — dasar untuk Beast Summon di masa depan
	DWARF,       # Doran, Orin
	ONI          # Katsura, Sylven
}

# ==============================================================
# WEAPON TYPE — 10 jenis senjata utama
# ==============================================================
enum WeaponType {
	SWORD,       # Aren
	BOW,         # Aelia
	DAGGER,      # Lyra
	SPEAR,       # Neria (Spear / Lance)
	AXE,         # Torga
	LONGSWORD,   # Kaelis
	CLAYMORE,    # Doran
	STAFF,       # Orin
	KATANA,      # Katsura
	MAGICBOOK    # Sylven — mengikuti elemental affinity penggunanya
}

# ==============================================================
# ELEMENT AFFINITY — 6 elemen + Raw/Neutral
# ==============================================================
enum ElementAffinity {
	RAW,         # Aren, Katsura — tidak memiliki elemen spesifik
	FIRE,        # Doran
	WATER,       # Neria
	ICE,         # Lyra, Sylven
	LIGHTNING,   # Kaelis
	WIND,        # Aelia
	EARTH        # Torga, Orin
}

# ==============================================================
# DISPLAY HELPERS
# ==============================================================

static func race_name(race: Race) -> String:
	match race:
		Race.HUMAN: return "Human"
		Race.ELF: return "Elf"
		Race.BEAST: return "Beast"
		Race.DWARF: return "Dwarf"
		Race.ONI: return "Oni"
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
