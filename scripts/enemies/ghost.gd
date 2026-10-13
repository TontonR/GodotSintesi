extends EnemyBase
## Fantasma: persigue, carga, dispara y se teletransporta.
## Al huir intenta TP; si no puede, se queda y sigue atacando (no corre).
## El TP se sitúa alrededor del jugador: offsets en X e Y entre el radio
## de flee_area y el de attack_area (no hace falta círculo perfecto).
## Tras un ataque, el TP queda bloqueado tp_cooldown + post_attack_tp_delay.

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
@export var tp_cooldown: float = 4.0
## Extra TP lockout after a full attack (added to tp_cooldown).
@export var post_attack_tp_delay: float = 0.5
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
var _can_teleport: bool = true
var _hold_ground_attack: bool = false
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
	_tp_cooldown_timer.timeout.connect(func(): _can_teleport = true)
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
	# Re-busca al jugador si la detección se perdió (p. ej. tras un TP).
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	# Las señales no se actualizan al teletransportarse: se consulta de golpe.
	_refresh_area_flags()

	# La carga avanza en rango de ataque; si huye con TP, _start_teleport la pone a 0.
	if _player_in_attack_range:
		_charge_timer += delta
	else:
		_charge_timer = 0.0

	super(delta)


# ==============================================================================
# ATTACK & FLEE (EnemyBase hooks)
# ==============================================================================

## No arranca el ataque de la base hasta terminar la carga.
## Al terminar un ataque "normal" bloquea el TP tp_cooldown + post_attack_tp_delay.
## Los ataques de "aguanta el suelo" (sin TP) no reinician el cooldown completo.
func _start_attack() -> void:
	if _is_teleporting:
		return
	if _charge_timer < charge_time:
		_play_animation(idle_animation)
		return
	_charge_timer = 0.0
	# await super() espera a que el ataque termine por completo.
	await super()
	if _is_dead:
		return
	if _hold_ground_attack:
		# Solo un pequeño margen: el cooldown de TP ya está corriendo o está cerca.
		_hold_ground_attack = false
		if not _can_teleport:
			_tp_cooldown_timer.start(maxf(_tp_cooldown_timer.time_left, post_attack_tp_delay))
	else:
		_tp_cooldown_timer.start(tp_cooldown + post_attack_tp_delay)


func _chase(to_player: Vector2) -> void:
	_charge_timer = 0.0
	super(to_player)


## Huir = solo intentar TP a la zona de ataque.
## Si no puede (cooldown / sin posición), se queda quieto y sigue atacando.
func _flee(_to_player: Vector2) -> void:
	if _try_teleport():
		return

	# Sin TP disponible: no corre; aguanta el suelo y ataca si puede.
	_stop()
	if _can_attack and not _is_attacking:
		_hold_ground_attack = true
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

## Devuelve true si el TP se ha iniciado correctamente.
## Jamás durante un ataque ni si ya hay otro TP en curso.
func _try_teleport() -> bool:
	if _is_dead or _is_teleporting or _is_attacking or not _can_teleport:
		return false
	if not is_instance_valid(_player):
		return false

	# Comprobación previa: no desaparece si no hay posición posible.
	if not _find_attack_zone_position().is_finite():
		return false

	_start_teleport()
	return true


func _start_teleport() -> void:
	_can_teleport = false
	_is_teleporting = true
	_tp_applied = false
	_charge_timer = 0.0
	velocity = Vector2.ZERO

	# El lógico se agenda con la duración real de la animación (si existe).
	# Así no dependemos de animation_finished, que a veces no llega.
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

	# Refuerzo por si el timer se pierde: si la animación ya terminó, avanza.
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

## TP a la zona de ataque: se parte de la posición del jugador y se elige
## un punto en el anillo elíptico entre flee_area y attack_area.
## Cada eje usa su propio radio (rx ≠ ry), así que no hace falta círculo perfecto.
## Reintenta hasta encontrar un punto válido (incluida tp_min_travel).
## Solo entra en el bucle si attack es estrictamente mayor que flee en ambos ejes.
func _find_attack_zone_position() -> Vector2:
	if not is_instance_valid(_player):
		return Vector2.INF

	var attack_ext := _area_extents(attack_range)
	var flee_ext := _area_extents(flee_area)

	# Precondición: el anillo debe existir en ambos ejes (attack > flee + márgenes).
	# Sin esto el bucle de abajo podría no terminar nunca.
	if attack_ext.x <= flee_ext.x + tp_zone_margin * 2.0:
		return Vector2.INF
	if attack_ext.y <= flee_ext.y + tp_zone_margin * 2.0:
		return Vector2.INF

	var player_pos := _player.global_position
	# Origen de la distancia mínima: último TP si lo hay; si no, la posición actual.
	var from_pos := _last_tp_pos if _last_tp_pos.is_finite() else global_position

	# Red de seguridad: con la precondición cumplida casi siempre se sale en pocos
	# intentos; el tope evita colgar el juego si el mundo/cámara lo bloquea todo.
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
		# Nunca por encima del jugador (Y hacia abajo en Godot).
		offset.y = maxf(offset.y, 0.0)

		var candidate := _clamp_to_camera(player_pos + offset)
		if candidate.y < player_pos.y:
			continue
		if _is_blocked(candidate):
			continue
		# Debe alejarse lo suficiente del último punto de TP; si no, se reintenta.
		if candidate.distance_to(from_pos) < tp_min_travel:
			continue
		return candidate

	return Vector2.INF


## Distancia desde el origen hasta la elipse extents en la dirección dir.
## Devuelve -1 si no hay intersección válida.
func _ellipse_ray_distance(dir: Vector2, extents: Vector2) -> float:
	if extents.x <= 0.0 or extents.y <= 0.0:
		return -1.0
	var dx := dir.x / extents.x
	var dy := dir.y / extents.y
	var denom := dx * dx + dy * dy
	if denom <= 0.0:
		return -1.0
	return 1.0 / sqrt(denom)


## Mitades globales (rx, ry) de la primera forma del área.
## Con escala no uniforme un círculo se comporta como elipse: cada eje se mide aparte.
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


## Duración en segundos de una animación (0 si no existe).
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

	# Se desvanece antes de eliminarse.
	if _has_anim(vanish_animation):
		_is_teleporting = true
		_play_animation(vanish_animation, true)
		# Red de seguridad por si no llega animation_finished.
		get_tree().create_timer(1.0).timeout.connect(queue_free, CONNECT_ONE_SHOT)
	else:
		queue_free()
