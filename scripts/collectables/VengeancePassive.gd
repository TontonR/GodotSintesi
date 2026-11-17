class_name VengeancePassive
extends PassiveItems
## Vengeance: reaching zero stamina grants a temporary critical window.

@export_group("Vengeance")
## Extra critical chance while active (0.2 = 20%).
@export_range(0.0, 1.0, 0.05) var crit_chance: float = 0.2
## Damage multiplier of the temporary critical hit.
@export var crit_multiplier: float = 1.8
## Seconds the window lasts after stamina reaches zero.
@export var duration: float = 20.0
## The window ends when stamina goes back above this fraction.
@export_range(0.0, 1.0, 0.05) var end_stamina_ratio: float = 0.75

var _player: Node = null
var _active: bool = false
var _timer: float = 0.0


func on_equip(player: Node) -> void:
	_player = player
	_active = false
	_timer = 0.0


func on_unequip(_player: Node) -> void:
	_player = null
	_active = false
	_timer = 0.0


func on_update(player: Node, delta: float) -> void:
	if not is_instance_valid(player):
		return
	_player = player
	var stamina_value = player.get("stamina")
	var max_stamina_value = player.get("max_stamina")
	var stamina: float = float(stamina_value) if stamina_value != null else 0.0
	var max_stamina: float = float(max_stamina_value) if max_stamina_value != null else 1.0
	if not _active and stamina <= 0.0:
		_active = true
		_timer = duration
	if not _active:
		return
	_timer = maxf(_timer - delta, 0.0)
	if _timer <= 0.0 or (max_stamina > 0.0 and stamina / max_stamina > end_stamina_ratio):
		_active = false


func on_player_attack(_target: Node, damage: float) -> float:
	if _active and randf() < crit_chance:
		return damage * crit_multiplier
	return damage
