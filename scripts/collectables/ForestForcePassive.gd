class_name ForestForcePassive
extends PassiveItems
## Forest force: periodically summons an invulnerable rat that follows the player,
## damages enemies and blocks enemy projectiles.

const RAT_SCRIPT := preload("res://scripts/collectables/forest_rat.gd")

@export_group("Forest force")
## Seconds between summons.
@export var interval: float = 15.0
## Seconds the rat stays alive.
@export var lifetime: float = 8.0
## Damage per tick to enemies it touches.
@export var damage_per_tick: float = 3.0
## Seconds between damage ticks.
@export var tick_seconds: float = 0.5
## Follow speed in px/s.
@export var speed: float = 180.0
## Blocks enemy projectiles that enter its area.
@export var block_projectiles: bool = true

var _player: Node = null
var _timer: float = 0.0
var _rat: Node2D = null


func on_equip(player: Node) -> void:
	super.on_equip(player)
	_player = player
	_timer = 0.0


func on_unequip(_player: Node) -> void:
	if _rat != null and is_instance_valid(_rat):
		_rat.queue_free()
	_rat = null
	_player = null


func on_update(player: Node, delta: float) -> void:
	if not is_instance_valid(player):
		return
	_player = player
	if _rat != null and not is_instance_valid(_rat):
		_rat = null
	if _rat != null:
		return
	_timer = maxf(_timer - delta, 0.0)
	if _timer > 0.0:
		return
	_timer = interval
	_spawn_rat()


func _spawn_rat() -> void:
	if not is_instance_valid(_player):
		return
	var parent := _player.get_parent()
	if parent == null:
		return
	var rat := RAT_SCRIPT.new() as Area2D
	if rat == null:
		return
	parent.add_child(rat)
	rat.global_position = _player.global_position + Vector2(-18.0, 10.0)
	rat.call(
		"setup",
		_player,
		damage_per_tick,
		tick_seconds,
		lifetime,
		speed,
		block_projectiles
	)
	_rat = rat
