extends CanvasLayer

## InventoryUI — UI sederhana untuk menampilkan isi inventory.
## M27: Dipanggil dari Pause Menu. ESC menutup UI ini.
## process_mode = Node.PROCESS_MODE_ALWAYS agar merespon input saat dipause.

var _bg: ColorRect
var _vbox: VBoxContainer

func _init() -> void:
	layer = 110 # Di atas PauseMenu
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	_bg = ColorRect.new()
	_bg.color = Color(0.1, 0.1, 0.15, 0.95)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)
	
	var title = Label.new()
	title.text = "INVENTORY"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	title.position = Vector2(0, 40)
	title.size = Vector2(1280, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	var hint = Label.new()
	hint.text = "[Esc] Close"
	hint.add_theme_font_size_override("font_size", 16)
	hint.position = Vector2(0, 650)
	hint.size = Vector2(1280, 50)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)
	
	var scroll = ScrollContainer.new()
	scroll.position = Vector2(340, 150)
	scroll.size = Vector2(600, 450)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	
	_vbox = VBoxContainer.new()
	_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(_vbox)

func _ready() -> void:
	_refresh_ui()

func _refresh_ui() -> void:
	for child in _vbox.get_children():
		child.queue_free()
	
	var items = InventoryManager.inventory
	if items.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "Inventory is empty."
		empty_lbl.add_theme_font_size_override("font_size", 24)
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_vbox.add_child(empty_lbl)
		return
	
	var consumables = []
	var equipments = []
	
	for item_id in items:
		if EquipmentManager.equipment_registry.has(item_id):
			equipments.append(item_id)
		else:
			consumables.append(item_id)
			
	if not consumables.is_empty():
		var lbl = Label.new()
		lbl.text = "— CONSUMABLES —"
		lbl.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_vbox.add_child(lbl)
		for item_id in consumables:
			_add_item_to_ui(item_id, items[item_id], false)
			
	if not equipments.is_empty():
		if not consumables.is_empty():
			var space = Control.new()
			space.custom_minimum_size = Vector2(0, 10)
			_vbox.add_child(space)
			
		var lbl = Label.new()
		lbl.text = "— EQUIPMENT —"
		lbl.add_theme_color_override("font_color", Color(0.8, 0.6, 0.8))
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_vbox.add_child(lbl)
		for item_id in equipments:
			_add_item_to_ui(item_id, items[item_id], true)

func _add_item_to_ui(item_id: String, qty: int, is_equipment: bool = false) -> void:
	var display_name = item_id
	var desc = ""
	
	if is_equipment:
		var eq_data = EquipmentManager.get_equipment_data(item_id)
		if eq_data:
			display_name = eq_data.display_name
			desc = eq_data.description
	else:
		var item_data = InventoryManager.get_item_data(item_id)
		if item_data:
			display_name = item_data.display_name
			desc = item_data.description
			
	var lbl = Label.new()
	lbl.text = "%s  x%d\n  %s" % [display_name, qty, desc]
	lbl.add_theme_font_size_override("font_size", 18)
	_vbox.add_child(lbl)
	
	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 2)
	sep.color = Color(0.3, 0.3, 0.3, 0.5)
	_vbox.add_child(sep)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		queue_free()
