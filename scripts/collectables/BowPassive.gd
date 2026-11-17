class_name BowPassive
extends PassiveItems
## Basic bow: holding the attack button charges an arrow.
## A short tap still performs the normal melee attack.

@export_group("Bow")
## Arrow scene; its root must implement `setup(direction, speed, damage, shooter)`.
@export var arrow_scene: PackedScene
## Damage of a fully charged arrow before the hold bonus.
@export var base_damage: float = 5.0
## Extra damage at `full_hold` (1.5 = +150%).
@export_range(0.0, 5.0, 0.05) var full_bonus: float = 1.5
## Minimum hold time to fire instead of a melee hit (s).
@export var min_hold: float = 0.25
## Hold time that unlocks the full bonus (s).
@export var full_hold: float = 2.0
## Arrow speed in px/s.
@export var projectile_speed: float = 420.0
## Spawn offset from the player, mirrored with the facing direction.
@export var spawn_offset: Vector2 = Vector2(24.0, -12.0)


## The player asks this before deciding between an arrow and a melee hit.
func can_fire(hold_time: float) -> bool:
	return arrow_scene != null and hold_time >= min_hold


## Called by the player on release. `hold_time` is already accumulated.
func fire_arrow(player: Node, hold_time: float, direction: Vector2) -> void:
	if not can_fire(hold_time):
		return
	var player_2d := player as Node2D
	var parent := player.get_parent()
	if player_2d == null or parent == null:
		return

	var damage := base_damage
	if hold_time >= full_hold:
		damage *= 1.0 + full_bonus

	var horizontal := 1.0 if direction.x >= 0.0 else -1.0
	var spawn_position := player_2d.global_position + Vector2(spawn_offset.x * horizontal, spawn_offset.y)
	var projectile := arrow_scene.instantiate() as Node2D
	if projectile == null:
		return
	parent.add_child(projectile)
	projectile.global_position = spawn_position
	if projectile.has_method("setup"):
		projectile.call("setup", direction.normalized(), projectile_speed, damage, player_2d)
