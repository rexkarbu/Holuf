extends Node

## BattleSpeed — Autoload untuk mengelola kecepatan presentasi pertempuran.
## M22: Centralized battle speed control (x1, x2)

enum Speed { NORMAL, FAST }

const SPEED_MULTIPLIERS = {
	Speed.NORMAL: 1.0,
	Speed.FAST: 2.0
}

var current_speed: Speed = Speed.NORMAL

## Get current speed multiplier for timing calculations
func get_multiplier() -> float:
	return SPEED_MULTIPLIERS[current_speed]

## Toggle between NORMAL and FAST
func toggle_speed() -> void:
	if current_speed == Speed.NORMAL:
		current_speed = Speed.FAST
	else:
		current_speed = Speed.NORMAL
	print("[BattleSpeed] Toggled to x%.1f" % get_multiplier())

## Get display text for current speed
func get_display_text() -> String:
	match current_speed:
		Speed.NORMAL:
			return "Speed x1"
		Speed.FAST:
			return "Speed x2"
		_:
			return "Speed x1"

## Create a speed-aware timer
## Usage: await BattleSpeed.wait(1.0)
func wait(base_duration: float) -> Signal:
	var effective_duration = base_duration / get_multiplier()
	return get_tree().create_timer(effective_duration).timeout
