class_name EnemyBase
extends CharacterBody2D
## Emitted on death; the world generator uses it to avoid respawning the enemy.
signal died
## Base enemy: chases the player, attacks (melee or ranged),
## can flee when the player gets too close, and drops loot on death.
## Flying enemies (flying_enemy) move freely in 2D with no gravity.

@export_group("Basic Stats")
## Maximum hit points.
@export var max_health: float = 10.0
## Base damage dealt on hit.
@export var base_attack: float = 5.0
## Flat defense that reduces incoming damage.
@export var base_defense: float = 0.0
## Resistance to knockback force.
@export var knockback_defense: float = 0.0
## Movement speed in pixels per second.
@export var speed_movement: float = 50.0
## Seconds between two consecutive attacks.
@export var attack_cooldown: float = 2.0
## Automatic step-up of 1 tile (16px) for ground enemies.
@export var step_height: float = 16.0
## Vertical offset (px) when spawning into the world; positive moves it up.
@export var spawn_y_offset: float = 0.0

@export_group("FX")
## Blood color of this enemy's death burst; the burst layers derive from it.
@export var blood_color: Color = Color(0.82, 0.11, 0.1)

@export_group("Difficulty")
## Health multiplier applied on spawn (1 = scene stats).
@export var health_multiplier: float = 1.35
## Damage multiplier applied on spawn (1 = scene stats).
@export var attack_multiplier: float = 1.25

@export_group("Enemy Config")
## No gravity; moves freely on X and Y.
@export var flying_enemy: bool = false
@export_subgroup("Ranged")
## Attack spawns a projectile instead of a melee hit.
@export var ranged_enemy: bool = false
## Projectile scene. Must implement setup(direction, speed, damage, shooter).
@export var projectile: PackedScene
## Projectile speed in pixels per second.
@export var projectile_speed: float = 200.0
## Projectile damage. Negative value uses base_attack.
@export var projectile_damage: float = -1.0
## Where the projectile spawns. Null = enemy center. Child of flip_pivot to auto-flip.
@export var projectile_spawn: Node2D
@export_subgroup("Flee")
## Enemy flees when the player gets too close.
@export var flee_enemy: bool = false
## "Too close" zone: if the player enters, the enemy flees.
@export var flee_area: Area2D

@export_group("Attack")
## Seconds from animation start until the hit (or shot) lands.
@export var attack_impact_delay: float = 0.5
## Total attack length; the enemy stands still during this time.
@export var attack_duration: float = 1.0

const DEFAULT_COIN: PackedScene = preload("res://scenes/collectables/coin.tscn")
const ITEM_PICKUP_SCENE: PackedScene = preload("res://item_pickup.tscn")


@export_group("Loot")
## Chance to drop a coin on death (deliberately low: coins are scarce).
@export_range(0.0, 1.0, 0.05) var coin_drop_chance: float = 0.45
## Coins dropped when the coin roll succeeds.
@export var coin_drop_amount: int = 1
## Item table specific to this enemy. Chances are added up into a single
## roll and, if it succeeds, one item is picked weighted by them.
@export var item_drops: Array[LootEntry] = []
## Horizontal spread (px) when dropping loot.
@export var loot_drop_spread: float = 15.0
## Vertical spread (px) when dropping loot.
@export var loot_drop_y: float = 15.0


@export_group("Nodes")
## Main sprite of the enemy.
@export var sprite: AnimatedSprite2D
## Area that detects the player.
@export var detection_area: Area2D
## Zone where the enemy can attack. For ranged, set it large (shot range).
@export var attack_range: Area2D
## Node scaled on X to flip sprite, hitbox and markers together (optional).
@export var flip_pivot: Node2D

@export_group("Animations")
## Animation name for idle / standing still.
@export var idle_animation: StringName = &"idle"
## Animation name for walking / chasing.
@export var move_animation: StringName = &"walk"
## Animation name for attacking.
@export var attack_animation: StringName = &"attack"
## True if the sprite's default facing is to the right.
@export var sprite_faces_right: bool = true


var health: float = 0.0
var defence: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _player: CharacterBody2D = null
var _player_in_attack_range: bool = false
var _player_in_flee_range: bool = false
var _is_attacking: bool = false
var _can_attack: bool = true
var _attack_timer: Timer
var _attack_range_offset_x: float = 0.0
var _projectile_spawn_offset_x: float = 0.0
var _is_dead: bool = false
var _is_facing_left: bool = false
## Active slow (frog tongue): factor and remaining seconds.
var _slow_factor: float = 1.0
var _slow_timer: float = 0.0
var _hit_tween: Tween


func _ready() -> void:
	# Global difficulty adjustment: children set their stats in `_init()` and
	# scenes may override them, so it is applied here, at the end.
	max_health = maxf(max_health * health_multiplier, 1.0)
	base_attack = maxf(base_attack * attack_multiplier, 0.0)
	health = max_health
	defence = base_defense

	# Floating mode: no floor and no "up/down", ideal for flying enemies.
	if flying_enemy:
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	# Cooldown timer: when it finishes, the enemy can attack again.
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.wait_time = attack_cooldown
	_attack_timer.timeout.connect(func(): _can_attack = true)
	add_child(_attack_timer)

	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)

	if attack_range:
		# Store the original offset so it can be mirrored when turning.
		_attack_range_offset_x = absf(attack_range.position.x)
		attack_range.body_entered.connect(_on_attack_range_body_entered)
		attack_range.body_exited.connect(_on_attack_range_body_exited)

	if flee_area:
		flee_area.body_entered.connect(_on_flee_area_body_entered)
		flee_area.body_exited.connect(_on_flee_area_body_exited)

	if projectile_spawn:
		_projectile_spawn_offset_x = absf(projectile_spawn.position.x)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	if _slow_timer > 0.0:
		_slow_timer = maxf(_slow_timer - delta, 0.0)
		if _slow_timer <= 0.0:
			_slow_factor = 1.0

	# Flying enemies are not affected by gravity.
	if not flying_enemy and not is_on_floor():
		velocity.y += gravity * delta

	# While attacking it brakes; otherwise it decides what to do.
	if _is_attacking:
		_decelerate()
	else:
		_update_behavior(delta)

	# Automatic step-up for ground enemies.
	if not flying_enemy and is_on_floor() and velocity.x != 0.0:
		_try_step_up(signf(velocity.x))

	move_and_slide()


func _try_step_up(direction: float) -> void:
	# Same check as the player: real body shape, not rays at mid-height
	# (the origin is above the feet).
	if flying_enemy or not is_on_floor() or direction == 0.0:
		return
	# Look ahead at what will be advanced this frame (+1 px) to avoid hitting it.
	var lookahead := maxf(absf(velocity.x) * get_physics_process_delta_time(), 2.0) + 1.0
	var forward := Vector2(lookahead * direction, 0.0)
	if not test_move(global_transform, forward):
		return
	# 1 extra px so it does not stay glued to the step face and can chain another climb.
	var up := Vector2(0.0, - (step_height + 1.0))
	if test_move(global_transform, up):
		return
	var raised := global_transform
	raised.origin += up
	if test_move(raised, forward, null, 0.0):
		return
	global_position += up


# ---------------------------------------------------------------------------
# Movement (split by type: ground = X only, flying = X and Y)
# ---------------------------------------------------------------------------

## Brakes gradually.
func _decelerate() -> void:
	if flying_enemy:
		velocity = velocity.move_toward(Vector2.ZERO, speed_movement)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed_movement)


## Stops abruptly (used when attacking or while in range).
func _stop() -> void:
	if flying_enemy:
		velocity = Vector2.ZERO
	else:
		velocity.x = 0.0


## to_player: vector from the enemy to the player.
func _chase(to_player: Vector2) -> void:
	if flying_enemy:
		velocity = to_player.normalized() * _current_speed()
	else:
		velocity.x = signf(to_player.x) * _current_speed()
	_play_animation(move_animation)


## Moves away from the player (opposite direction to to_player).
func _flee(to_player: Vector2) -> void:
	if flying_enemy:
		velocity = - to_player.normalized() * _current_speed()
	else:
		velocity.x = - signf(to_player.x) * _current_speed()
	_play_animation(move_animation)


# ---------------------------------------------------------------------------
# Behavior
# ---------------------------------------------------------------------------

## Re-checks the areas against the player.
## Useful after teleports or other sudden position changes,
## because body_entered/exited signals become stale.
func _refresh_area_flags() -> void:
	if not is_instance_valid(_player):
		return
	if attack_range:
		_player_in_attack_range = attack_range.overlaps_body(_player)
	if flee_area:
		_player_in_flee_range = flee_area.overlaps_body(_player)


## Priority: flee > attack > chase.
func _update_behavior(_delta: float) -> void:
	if not is_instance_valid(_player):
		_decelerate()
		_play_animation(idle_animation)
		return

	var to_player := _player.global_position - global_position
	# The enemy always looks at the player (the margin avoids flicker when overlapping).
	if absf(to_player.x) > 5.0:
		_set_facing_direction(to_player.x < 0.0)

	if flee_enemy and _player_in_flee_range:
		_flee(to_player)
	elif _player_in_attack_range:
		_stop()
		if _can_attack:
			_start_attack()
		else:
			_play_animation(idle_animation)
	else:
		_chase(to_player)


## True when the enemy hurts with its own contact hitbox (wolf), so the player
## does not add the generic body-contact hit on top of it.
func uses_custom_contact_damage() -> bool:
	return false


# ---------------------------------------------------------------------------
# Attack
# ---------------------------------------------------------------------------

func _start_attack() -> void:
	_is_attacking = true
	_can_attack = false
	_attack_timer.start(attack_cooldown)
	_play_animation(attack_animation, true)

	# Wait for the impact moment (synced with the animation).
	await get_tree().create_timer(attack_impact_delay).timeout
	if _is_dead:
		return
	_perform_attack()

	# Wait for the animation to finish before releasing the enemy.
	var remaining := attack_duration - attack_impact_delay
	if remaining > 0.0:
		await get_tree().create_timer(remaining).timeout
	if _is_dead:
		return

	_is_attacking = false


## Decision point: projectile if ranged, direct hit if not.
func _perform_attack() -> void:
	if ranged_enemy:
		_shoot_projectile()
	else:
		_perform_melee_hit()


func _perform_melee_hit() -> void:
	if not attack_range:
		return
	for body in attack_range.get_overlapping_bodies():
		if _is_valid_target(body):
			_deal_damage_to(body)


## Instantiates the projectile and passes it direction, speed and damage.
## The projectile is responsible for colliding and dealing damage.
func _shoot_projectile() -> void:
	if not projectile:
		push_warning("%s is a ranged_enemy but has no 'projectile' assigned." % name)
		return

	var parent := get_parent()
	if parent == null:
		return

	var proj := projectile.instantiate() as Node2D
	if not proj:
		push_warning("The root of the 'projectile' scene must be a Node2D.")
		return

	# Add to the tree first, then position it, so global_position is reliable.
	parent.add_child(proj)
	var spawn_pos := _get_projectile_spawn_position()
	proj.global_position = spawn_pos
	var dir := _get_projectile_direction(spawn_pos)

	# Expected contract: setup(direction: Vector2, speed: float, damage: float, shooter: Node2D)
	if proj.has_method("setup"):
		proj.setup(dir, projectile_speed, _get_projectile_damage(), self)
	elif "direction" in proj:
		# Compatibility with old projectiles that only expose the 'direction' property.
		proj.set("direction", dir)
		proj.rotation = dir.angle()
	else:
		push_warning("The projectile scene has neither setup(direction, speed, damage, shooter) nor 'direction'.")


func _get_projectile_spawn_position() -> Vector2:
	if projectile_spawn:
		return projectile_spawn.global_position
	return global_position


## Aims at the player if still detected; otherwise shoots where the enemy faces.
func _get_projectile_direction(from: Vector2) -> Vector2:
	if is_instance_valid(_player):
		return (_player.global_position - from).normalized()
	return Vector2.LEFT if _is_facing_left else Vector2.RIGHT


func _get_projectile_damage() -> float:
	return base_attack if projectile_damage < 0.0 else projectile_damage


func _deal_damage_to(body: Node2D) -> void:
	# If the target supports knockback we pass our position.
	if body.has_method("take_damage_from"):
		body.take_damage_from(base_attack, global_position)
	else:
		body.take_damage(base_attack)


# ---------------------------------------------------------------------------
# Facing and animation
# ---------------------------------------------------------------------------

func _set_facing_direction(look_left: bool) -> void:
	if _is_facing_left == look_left:
		return
	_is_facing_left = look_left

	# If the original sprite faces left, the flip logic is reversed.
	var flipped := look_left if sprite_faces_right else not look_left

	# With flip_pivot everything is flipped at once.
	if flip_pivot:
		flip_pivot.scale.x = -1.0 if flipped else 1.0
		return

	# No pivot: flip the sprite and mirror the hitbox and spawn point by hand.
	if sprite:
		sprite.flip_h = flipped
	if attack_range:
		attack_range.position.x = - _attack_range_offset_x if look_left else _attack_range_offset_x
	if projectile_spawn:
		projectile_spawn.position.x = - _projectile_spawn_offset_x if look_left else _projectile_spawn_offset_x


## With force = true it restarts the animation even if it is already the current one (useful when attacking).
func _play_animation(anim_name: StringName, force: bool = false) -> void:
	if _is_attacking and not force:
		return
	if not sprite or not sprite.sprite_frames:
		return
	if not sprite.sprite_frames.has_animation(anim_name):
		return

	if sprite.animation != anim_name or force:
		sprite.play(anim_name)


# ---------------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------------

## Checks whether the body is a valid target (mainly the player).
func _is_valid_target(body: Node2D) -> bool:
	return body.is_in_group("player")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player = body as CharacterBody2D


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_player_in_attack_range = false
		_player_in_flee_range = false


func _on_attack_range_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_attack_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_attack_range = false


func _on_flee_area_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_flee_range = true


func _on_flee_area_body_exited(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_flee_range = false


# ---------------------------------------------------------------------------
# Health and death
# ---------------------------------------------------------------------------

func take_damage(amount: float, critical: bool = false) -> void:
	if _is_dead:
		return
	var damage := amount * (amount / (amount + defence))
	health = maxf(health - damage, 0.0)
	var fx := _fx()
	if fx:
		fx.call("enemy_hit", global_position + Vector2(0.0, -20.0), damage, critical)
	if health <= 0.0:
		_die()
	else:
		_flash_hit()


func _die() -> void:
	_is_dead = true
	var fx := _fx()
	if fx:
		fx.call("enemy_death", global_position + Vector2(0.0, -20.0), blood_color)
	died.emit()
	_is_attacking = false
	_can_attack = false
	_player = null
	_player_in_attack_range = false
	_player_in_flee_range = false
	velocity = Vector2.ZERO
	if sprite:
		sprite.stop()
	# set_deferred because 'monitoring' cannot be changed during a physics callback.
	if detection_area:
		detection_area.set_deferred("monitoring", false)
	if attack_range:
		attack_range.set_deferred("monitoring", false)
	if flee_area:
		flee_area.set_deferred("monitoring", false)
	_notify_player_kill()
	_drop_loot()
	_on_death()


## Children can override it for death animations.
func _on_death() -> void:
	queue_free()


## Slows the enemy (frog tongue): 0.5 = half speed.
func apply_slow(multiplier: float, seconds: float) -> void:
	if _is_dead:
		return
	_slow_factor = clampf(multiplier, 0.1, 1.0)
	_slow_timer = maxf(seconds, 0.0)


func _current_speed() -> float:
	return speed_movement * _slow_factor


## Items it can still drop: invalid ones, zero-chance ones and passives the
## player already has are excluded (collectables do not repeat).
func _available_drops() -> Array[LootEntry]:
	var available: Array[LootEntry] = []
	for entry in item_drops:
		if entry == null or entry.item == null or entry.drop_chance <= 0.0:
			continue
		if entry.item is PassiveItems and _player_has_passive(entry.item):
			continue
		available.append(entry)
	return available


## True if the player already has that passive equipped.
func _player_has_passive(item: PassiveItems) -> bool:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return false
	var passives := player.get_node_or_null("PlayerPassives")
	if passives == null or not passives.has_method("has_passive"):
		return false
	return bool(passives.call("has_passive", item))


## Notifies the player's passives (vampirism, greed...).
func _notify_player_kill() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var passives := player.get_node_or_null("PlayerPassives")
	if passives and passives.has_method("trigger_kill_passives"):
		passives.call("trigger_kill_passives", player, self)


func _drop_loot() -> void:
	var parent := get_parent()
	if parent == null:
		return
	_drop_coins(parent)
	_drop_item(parent)


## Coins always use their own roll and can be several.
func _drop_coins(parent: Node) -> void:
	var chance := minf(coin_drop_chance + _luck_drop_bonus() + _coin_drop_bonus(), 1.0)
	if randf() > chance:
		return
	for _i in coin_drop_amount:
		_spawn_pickup(DEFAULT_COIN, parent, null)


## A single roll for all items: the total chance is the sum of the
## entries. If it succeeds, one is picked weighted by its chance.
func _drop_item(parent: Node) -> void:
	var available := _available_drops()
	var total := 0.0
	for entry in available:
		total += entry.drop_chance
	if available.is_empty():
		return
	if randf() > minf(total + _luck_drop_bonus(), 1.0):
		return

	var roll := randf() * total
	var chosen: LootEntry = available.back()
	for entry in available:
		roll -= entry.drop_chance
		if roll <= 0.0:
			chosen = entry
			break
	for _i in randi_range(chosen.min_amount, chosen.max_amount):
		_spawn_pickup(ITEM_PICKUP_SCENE, parent, chosen.item)


## Instantiates a pickup and assigns the item before it enters the scene.
func _spawn_pickup(scene: PackedScene, parent: Node, item: Items) -> void:
	var pickup := scene.instantiate()
	if pickup == null:
		return
	if item != null and "item" in pickup:
		pickup.set("item", item)
	var offset_x := randf_range(-loot_drop_spread, loot_drop_spread)
	var offset_y := randf_range(-loot_drop_y, loot_drop_y)
	var drop_position := global_position + Vector2(offset_x, offset_y)
	parent.add_child(pickup)
	# Assigning global_position after parenting avoids adding the chunk
	# offset twice; the pickup's physics starts on the next tick.
	pickup.global_position = drop_position


## Extra drop percentage points given by the player's luck (luck = 5 → +5 %).
func _luck_drop_bonus() -> float:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or not ("luck" in player):
		return 0.0
	return maxf(float(player.luck) * 0.01, 0.0)


## Extra coin chance contributed by the current player's passives.
func _coin_drop_bonus() -> float:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return 0.0
	var passives := player.get_node_or_null("PlayerPassives")
	if passives == null:
		return 0.0
	var list = passives.get("active_passives")
	if not (list is Array):
		return 0.0
	var bonus := 0.0
	for passive in list:
		if passive and passive.has_method("get_coin_drop_bonus"):
			bonus += float(passive.call("get_coin_drop_bonus"))
	return bonus


func _fx() -> Node:
	return get_tree().get_first_node_in_group("fx")


## Red flash when taking damage.
func _flash_hit() -> void:
	if not sprite:
		return
	if _hit_tween:
		_hit_tween.kill()
	sprite.modulate = Color(1.0, 0.2, 0.2)
	_hit_tween = create_tween()
	_hit_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
