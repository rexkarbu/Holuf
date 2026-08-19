extends Node
class_name StoryTransitionGate

## StoryTransitionGate — M71: Komponen child opsional dari TransitionZone.
## Mengontrol TransitionZone.is_enabled berdasarkan story flags dari StoryManager.
## TIDAK memodifikasi logika transisi inti M67.
##
## Desain:
##   TransitionZone (parent)
##   └── StoryTransitionGate (child ini)
##
## TransitionZone.is_enabled yang efektif:
##   = base_enabled (authored di editor) AND conditions_met(required_flags, blocked_flags)
##
## Ketika story flag berubah, gate me-refresh langsung tanpa polling per frame.

## Semua flag ini harus true agar TransitionZone diaktifkan oleh gate.
@export var required_flags: Array[StringName] = []

## Jika salah satu flag ini true, TransitionZone dinonaktifkan oleh gate.
@export var blocked_flags: Array[StringName] = []

## Referensi parent TransitionZone. Dicari secara otomatis saat _ready.
var _parent_zone: TransitionZone = null

## Nilai is_enabled yang di-author di editor (base authored state).
## Gate tidak boleh mengaktifkan zone yang memang sengaja dinonaktifkan
## karena alasan di luar kontrol story.
var _base_enabled: bool = true


func _ready() -> void:
	var parent = get_parent()
	if not parent is TransitionZone:
		push_error(
			"[StoryTransitionGate] Parent bukan TransitionZone pada: " + str(get_path()) +
			" — gate tidak aktif."
		)
		return

	_parent_zone = parent as TransitionZone
	# Simpan base_enabled dari authored editor state
	_base_enabled = _parent_zone.is_enabled

	# Subscribe ke perubahan story flag
	StoryManager.story_flag_changed.connect(_on_story_flag_changed)

	# Evaluasi kondisi awal
	_refresh()


## Dipanggil setiap kali story flag berubah. Refresh langsung.
func _on_story_flag_changed(_flag_id: StringName, _value: bool) -> void:
	_refresh()


## Hitung dan terapkan effective is_enabled ke parent TransitionZone.
func _refresh() -> void:
	if _parent_zone == null or not is_instance_valid(_parent_zone):
		return
	var story_allows := StoryManager.conditions_met(required_flags, blocked_flags)
	_parent_zone.is_enabled = _base_enabled and story_allows
