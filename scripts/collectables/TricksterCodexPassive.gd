class_name TricksterCodexPassive
extends PassiveItems
## Trickster codex: jumps charge projectiles for the next attack.

@export_group("Trickster codex")
## Projectile launched per accumulated jump.
@export var projectile_scene: PackedScene
## Maximum stored jumps.
@export var max_charges: int = 3
## Fraction of the player's base damage per projectile (0.05 = 5%).
@export_range(0.0, 1.0, 0.01) var damage_ratio: float = 0.05
## Projectile speed in px/s.
@export var projectile_speed: float = 320.0
## Fan opening in degrees.
@export var spread_degrees: float = 12.0
## Knockback applied when the chance succeeds.
@export var knockback_force: float = 120.0
## Chance per projectile to push the enemy (0.25 = 25%).
@export_range(0.0, 1.0, 0.05) var knockback_chance: float = 0.25

var _player: Node = null
var _charges: int = 0


func on_equip(player: Node) -> void:
	_player = player
	_charges = 0
	if player.has_signal("jumped") and not player.is_connected("jumped", _on_jumped):
		player.connect("jumped", _on_jumped)


func on_unequip(player: Node) -> void:
	if is_instance_valid(player) and player.is_connected("jumped", _on_jumped):
		player.disconnect("jumped", _on_jumped)
	_player = null
	_charges = 0


func _on_jumped() -> void:
	_charges = mini(_charges + 1, max_charges)


func on_player_attack_started(player: Node, _step: int, direction: Vector2) -> void:
	if _charges <= 0 or projectile_scene == null:
		return
	var player_2d := player as Node2D
	var parent := player.get_parent()
	if player_2d == null or parent == null:
		return

	var base_damage := 20
	var base_damage_value = player.get("hitbox_damage")
	if base_damage_value != null:
		base_damage = int(base_damage_value)
	var projectile_damage := maxi(roundi(float(base_damage) * damage_ratio), 1)
	var horizontal := 1.0 if direction.x >= 0.0 else -1.0
	var spawn_position := player_2d.global_position + Vector2(22.0 * horizontal, -12.0)
	var count := _charges

	for i in count:
		var angle := 0.0
		if count > 1:
			angle = deg_to_rad(lerpf(-spread_degrees * 0.5, spread_degrees * 0.5, float(i) / float(count - 1)))
		var projectile := projectile_scene.instantiate() as Node2D
		if projectile == null:
			continue
		parent.add_child(projectile)
		projectile.global_position = spawn_position
		if projectile.get("knockback_force") != null:
			projectile.set("knockback_force", knockback_force)
		if projectile.get("knockback_chance") != null:
			projectile.set("knockback_chance", knockback_chance)
		if projectile.has_method("setup"):
			projectile.call("setup", direction.rotated(angle), projectile_speed, float(projectile_damage), player_2d)
	_charges = 0
