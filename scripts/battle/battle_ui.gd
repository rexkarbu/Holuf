extends CanvasLayer

## BattleUI — menangani update visual pertempuran.
## Script ini berdiri terpisah dari BattleController untuk memudahkan iterasi UI.

@onready var title_label: Label = $Title
@onready var hint_label: Label = $Hint
@onready var log_label: Label = $LogPanel/MarginContainer/LogLabel

@onready var player_hp_label: Label = $PlayerStats/VBoxContainer/HPLabel
@onready var enemy_hp_label: Label = $EnemyStats/VBoxContainer/HPLabel

@onready var command_panel: PanelContainer = $CommandPanel

func _ready() -> void:
	command_panel.hide()


func update_player_hp(current: int, max_hp: int) -> void:
	player_hp_label.text = "HP: %d / %d" % [current, max_hp]


func update_enemy_hp(current: int, max_hp: int) -> void:
	enemy_hp_label.text = "HP: %d / %d" % [current, max_hp]


func set_turn_title(text: String) -> void:
	title_label.text = text


func add_log(text: String) -> void:
	log_label.text = text


func show_commands(show: bool) -> void:
	command_panel.visible = show


func set_hint(text: String) -> void:
	hint_label.text = text
