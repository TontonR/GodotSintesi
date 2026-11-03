class_name ComboProjectilePassive
extends PassiveItems
## Lanza uno o varios proyectiles al alcanzar cierto ataque de la rotación.
## El daño se calcula como una fracción del daño base del jugador.

@export_group("Disparo por combo")
## Escena del proyectil que se lanza.
@export var projectile_scene: PackedScene
## Cada cuántos ataques de la rotación se dispara (3 = tercer ataque).
@export var every_n_attacks: int = 3
## Fracción del daño base del jugador que hace cada proyectil.
@export_range(0.0, 2.0, 0.01) var damage_ratio: float = 0.25
## Número de proyectiles por disparo.
@export var projectile_count: int = 1
## Apertura total del abanico en grados (0 = todos en la misma dirección).
@export var spread_degrees: float = 0.0
## Velocidad de los proyectiles (px/s).
@export var projectile_speed: float = 300.0
## Desplazamiento desde el centro del jugador al aparecer.
@export var spawn_offset: Vector2 = Vector2(24, -10)


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
		if projectile.has_method("setup"):
			projectile.call("setup", direction.rotated(angle), projectile_speed, float(projectile_damage), player_2d)
