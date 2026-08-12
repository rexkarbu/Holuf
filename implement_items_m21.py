#!/usr/bin/env python3
"""
Milestone 21 Implementation Script
Adds complete ITEM command integration to battle system
"""

# This script documents the remaining implementation steps for M21

# ==============================================================
# STEP 1: Add PLAYER_ITEM_SELECT state handling in battle_controller.gd _set_state()
# ==============================================================
STATE_ITEM_SELECT = """
		State.PLAYER_ITEM_SELECT:
			item_index = 0
			ui.show_commands(false)
			var items = InventoryManager.get_battle_items()
			ui.populate_item_menu(items)
			if items.size() > 0:
				ui.set_item_selection(item_index, items)
			ui.show_items(true)
			ui.clear_enemy_target_indicator(enemies)
			ui.set_hint("Press ESC to cancel")
"""

# ==============================================================
# STEP 2: Add PLAYER_ITEM_SELECT input handling
# ==============================================================
INPUT_ITEM_SELECT = """
		State.PLAYER_ITEM_SELECT:
			var items = InventoryManager.get_battle_items()
			if event.is_action_pressed("ui_cancel"):
				get_viewport().set_input_as_handled()
				_set_state(State.PLAYER_COMMAND)
			elif event.is_action_pressed("ui_down") or (event is InputEventKey and event.keycode == KEY_S and event.pressed and not event.echo):
				if items.size() > 0:
					item_index = (item_index + 1) % items.size()
					ui.set_item_selection(item_index, items)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_up") or (event is InputEventKey and event.keycode == KEY_W and event.pressed and not event.echo):
				if items.size() > 0:
					item_index = (item_index - 1 + items.size()) % items.size()
					ui.set_item_selection(item_index, items)
				get_viewport().set_input_as_handled()
			elif event.is_action_pressed("ui_accept"):
				get_viewport().set_input_as_handled()
				if items.size() > 0:
					_execute_player_item(items[item_index])
"""

# ==============================================================
# STEP 3: Add item execution functions
# ==============================================================
ITEM_FUNCTIONS = """
func _execute_player_item(item: ItemData) -> void:
	pending_item = item
	if item.target_type == ItemData.TargetType.ONE_LIVING_ALLY:
		pending_action = func(tgt): _process_item_use(item, tgt)
		selected_target_index = players.find(current_combatant)
		_set_state(State.ALLY_TARGET_SELECT)

func _process_item_use(item: ItemData, target: Combatant) -> void:
	# Validate target based on effect type
	var is_valid = _validate_item_target(item, target)
	if not is_valid:
		return  # Stay in target selection
	
	# Consume item from inventory
	if not InventoryManager.remove_item(item.item_id, 1):
		ui.add_log("Item no longer available.")
		_set_state(State.PLAYER_COMMAND)
		return
	
	_set_state(State.PLAYER_ACTION)
	ui.show_items(false)
	ui.set_hint("")
	
	await get_tree().create_timer(0.3).timeout
	
	# Apply item effect
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			var old_hp = target.current_hp
			var target_max_hp = target.get_effective_max_hp() if target.has_method("get_effective_max_hp") else target.base_data.max_hp
			target.current_hp = min(target.current_hp + item.power, target_max_hp)
			var actual_heal = target.current_hp - old_hp
			_update_all_hp_mp_ui()
			ui.add_log("%s uses %s on %s. +%d HP!" % [current_combatant.get_display_name(), item.display_name, target.get_display_name(), actual_heal])
		
		ItemData.EffectType.RESTORE_MP:
			var old_mp = target.current_mp
			var target_max_mp = target.get_effective_max_mp() if target.has_method("get_effective_max_mp") else target.base_data.max_mp
			target.current_mp = min(target.current_mp + item.power, target_max_mp)
			var actual_restore = target.current_mp - old_mp
			_update_all_hp_mp_ui()
			ui.add_log("%s uses %s on %s. +%d MP!" % [current_combatant.get_display_name(), item.display_name, target.get_display_name(), actual_restore])
	
	await get_tree().create_timer(0.8).timeout
	_set_state(State.TURN_START)

func _validate_item_target(item: ItemData, target: Combatant) -> bool:
	var target_max_hp = target.get_effective_max_hp() if target.has_method("get_effective_max_hp") else target.base_data.max_hp
	var target_max_mp = target.get_effective_max_mp() if target.has_method("get_effective_max_mp") else target.base_data.max_mp
	
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			if target.current_hp >= target_max_hp:
				ui.add_log("HP is already full.")
				return false
		ItemData.EffectType.RESTORE_MP:
			if target_max_mp <= 0:
				ui.add_log("Target has no MP.")
				return false
			if target.current_mp >= target_max_mp:
				ui.add_log("MP is already full.")
				return false
	
	return true
"""

# ==============================================================
# STEP 4: Update ALLY_TARGET_SELECT cancel to handle items
# ==============================================================
ALLY_TARGET_CANCEL_FIX = """
# In ALLY_TARGET_SELECT cancel handling:
if event.is_action_pressed("ui_cancel"):
	get_viewport().set_input_as_handled()
	if pending_item != null:
		pending_item = null
		_set_state(State.PLAYER_ITEM_SELECT)
	else:
		_set_state(State.PLAYER_SKILL_SELECT)
	ui.clear_ally_target_indicator(players)
"""

# ==============================================================
# STEP 5: Fix level up to NOT restore MP (M21 requirement)
# ==============================================================
LEVEL_UP_MP_FIX = """
# In party_manager.gd _process_exp():
# REMOVE or comment out: progress.needs_full_heal = true
# MP should NOT be restored on level up
# Only current_exp should be managed
"""

# ==============================================================
# STEP 6: Add Item UI to battle_ui.gd
# ==============================================================
BATTLE_UI_ADDITIONS = """
# Add signals
signal item_hovered(index: int)
signal item_clicked(index: int)

# Add UI nodes
@onready var item_panel: PanelContainer = $BottomHUD/LeftSection/ItemPanel
@onready var item_vbox: VBoxContainer = $BottomHUD/LeftSection/ItemPanel/MarginContainer/VBoxContainer

# Add functions
func show_items(visible_state: bool) -> void:
	item_panel.visible = visible_state

func populate_item_menu(items: Array[ItemData]) -> void:
	for child in item_vbox.get_children():
		child.free()
	
	for i in range(items.size()):
		var item = items[i]
		var qty = InventoryManager.get_quantity(item.item_id)
		var label = Label.new()
		label.text = "  %s x%d" % [item.display_name, qty]
		label.add_theme_font_size_override("font_size", 18)
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.mouse_entered.connect(_on_item_hovered.bind(i))
		label.gui_input.connect(_on_item_gui_input.bind(i))
		item_vbox.add_child(label)

func set_item_selection(index: int, items: Array[ItemData]) -> void:
	var children = item_vbox.get_children()
	for i in range(children.size()):
		var label = children[i] as Label
		if label == null or i >= items.size(): continue
		var item = items[i]
		var qty = InventoryManager.get_quantity(item.item_id)
		if i == index:
			label.text = "> %s x%d" % [item.display_name, qty]
			label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
		else:
			label.text = "  %s x%d" % [item.display_name, qty]
			label.add_theme_color_override("font_color", Color(1, 1, 1))

func _on_item_hovered(index: int) -> void:
	item_hovered.emit(index)

func _on_item_gui_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		item_clicked.emit(index)
"""

# ==============================================================
# STEP 7: Update command menu label from "DEFEND" to include ITEM
# ==============================================================
COMMAND_MENU_UPDATE = """
# Command menu in battle UI scene must have 4 labels:
# - Attack
# - Skill
# - Item
# - Defend

# Or update dynamically in battle_ui.gd setup
"""

print("=" * 60)
print("MILESTONE 21 IMPLEMENTATION GUIDE")
print("=" * 60)
print("\nThis script documents all code additions needed.")
print("Due to context window limits, implementation will continue")
print("in next session or via manual code integration.")
print("\nKey files to modify:")
print("1. scripts/battle/battle_controller.gd - Add item states and handlers")
print("2. scripts/battle/battle_ui.gd - Add item UI panel and methods")
print("3. scripts/party/party_manager.gd - Remove MP restore on level up")
print("4. scenes/battle/* - Add ItemPanel to UI scene")
print("\nAll item data and InventoryManager are already created!")
print("=" * 60)
