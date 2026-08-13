extends Node

## EquipmentManager — M30: Equipment System Foundation.
## Autoload singleton yang mengelola:
##   - Registry equipment yang tersedia di game
##   - owned_equipment: jumlah yang dimiliki player { equipment_id: quantity }
##   - character_equipment: slot yang dipakai tiap karakter { char_id: { slot: id or "" } }
##
## CRITICAL: Base stat karakter TIDAK PERNAH dimutasi.
## Bonus equipment dihitung secara on-demand via get_stat_bonus().

# ==============================================================
# REGISTRY & STATE
# ==============================================================

## equipment_id → EquipmentData resource
var equipment_registry: Dictionary = {}

## { equipment_id: quantity }
## Jumlah total yang dimiliki player (termasuk yang sedang dipakai)
var owned_equipment: Dictionary = {}

## { char_id: { "weapon": id_or_empty, "armor": id_or_empty, "accessory": id_or_empty } }
var character_equipment: Dictionary = {}

const SLOT_WEAPON    = "weapon"
const SLOT_ARMOR     = "armor"
const SLOT_ACCESSORY = "accessory"

const EQUIPMENT_DATA_PATH := "res://data/equipment/"

# ==============================================================
# LIFECYCLE
# ==============================================================

func _ready() -> void:
	_load_equipment_registry()
	_initialize_character_equipment()

func _load_equipment_registry() -> void:
	var ids = ["training_sword", "traveler_armor", "health_charm"]
	for eid in ids:
		var path = EQUIPMENT_DATA_PATH + eid + ".tres"
		if ResourceLoader.exists(path):
			var res = load(path) as EquipmentData
			if res:
				equipment_registry[eid] = res
			else:
				push_error("[EquipmentManager] Failed to cast resource as EquipmentData: %s" % path)
		else:
			push_error("[EquipmentManager] Equipment data not found: %s" % path)

func _initialize_character_equipment() -> void:
	# Inisialisasi semua karakter dengan slot kosong
	# Dipanggil sekali saat boot — akan ditimpa oleh SaveManager jika ada save data
	var char_ids = [
		"hero", "character_b", "character_c", "character_d", "character_e",
		"character_f", "character_g", "character_h", "character_i", "character_j"
	]
	for cid in char_ids:
		if not character_equipment.has(cid):
			character_equipment[cid] = _empty_slots()

# ==============================================================
# NEW GAME RESET
# ==============================================================

func reset_to_new_game() -> void:
	owned_equipment.clear()
	# Berikan item prototype untuk testing M30
	owned_equipment["training_sword"] = 1
	owned_equipment["traveler_armor"] = 1
	owned_equipment["health_charm"]   = 1

	# Bersihkan semua slot equipped
	for cid in character_equipment.keys():
		character_equipment[cid] = _empty_slots()

# ==============================================================
# QUERY API
# ==============================================================

## Dapatkan EquipmentData dari registry. Null jika tidak ada.
func get_equipment_data(equipment_id: String) -> EquipmentData:
	if equipment_registry.has(equipment_id):
		return equipment_registry[equipment_id]
	return null

## Jumlah total yang dimiliki player (termasuk yang sedang dipakai karakter lain)
func get_owned_quantity(equipment_id: String) -> int:
	return owned_equipment.get(equipment_id, 0)

## Jumlah yang sedang dipakai oleh semua karakter
func get_equipped_quantity(equipment_id: String) -> int:
	var count = 0
	for cid in character_equipment:
		var slots = character_equipment[cid]
		for slot in slots.values():
			if slot == equipment_id:
				count += 1
	return count

## Jumlah yang tersedia untuk di-equip (owned - equipped oleh orang lain)
func get_available_quantity(equipment_id: String) -> int:
	return get_owned_quantity(equipment_id) - get_equipped_quantity(equipment_id)

## Dapatkan ID equipment yang sedang di-equip di slot tertentu untuk karakter tertentu.
## Mengembalikan "" jika kosong.
func get_equipped_id(char_id: String, slot: String) -> String:
	if not character_equipment.has(char_id):
		return ""
	return character_equipment[char_id].get(slot, "")

## Dapatkan EquipmentData yang sedang di-equip di slot karakter.
## Null jika kosong.
func get_equipped(char_id: String, slot: String) -> EquipmentData:
	var eid = get_equipped_id(char_id, slot)
	if eid == "":
		return null
	return get_equipment_data(eid)

## Cek apakah equipment dapat di-equip oleh karakter di slot tertentu.
## Menggunakan CharacterData.weapon_type untuk validasi weapon.
func can_equip(char_id: String, equipment_id: String) -> bool:
	var eq_data = get_equipment_data(equipment_id)
	if eq_data == null:
		return false

	# Cek ketersediaan (available quantity > 0 setelah diperhitungkan item yang sudah equipped di slot ini)
	var currently_in_slot = get_equipped_id(char_id, _slot_key(eq_data.slot_type))
	var effective_available = get_available_quantity(equipment_id)
	# Jika item yang mau dipakai sudah ada di slot ini (replace), itu tidak mengurangi available
	if currently_in_slot == equipment_id:
		return true  # sudah equipped di slot ini, tidak ada yang bisa dilakukan (no-op)

	if effective_available <= 0:
		return false

	# Cek kompatibilitas weapon
	var char_data = _get_char_data(char_id)
	if char_data == null:
		return false

	return eq_data.is_compatible_with(char_data)

# ==============================================================
# EQUIP / UNEQUIP
# ==============================================================

## Equip item ke karakter. Jika ada item di slot yang sama, item lama di-unequip dulu.
## Mengembalikan true jika berhasil.
func equip(char_id: String, equipment_id: String) -> bool:
	if not can_equip(char_id, equipment_id):
		push_warning("[EquipmentManager] Cannot equip '%s' to '%s'." % [equipment_id, char_id])
		return false

	var eq_data = get_equipment_data(equipment_id)
	var slot = _slot_key(eq_data.slot_type)

	# Unequip item lama jika ada (tanpa HP/MP clamp — akan dilakukan oleh caller jika perlu)
	var old_id = get_equipped_id(char_id, slot)
	if old_id != "" and old_id != equipment_id:
		_internal_unequip(char_id, slot)

	# Equip item baru
	if not character_equipment.has(char_id):
		character_equipment[char_id] = _empty_slots()
	character_equipment[char_id][slot] = equipment_id

	# Apply HP/MP clamp setelah equip
	_apply_hp_mp_clamp(char_id)

	print("[EquipmentManager] Equipped '%s' → %s [%s]" % [equipment_id, char_id, slot])
	return true

## Unequip item dari slot karakter.
## Mengembalikan true jika berhasil.
func unequip(char_id: String, slot: String) -> bool:
	if not character_equipment.has(char_id):
		return false
	var current = character_equipment[char_id].get(slot, "")
	if current == "":
		return false  # sudah kosong

	_internal_unequip(char_id, slot)
	# Apply HP/MP clamp setelah unequip
	_apply_hp_mp_clamp(char_id)

	print("[EquipmentManager] Unequipped slot '%s' from '%s'." % [slot, char_id])
	return true

func _internal_unequip(char_id: String, slot: String) -> void:
	if character_equipment.has(char_id):
		character_equipment[char_id][slot] = ""

# ==============================================================
# STAT BONUS (calculated on-demand — no base stat mutation)
# ==============================================================

## Dapatkan total bonus untuk satu stat dari semua slot yang equipped.
## stat_key: "max_hp", "max_mp", "atk", "def", "mag_atk", "mag_def", "spd"
func get_stat_bonus(char_id: String, stat_key: String) -> int:
	var total = 0
	if not character_equipment.has(char_id):
		return 0
	var slots = character_equipment[char_id]
	for slot in slots.values():
		if slot == "":
			continue
		var eq = get_equipment_data(slot)
		if eq == null:
			continue
		var bonuses = eq.get_stat_bonuses()
		total += int(bonuses.get(stat_key, 0))
	return total

# ==============================================================
# HP/MP CLAMP (safe equip/unequip)
# ==============================================================

## Clamp current HP/MP karakter agar tidak melebihi effective max (termasuk equipment bonus).
## TIDAK menaikkan HP/MP (tidak heal).
func _apply_hp_mp_clamp(char_id: String) -> void:
	if not PartyManager.character_progress.has(char_id):
		return

	var prog = PartyManager.character_progress[char_id]
	var level = prog.level

	# Dapatkan base max dari CombatantData
	var combat_data = _get_combat_data(char_id)
	if combat_data == null:
		return

	var level_bonus = level - 1
	var base_max_hp = combat_data.max_hp + (combat_data.hp_growth * level_bonus)
	var base_max_mp = combat_data.max_mp + (combat_data.mp_growth * level_bonus)

	var effective_max_hp = base_max_hp + get_stat_bonus(char_id, "max_hp")
	var effective_max_mp = base_max_mp + get_stat_bonus(char_id, "max_mp")

	# Clamp — JANGAN naikan HP/MP melebihi current
	prog.current_hp = min(prog.current_hp, effective_max_hp)
	prog.current_mp = min(prog.current_mp, effective_max_mp)

# ==============================================================
# LIST HELPERS (untuk Equipment UI)
# ==============================================================

## Dapatkan semua equipment yang:
## 1. Compatible dengan karakter
## 2. Slot type sesuai
## 3. Available (ada stok untuk dipakai)
## Mengembalikan Array[EquipmentData]
func get_equippable_for_slot(char_id: String, slot: String) -> Array:
	var result: Array = []
	var target_slot_type = _slot_type_from_key(slot)
	var char_data = _get_char_data(char_id)
	if char_data == null:
		return result

	for eid in equipment_registry:
		var eq = equipment_registry[eid] as EquipmentData
		if eq.slot_type != target_slot_type:
			continue
		if not eq.is_compatible_with(char_data):
			continue  # Option A: tidak tampilkan yang incompatible
		# Cek availability: available > 0, ATAU item ini sudah di-equip di slot ini
		var currently_here = get_equipped_id(char_id, slot)
		if currently_here == eid:
			result.append(eq)  # item saat ini, selalu tampilkan
		elif get_available_quantity(eid) > 0:
			result.append(eq)

	return result

# ==============================================================
# SAVE / LOAD INTEGRATION
# ==============================================================

## Serialisasi state ke Dictionary untuk disimpan.
func get_save_data() -> Dictionary:
	return {
		"owned_equipment": owned_equipment.duplicate(),
		"character_equipment": _serialize_char_equipment()
	}

## Load dari Dictionary yang disimpan. Fallback aman jika field tidak ada (Save v1).
func apply_save_data(data: Dictionary) -> void:
	# owned_equipment
	owned_equipment.clear()
	var owned = data.get("owned_equipment", {})
	for eid in owned:
		var qty = int(owned[eid])
		if qty > 0:
			owned_equipment[eid] = qty

	# character_equipment
	var char_eq = data.get("character_equipment", {})
	for cid in character_equipment.keys():
		if char_eq.has(cid):
			var saved_slots = char_eq[cid]
			character_equipment[cid] = {
				SLOT_WEAPON:    str(saved_slots.get(SLOT_WEAPON, "")),
				SLOT_ARMOR:     str(saved_slots.get(SLOT_ARMOR, "")),
				SLOT_ACCESSORY: str(saved_slots.get(SLOT_ACCESSORY, ""))
			}
		else:
			character_equipment[cid] = _empty_slots()

	# Validasi: pastikan semua equipped item ID valid dan ada di registry
	for cid in character_equipment:
		for slot in character_equipment[cid]:
			var eid = character_equipment[cid][slot]
			if eid != "" and not equipment_registry.has(eid):
				push_warning("[EquipmentManager] Unknown equipment id '%s' cleared from %s[%s]." % [eid, cid, slot])
				character_equipment[cid][slot] = ""

# ==============================================================
# PRIVATE HELPERS
# ==============================================================

func _empty_slots() -> Dictionary:
	return { SLOT_WEAPON: "", SLOT_ARMOR: "", SLOT_ACCESSORY: "" }

func _slot_key(slot_type: EquipmentData.SlotType) -> String:
	match slot_type:
		EquipmentData.SlotType.WEAPON:    return SLOT_WEAPON
		EquipmentData.SlotType.ARMOR:     return SLOT_ARMOR
		EquipmentData.SlotType.ACCESSORY: return SLOT_ACCESSORY
	return SLOT_WEAPON

func _slot_type_from_key(key: String) -> EquipmentData.SlotType:
	match key:
		SLOT_WEAPON:    return EquipmentData.SlotType.WEAPON
		SLOT_ARMOR:     return EquipmentData.SlotType.ARMOR
		SLOT_ACCESSORY: return EquipmentData.SlotType.ACCESSORY
	return EquipmentData.SlotType.WEAPON

func _get_char_data(char_id: String) -> CharacterData:
	if PartyManager.roster.has(char_id):
		return PartyManager.roster[char_id]
	return null

func _get_combat_data(char_id: String) -> CombatantData:
	var path = "res://data/battle/" + char_id + ".tres"
	if ResourceLoader.exists(path):
		return load(path)
	return null

func _serialize_char_equipment() -> Dictionary:
	var result: Dictionary = {}
	for cid in character_equipment:
		result[cid] = {
			SLOT_WEAPON:    character_equipment[cid].get(SLOT_WEAPON, ""),
			SLOT_ARMOR:     character_equipment[cid].get(SLOT_ARMOR, ""),
			SLOT_ACCESSORY: character_equipment[cid].get(SLOT_ACCESSORY, "")
		}
	return result
