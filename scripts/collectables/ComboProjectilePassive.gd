class_name ComboProjectilePassive
extends PassiveItems
## Launches one or several projectiles when reaching a certain attack of the rotation.
## Damage is computed as a fraction of the player base damage.

@export_group("Combo shot")
## Projectile scene that is launched.
@export var projectile_scene: PackedScene
## Every how many rotation attacks it shoots (3 = third attack).
@export var every_n_attacks: int = 3
## Fraction of the player base damage dealt by each projectile.
@export_range(0.0, 2.0, 0.01) var damage_ratio: float = 0.25
## Number of projectiles per shot.
@export var projectile_count: int = 1
## Total fan opening in degrees (0 = all in the same direction).
@export var spread_degrees: float = 0.0
## Projectile speed (px/s).
@export var projectile_speed: float = 300.0
## Offset from the player center on spawn.
@export var spawn_offset: Vector2 = Vector2(24, -10)
## Goes through every enemy instead of disappearing on the first impact.
@export var piercing: bool = false


func on_player_attack_started(player: Node, step: int, direction: Vector2) -> void:
	if projectile_scene == null or every_n_attacks <= 0:
		return
	if step % every_n_attacks != 0:
		return

	var parent := player.get_parent()
	var player_2d := player as Node2D
	if parent == null or player_2d == null:
		return

	var base_damage: int = 20
	if "hitbox_damage" in player:
		base_damage = int(player.get("hitbox_damage"))
	var projectile_damage := maxi(roundi(float(base_damage) * damage_ratio), 1)

	var horizontal := 1.0 if direction.x >= 0.0 else -1.0
	var spawn_position := player_2d.global_position + Vector2(spawn_offset.x * horizontal, spawn_offset.y)
	var count := maxi(projectile_count, 1)

	for i in count:
		var angle := 0.0
		if count > 1:
			angle = deg_to_rad(lerpf(-spread_degrees * 0.5, spread_degrees * 0.5, float(i) / float(count - 1)))
		var projectile := projectile_scene.instantiate() as Node2D
		if projectile == null:
			continue
		parent.add_child(projectile)
		projectile.global_position = spawn_position
		if "piercing" in projectile:
			projectile.set("piercing", piercing)
		if projectile.has_method("setup"):
			projectile.call("setup", direction.rotated(angle), projectile_speed, float(projectile_damage), player_2d)
