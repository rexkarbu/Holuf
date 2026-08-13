extends Node

## SettingsManager — M29: Mengatur preferensi player.
## Disimpan secara terpisah dari SaveManager di user://settings.json

const SETTINGS_FILE = "user://settings.json"

enum TextSpeed { SLOW, NORMAL, FAST }
enum BattleCursor { REVERT, REMEMBER }
enum DisplayMode { WINDOWED, BORDERLESS, FULLSCREEN }

# Default Settings (Konstan)
const DEFAULT_SETTINGS = {
	"text_speed": TextSpeed.NORMAL,
	"remember_cursor": BattleCursor.REVERT,
	
	"display_mode": DisplayMode.WINDOWED,
	"resolution": Vector2(1280, 720),
	"vsync": true,
	"fps_limit": 60,
	"brightness": 1.0,
	
	"vol_master": 100.0,
	"vol_music": 100.0,
	"vol_sfx": 100.0
}

var current_settings = DEFAULT_SETTINGS.duplicate()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	load_settings()

func _ensure_audio_buses() -> void:
	# Pastikan bus Music ada
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	# Pastikan bus SFX ada
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		# Convert Vector2 ke Dictionary karena JSON tidak mensupport Vector2 natively
		var data_to_save = current_settings.duplicate()
		data_to_save["resolution"] = {"x": current_settings["resolution"].x, "y": current_settings["resolution"].y}
		
		var json_str = JSON.stringify(data_to_save, "\t")
		file.store_string(json_str)

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		apply_all_settings()
		return
		
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		var json = JSON.new()
		if json.parse(json_str) == OK:
			var data = json.get_data()
			for key in current_settings.keys():
				if data.has(key):
					if key == "resolution":
						current_settings[key] = Vector2(data[key]["x"], data[key]["y"])
					else:
						# Parsing JSON sering mengembalikan float untuk int, jadi kita cast sesuai default
						if typeof(DEFAULT_SETTINGS[key]) == TYPE_INT:
							current_settings[key] = int(data[key])
						else:
							current_settings[key] = data[key]
	
	apply_all_settings()

func restore_defaults() -> void:
	current_settings = DEFAULT_SETTINGS.duplicate()
	apply_all_settings()
	save_settings()

func apply_all_settings() -> void:
	apply_display_mode()
	apply_resolution()
	apply_vsync()
	apply_fps_limit()
	apply_volumes()

# ==============================================================
# APPLY FUNCTIONS
# ==============================================================

func apply_display_mode() -> void:
	match current_settings["display_mode"]:
		DisplayMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func apply_resolution() -> void:
	# Hanya apply jika kita sedang di Windowed/Borderless
	if current_settings["display_mode"] != DisplayMode.FULLSCREEN:
		DisplayServer.window_set_size(Vector2i(current_settings["resolution"].x, current_settings["resolution"].y))
		# Boleh juga menengahkan window jika perlu, tapi set_size cukup untuk sekarang.

func apply_vsync() -> void:
	if current_settings["vsync"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func apply_fps_limit() -> void:
	var limit = current_settings["fps_limit"]
	if limit <= 0:
		Engine.max_fps = 0 # Unlimited
	else:
		Engine.max_fps = limit

func apply_volumes() -> void:
	_set_bus_volume("Master", current_settings["vol_master"])
	_set_bus_volume("Music", current_settings["vol_music"])
	_set_bus_volume("SFX", current_settings["vol_sfx"])

func _set_bus_volume(bus_name: String, percentage: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		if percentage <= 0.0:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			# Convert 0-100% linear to DB (Godot formula approximation)
			var db = linear_to_db(percentage / 100.0)
			AudioServer.set_bus_volume_db(bus_idx, db)

# Helper untuk get/set settings
func get_setting(key: String):
	return current_settings.get(key, DEFAULT_SETTINGS.get(key))

func set_setting(key: String, value) -> void:
	if current_settings.has(key):
		current_settings[key] = value
