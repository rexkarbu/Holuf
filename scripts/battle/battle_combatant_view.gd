class_name BattleCombatantView
extends Node2D

## BattleCombatantView — placeholder visual untuk satu combatant di Battle Arena.
## Tidak mengandung combat logic. Hanya presentation.

var combatant: Combatant = null
var _base_color: Color = Color.WHITE
var _polygon: Polygon2D = null
var _name_label: Label = null
var _indicator_label: Label = null
var _is_ko: bool = false
var _is_enemy: bool = false

# Warna placeholder untuk Party (development only)
const PARTY_COLORS: Array = [
	Color(0.20, 0.60, 1.00, 1),  # Slot 0 - Biru (Hero)
	Color(0.20, 0.90, 0.40, 1),  # Slot 1 - Hijau (B)
	Color(0.75, 0.30, 1.00, 1),  # Slot 2 - Ungu (C)
	Color(0.15, 0.90, 0.90, 1),  # Slot 3 - Cyan (D)
]

# Warna placeholder untuk Enemies (development only)
const ENEMY_COLORS: Array = [
	Color(0.90, 0.20, 0.30, 1),  # Slot 0 - Merah (Forest Beast)
	Color(1.00, 0.55, 0.10, 1),  # Slot 1 - Oranye (Wolf)
	Color(0.90, 0.80, 0.10, 1),  # Slot 2 - Kuning
]

# ==============================================================
# SETUP
# ==============================================================

func setup_party(c: Combatant, slot_index: int) -> void:
	combatant = c
	_is_enemy = false
	var color = PARTY_COLORS[slot_index % PARTY_COLORS.size()]
	_build_visual(color, Vector2(50, 68))

func setup_enemy(c: Combatant, slot_index: int) -> void:
	combatant = c
	_is_enemy = true
	var color = ENEMY_COLORS[slot_index % ENEMY_COLORS.size()]
	_build_visual(color, Vector2(64, 88))

func _build_visual(color: Color, size: Vector2) -> void:
	_base_color = color
	var hw = size.x / 2.0
	var hh = size.y / 2.0

	# Placeholder polygon (trapezoid)
	_polygon = Polygon2D.new()
	_polygon.color = color
	_polygon.polygon = PackedVector2Array([
		Vector2(-hw * 0.72, -hh),
		Vector2( hw * 0.72, -hh),
		Vector2( hw, hh),
		Vector2(-hw, hh),
	])
	add_child(_polygon)

	# Indicator label above sprite (turn marker / target arrow)
	_indicator_label = Label.new()
	_indicator_label.text = ""
	_indicator_label.add_theme_font_size_override("font_size", 14)
	_indicator_label.custom_minimum_size = Vector2(80, 0)
	_indicator_label.position = Vector2(-40.0, -hh - 26.0)
	_indicator_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_indicator_label)

	# Name label below sprite
	_name_label = Label.new()
	_name_label.text = c_display_name()
	_name_label.add_theme_font_size_override("font_size", 11)
	_name_label.custom_minimum_size = Vector2(100, 0)
	_name_label.position = Vector2(-50.0, hh + 3.0)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_name_label)

func c_display_name() -> String:
	if combatant == null: return "???"
	return combatant.base_data.display_name

# ==============================================================
# STATE UPDATES
# ==============================================================

func set_current_actor(is_current: bool) -> void:
	if _is_ko or _polygon == null: return
	if is_current:
		_polygon.color = _base_color.lightened(0.30)
		_indicator_label.text = "▼ TURN"
		_indicator_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.30, 1))
	else:
		_polygon.color = _base_color
		_indicator_label.text = ""

func set_targeted(is_targeted: bool) -> void:
	if _is_ko or _polygon == null: return
	if is_targeted:
		_polygon.color = _base_color.lightened(0.20)
		_indicator_label.text = "▼ TARGET"
		_indicator_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35, 1))
	else:
		_polygon.color = _base_color
		_indicator_label.text = ""

func set_ko() -> void:
	if _is_ko: return
	_is_ko = true
	if _polygon == null: return
	_polygon.color = Color(_base_color.r * 0.25, _base_color.g * 0.25, _base_color.b * 0.25, 0.55)
	if _name_label:
		_name_label.text = c_display_name() + " [KO]"
		_name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
	if _indicator_label:
		_indicator_label.text = "✕"
		_indicator_label.add_theme_color_override("font_color", Color(0.55, 0.1, 0.1, 1))

func set_defeated() -> void:
	# Enemy defeated — hide from arena
	hide()
