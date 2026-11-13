class_name werewolf
extends EnemyBase
## Wolf: wanders its zone and, when it sees the player, charges from end to end
## of its detection area. Every two charges, the next pass is a
## jump that hits for double the base attack on landing.
## Contact damage uses the real hitbox and is checked every physics frame;
## the charge always travels its straight line before deciding whether to turn.
## A perfect parry cuts the charge and leaves it stunned (see `parry_stun_time`);
## when the stun ends it either charges again or answers with the jump.

enum State { WANDER, WINDUP, CHARGE, JUMP, RECOVER, STUN }

## Normal charges before the next pass is a jump.
const CHARGES_BEFORE_JUMP := 2

@export_group("Wander")
## Walking speed around the zone (px/s).
@export var wander_speed: float = 70.0
## Margin (px) from the zone edges to avoid leaving it.
@export var wander_edge_margin: float = 64.0
## Minimum distance (px) when picking the next walking point.
@export var wander_min_step: float = 80.0
## Minimum pause between walking points (s).
@export var wander_pause_min: float = 1.0
## Maximum pause between walking points (s).
@export var wander_pause_max: float = 2.5
## Wander radius (px) if the WorldGenerator is not found (to test it standalone).
@export var wander_radius: float = 400.0

@export_group("Charge")
## Charge speed (px/s): faster than the player's walk (130), slower than the
## sprint (221).
@export var charge_speed: float = 140.0
## Still windup time before charging (s).
@export var charge_windup: float = 0.25
## Still pause after each charge or jump, before charging again (s).
@export var attack_recovery: float = 1.5
## Fraction of the detection diameter covered by each charge.
@export var charge_distance_scale: float = 0.4
## Contact damage: minimum seconds between two hits on the same target.
@export var hit_cooldown: float = 0.5
## Vertical launch force on the first hit of each charge (px/s).
@export var knockup_force: float = 280.0
## Time (s) the player loses control after the launch.
@export var knockup_lock: float = 0.12

@export_group("Jump Attack")
## Upward jump force.
@export var jump_force: float = -350.0
## Damage multiplier on landing.
@export var jump_damage_multiplier: float = 2.0
## Impact radius when touching the ground (px).
@export var impact_radius: float = 40.0
## Maximum horizontal speed during the jump (px/s).
@export var jump_speed_max: float = 320.0

@export_group("Stun")
## Seconds it stays stunned after a perfect parry (s).
@export_range(0.1, 3.0, 0.05) var parry_stun_time: float = 0.8
## Chance that the stun is answered with the jump instead of charging again.
@export_range(0.0, 1.0, 0.05) var stun_jump_chance: float = 0.5

# ---------------------------------------------------------------------------
# Internal state
# ---------------------------------------------------------------------------
var _state: State = State.WANDER
var _state_timer: float = 0.0
var _zone_min_x: float = 0.0
var _zone_max_x: float = 0.0
var _wander_target_x: float = 0.0
var _wander_pause: float = 0.0
var _charge_dir: float = 1.0
var _charge_remaining: float = 0.0
var _charge_distance: float = 500.0
## The turn-around is only allowed once per charge.
var _charge_turned: bool = false
## The first hit of a charge launches the player into the air (knockup).
var _charge_hit_done: bool = false
var _charges_done: int = 0
## Player whose physical collision has already been excluded.
var _collision_excluded_player: CharacterBody2D = null
var _jump_vx: float = 0.0
var _jump_taken_off: bool = false
## Seconds left before it can hit by contact again.
var _hit_cooldown_left: float = 0.0
## Player whose `parried` signal is already connected (avoids double connect).
var _parry_connected: Node = null
## Attack chosen by the stun: -1 = the normal 2 + 1 cycle, 1 = charge, 2 = jump.
var _stun_next_attack: int = -1


func _init() -> void:
	max_health = 60.0
	base_attack = 10.0
	speed_movement = 75.0
	idle_animation = &"idle"
	move_animation = &"run"


func _ready() -> void:
	# Fallbacks in case the scene does not have the exports wired (like orc.gd).
	if not sprite:
		sprite = get_node_or_null("pivot/werewolf")
	if not detection_area:
		detection_area = get_node_or_null("pivot/detection_range")
	if not attack_range:
		attack_range = get_node_or_null("pivot/attack_range")
	if not flip_pivot:
		flip_pivot = get_node_or_null("pivot")

	super()

	_charge_distance = _get_detection_diameter() * charge_distance_scale

	_setup_wander_bounds()
	_pick_wander_target()
	_play_animation(idle_animation, true)
	_connect_player_parry_signal()


# ---------------------------------------------------------------------------
# Behavior: its own state machine (EnemyBase's is ignored)
# ---------------------------------------------------------------------------

func _update_behavior(delta: float) -> void:
	_ensure_player_collision_exception()
	_hit_cooldown_left = maxf(_hit_cooldown_left - delta, 0.0)
	_try_contact_damage()
	match _state:
		State.WANDER:
			if is_instance_valid(_player):
				_start_windup()
			else:
				_process_wander(delta)
		State.WINDUP:
			_process_windup(delta)
		State.CHARGE:
			_process_charge(delta)
		State.JUMP:
			_process_jump(delta)
		State.RECOVER:
			_process_recovery(delta)
		State.STUN:
			_process_stun(delta)


# ---------------------------------------------------------------------------
# Wandering around the zone
# ---------------------------------------------------------------------------

## Limits walking to the world zone where the wolf spawned.
func _setup_wander_bounds() -> void:
	var gen := get_tree().get_first_node_in_group("world_generator")
	var chunk_tiles := 0
	var safe_tiles := 0
	if gen:
		if gen.get("chunk_width_tiles") != null:
			chunk_tiles = int(gen.get("chunk_width_tiles"))
		if gen.get("safe_start_tiles") != null:
			safe_tiles = int(gen.get("safe_start_tiles"))

	if chunk_tiles > 0:
		var chunk_width_px := float(chunk_tiles) * 16.0
		var chunk_index := floori(global_position.x / chunk_width_px)
		_zone_min_x = chunk_index * chunk_width_px + wander_edge_margin
		_zone_max_x = (chunk_index + 1) * chunk_width_px - wander_edge_margin
		# In the starting chunk, do not invade the player's safe stretch.
		if chunk_index == 0 and safe_tiles > 0:
			_zone_min_x = maxf(_zone_min_x, float(safe_tiles) * 16.0 + wander_edge_margin)
	else:
		_zone_min_x = global_position.x - wander_radius
		_zone_max_x = global_position.x + wander_radius

	# Zone too narrow: better a fixed radius around the spawn.
	if _zone_max_x - _zone_min_x < wander_edge_margin * 2.0:
		_zone_min_x = global_position.x - wander_radius
		_zone_max_x = global_position.x + wander_radius


## Picks a random walking point inside the zone.
func _pick_wander_target() -> void:
	var x := randf_range(_zone_min_x, _zone_max_x)
	for _i in 4:
		if absf(x - global_position.x) >= wander_min_step:
			break
		x = randf_range(_zone_min_x, _zone_max_x)
	_wander_target_x = x


func _process_wander(delta: float) -> void:
	# Pause between points: standing still in idle.
	if _wander_pause > 0.0:
		_wander_pause -= delta
		_stop()
		_play_animation(idle_animation)
		if _wander_pause <= 0.0:
			_pick_wander_target()
		return

	# Reached the point? Then rest and look for another one.
	if absf(_wander_target_x - global_position.x) <= 4.0:
		_wander_pause = randf_range(wander_pause_min, wander_pause_max)
		return

	var dir := signf(_wander_target_x - global_position.x)
	_set_facing_direction(dir < 0.0)
	velocity.x = dir * wander_speed
	_play_animation(move_animation)


# ---------------------------------------------------------------------------
# Attack: cycle of 2 charges + 1 jump
# ---------------------------------------------------------------------------

func _start_windup() -> void:
	_ensure_player_collision_exception()
	_state = State.WINDUP
	_state_timer = charge_windup
	_stop()
	_play_animation(idle_animation, true)
	if _state_timer <= 0.0:
		_launch_attack()


func _process_windup(delta: float) -> void:
	if not is_instance_valid(_player):
		_return_to_wander()
		return

	# Still and facing the player: warning before charging.
	_set_facing_direction(_dir_to_player() < 0.0)
	_stop()
	_state_timer -= delta
	if _state_timer <= 0.0:
		_launch_attack()


## Decides the pass: what the stun chose, otherwise every two charges the
## third is a jump.
func _launch_attack() -> void:
	var forced := _stun_next_attack
	_stun_next_attack = -1
	if forced == 1:
		_start_charge()
	elif forced == 2:
		_start_jump()
	elif _charges_done >= CHARGES_BEFORE_JUMP:
		_start_jump()
	else:
		_start_charge()


func _start_charge() -> void:
	if not is_instance_valid(_player):
		_return_to_wander()
		return

	_ensure_player_collision_exception()
	_charge_dir = _dir_to_player()
	_set_facing_direction(_charge_dir < 0.0)
	_charge_remaining = _charge_distance
	_charge_turned = false
	_charge_hit_done = false
	_charges_done += 1
	_state = State.CHARGE
	_play_animation(move_animation, true)


func _process_charge(delta: float) -> void:
	# Only terrain stops the charge; the player is passed through.
	if _is_blocked_by_world():
		_begin_recovery()
		return

	# Straight line: no turning mid-charge, even if the player switches sides.
	velocity.x = _charge_dir * charge_speed
	_charge_remaining -= charge_speed * delta
	if _charge_remaining <= 0.0:
		_finish_charge_pass()


## Called at the end of the current line: only then is it decided whether to turn.
func _finish_charge_pass() -> void:
	var player_in_sight := (
		is_instance_valid(_player)
		and detection_area != null
		and detection_area.overlaps_body(_player)
	)

	if _charge_hit_done and not _charge_turned and player_in_sight:
		# Hit: a single pass back in the opposite direction.
		_charge_turned = true
		_charge_dir = -_charge_dir
		_set_facing_direction(_charge_dir < 0.0)
		_charge_remaining = _charge_distance * 0.5
		_play_animation(move_animation, true)
		return

	# On reaching the destination it stops and waits for the cooldown before repeating.
	_begin_recovery()


func _start_jump() -> void:
	if not is_instance_valid(_player):
		_return_to_wander()
		return

	var dx := _player.global_position.x - global_position.x
	_set_facing_direction(_dir_to_player() < 0.0)

	# Horizontal speed to land on the player within the arc duration.
	var airtime := 2.0 * absf(jump_force) / maxf(gravity, 1.0)
	_jump_vx = clampf(dx / airtime, -jump_speed_max, jump_speed_max)
	velocity.x = _jump_vx
	velocity.y = minf(jump_force, -1.0)
	_jump_taken_off = false
	_state = State.JUMP
	_play_animation(&"jump", true)


func _process_jump(_delta: float) -> void:
	velocity.x = _jump_vx

	if not _jump_taken_off:
		# Considered airborne as soon as physics lifts it off the ground.
		if not is_on_floor():
			_jump_taken_off = true
		return

	# Going up: "jump"; going down: "fall".
	if velocity.y < 0.0:
		_play_animation(&"jump")
	else:
		_play_animation(&"fall")

	# Landing: area hit for double the base attack.
	if is_on_floor():
		_deal_impact_damage()
		_charges_done = 0
		_begin_recovery()


## Area damage on landing (impact_radius), double the base attack.
func _deal_impact_damage() -> void:
	var damage := base_attack * jump_damage_multiplier
	for target in get_tree().get_nodes_in_group("player"):
		var node := target as Node2D
		if not node:
			continue
		if node.global_position.distance_to(global_position) <= impact_radius:
			_hit_target(node, damage)


func _begin_recovery() -> void:
	_state = State.RECOVER
	_state_timer = attack_recovery
	_stop()
	_play_animation(idle_animation, true)


func _process_recovery(delta: float) -> void:
	# Still at the destination until the cooldown passes.
	_stop()
	_play_animation(idle_animation)

	_state_timer -= delta
	if _state_timer > 0.0:
		return
	if is_instance_valid(_player):
		_start_windup()
	else:
		_return_to_wander()


## Returns to wandering (the 2 + 1 cycle counter is kept).
func _return_to_wander() -> void:
	_stun_next_attack = -1
	_state = State.WANDER
	_wander_pause = 0.0
	_stop()
	_pick_wander_target()


# ---------------------------------------------------------------------------
# Parry stun: the risk-reward answer to the charge
# ---------------------------------------------------------------------------

## Connects to the player's perfect-parry notice (idempotent: one connect).
func _connect_player_parry_signal() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or player == _parry_connected or not player.has_signal("parried"):
		return
	_parry_connected = player
	var handler := Callable(self, "_on_player_parried")
	if not player.is_connected("parried", handler):
		player.connect("parried", handler)


## Only a parry of this wolf's own hit stuns it; other attackers are ignored.
func _on_player_parried(attacker: Node) -> void:
	if attacker != self or _is_dead:
		return
	_start_stun()


## Cuts the current pass (charge or jump) and leaves it standing still.
func _start_stun() -> void:
	_state = State.STUN
	_state_timer = parry_stun_time
	_charge_hit_done = true
	_stop()
	_play_animation(idle_animation, true)
	_flash_stun()


func _process_stun(delta: float) -> void:
	# Standing still and harmless: `_try_contact_damage` ignores this state.
	_stop()
	_play_animation(idle_animation)
	_state_timer -= delta
	if _state_timer > 0.0:
		return
	# Parried in mid-air: it does not chain until it lands again.
	if not is_on_floor():
		return
	if is_instance_valid(_player):
		# Two ways out of the stun: charge again or answer with the jump.
		_stun_next_attack = 2 if randf() < stun_jump_chance else 1
		_start_windup()
	else:
		_return_to_wander()


## Bluish flash so the stun reads as a state, not as idle wandering.
func _flash_stun() -> void:
	if not sprite:
		return
	if _hit_tween:
		_hit_tween.kill()
	sprite.modulate = Color(0.65, 0.85, 1.0)
	_hit_tween = create_tween()
	_hit_tween.tween_property(sprite, "modulate", Color.WHITE, parry_stun_time)


# ---------------------------------------------------------------------------
# Contact damage (real hitbox, every physics frame)
# ---------------------------------------------------------------------------

## Hits the player if the real hitbox overlaps them and the cooldown allows it.
## Checked every physics frame (does not depend on the sprite's frames).
func _try_contact_damage() -> void:
	if _is_dead or _hit_cooldown_left > 0.0 or not attack_range:
		return
	# Deals damage during the charge and while running around (not standing in idle).
	var can_damage := _state == State.CHARGE
	if not can_damage and _state == State.WANDER:
		can_damage = sprite != null and sprite.animation == move_animation
	if not can_damage:
		return

	for body in attack_range.get_overlapping_bodies():
		var target := body as Node2D
		if not target or not target.is_in_group("player"):
			continue

		_hit_cooldown_left = hit_cooldown
		# Only the first hit of each charge launches the player into the air.
		if _state == State.CHARGE and not _charge_hit_done:
			_charge_hit_done = true
			_hit_target(target, base_attack, knockup_force)
		else:
			_hit_target(target, base_attack)
		return


## Applies damage passing our position (player's frontal guard).
func _hit_target(body: Node2D, amount: float, knockup: float = 0.0) -> void:
	var damage := roundi(amount)
	if body.has_method("take_damage_from"):
		body.take_damage_from(damage, global_position, 0.0, knockup_lock, knockup, self)
	elif body.has_method("take_damage"):
		body.take_damage(damage)


# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------

## The wolf hurts with its own contact hitbox (`_try_contact_damage`), so the
## player must not stack the generic body-contact hit on top of it.
func uses_custom_contact_damage() -> bool:
	return true


## True if the current wall collision is not with the player (the wolf passes through).
func _is_blocked_by_world() -> bool:
	if not is_on_wall():
		return false
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider()
		if collider != _player:
			return true
	return false


## Excludes collision with the player as soon as it detects them (pass-through).
func _on_detection_area_body_entered(body: Node2D) -> void:
	super(body)
	_ensure_player_collision_exception()
	_connect_player_parry_signal()


## Horizontal direction (-1/1) toward the player; with no player, where it faces.
func _dir_to_player() -> float:
	if is_instance_valid(_player):
		var dx := _player.global_position.x - global_position.x
		if not is_zero_approx(dx):
			return signf(dx)
	return -1.0 if _is_facing_left else 1.0


## Effective diameter of the detection area (larger radius × 2).
func _get_detection_diameter() -> float:
	var radius := 0.0
	if detection_area:
		for child in detection_area.get_children():
			var hitbox := child as CollisionShape2D
			if not hitbox or not hitbox.shape:
				continue
			var shape_scale := hitbox.global_transform.get_scale()
			if hitbox.shape is CircleShape2D:
				var r := (hitbox.shape as CircleShape2D).radius
				radius = maxf(radius, r * maxf(absf(shape_scale.x), absf(shape_scale.y)))
			elif hitbox.shape is RectangleShape2D:
				var half := (hitbox.shape as RectangleShape2D).size * 0.5
				radius = maxf(radius, half.x * absf(shape_scale.x))
	return maxf(radius, 1.0) * 2.0


## Excludes physical collision with the player in both directions, so as not to
## drag them. Area2Ds (detection and attack) are not affected.
func _ensure_player_collision_exception() -> void:
	if not is_instance_valid(_player) or _player == _collision_excluded_player:
		return
	_collision_excluded_player = _player
	add_collision_exception_with(_player)
	_player.add_collision_exception_with(self)
