class_name PoisonCloudPassive
extends PassiveItems
## Túberculos cutáneos: al recibir daño el jugador suelta una nube de veneno
## en sus pies. Tiene cooldown para que no se llene la pantalla de nubes.

const CLOUD_SCRIPT := preload("res://scripts/collectables/poison_cloud.gd")

@export_group("Nube de veneno")
## Segundos de espera entre dos nubes.
@export var cooldown_seconds: float = 4.0
## Radio de la nube (px).
@export var radius: float = 44.0
## Daño por tick a cada enemigo dentro.
@export var damage_per_tick: float = 2.0
## Segundos que dura cada nube.
@export var cloud_lifetime: float = 4.0

var _player: Node = null
var _cooldown: float = 0.0


func on_equip(player: Node) -> void:
	super.on_equip(player)
	_player = player
	_cooldown = 0.0


func on_update(_player: Node, delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)


func on_player_take_damage(amount: float, _attacker: Node = null) -> float:
	if _cooldown <= 0.0 and is_instance_valid(_player):
		_cooldown = cooldown_seconds
		# Diferido: no se puede añadir un Area2D mientras se procesan señales.
		_spawn_cloud.call_deferred()
	return amount


func _spawn_cloud() -> void:
	if not is_instance_valid(_player):
		return
	var parent := _player.get_parent()
	var player_2d := _player as Node2D
	if parent == null or player_2d == null:
		return
	var cloud := CLOUD_SCRIPT.new() as Area2D
	cloud.radius = radius
	cloud.damage_per_tick = damage_per_tick
	cloud.lifetime = cloud_lifetime
	parent.add_child(cloud)
	cloud.global_position = player_2d.global_position + Vector2(0.0, 12.0)
