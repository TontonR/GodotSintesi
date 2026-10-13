extends EnemyBase
## Fantasma: persigue, carga, dispara y se teletransporta.
## Al huir intenta TP; si no puede, se queda y sigue atacando (no corre).
## El TP se sitúa alrededor del jugador: offsets en X e Y entre el radio
## de flee_area y el de attack_area (no hace falta círculo perfecto).
## La Y del destino varía al azar, pero nunca queda por debajo del jugador
## (ni, por tanto, por debajo del suelo).

@export_group("Extra Animations")
## Animation played when disappearing before a teleport.
@export var vanish_animation: StringName = &"vanish"
## Animation played when reappearing after a teleport.
@export var appear_animation: StringName = &"appear"

@export_group("Attack")
## Seconds the ghost must stay in range before shooting.
@export var charge_time: float = 0.4

@export_group("Teleport")
## Seconds before the ghost can teleport again.
@export var tp_cooldown: float = 8.0
## Margin (px) outside flee and inside attack when picking a spot.
@export var tp_zone_margin: float = 10.0
## Minimum distance (px) between the previous and the new TP spot.
@export var tp_min_travel: float = 80.0
## How many random spots to try before giving up.
@export var tp_attempts: int = 12
## Ghost cannot be damaged while teleporting.
@export var invulnerable_while_teleporting: bool = true

const SCREEN_MARGIN := 30.0

var _is_teleporting: bool = false
var _tp_applied: bool = false
var _charge_timer: float = 0.0
var _last_tp_pos := Vector2.INF

var _tp_cooldown_timer: Timer
var _body_shape: CollisionShape2D


func _init() -> void:
	max_health = 40.0
	speed_movement = 85.0
	move_animation = &"chase"
	attack_impact_delay = 0.6
	attack_duration = 1.75
	flying_enemy = true
	flee_enemy = true
	ranged_enemy = true


func _ready() -> void:
	if not sprite:
		sprite = get_node_or_null("Pivot/ghost")
	if not detection_area:
		detection_area = get_node_or_null("Pivot/detection_area")
	if not attack_range:
		attack_range = get_node_or_null("Pivot/attack_range")
	if not flee_area:
		flee_area = get_node_or_null("Pivot/flee_range")
	if not projectile_spawn:
		projectile_spawn = get_node_or_null("Pivot/SpawnPoint")
	if not flip_pivot:
		flip_pivot = get_node_or_null("Pivot")

	super()

	add_to_group("ghost")
	set_collision_mask_value(2, false)

	_body_shape = get_node_or_null("ghost_hitbox")

	_tp_cooldown_timer = Timer.new()
	_tp_cooldown_timer.one_shot = true
	add_child(_tp_cooldown_timer)

	if sprite:
		if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)
		if not sprite.animation_looped.is_connected(_on_animation_finished):
			sprite.animation_looped.connect(_on_animation_finished)
		_play_animation(idle_animation, true)


func _physics_process(delta: float) -> void:
	if _is_teleporting:
		velocity = velocity.move_toward(Vector2.ZERO, speed_movement)
		move_and_slide()
		return
	super(delta)


func _update_behavior(delta: float) -> void:
	_refresh_area_flags()

	if _player_in_attack_range:
		_charge_timer += delta
	else:
		_charge_timer = 0.0

	super(delta)


# ==============================================================================
# ATTACK & FLEE (EnemyBase hooks)
# ==============================================================================

func _start_attack() -> void:
	if _is_teleporting:
		return
	if _charge_timer < charge_time:
		_play_animation(idle_animation)
		return
	_charge_timer = 0.0
	await super()


func _chase(to_player: Vector2) -> void:
	_charge_timer = 0.0
	super(to_player)


func _flee(_to_player: Vector2) -> void:
	if _try_teleport():
		return

	_stop()
	if _can_attack and not _is_attacking:
		_start_attack()
	else:
		_play_animation(idle_animation)


func take_damage(amount: float) -> void:
	if invulnerable_while_teleporting and _is_teleporting:
		return
	super(amount)


# ==============================================================================
# TELEPORT
# ==============================================================================

func _try_teleport() -> bool:
	if _is_dead or _is_teleporting or _is_attacking or not _tp_cooldown_timer.is_stopped():
		return false
	if not is_instance_valid(_player):
		return false

	if not _find_attack_zone_position().is_finite():
		return false

	_start_teleport()
	return true


func _start_teleport() -> void:
	_is_teleporting = true
	_tp_applied = false
	_charge_timer = 0.0
	velocity = Vector2.ZERO

	var vanish_dur := _anim_duration(vanish_animation)
	if vanish_dur > 0.0:
		_play_animation(vanish_animation, true)
		get_tree().create_timer(vanish_dur).timeout.connect(_execute_teleport, CONNECT_ONE_SHOT)
	else:
		_execute_teleport()


func _execute_teleport() -> void:
	if _is_dead or not _is_teleporting or _tp_applied:
		return
	_tp_applied = true

	var pos := _find_attack_zone_position()
	if pos.is_finite():
		_last_tp_pos = pos
		global_position = pos
		_refresh_area_flags()

	var appear_dur := _anim_duration(appear_animation)
	if appear_dur > 0.0:
		_play_animation(appear_animation, true)
		get_tree().create_timer(appear_dur).timeout.connect(_end_teleport, CONNECT_ONE_SHOT)
	else:
		_end_teleport()


func _end_teleport() -> void:
	if _is_dead:
		return
	_is_teleporting = false
	_tp_applied = false
	velocity = Vector2.ZERO
	_tp_cooldown_timer.start(tp_cooldown)


func _on_animation_finished() -> void:
	if not sprite or _is_dead or not _is_teleporting:
		return

	match sprite.animation:
		vanish_animation:
			if not _tp_applied:
				_execute_teleport()
		appear_animation:
			if _tp_applied:
				_end_teleport()


# ==============================================================================
# POSITION SEARCH
# ==============================================================================

func _find_attack_zone_position() -> Vector2:
	if not is_instance_valid(_player):
		return Vector2.INF

	var attack_ext := _area_extents(attack_range)
	var flee_ext := _area_extents(flee_area)

	if attack_ext.x <= flee_ext.x + tp_zone_margin * 2.0:
		return Vector2.INF
	if attack_ext.y <= flee_ext.y + tp_zone_margin * 2.0:
		return Vector2.INF

	var player_pos := _player.global_position
	var from_pos := _last_tp_pos if _last_tp_pos.is_finite() else global_position

	var flee_keep_out := flee_ext + Vector2.ONE * tp_zone_margin
	var attack_keep_in := attack_ext - Vector2.ONE * tp_zone_margin

	var max_tries := maxi(tp_attempts, 1) * 20
	for i in range(max_tries):
		var angle := randf() * TAU
		var dir := Vector2.from_angle(angle)

		var d_flee := _ellipse_ray_distance(dir, flee_ext)
		var d_attack := _ellipse_ray_distance(dir, attack_ext)
		if d_flee < 0.0 or d_attack < 0.0:
			continue

		var d_min := d_flee + tp_zone_margin
		var d_max := d_attack - tp_zone_margin
		if d_min >= d_max:
			continue

		var offset := dir * randf_range(d_min, d_max)
		offset.y = minf(offset.y, 0.0)

		var candidate := _clamp_to_camera(player_pos + offset)
		candidate.y = minf(candidate.y, player_pos.y)

		if not _is_inside_ellipse(candidate, player_pos, attack_keep_in):
			continue
		if _is_inside_ellipse(candidate, player_pos, flee_keep_out):
			continue
		if _is_blocked(candidate):
			continue
		if candidate.distance_to(from_pos) < tp_min_travel:
			continue
		return candidate

	return Vector2.INF


func _is_inside_ellipse(point: Vector2, center: Vector2, extents: Vector2) -> bool:
	if extents.x <= 0.0 or extents.y <= 0.0:
		return false
	var rel := (point - center) / extents
	return rel.length_squared() < 1.0


func _ellipse_ray_distance(dir: Vector2, extents: Vector2) -> float:
	if extents.x <= 0.0 or extents.y <= 0.0:
		return -1.0
	var dx := dir.x / extents.x
	var dy := dir.y / extents.y
	var denom := dx * dx + dy * dy
	if denom <= 0.0:
		return -1.0
	return 1.0 / sqrt(denom)


func _area_extents(area: Area2D) -> Vector2:
	if not area:
		return Vector2.ZERO

	var extents := Vector2.ZERO
	for child in area.get_children():
		var cs := child as CollisionShape2D
		if not cs or cs.disabled or not cs.shape:
			continue

		var s := cs.global_transform.get_scale()
		var shape := cs.shape
		if shape is CircleShape2D:
			var r := (shape as CircleShape2D).radius
			extents.x = maxf(extents.x, r * absf(s.x))
			extents.y = maxf(extents.y, r * absf(s.y))
		elif shape is RectangleShape2D:
			var half := (shape as RectangleShape2D).size * 0.5
			extents.x = maxf(extents.x, half.x * absf(s.x))
			extents.y = maxf(extents.y, half.y * absf(s.y))

	return extents


func _is_blocked(pos: Vector2) -> bool:
	return test_move(Transform2D(0.0, pos), Vector2.ZERO)


func _clamp_to_camera(pos: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if not cam:
		return pos

	var center := cam.get_screen_center_position()
	var half := get_viewport_rect().size / cam.zoom / 2.0 - Vector2.ONE * SCREEN_MARGIN
	half.x = maxf(half.x, 0.0)
	half.y = maxf(half.y, 0.0)

	return pos.clamp(center - half, center + half)


# ==============================================================================
# ANIMATIONS & DEATH
# ==============================================================================

func _has_anim(anim: StringName) -> bool:
	return (
		sprite != null
		and sprite.sprite_frames != null
		and sprite.sprite_frames.has_animation(anim)
	)


func _anim_duration(anim: StringName) -> float:
	if not _has_anim(anim):
		return 0.0
	var frames := sprite.sprite_frames.get_frame_count(anim)
	var speed := sprite.sprite_frames.get_animation_speed(anim)
	if frames <= 0 or speed <= 0.0:
		return 0.0
	return frames / speed


func _is_valid_target(body: Node2D) -> bool:
	return body != self and body.is_in_group("player")


func _on_death() -> void:
	if _tp_cooldown_timer:
		_tp_cooldown_timer.stop()
	_charge_timer = 0.0

	if _body_shape:
		_body_shape.set_deferred("disabled", true)

	if _has_anim(vanish_animation):
		_is_teleporting = true
		_play_animation(vanish_animation, true)
		get_tree().create_timer(1.0).timeout.connect(queue_free, CONNECT_ONE_SHOT)
	else:
		queue_free()
