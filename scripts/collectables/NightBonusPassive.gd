class_name NightBonusPassive
extends PassiveItems

@export_group("Night Bonus")
## Attack multiplier while it is night (1.15 = +15%).
@export var damage_multiplier: float = 1.15
## Movement speed multiplier while it is night (1.15 = +15%).
@export var speed_multiplier: float = 1.15
## Day/night cycle node, relative to the player.
@export var night_node_path: NodePath = ^"../day_night"

var _player: Node = null
var _night: Node = null
var _applied_attack: int = 0
var _applied_speed: float = 0.0
var _is_active: bool = false


func on_equip(player: Node) -> void:
	_player = player
	_night = player.get_node_or_null(night_node_path)
	_refresh()


func on_unequip(_player: Node) -> void:
	_set_bonus(false)


func on_update(_player: Node, _delta: float) -> void:
	_refresh()


func _refresh() -> void:
	var night_now := false
	if is_instance_valid(_night) and _night.has_method("is_night"):
		# `call` returns Variant: it is forced to bool to keep the type.
		night_now = bool(_night.call("is_night"))
	_set_bonus(night_now)


## Activates or removes the bonus. It only acts when the state changes, so it can
## be called every frame without stacking multipliers.
func _set_bonus(active: bool) -> void:
	if not is_instance_valid(_player) or not ("hitbox_damage" in _player and "move_speed" in _player):
		return
	if active == _is_active:
		return
	# Values without our bonus: the flat bonuses of other passives still count.
	var base_attack := int(_player.hitbox_damage) - _applied_attack
	var base_speed := float(_player.move_speed) - _applied_speed
	var attack := roundi(float(base_attack) * (damage_multiplier - 1.0)) if active else 0
	var speed := base_speed * (speed_multiplier - 1.0) if active else 0.0
	_player.hitbox_damage += attack - _applied_attack
	_player.move_speed += speed - _applied_speed
	_applied_attack = attack
	_applied_speed = speed
	_is_active = active
