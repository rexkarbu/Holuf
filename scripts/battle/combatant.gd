class_name Combatant
extends RefCounted

## Kelas runtime untuk membungkus CombatantData dan menyimpan current HP.

var base_data: CombatantData
var current_hp: int


func _init(data: CombatantData) -> void:
	base_data = data
	current_hp = data.max_hp


## Mengurangi HP berdasarkan damage. Mengembalikan damage aktual yang diterima.
func take_damage(amount: int) -> int:
	var old_hp = current_hp
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	
	return old_hp - current_hp


func is_dead() -> bool:
	return current_hp <= 0
