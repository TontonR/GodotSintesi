extends CharacterBody2D

## Emitted once when the player dies; the game root ends the run with it.
signal died
## Emitted when a perfect parry stops a hit, passing the attacker so it can
## react (the wolf stuns its charge).
signal parried(attacker: Node)

# ==============================================================================
# CONFIGURATION AND VARIABLES
# ==============================================================================
# region Movement
@export_group("Movement")
@export var move_speed: float = 130.0
@export var acceleration: float = 750.0
@export var friction: float = 1000.0
@export var jump_velocity: float = -340.0
@export var gravity: float = 1400.0
@export var fall_gravity_multiplier: float = 1.6
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.12
## Maximum step height for auto step-up (1 tile = 16px).
@export var step_height: float = 16.0
## Duration of the visual step-up smoothing (s).
@export var step_duration: float = 0.08

# Sprite offset when stepping up: the body jumps up, the drawing does not.
var _visual_step_offset: float = 0.0
# Integer camera Y; steps are spread over several frames.
var _cam_y: float = NAN
## Player control; the fall intro disables it until landing.
var control_enabled: bool = true
## If false the camera does not follow the player (used by the fall intro).
var camera_follow_enabled: bool = true
## Fall speed cap with control disabled (0 = no cap, px/s).
var fall_speed_cap: float = 0.0
## Debug immortality (KP5): while active, takes no damage.
var immortal: bool = false
# Seconds of control lock after a knockup (wolf).
var _control_lock_timer: float = 0.0
# Temporary jump multiplier (mucus potion).
var _jump_bonus_factor: float = 1.0
var _jump_bonus_timer: float = 0.0
# Mucus particle emitter; created by passives and the slime potion.
var _moco_emitter: Node2D
# Run dust cadence and HUD pulse at low health.
var _run_dust_timer: float = 0.0
var _hud_pulse: float = 0.0
var _coins_tween: Tween
# endregion

# region Stats and Economy
@export_group("Stats and Economy")
@export var max_health: int = 100
@export var max_stamina: float = 100.0
@export var current_coins: int = 0
@export var initial_coins: int = 0

var health: int
var stamina: float
# endregion

# region Combat stats
@export_group("Combat stats")
## Attack speed multiplier (1 = normal; 1.25 = 25% faster).
@export var attack_speed: float = 1.0
## Base crit chance (0-1). Crit passives roll separately.
@export_range(0.0, 1.0, 0.01) var crit_chance: float = 0.05
## Damage multiplier for critical hits.
@export var crit_damage: float = 2.0
## Luck in percentage points: raises enemy drop chance.
@export var luck: float = 0.0
# endregion

# region Stamina mechanics
@export_group("Stamina costs")
@export var run_speed_multiplier: float = 1.7
@export var run_acceleration_multiplier: float = 1.3
@export var run_initial_cost: float = 10.0
@export var run_drain_per_second: float = 10.0
@export var guard_initial_cost: float = 15.0
@export var guard_drain_per_second: float = 20.0
@export var stamina_regen_per_second: float = 10.0
# endregion

# region Combat
@export_group("Combat")
@export var hitbox_damage: int = 20
@export var combo_window: float = 0.35
## Parry window when raising guard (s): a frontal hit inside
## this window is stopped with sparks and deals no damage.
@export var parry_window: float = 0.2
## Cooldown between parry windows (s): cannot re-arm before.
@export var parry_cooldown: float = 0.3
## Stamina returned by a parry (compensates the cost of raising guard).
@export var parry_stamina_refund: float = 30.0
## Health taken when walking through an enemy body (0 = no contact damage).
@export var body_contact_damage: int = 5
## Seconds before the same enemy can hurt the player again by contact.
@export var body_contact_cooldown: float = 1.0

const _ATTACK_ANIMS: Array[String] = ["attack_1", "attack_2", "attack_3"]
## Physics layer of the enemy bodies; the player only collides with the world.
const ENEMY_LAYER: int = 4
const STAMINA_COLOR: Color = Color(0.35, 0.82, 0.29, 1)
# endregion

# region OnReady nodes
@onready var sprite_pivot: Node2D = $SpritePivot
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $SpritePivot/AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var attack_hitboxes: Array[Area2D] = [$AttackHitbox1, $AttackHitbox2, $AttackHitbox3]
@onready var hitbox_shapes: Array[CollisionShape2D] = [
	$AttackHitbox1/CollisionShape2D,
	$AttackHitbox2/CollisionShape2D,
	$AttackHitbox3/CollisionShape2D,
]
@onready var passives: PlayerPassives = get_node_or_null("PlayerPassives")
# endregion

# Internal state variables
var health_bar: ProgressBar
var health_label: Label
var stamina_bar: ProgressBar
var stamina_label: Label
var coins_label: Label

var _hitbox_offsets: Array[Vector2] = []
var _hitbox_shape_offsets: Array[Vector2] = []
var _active_hitbox: int = 0
var _hit_targets: Array = []

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_was_pressed: bool = false
var _facing_right: bool = true
var _is_attacking: bool = false
var _is_guarding: bool = false
var _is_running: bool = false
var _is_dead: bool = false
var _combo_index: int = 0
var _combo_timer: float = 0.0
# Remaining parry time since the guard was raised.
var _parry_timer: float = 0.0
# Cooldown that prevents re-arming the parry window by spamming guard.
var _parry_cooldown_timer: float = 0.0
# Stats panel: only refreshes when a value changes.
var _stats_dirty: bool = true
var _stats_values: Array[Label] = []
# Contact damage: seconds left before each enemy can hit again (instance id → time).
var _contact_cooldowns: Dictionary = {}


# ==============================================================================
# MAIN METHODS
# ==============================================================================
func _ready() -> void:
	health = max_health
	stamina = max_stamina
	current_coins = initial_coins
	
	animated_sprite.animation_finished.connect(_on_attack_finished)
	
	for i in attack_hitboxes.size():
		_hitbox_offsets.append(attack_hitboxes[i].position + hitbox_shapes[i].position)
		_hitbox_shape_offsets.append(hitbox_shapes[i].position)
		attack_hitboxes[i].set_deferred("monitoring", false)
		attack_hitboxes[i].body_entered.connect(_on_attack_hitbox_body_entered)
		attack_hitboxes[i].area_entered.connect(_on_attack_hitbox_area_entered)
		
	_ensure_health_ui()
	_ensure_stamina_ui()
	_ensure_coins_ui()
	_ensure_stats_ui()
	_update_health_ui()
	_update_stamina_ui()
	_update_coins_ui()
	_update_stats_ui()


func _process(delta: float) -> void:
	if _stats_dirty:
		_update_stats_ui()
	# Low health: the bar pulses red so it's noticeable without looking at the number.
	if health_bar == null:
		return
	var ratio := float(health) / float(maxi(max_health, 1))
	if health > 0 and ratio <= 0.3:
		_hud_pulse += delta
		var pulse := 0.5 + 0.5 * sin(_hud_pulse * 7.0)
		health_bar.modulate = Color(1.0, 1.0 - 0.45 * pulse, 1.0 - 0.45 * pulse)
	elif health_bar.modulate != Color.WHITE:
		_hud_pulse = 0.0
		health_bar.modulate = Color.WHITE


func _try_step_up(direction: float) -> void:
	# Checked with the body's real shape: rays at mid height did not
	# see 1-tile steps (the origin is ~27 px above the feet).
	if not is_on_floor() or direction == 0.0:
		return
	var forward := Vector2(direction, 0.0)
	if not test_move(global_transform, forward):
		return
	# 1 px extra: with the feet right at step level the wall still
	# counts as a collision and two step-ups chained (2 tiles at once).
	var up := Vector2(0.0, - (step_height + 1.0))
	if test_move(global_transform, up):
		return
	var raised := global_transform
	raised.origin += up
	# safe_margin 0: resting right on the step does not count as a collision.
	if test_move(raised, forward, null, 0.0):
		return
	global_position += up
	_visual_step_offset += step_height


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_attack()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_attack()


## Debug: toggles immortality and returns the new state (KP5).
func toggle_immortal() -> bool:
	immortal = not immortal
	return immortal


## Debug: dry jump to test far zones. Cuts inertia and resets
## camera and visual step-up so the trip leaves no offsets.
func debug_teleport(offset: Vector2) -> void:
	global_position += offset
	velocity = Vector2.ZERO
	_visual_step_offset = 0.0
	sprite_pivot.position.y = 0.0
	_cam_y = NAN
	_update_camera()


func _physics_process(delta: float) -> void:
	if _is_dead:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.y += gravity * delta
		move_and_slide()
		return

	# No control (fall intro): no input, jump, attack or guard; the
	# fall speed is capped with `fall_speed_cap` so it's predictable.
	if not control_enabled:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.y += gravity * delta * fall_gravity_multiplier
		if fall_speed_cap > 0.0:
			velocity.y = minf(velocity.y, fall_speed_cap)
		move_and_slide()
		if camera_follow_enabled:
			_update_camera()
		_update_animation()
		return

	_control_lock_timer = maxf(_control_lock_timer - delta, 0.0)
	_jump_bonus_timer = maxf(_jump_bonus_timer - delta, 0.0)
	_parry_timer = maxf(_parry_timer - delta, 0.0)
	_parry_cooldown_timer = maxf(_parry_cooldown_timer - delta, 0.0)
	if _jump_bonus_timer <= 0.0:
		_jump_bonus_factor = 1.0

	_update_stamina(delta)

	# For dust on landing: check if it came from the air before moving.
	var was_on_floor := is_on_floor()

	# Combo clock
	if not _is_attacking and _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_index = 0

	# Gravity
	var current_gravity: float = gravity
	if velocity.y > 0.0:
		current_gravity *= fall_gravity_multiplier
	velocity.y += current_gravity * delta

	# Horizontal movement (A/D; arrows are left for the UI)
	var raw_direction: float = 0.0
	if Input.is_key_pressed(KEY_D):
		raw_direction += 1.0
	if Input.is_key_pressed(KEY_A):
		raw_direction -= 1.0

	var direction: float = raw_direction
	if _control_lock_timer > 0.0:
		direction = 0.0
	elif _is_guarding:
		direction = 0.0
	elif _is_attacking:
		if (_facing_right and raw_direction < 0.0) or (not _facing_right and raw_direction > 0.0):
			direction = 0.0

	# Auto step-up of 1-tile steps (before applying velocity)
	if is_on_floor() and direction != 0.0:
		_try_step_up(direction)

	# Sprite smoothing after step-up: the body is already up.
	if _visual_step_offset > 0.0:
		_visual_step_offset = move_toward(_visual_step_offset, 0.0, step_height / step_duration * delta)
		sprite_pivot.position.y = _visual_step_offset

	var effective_speed: float = move_speed * (0.38 if _is_attacking else 1.0)
	var effective_accel: float = acceleration * (0.38 if _is_attacking else 1.0)
	
	if _is_running:
		effective_speed *= run_speed_multiplier
		effective_accel *= run_acceleration_multiplier
		
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * effective_speed, effective_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# Sprite and hitbox orientation
	if not _is_attacking:
		if direction > 0.0:
			_facing_right = true
		elif direction < 0.0:
			_facing_right = false
			
	sprite_pivot.scale.x = 1.0 if _facing_right else -1.0
	animated_sprite.flip_h = false

	var mirror: float = 1.0 if _facing_right else -1.0
	for i in attack_hitboxes.size():
		attack_hitboxes[i].position = Vector2(
			_hitbox_offsets[i].x * mirror - _hitbox_shape_offsets[i].x,
			_hitbox_offsets[i].y - _hitbox_shape_offsets[i].y
		)

	# Jump
	if _is_attacking or _is_guarding:
		_jump_buffer_timer = 0.0
		_jump_was_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W)
	else:
		var jump_pressed: bool = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W)
		var jump_just_pressed: bool = jump_pressed and not _jump_was_pressed

		if jump_just_pressed:
			_jump_buffer_timer = jump_buffer_time
		else:
			_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

		if is_on_floor():
			_coyote_timer = coyote_time
		else:
			_coyote_timer = maxf(_coyote_timer - delta, 0.0)

		if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
			velocity.y = jump_velocity * _jump_bonus_factor
			_jump_buffer_timer = 0.0
			_coyote_timer = 0.0
			_dust_at(_feet_offset(), 4, 0.7)

		if not jump_pressed and _jump_was_pressed and velocity.y < 0.0:
			velocity.y *= 0.45
			
		_jump_was_pressed = jump_pressed

	var landing_speed := velocity.y
	move_and_slide()
	if not was_on_floor and is_on_floor() and landing_speed > 140.0:
		_dust_at(_feet_offset(), clampf(landing_speed / 70.0, 3.0, 9.0), 1.0)
	# Run dust: small and spaced so it doesn't cover the ground.
	if _is_running and is_on_floor() and absf(velocity.x) > 40.0:
		_run_dust_timer = maxf(_run_dust_timer - delta, 0.0)
		if _run_dust_timer <= 0.0:
			_run_dust_timer = 0.14
			_dust_at(_feet_offset() + Vector2(-signf(velocity.x) * 6.0, 0.0), 2, 0.55)
	_update_camera()
	_update_animation()
	_update_body_contact(delta)


# ==============================================================================
# COMBAT AND DAMAGE
# ==============================================================================
func _try_attack() -> void:
	if _is_dead or _is_attacking:
		return
	# Combo passive hook (projectiles, empowered hits...).
	if passives:
		passives.trigger_attack_started_passives(
			self, _combo_index + 1, Vector2(1.0 if _facing_right else -1.0, 0.0)
		)
	var anim: String = _ATTACK_ANIMS[_combo_index]
	_is_attacking = true
	_active_hitbox = _combo_index
	set_hitbox_active(true)
	# Attack speed: accelerates the animation (and with it the combo cadence).
	animated_sprite.speed_scale = attack_speed
	animated_sprite.play(anim)


func _on_attack_finished() -> void:
	_is_attacking = false
	animated_sprite.speed_scale = 1.0
	set_hitbox_active(false)
	if animated_sprite.animation in _ATTACK_ANIMS:
		_combo_index = (_combo_index + 1) % _ATTACK_ANIMS.size()
		_combo_timer = combo_window
		_update_animation()


func set_hitbox_active(active: bool) -> void:
	for i in attack_hitboxes.size():
		attack_hitboxes[i].set_deferred("monitoring", active and i == _active_hitbox)
	if active:
		_hit_targets.clear()


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	_register_hit(body)


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	_register_hit(area)


func _register_hit(target: Node) -> void:
	if not _is_attacking or target == self or _hit_targets.has(target):
		return
	_hit_targets.append(target)
	_deal_damage(target)


func _deal_damage(target: Node) -> void:
	# Active passives can modify the hit damage.
	var damage := float(hitbox_damage)
	if passives:
		damage = passives.trigger_attack_passives(target, damage)
	# Player base crit: own roll, separate from crit passives.
	var critical := randf() < crit_chance
	if critical:
		damage *= crit_damage
	var final_damage := roundi(damage)
	if target.has_method("take_damage"):
		if target is EnemyBase:
			target.take_damage(final_damage, critical)
		else:
			target.take_damage(final_damage)
	else:
		var parent := target.get_parent()
		if parent and parent.has_method("take_damage"):
			if parent is EnemyBase:
				parent.take_damage(final_damage, critical)
			else:
				parent.take_damage(final_damage)


func take_damage(amount: int) -> void:
	_apply_damage(amount, true)


## New enemies (wolf, toad, demon) also send knockback, knockup and
## control lock; those that don't pass them behave as before.
func take_damage_from(
	amount: int,
	attacker_position: Vector2,
	knockback: float = 0.0,
	knockup_lock: float = 0.0,
	knockup: float = 0.0,
	attacker: Node = null
) -> void:
	var from_front := is_attack_from_front(attacker_position)
	# If guard (or parry) stops the hit, there is no knockback or control lock.
	# Debug immortality does not change knockback: it still applies.
	if not _apply_damage(amount, from_front, attacker) and from_front and _is_guarding:
		return
	var away := signf(global_position.x - attacker_position.x)
	if is_zero_approx(away):
		away = -1.0 if _facing_right else 1.0
	if knockback > 0.0:
		velocity.x = away * knockback
	if knockup > 0.0:
		velocity.y = -knockup
	if knockup_lock > 0.0:
		_control_lock_timer = maxf(_control_lock_timer, knockup_lock)


## Used by the demon's jet to know if guard stops the hit.
func is_guarding() -> bool:
	return _is_guarding


## True from `_die()` on: the run is over and nothing can be saved or revived.
func is_dead() -> bool:
	return _is_dead


func is_attack_from_front(attacker_position: Vector2) -> bool:
	if is_equal_approx(attacker_position.x, global_position.x):
		return true
	return (attacker_position.x > global_position.x) == _facing_right


## Enemies are not solid, so crossing a body costs a contact hit: the space is
## queried with the player's own collider (its `collision_mask` is only the
## world) and each enemy can only hit again after `body_contact_cooldown`.
func _update_body_contact(delta: float) -> void:
	for id in _contact_cooldowns.keys():
		var left: float = _contact_cooldowns[id] - delta
		if left <= 0.0:
			_contact_cooldowns.erase(id)
		else:
			_contact_cooldowns[id] = left
	if body_contact_damage <= 0 or body_collision == null or body_collision.shape == null:
		return
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = body_collision.shape
	query.transform = body_collision.global_transform
	query.collision_mask = ENEMY_LAYER
	query.collide_with_areas = false
	query.collide_with_bodies = true
	for hit in get_world_2d().direct_space_state.intersect_shape(query, 12):
		var enemy := hit["collider"] as EnemyBase
		if enemy == null:
			continue
		# Enemies that already hurt with their own hitbox (wolf) must not take
		# a second contact hit on top of it.
		if enemy.uses_custom_contact_damage():
			continue
		var id := enemy.get_instance_id()
		if _contact_cooldowns.has(id):
			continue
		_contact_cooldowns[id] = body_contact_cooldown
		# Same path as an enemy hit, so a frontal guard or parry still stops it.
		take_damage_from(body_contact_damage, enemy.global_position, 0.0, 0.0, 0.0, enemy)


## Applies damage and returns true only if the hit actually removed health (guard
## and parry return false so the attacker does not push the player).
func _apply_damage(amount: int, from_front: bool, attacker: Node = null) -> bool:
	if _is_dead or immortal:
		return false
	if _is_guarding and from_front:
		# Parry: the hit lands inside the perfect guard window.
		if _parry_timer > 0.0:
			_parry_timer = 0.0
			_parry_cooldown_timer = parry_cooldown
			# Parrying returns stamina: keeps guard alive and rewards timing.
			restore_stamina(parry_stamina_refund)
			var fx := _fx()
			if fx:
				fx.call("parry", global_position + Vector2(0.0, -26.0))
			if attacker != null:
				parried.emit(attacker)
		# Guard stops the frontal hit (notice for block passives).
		if passives:
			passives.trigger_blocked_passives(self)
		return false
	# Active passives can reduce (or increase) incoming damage
	var final_amount := amount
	if passives:
		final_amount = maxi(roundi(passives.trigger_take_damage_passives(float(amount), attacker)), 0)
	# Compact mucus eats flat damage (more particles, more defense).
	final_amount = maxi(final_amount - moco_defense(), 0)
	health = maxi(health - final_amount, 0)
	_update_health_ui()
	if final_amount > 0:
		var fx := _fx()
		if fx:
			fx.call("player_hit", global_position + Vector2(0.0, -26.0), final_amount)
	if health <= 0:
		_die()
	return true


func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	_update_health_ui()
	if amount > 0:
		var fx := _fx()
		if fx:
			fx.call("heal", global_position + Vector2(0.0, -20.0), amount)


# ==============================================================================
# STATS (passives)
# ==============================================================================
## Raises max health without healing: the new gap stays empty.
func add_max_health(amount: int) -> void:
	max_health = maxi(max_health + amount, 1)
	health = mini(health, max_health)
	_update_health_ui()


## Raises max stamina; the current bar is clipped if needed.
func add_max_stamina(amount: float) -> void:
	max_stamina = maxf(max_stamina + amount, 1.0)
	stamina = minf(stamina, max_stamina)
	_update_stamina_ui()


## Flat extra damage per hit (mace or fang type passives).
func add_attack_bonus(amount: int) -> void:
	hitbox_damage = maxi(hitbox_damage + amount, 0)
	_stats_dirty = true


## Flat extra speed in px/s (ogre nail type passives).
func add_speed_bonus(amount: float) -> void:
	move_speed = maxf(move_speed + amount, 0.0)
	_stats_dirty = true


## Speed multiplier (light feet type passives).
func multiply_move_speed(factor: float) -> void:
	move_speed = maxf(move_speed * factor, 0.0)
	_stats_dirty = true


## Extra attack speed multiplier (1.25 = +25%).
func add_attack_speed(amount: float) -> void:
	attack_speed = maxf(attack_speed + amount, 0.1)
	_stats_dirty = true


## Extra crit chance (0-1).
func add_crit_chance(amount: float) -> void:
	crit_chance = clampf(crit_chance + amount, 0.0, 1.0)
	_stats_dirty = true


## Extra crit damage multiplier.
func add_crit_damage(amount: float) -> void:
	crit_damage = maxf(crit_damage + amount, 0.0)
	_stats_dirty = true


## Extra luck percentage points.
func add_luck(amount: float) -> void:
	luck = maxf(luck + amount, 0.0)
	_stats_dirty = true


## Jump multiplied for `seconds` (mucus potion).
func apply_jump_bonus(factor: float, seconds: float) -> void:
	_jump_bonus_factor = maxf(factor, 0.1)
	_jump_bonus_timer = maxf(seconds, 0.0)


## Creates (if needed) the mucus emitter and returns the current level.
func moco_emitter() -> Node2D:
	if _moco_emitter != null and is_instance_valid(_moco_emitter):
		return _moco_emitter
	var emitter_script := preload("res://scripts/collectables/moco_emitter.gd")
	_moco_emitter = emitter_script.new()
	_moco_emitter.name = "MocoEmitter"
	add_child(_moco_emitter)
	return _moco_emitter


## Flat defense given by mucus particles (compact mucus).
func moco_defense() -> float:
	if _moco_emitter == null or not is_instance_valid(_moco_emitter):
		return 0.0
	return float(_moco_emitter.call("get_defense"))


func _fx() -> Node:
	return get_tree().get_first_node_in_group("fx")


## Feet height above the body origin (the hitbox is 16×54 px and
## centered): dust must spawn at ground level, not mid height.
func _feet_offset() -> Vector2:
	var feet_y := 25.0
	if body_collision and body_collision.shape is RectangleShape2D:
		feet_y = (body_collision.shape as RectangleShape2D).size.y * 0.5 * body_collision.scale.y - 2.0
	return Vector2(0.0, feet_y)


func _dust_at(offset: Vector2, amount: float, strength: float = 1.0) -> void:
	var fx := _fx()
	if fx:
		fx.call("dust", global_position + offset, int(round(amount)), strength)


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	_is_guarding = false
	_is_running = false
	_is_attacking = false
	_combo_index = 0
	_combo_timer = 0.0
	animated_sprite.speed_scale = 1.0
	set_hitbox_active(false)
	velocity = Vector2.ZERO
	animated_sprite.play("death")
	died.emit()


# ==============================================================================
# STAMINA AND COINS
# ==============================================================================
func add_coin(amount: int = 1) -> void:
	current_coins += amount
	_update_coins_ui()
	_pop_coins_ui()


## Restores the run stats from a save, clamped to the current maxima.
func restore_run_state(saved_health: int, saved_stamina: float, saved_coins: int) -> void:
	health = clampi(saved_health, 1, max_health)
	stamina = clampf(saved_stamina, 0.0, max_stamina)
	current_coins = maxi(saved_coins, 0)
	_update_health_ui()
	_update_stamina_ui()
	_update_coins_ui()


## Coin counter pop: grows and returns to its size.
func _pop_coins_ui() -> void:
	if coins_label == null:
		return
	coins_label.pivot_offset = coins_label.size * 0.5
	if _coins_tween and _coins_tween.is_valid():
		_coins_tween.kill()
	coins_label.scale = Vector2(1.28, 1.28)
	_coins_tween = create_tween()
	_coins_tween.tween_property(coins_label, "scale", Vector2.ONE, 0.18)


func spend_coins(amount: int) -> bool:
	if current_coins < amount:
		return false
	current_coins -= amount
	_update_coins_ui()
	return true


func has_stamina(amount: float) -> bool:
	return stamina >= amount


func can_run() -> bool:
	return not _is_dead and not _is_guarding and not _is_attacking and is_on_floor() and has_stamina(run_initial_cost)


func can_guard() -> bool:
	return not _is_dead and not _is_attacking and has_stamina(guard_initial_cost)


func spend_stamina(amount: float) -> void:
	stamina = maxf(stamina - amount, 0.0)
	_update_stamina_ui()


func restore_stamina(amount: float) -> void:
	stamina = minf(stamina + amount, max_stamina)
	_update_stamina_ui()


func _update_stamina(delta: float) -> void:
	var guard_input: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_key_pressed(KEY_E)
	var run_input: bool = Input.is_key_pressed(KEY_SHIFT)

	if _is_guarding:
		if not guard_input:
			_is_guarding = false
			_parry_timer = 0.0
		else:
			spend_stamina(guard_drain_per_second * delta)
			if stamina <= 0.0:
				_is_guarding = false
				_parry_timer = 0.0
	elif guard_input and can_guard():
		_is_guarding = true
		spend_stamina(guard_initial_cost)
		# Only opens the window if not on cooldown: holding or
		# spamming guard doesn't chain parries, and each attempt costs stamina.
		if _parry_cooldown_timer <= 0.0:
			_parry_timer = parry_window
			_parry_cooldown_timer = parry_window + parry_cooldown
			_parry_ready_cue()
		else:
			_parry_timer = 0.0

	if _is_running:
		if not run_input or _is_guarding or _is_attacking or not is_on_floor():
			_is_running = false
		else:
			spend_stamina(run_drain_per_second * delta)
			if stamina <= 0.0:
				_is_running = false
	elif not _is_guarding and not _is_attacking and run_input and is_on_floor() and has_stamina(run_initial_cost):
		_is_running = true
		spend_stamina(run_initial_cost)

	if not _is_running and not _is_guarding:
		restore_stamina(stamina_regen_per_second * delta)


# ==============================================================================
# ANIMATIONS AND UI
# ==============================================================================
func _update_camera() -> void:
	# X in whole pixels: the background stops shaking. Y too, but a
	# 1-tile step (16 px) is climbed over several frames so the view doesn't jolt.
	if is_nan(_cam_y):
		_cam_y = global_position.y
	# The target is the player, not the camera: using the camera, the
	# accumulated offset would be permanent and the player would end up off the top.
	var dy := global_position.y - _cam_y
	if is_on_floor() and absf(dy) <= step_height + 2.0:
		dy = clampf(dy, -6.0, 6.0)
	_cam_y = roundf(_cam_y + dy)
	camera.global_position = Vector2(roundf(global_position.x), _cam_y)


func _update_animation() -> void:
	if _is_dead or _is_attacking:
		return
	if _is_guarding:
		animated_sprite.play("defend")
		return
	if not is_on_floor():
		if velocity.y < 0.0:
			animated_sprite.play("movement_right")
		else:
			animated_sprite.play("idle")
	elif _is_running:
		animated_sprite.play("run_right")
	elif absf(velocity.x) > 10.0:
		animated_sprite.play("movement_right")
	else:
		animated_sprite.play("idle")


func _ensure_health_ui() -> void:
	var root = get_parent()
	if root == null:
		root = get_tree().current_scene
	health_bar = root.get_node_or_null("UILayer/HealthBar") as ProgressBar
	if health_bar == null:
		health_bar = get_node_or_null("../UILayer/HealthBar") as ProgressBar
	if health_bar == null and root:
		var ui_layer = root.get_node_or_null("UILayer")
		if ui_layer == null:
			ui_layer = CanvasLayer.new()
			ui_layer.name = "UILayer"
			ui_layer.layer = 10
			root.add_child(ui_layer)
		var bg = StyleBoxFlat.new()
		bg.bg_color = Color(0.176, 0.176, 0.176, 1)
		bg.corner_radius_top_left = 6
		bg.corner_radius_top_right = 6
		bg.corner_radius_bottom_right = 6
		bg.corner_radius_bottom_left = 6
		bg.border_width_left = 2
		bg.border_width_top = 2
		bg.border_width_right = 2
		bg.border_width_bottom = 2
		bg.border_color = Color(0, 0, 0, 1)
		var fg = StyleBoxFlat.new()
		fg.bg_color = Color(0.859, 0.192, 0.192, 1)
		fg.corner_radius_top_left = 4
		fg.corner_radius_top_right = 4
		fg.corner_radius_bottom_right = 4
		fg.corner_radius_bottom_left = 4
		var bar = ProgressBar.new()
		bar.name = "HealthBar"
		bar.anchor_left = 1.0
		bar.anchor_top = 0.0
		bar.anchor_right = 1.0
		bar.anchor_bottom = 0.0
		bar.offset_left = -220.0
		bar.offset_top = 12.0
		bar.offset_right = -12.0
		bar.offset_bottom = 36.0
		bar.max_value = max_health
		bar.value = health
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", bg)
		bar.add_theme_stylebox_override("fill", fg)
		ui_layer.add_child(bar)
		health_bar = bar
	health_label = null
	if health_bar:
		health_label = _get_or_create_bar_label(health_bar, "%d / %d" % [health, max_health])


func _ensure_stamina_ui() -> void:
	var root = get_parent()
	if root == null:
		root = get_tree().current_scene
	stamina_bar = root.get_node_or_null("UILayer/StaminaBar") as ProgressBar
	if stamina_bar == null:
		stamina_bar = get_node_or_null("../UILayer/StaminaBar") as ProgressBar
	if stamina_bar == null and root:
		var ui_layer = root.get_node_or_null("UILayer")
		if ui_layer == null:
			ui_layer = CanvasLayer.new()
			ui_layer.name = "UILayer"
			ui_layer.layer = 10
			root.add_child(ui_layer)
		var bg = StyleBoxFlat.new()
		bg.bg_color = Color(0.176, 0.176, 0.176, 1)
		bg.corner_radius_top_left = 6
		bg.corner_radius_top_right = 6
		bg.corner_radius_bottom_right = 6
		bg.corner_radius_bottom_left = 6
		bg.border_width_left = 2
		bg.border_width_top = 2
		bg.border_width_right = 2
		bg.border_width_bottom = 2
		bg.border_color = Color(0, 0, 0, 1)
		var fg = StyleBoxFlat.new()
		fg.bg_color = STAMINA_COLOR
		fg.corner_radius_top_left = 4
		fg.corner_radius_top_right = 4
		fg.corner_radius_bottom_right = 4
		fg.corner_radius_bottom_left = 4
		var bar = ProgressBar.new()
		bar.name = "StaminaBar"
		bar.anchor_left = 1.0
		bar.anchor_top = 0.0
		bar.anchor_right = 1.0
		bar.anchor_bottom = 0.0
		bar.offset_left = -220.0
		bar.offset_top = 36.0
		bar.offset_right = -12.0
		bar.offset_bottom = 60.0
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", bg)
		bar.add_theme_stylebox_override("fill", fg)
		ui_layer.add_child(bar)
		stamina_bar = bar
	stamina_label = null
	if stamina_bar:
		stamina_label = _get_or_create_bar_label(stamina_bar, "%d / %d" % [roundi(stamina), roundi(max_stamina)])


func _ensure_coins_ui() -> void:
	var root = get_parent()
	if root == null:
		root = get_tree().current_scene
	coins_label = root.get_node_or_null("UILayer/coins") as Label
	if coins_label == null:
		coins_label = get_node_or_null("../UILayer/coins") as Label
	if coins_label == null and root:
		var ui_layer = root.get_node_or_null("UILayer")
		if ui_layer == null:
			ui_layer = CanvasLayer.new()
			ui_layer.name = "UILayer"
			ui_layer.layer = 10
			root.add_child(ui_layer)
		var lbl = Label.new()
		lbl.name = "coins"
		lbl.layout_mode = 0
		# Fixed rect in the top-left corner: with full-screen anchors the text
		# drifted with the viewport size and ended up over the stats panel.
		lbl.offset_left = 26.0
		lbl.offset_top = 26.0
		lbl.offset_right = 120.0
		lbl.offset_bottom = 42.0
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
		ui_layer.add_child(lbl)
		coins_label = lbl


func _get_or_create_bar_label(bar: ProgressBar, text: String) -> Label:
	var lbl: Label = bar.get_node_or_null("Label") as Label
	if lbl == null:
		lbl = Label.new()
		lbl.name = "Label"
		lbl.layout_mode = 1
		lbl.anchors_preset = 15
		lbl.anchor_right = 1.0
		lbl.anchor_bottom = 1.0
		lbl.grow_horizontal = 2
		lbl.grow_vertical = 2
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
		bar.add_child(lbl)
	lbl.text = text
	return lbl


func _update_health_ui() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if health_label:
		health_label.text = "%d / %d" % [health, max_health]


func _update_stamina_ui() -> void:
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina
	if stamina_label:
		stamina_label.text = "%d / %d" % [roundi(stamina), roundi(max_stamina)]


func _update_coins_ui() -> void:
	if coins_label:
		coins_label.text = str(current_coins)


## Subtle notice that the parry window is open (golden sparks).
func _parry_ready_cue() -> void:
	var fx := _fx()
	if fx:
		fx.call("parry_ready", global_position + Vector2(0.0, -26.0))


## Stats panel on the left, always visible and translucent.
func _ensure_stats_ui() -> void:
	var root = get_parent()
	if root == null:
		root = get_tree().current_scene
	var ui_layer = root.get_node_or_null("UILayer")
	if ui_layer == null:
		ui_layer = get_node_or_null("../UILayer")
	if ui_layer == null:
		return
	var grid := ui_layer.get_node_or_null("StatsPanel") as GridContainer
	if grid == null:
		grid = GridContainer.new()
		grid.name = "StatsPanel"
		grid.columns = 2
		grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Below the coin line (top-left, y 26..42): the panel starts at 82.
		grid.position = Vector2(5.0, 82.0)
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 0)
		# Translucent so it doesn't cover the game.
		grid.modulate = Color(1.0, 1.0, 1.0, 0.6)
		ui_layer.add_child(grid)
	if not _stats_values.is_empty():
		return
	var stat_names: Array[String] = [
		"Damage", "Atk. speed", "Crit. damage", "Crit. chance", "Speed", "Luck"
	]
	for stat_name in stat_names:
		var key := Label.new()
		key.text = stat_name
		key.mouse_filter = Control.MOUSE_FILTER_IGNORE
		key.add_theme_font_size_override("font_size", 9)
		key.add_theme_color_override("font_color", Color(0.87, 0.91, 0.87, 1.0))
		key.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
		key.add_theme_constant_override("shadow_offset_x", 1)
		key.add_theme_constant_override("shadow_offset_y", 1)
		grid.add_child(key)
		var value := Label.new()
		value.text = "0"
		value.custom_minimum_size.x = 34.0
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.mouse_filter = Control.MOUSE_FILTER_IGNORE
		value.add_theme_font_size_override("font_size", 9)
		value.add_theme_color_override("font_color", Color(1.0, 0.95, 0.7, 1.0))
		value.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
		value.add_theme_constant_override("shadow_offset_x", 1)
		value.add_theme_constant_override("shadow_offset_y", 1)
		grid.add_child(value)
		_stats_values.append(value)


func _update_stats_ui() -> void:
	_stats_dirty = false
	if _stats_values.size() < 6:
		return
	_stats_values[0].text = "%d" % hitbox_damage
	_stats_values[1].text = "%d%%" % roundi(attack_speed * 100.0)
	_stats_values[2].text = "%d%%" % roundi(crit_damage * 100.0)
	_stats_values[3].text = "%d%%" % roundi(crit_chance * 100.0)
	_stats_values[4].text = "%d" % roundi(move_speed)
	_stats_values[5].text = "%d%%" % roundi(luck)
