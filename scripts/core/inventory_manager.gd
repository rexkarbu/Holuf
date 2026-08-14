extends Node

## InventoryManager — Persistent inventory system for Holuf.
## Inventory persists across World → Battle → World transitions.

## Storage: item_id → quantity
var inventory: Dictionary = {}

## Item definitions cache
var item_registry: Dictionary = {}

const MAX_STACK: int = 99

func _ready() -> void:
	_load_item_definitions()
	_initialize_starting_inventory()

func _load_item_definitions() -> void:
	# Load item data resources
	var healing_potion = load("res://data/items/healing_potion.tres")
	var spirit_tonic = load("res://data/items/spirit_tonic.tres")
	
	if healing_potion:
		item_registry["healing_potion"] = healing_potion
	if spirit_tonic:
		item_registry["spirit_tonic"] = spirit_tonic

func _initialize_starting_inventory() -> void:
	# Development starting inventory (only runs once)
	if inventory.is_empty():
		# Consumables
		inventory["healing_potion"] = 5
		inventory["spirit_tonic"] = 3
		# M31: Prototype equipment for testing
		inventory["training_sword"] = 1
		inventory["leather_cap"] = 1
		inventory["leather_armor"] = 1
		inventory["copper_ring"] = 1

## Reset inventory ke kondisi New Game.
## Dipanggil oleh SaveManager.start_new_game().
func reset_to_new_game() -> void:
	inventory.clear()
	_initialize_starting_inventory()

# ==============================================================
# INVENTORY API
# ==============================================================

func has_item(item_id: String) -> bool:
	return inventory.has(item_id) and inventory[item_id] > 0

func get_quantity(item_id: String) -> int:
	if inventory.has(item_id):
		return inventory[item_id]
	return 0

func can_add_item(item_id: String, amount: int) -> bool:
	if amount <= 0: return false
	
	var current = get_quantity(item_id)
	# Use item_registry stack limit if available; otherwise allow up to MAX_STACK.
	# This allows equipment items (not in item_registry) to be tracked in inventory.
	var stack_limit = MAX_STACK
	if item_registry.has(item_id):
		var item_data_res = item_registry[item_id] as ItemData
		if item_data_res:
			stack_limit = item_data_res.stack_limit
	
	return (current + amount) <= stack_limit

func add_item(item_id: String, amount: int) -> bool:
	if amount <= 0: return false
	if not can_add_item(item_id, amount): return false
	
	if not inventory.has(item_id):
		inventory[item_id] = 0
	
	inventory[item_id] += amount
	return true

func can_remove_item(item_id: String, amount: int) -> bool:
	if amount <= 0: return false
	return get_quantity(item_id) >= amount

func remove_item(item_id: String, amount: int) -> bool:
	if not can_remove_item(item_id, amount): return false
	
	inventory[item_id] -= amount
	
	# Clean up zero quantities
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	
	return true

func get_item_data(item_id: String) -> ItemData:
	if item_registry.has(item_id):
		return item_registry[item_id]
	return null

## Get all battle-usable consumables with quantity > 0
func get_battle_items() -> Array[ItemData]:
	var result: Array[ItemData] = []
	
	for item_id in inventory.keys():
		if inventory[item_id] <= 0: continue
		
		var item_data = get_item_data(item_id)
		if item_data and item_data.usable_in_battle and item_data.item_type == ItemData.ItemType.CONSUMABLE:
			result.append(item_data)
	
	return result

# ==============================================================
# DEBUG HELPERS
# ==============================================================

func grant_item(item_id: String, amount: int) -> void:
	if add_item(item_id, amount):
		print("[DEBUG] Granted %d x %s" % [amount, item_id])
	else:
		print("[DEBUG] Failed to grant %s (stack limit or invalid item)" % item_id)

func debug_print_inventory() -> void:
	print("[DEBUG] === INVENTORY ===")
	for item_id in inventory.keys():
		var item_data = get_item_data(item_id)
		var display_name = item_data.display_name if item_data else item_id
		print("[DEBUG] %s x%d" % [display_name, inventory[item_id]])
	print("[DEBUG] =================")
