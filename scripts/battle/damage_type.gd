class_name DamageType

## DamageType — enum terpusat untuk semua tipe damage dalam sistem pertempuran Holuf.
## Urutan enum ini juga menentukan urutan slot pada Weakness UI.

enum Type {
	SWORD,      # 0 — Hero Basic Attack
	BOW,        # 1 — belum diimplementasikan
	FIRE,       # 2 — Fire Slash
	ICE,        # 3 — belum diimplementasikan
	LIGHTNING,  # 4 — belum diimplementasikan
	HEALING     # 5 — Heal (tidak melakukan weakness check)
}

## Semua offensive type yang ditampilkan sebagai slot di Weakness UI.
const OFFENSIVE_TYPES: Array[int] = [Type.SWORD, Type.BOW, Type.FIRE, Type.ICE, Type.LIGHTNING]

## Nama tampilan untuk setiap type.
const DISPLAY_NAMES: Dictionary = {
	Type.SWORD: "SWORD",
	Type.BOW: "BOW",
	Type.FIRE: "FIRE",
	Type.ICE: "ICE",
	Type.LIGHTNING: "LIGHTNING",
	Type.HEALING: "HEALING",
}
