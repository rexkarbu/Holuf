extends Node

## EquipmentManager — M31: Equipment System Core.
## Autoload singleton yang mengelola:
##   - Registry equipment (EquipmentData resources)
##   - character_equipment: slot equipped per karakter { char_id: { slot: id_or_empty } }
##
## OWNERSHIP MODEL (M31):
##   InventoryManager.inventory adalah sumber kebenaran jumlah equipment TERSEDIA.
##   Equip  → kurangi inventory qty by 1
##   Unequip → tambah inventory qty by 1
##   Satu copy tidak bisa dipakai dua karakter sekaligus.
##
## CRITICAL: Base stat karakter TIDAK PERNAH dimutasi.
## Bonus equipment dihitung secara on-demand via get_stat_bonus().

# ==============================================================
# SLOT CONSTANTS
# M31: Weapon / Head / Body / Accessory
# ==============================================================

const SLOT_WEAPON    = "weapon"
const SLOT_HEAD      = "head"
const SLOT_BODY      = "body"
const SLOT_ACCESSORY = "accessory"

const SLOTS_ORDERED = [SLOT_WEAPON, SLOT_HEAD, SLOT_BODY, SLOT_ACCESSORY]

# ==============================================================
# REGISTRY & STATE
# ==============================================================

## equipment_id → EquipmentData resource
var equipment_registry: Dictionary = {}

## { char_id: { "weapon": id_or_empty, "head": id_or_empty, "body": id_or_empty, "accessory": id_or_empty } }
var character_equipment: Dictionary = {}

const EQUIPMENT_DATA_PATH := "res://data/equipment/"

# ==============================================================
# LIFECYCLE
# ==============================================================

func _ready() -> void:
	_load_equipment_registry()
	_initialize_character_equipment()

func _load_equipment_registry() -> void:
	var ids = ["training_sword", "training_bow", "leather_cap", "leather_armor", "copper_ring"]
	for eid in ids:
		var path = EQUIPMENT_DATA_PATH + eid + ".tres"
		if ResourceLoader.exists(path):
			var res = load(path) as EquipmentData
			if res:
				equipment_registry[eid] = res
			else:
				push_error("[EquipmentManager] Failed to cast EquipmentData: %s" % path)
		else:
			push_error("[EquipmentManager] Equipment data not found: %s" % path)

func _initialize_character_equipment() -> void:
	var char_ids = [
		"aren", "aelia", "lyra", "doran", "neria",
		"torga", "katsura", "kaelis", "sylven", "orin"
	]
	for cid in char_ids:
		if not character_equipment.has(cid):
			character_equipment[cid] = _empty_slots()

# ==============================================================
# NEW GAME RESET
# ==============================================================

## Reset semua character equipment slots.
## Equipment items diberikan via InventoryManager (dipanggil dari SaveManager/PartyManager).
func reset_to_new_game() -> void:
	for cid in character_equipment.keys():
		character_equipment[cid] = _empty_slots()

# ==============================================================
# QUERY API
# ==============================================================

func get_equipment_data(equipment_id: String) -> EquipmentData:
	return equipment_registry.get(equipment_id, null)

## Jumlah yang tersedia di inventory (belum dipakai karakter manapun).
func get_available_quantity(equipment_id: String) -> int:
	return InventoryManager.get_quantity(equipment_id)

## Jumlah yang sedang dipakai oleh semua karakter (equipped count).
func get_equipped_quantity(equipment_id: String) -> int:
	var count = 0
	for cid in character_equipment:
		for slot_val in character_equipment[cid].values():
			if slot_val == equipment_id:
				count += 1
	return count

## Jumlah total dimiliki player = inventory + equipped.
func get_owned_quantity(equipment_id: String) -> int:
	return get_available_quantity(equipment_id) + get_equipped_quantity(equipment_id)

## ID equipment yang equipped di slot karakter. "" jika kosong.
func get_equipped_id(char_id: String, slot: String) -> String:
	if not character_equipment.has(char_id):
		return ""
	return character_equipment[char_id].get(slot, "")

## EquipmentData yang equipped di slot karakter. null jika kosong.
func get_equipped(char_id: String, slot: String) -> EquipmentData:
	var eid = get_equipped_id(char_id, slot)
	if eid == "":
		return null
	return get_equipment_data(eid)

## Cek apakah equipment bisa di-equip oleh karakter ke slot yang sesuai.
## Syarat: item ada di registry, slot_type cocok, ada di inventory (qty > 0).
## M32: Weapon Type restriction divalidasi.
func can_equip(char_id: String, equipment_id: String) -> bool:
	var eq_data = get_equipment_data(equipment_id)
	if eq_data == null:
		return false
		
	var char_data = _get_char_data(char_id)
	if char_data == null:
		return false
		
	if not eq_data.is_compatible_with(char_data):
		return false

	var slot = _slot_key(eq_data.slot_type)

	# Jika sudah ada di slot ini — tidak perlu equip ulang
	if get_equipped_id(char_id, slot) == equipment_id:
		return false

	# Harus ada di inventory
	return InventoryManager.get_quantity(equipment_id) > 0

# ==============================================================
# EQUIP / UNEQUIP
# ==============================================================

## Equip item ke karakter.
## Jika slot sudah terisi → old item kembali ke inventory, new item keluar dari inventory.
## Mengembalikan true jika berhasil.
func equip(char_id: String, equipment_id: String) -> bool:
	if not can_equip(char_id, equipment_id):
		push_warning("[EquipmentManager] Cannot equip '%s' to '%s'." % [equipment_id, char_id])
		return false

	var eq_data = get_equipment_data(equipment_id)
	var slot = _slot_key(eq_data.slot_type)

	# 1. Kembalikan item lama ke inventory jika ada
	var old_id = get_equipped_id(char_id, slot)
	if old_id != "":
		_return_to_inventory(old_id)
		character_equipment[char_id][slot] = ""

	# 2. Ambil item baru dari inventory
	_take_from_inventory(equipment_id)

	# 3. Equip
	if not character_equipment.has(char_id):
		character_equipment[char_id] = _empty_slots()
	character_equipment[char_id][slot] = equipment_id

	_apply_hp_mp_clamp(char_id)
	print("[EquipmentManager] Equipped '%s' → %s [%s]" % [equipment_id, char_id, slot])
	return true

## Unequip item dari slot karakter. Item kembali ke inventory.
## Mengembalikan true jika berhasil.
func unequip(char_id: String, slot: String) -> bool:
	if not character_equipment.has(char_id):
		return false
	var eid = character_equipment[char_id].get(slot, "")
	if eid == "":
		return false

	# Kembalikan ke inventory
	_return_to_inventory(eid)
	character_equipment[char_id][slot] = ""

	_apply_hp_mp_clamp(char_id)
	print("[EquipmentManager] Unequipped '%s' from %s [%s]." % [eid, char_id, slot])
	return true

func _take_from_inventory(equipment_id: String) -> void:
	var qty = InventoryManager.get_quantity(equipment_id)
	if qty > 0:
		InventoryManager.inventory[equipment_id] = qty - 1
		if InventoryManager.inventory[equipment_id] <= 0:
			InventoryManager.inventory.erase(equipment_id)

func _return_to_inventory(equipment_id: String) -> void:
	var qty = InventoryManager.get_quantity(equipment_id)
	InventoryManager.inventory[equipment_id] = qty + 1

# ==============================================================
# STAT BONUS — on-demand, NO base stat mutation
# ==============================================================

## Total bonus untuk satu stat dari semua slot yang equipped karakter.
## stat_key: "max_hp", "max_mp", "atk", "def", "mag_atk", "mag_def", "spd"
func get_stat_bonus(char_id: String, stat_key: String) -> int:
	var total = 0
	if not character_equipment.has(char_id):
		return 0
	for slot_val in character_equipment[char_id].values():
		if slot_val == "":
			continue
		var eq = get_equipment_data(slot_val)
		if eq == null:
			continue
		total += int(eq.get_stat_bonuses().get(stat_key, 0))
	return total

# ==============================================================
# HP/MP CLAMP — dipanggil setelah equip/unequip
# ==============================================================

func _apply_hp_mp_clamp(char_id: String) -> void:
	if not PartyManager.character_progress.has(char_id):
		return
	var prog = PartyManager.character_progress[char_id]
	var combat_data = _get_combat_data(char_id)
	if combat_data == null:
		return
	var lb = prog.level - 1
	var eff_max_hp = combat_data.max_hp + (combat_data.hp_growth * lb) + get_stat_bonus(char_id, "max_hp")
	var eff_max_mp = combat_data.max_mp + (combat_data.mp_growth * lb) + get_stat_bonus(char_id, "max_mp")
	prog.current_hp = min(prog.current_hp, eff_max_hp)
	prog.current_mp = min(prog.current_mp, eff_max_mp)

# ==============================================================
# LIST HELPERS — untuk Equipment UI
# ==============================================================

## Dapatkan equipment yang tersedia untuk slot tertentu:
##   - slot_type cocok
##   - ada di inventory (qty > 0) ATAU sedang di-equip di slot ini
## Mengembalikan Array[EquipmentData]
func get_equippable_for_slot(char_id: String, slot: String) -> Array:
	var result: Array = []
	var target_slot_type = _slot_type_from_key(slot)
	var current_eid = get_equipped_id(char_id, slot)
	var char_data = _get_char_data(char_id)

	for eid in equipment_registry:
		var eq = equipment_registry[eid] as EquipmentData
		if eq.slot_type != target_slot_type:
			continue
			
		# Filter M32: hanya tampilkan yang kompatibel dengan karakter
		if char_data != null and not eq.is_compatible_with(char_data):
			continue
			
		# Tampilkan jika: item ini sedang equipped di slot ini, ATAU ada di inventory
		if eid == current_eid or InventoryManager.get_quantity(eid) > 0:
			result.append(eq)

	return result

# ==============================================================
# SAVE / LOAD
# ==============================================================

## Serialisasi character_equipment ke Dictionary untuk disimpan.
## Inventory (available items) sudah di-handle oleh InventoryManager.
func get_save_data() -> Dictionary:
	return _serialize_char_equipment()

## Load character_equipment dari Dictionary.
## Fallback aman jika field tidak ada (legacy saves).
func apply_save_data(char_eq: Dictionary) -> void:
	for cid in character_equipment.keys():
		if char_eq.has(cid):
			var saved = char_eq[cid]
			character_equipment[cid] = {
				SLOT_WEAPON:    str(saved.get(SLOT_WEAPON, "")),
				SLOT_HEAD:      str(saved.get(SLOT_HEAD, "")),
				SLOT_BODY:      str(saved.get(SLOT_BODY, "")),
				SLOT_ACCESSORY: str(saved.get(SLOT_ACCESSORY, ""))
			}
		else:
			character_equipment[cid] = _empty_slots()

	# Validasi: hapus ID yang tidak ada di registry
	for cid in character_equipment:
		for slot in character_equipment[cid]:
			var eid = character_equipment[cid][slot]
			if eid != "" and not equipment_registry.has(eid):
				push_warning("[EquipmentManager] Unknown equipment '%s' cleared from %s[%s]." % [eid, cid, slot])
				character_equipment[cid][slot] = ""

# ==============================================================
# PRIVATE HELPERS
# ==============================================================

func _empty_slots() -> Dictionary:
	return { SLOT_WEAPON: "", SLOT_HEAD: "", SLOT_BODY: "", SLOT_ACCESSORY: "" }

func _slot_key(slot_type: EquipmentData.SlotType) -> String:
	match slot_type:
		EquipmentData.SlotType.WEAPON:    return SLOT_WEAPON
		EquipmentData.SlotType.HEAD:      return SLOT_HEAD
		EquipmentData.SlotType.BODY:      return SLOT_BODY
		EquipmentData.SlotType.ACCESSORY: return SLOT_ACCESSORY
	return SLOT_WEAPON

func _slot_type_from_key(key: String) -> EquipmentData.SlotType:
	match key:
		SLOT_WEAPON:    return EquipmentData.SlotType.WEAPON
		SLOT_HEAD:      return EquipmentData.SlotType.HEAD
		SLOT_BODY:      return EquipmentData.SlotType.BODY
		SLOT_ACCESSORY: return EquipmentData.SlotType.ACCESSORY
	return EquipmentData.SlotType.WEAPON

func _get_char_data(char_id: String) -> CharacterData:
	return PartyManager.roster.get(char_id, null)

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
			SLOT_HEAD:      character_equipment[cid].get(SLOT_HEAD, ""),
			SLOT_BODY:      character_equipment[cid].get(SLOT_BODY, ""),
			SLOT_ACCESSORY: character_equipment[cid].get(SLOT_ACCESSORY, "")
		}
	return result
