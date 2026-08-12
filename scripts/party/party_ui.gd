extends CanvasLayer

## PartyUI — UI Manajemen Party sederhana berbasis teks.
## Dibuka dari World scene menggunakan tombol T.
## R = Remove Active Member | Enter = Select/Add/Swap | Esc/T = Close/Cancel

var bg: ColorRect
var active_vbox: VBoxContainer
var reserve_vbox: VBoxContainer
var feedback_label: Label

var active_labels: Array[Label] = []    # Label per slot (termasuk EMPTY)
var reserve_labels: Array[Label] = []

var is_selecting_active: bool = true
var active_cursor: int = 0
var reserve_cursor: int = 0
var selected_active_index: int = -1     # -1 = belum ada yang dipilih

var _feedback_timer: float = 0.0

func _init() -> void:
	layer = 100
	
	bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var title = Label.new()
	title.text = "PARTY MANAGEMENT"
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.2))
	title.position = Vector2(0, 40)
	title.size = Vector2(1280, 50)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(title)
	
	var hint = Label.new()
	hint.text = "[W/S] Navigate   [A/D] Switch Column   [Enter] Select/Add   [R] Remove   [T/Esc] Close"
	hint.add_theme_font_size_override("font_size", 16)
	hint.position = Vector2(0, 650)
	hint.size = Vector2(1280, 50)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)
	
	# Feedback label (untuk pesan error sementara)
	feedback_label = Label.new()
	feedback_label.text = ""
	feedback_label.add_theme_font_size_override("font_size", 18)
	feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	feedback_label.position = Vector2(0, 610)
	feedback_label.size = Vector2(1280, 36)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(feedback_label)
	
	var hbox = HBoxContainer.new()
	hbox.position = Vector2(100, 150)
	hbox.size = Vector2(1080, 450)
	hbox.add_theme_constant_override("separation", 50)
	add_child(hbox)
	
	var active_panel = _create_column("ACTIVE")
	active_vbox = active_panel.get_node("MarginContainer/VBoxContainer") as VBoxContainer
	hbox.add_child(active_panel)
	
	var reserve_panel = _create_column("RESERVE")
	reserve_vbox = reserve_panel.get_node("MarginContainer/VBoxContainer") as VBoxContainer
	hbox.add_child(reserve_panel)

func _create_column(title_text: String) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var margin = MarginContainer.new()
	margin.name = "MarginContainer"
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	vbox.add_child(title)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	return panel

func _ready() -> void:
	_refresh_ui()

func _process(delta: float) -> void:
	if _feedback_timer > 0.0:
		_feedback_timer -= delta
		if _feedback_timer <= 0.0:
			feedback_label.text = ""

func _show_feedback(msg: String) -> void:
	feedback_label.text = msg
	_feedback_timer = 2.5

# ==============================================================
# UI REFRESH
# ==============================================================

func _refresh_ui() -> void:
	# Clear old labels
	for lbl in active_labels: lbl.queue_free()
	for lbl in reserve_labels: lbl.queue_free()
	active_labels.clear()
	reserve_labels.clear()
	
	# --- Active column: selalu tampilkan 4 slot ---
	for i in range(PartyManager.MAX_ACTIVE):
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 20)
		if i < PartyManager.active_party.size():
			var cid = PartyManager.active_party[i]
			var data = PartyManager.roster[cid]
			lbl.text = "  " + data.display_name
			lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			lbl.text = "  [EMPTY]"
			lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		active_vbox.add_child(lbl)
		active_labels.append(lbl)
	
	# --- Reserve column ---
	for i in range(PartyManager.reserve_party.size()):
		var cid = PartyManager.reserve_party[i]
		var data = PartyManager.roster[cid]
		var lbl = Label.new()
		lbl.text = "  " + data.display_name
		lbl.add_theme_font_size_override("font_size", 20)
		reserve_vbox.add_child(lbl)
		reserve_labels.append(lbl)
	
	# Pastikan kursor aktif dalam range anggota nyata
	var real_active_count = PartyManager.active_party.size()
	if active_cursor >= real_active_count:
		active_cursor = max(0, real_active_count - 1)
	if reserve_cursor >= reserve_labels.size():
		reserve_cursor = max(0, reserve_labels.size() - 1)
	
	_update_cursors()

# ==============================================================
# CURSOR UPDATE
# ==============================================================

func _update_cursors() -> void:
	var real_active = PartyManager.active_party.size()
	
	# Reset active labels
	for i in range(active_labels.size()):
		if i < real_active:
			var text = PartyManager.roster[PartyManager.active_party[i]].display_name
			if i == selected_active_index:
				active_labels[i].text = "[S] " + text
				active_labels[i].add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
			else:
				active_labels[i].text = "  " + text
				active_labels[i].add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			active_labels[i].text = "  [EMPTY]"
			active_labels[i].add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	
	# Reset reserve labels
	for i in range(reserve_labels.size()):
		var text = PartyManager.roster[PartyManager.reserve_party[i]].display_name
		reserve_labels[i].text = "  " + text
		reserve_labels[i].add_theme_color_override("font_color", Color(1, 1, 1))
	
	# Apply active highlight (hanya pada member nyata)
	if is_selecting_active:
		if active_cursor < real_active:
			var text = PartyManager.roster[PartyManager.active_party[active_cursor]].display_name
			if active_cursor == selected_active_index:
				active_labels[active_cursor].text = "[S]> " + text
			else:
				active_labels[active_cursor].text = "> " + text
			active_labels[active_cursor].add_theme_color_override("font_color", Color(1, 1, 0.4))
	else:
		if reserve_labels.size() > 0 and reserve_cursor < reserve_labels.size():
			var text = PartyManager.roster[PartyManager.reserve_party[reserve_cursor]].display_name
			reserve_labels[reserve_cursor].text = "> " + text
			reserve_labels[reserve_cursor].add_theme_color_override("font_color", Color(1, 1, 0.4))

# ==============================================================
# INPUT
# ==============================================================

func _unhandled_input(event: InputEvent) -> void:
	# --- Close / Cancel ---
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("party_menu"):
		get_viewport().set_input_as_handled()
		if selected_active_index != -1:
			selected_active_index = -1
			is_selecting_active = true
			_update_cursors()
		else:
			PartyManager.close_party_ui()
		return
	
	# --- Remove Active Member (R) ---
	if event.is_action_pressed("party_remove"):
		get_viewport().set_input_as_handled()
		if is_selecting_active and active_cursor < PartyManager.active_party.size():
			var char_id = PartyManager.active_party[active_cursor]
			var ok = PartyManager.remove_from_active(char_id)
			if ok:
				selected_active_index = -1
				_refresh_ui()
			else:
				_show_feedback("At least one active party member is required.")
		return
	
	# --- Switch column (A/D or Left/Right) ---
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") or \
	   (event is InputEventKey and (event.keycode == KEY_A or event.keycode == KEY_D) and event.pressed and not event.echo):
		get_viewport().set_input_as_handled()
		if selected_active_index == -1:
			is_selecting_active = not is_selecting_active
			_update_cursors()
		return
	
	# --- Navigate Down ---
	if event.is_action_pressed("ui_down") or (event is InputEventKey and event.keycode == KEY_S and event.pressed and not event.echo):
		get_viewport().set_input_as_handled()
		if is_selecting_active:
			var real_count = PartyManager.active_party.size()
			if real_count > 0:
				active_cursor = (active_cursor + 1) % real_count
		else:
			if reserve_labels.size() > 0:
				reserve_cursor = (reserve_cursor + 1) % reserve_labels.size()
		_update_cursors()
		return
	
	# --- Navigate Up ---
	if event.is_action_pressed("ui_up") or (event is InputEventKey and event.keycode == KEY_W and event.pressed and not event.echo):
		get_viewport().set_input_as_handled()
		if is_selecting_active:
			var real_count = PartyManager.active_party.size()
			if real_count > 0:
				active_cursor = (active_cursor - 1 + real_count) % real_count
		else:
			if reserve_labels.size() > 0:
				reserve_cursor = (reserve_cursor - 1 + reserve_labels.size()) % reserve_labels.size()
		_update_cursors()
		return
	
	# --- Enter / Accept ---
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_handle_accept()
		return

func _handle_accept() -> void:
	if is_selecting_active:
		# Pilih Active member untuk di-swap
		if PartyManager.active_party.size() > 0 and active_cursor < PartyManager.active_party.size():
			selected_active_index = active_cursor
			is_selecting_active = false  # Pindah ke Reserve untuk memilih target
			_update_cursors()
	else:
		if selected_active_index != -1:
			# Mode swap: active[selected] ↔ reserve[cursor]
			if reserve_labels.size() > 0:
				PartyManager.swap_members(selected_active_index, reserve_cursor)
				selected_active_index = -1
				is_selecting_active = true
				_refresh_ui()
		else:
			# Tidak ada yang dipilih di active → coba add reserve ke slot kosong
			if reserve_labels.size() > 0:
				var char_id = PartyManager.reserve_party[reserve_cursor]
				var ok = PartyManager.add_to_active(char_id)
				if ok:
					_refresh_ui()
				else:
					# Active sudah penuh → minta pilih dulu siapa yang mau di-swap
					_show_feedback("Party is full. Select an Active member first to swap.")
