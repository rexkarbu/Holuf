extends Area2D
class_name StoryTrigger

## StoryTrigger — M71: Komponen reusable Area2D untuk memicu story event.
## Mendeteksi Player masuk, evaluasi kondisi flags, dan request event ke StoryManager.
##
## Tidak langsung memulai dialogue, battle, teleport, atau cutscene.
## Hanya MEMINTA named story event — listener konten future yang bereaksi.
##
## Ditempatkan sebagai child dari Node2D di scene world.
## Tidak perlu di-queue_free() setelah consumed — State tersimpan di StoryManager.

## ID unik untuk event ini. Wajib diisi.
@export var trigger_id: StringName = &""

## Jika true, trigger hanya bisa diterima sekali seumur hidup game (via StoryManager).
## Jika false, trigger dapat diterima lagi setiap kali Player masuk ulang.
@export var one_shot: bool = true

## Jika false, komponen ini tidak aktif sama sekali (tanpa mengganggu collision).
@export var is_enabled: bool = true

## Semua flag ini harus true agar trigger diterima.
@export var required_flags: Array[StringName] = []

## Jika SALAH SATU flag ini true, trigger ditolak.
@export var blocked_flags: Array[StringName] = []

## Signal lokal yang diemit ketika trigger berhasil diterima.
signal triggered(trigger_id: StringName)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	# Filter: hanya player yang memicu
	if not body.is_in_group(&"player"):
		return

	# Komponen ini dinonaktifkan secara lokal
	if not is_enabled:
		return

	# Validasi trigger_id
	if trigger_id == &"":
		push_warning("[StoryTrigger] trigger_id kosong pada: " + name + " — trigger diabaikan.")
		return

	# Delegasikan ke StoryManager
	var accepted := StoryManager.try_trigger(trigger_id, one_shot, required_flags, blocked_flags)
	if accepted:
		triggered.emit(trigger_id)
