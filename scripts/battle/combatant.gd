class_name Combatant
extends RefCounted

## Kelas runtime untuk membungkus CombatantData dan menyimpan state seperti HP/MP/Status.

var base_data: CombatantData
var current_hp: int
var current_mp: int

var is_defending: bool = false

## Runtime — weakness types yang sudah ditemukan selama battle ini. Reset setiap battle baru.
var discovered_weaknesses: Array = []



func _init(data: CombatantData) -> void:
	base_data = data
	current_hp = data.max_hp
	current_mp = data.max_mp


## Mengurangi HP berdasarkan damage. Mengembalikan damage aktual yang diterima.
func take_damage(amount: int) -> int:
	var old_hp = current_hp
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	
	return old_hp - current_hp


func is_dead() -> bool:
	return current_hp <= 0


func can_spend_mp(amount: int) -> bool:
	return current_mp >= amount


func spend_mp(amount: int) -> void:
	current_mp -= amount
	if current_mp < 0:
		current_mp = 0


func restore_mp(amount: int) -> void:
	current_mp += amount
	if current_mp > base_data.max_mp:
		current_mp = base_data.max_mp

