extends EnemyBase
## Fantasma: Aproximación -> Ataque -> TP Lejano -> Huida fluida y acotada

enum State {IDLE, CHASING, ATTACKING, TELEPORTING, RETREATING}

const FACING_DEADZONE := 5.0
const SCREEN_MARGIN := 30.0

@export_group("Animaciones Extra")
@export var vanish_animation: StringName = &"vanish"
@export var appear_animation: StringName = &"appear"

@export_group("Movimiento Espectral")
@export var acceleration: float = 6.0
@export var float_amplitude_y: float = 12.0
@export var float_amplitude_x: float = 5.0
@export var float_frequency: float = 2.5
@export var hover_height: float = 20.0
@export var vertical_follow_speed: float = 2.0

@export_group("Jugosidad Visual")
@export var max_tilt_angle: float = 12.0
@export var lean_speed: float = 8.0
@export var float_squash_amount: float = 0.08

@export_group("Ataque a Distancia")
@export var projectile_scene: PackedScene
@export var charge_time: float = 0.4
@export var charge_tint: Color = Color(1.0, 0.6, 1.0)
@export var projectile_spawn_delay: float = 0.15

@export_group("Rango Cercano & Huida")
@export var near_range: Area2D
@export var retreat_speed_multiplier: float = 1.6
@export var max_flee_time: float = 1.8
@export var flee_tp_check_interval: float = 0.3
@export_range(0.0, 1.0) var tp_chance_during_flee: float = 0.35

@export_group("Teletransporte Lejano")
@export var tp_cooldown: float = 4.0
@export var tp_min_distance_x: float = 250.0
@export var tp_max_distance_x: float = 380.0
@export var tp_min_height_above_player: float = 35.0
@export var tp_max_height_above_player: float = 80.0
@export var tp_min_distance_from_player: float = 220.0
@export var tp_min_vertical_separation: float = 25.0
@export var tp_attempts: int = 20
@export var invulnerable_while_teleporting: bool = true

@onready var spawn_point: Node2D = get_node_or_null("Pivot/SpawnPoint")

var _state: State = State.IDLE
var _charge_timer: float = 0.0
var _float_time: float = 0.0
var _current_tilt: float = 0.0
var _player_dir: float = 1.0

# Dirección fija durante la huida.
var _flee_direction_x: float = 1.0

var _flee_timer: float = 0.0
var _flee_tp_check_timer: float = 0.0
var _can_teleport: bool = true

var _shoot_timer: Timer
var _tp_cooldown_timer: Timer
var _body_shape: CollisionShape2D


func _init() -> void:
	max_health = 40.0
	speed_movement = 85.0
	move_animation = &"chase"
	attack_duration = 0.5
	uses_gravity = false


func _ready() -> void:
	if not sprite:
		sprite = get_node_or_null("Pivot/ghost")

	if not detection_area:
		detection_area = get_node_or_null("Pivot/detection_area")

	if not attack_range:
		attack_range = get_node_or_null("Pivot/attack_range")

	if not near_range:
		near_range = get_node_or_null("Pivot/near_range")

	flip_pivot = get_node_or_null("Pivot")

	super()

	add_to_group("ghost")
	set_collision_mask_value(2, false)

	_body_shape = get_node_or_null("ghost_hitbox")

	# Temporizador de disparo.
	_shoot_timer = Timer.new()
	_shoot_timer.one_shot = true
	_shoot_timer.timeout.connect(_on_shoot_timeout)
	add_child(_shoot_timer)

	# Temporizador de teletransporte.
	_tp_cooldown_timer = Timer.new()
	_tp_cooldown_timer.one_shot = true
	_tp_cooldown_timer.timeout.connect(_on_tp_cooldown_timeout)
	add_child(_tp_cooldown_timer)

	if sprite:
		if not sprite.animation_finished.is_connected(_on_animation_finished):
			sprite.animation_finished.connect(_on_animation_finished)

		if not sprite.animation_looped.is_connected(_on_animation_finished):
			sprite.animation_looped.connect(_on_animation_finished)

		_play_animation(idle_animation, true)


# ==============================================================================
# COMPORTAMIENTO PRINCIPAL
# ==============================================================================

func _update_behavior(delta: float) -> void:
	# Durante el teletransporte no se ejecuta el comportamiento normal.
	if _state == State.TELEPORTING:
		velocity = velocity.lerp(Vector2.ZERO, minf(delta * 10.0, 1.0))
		_apply_visual_juice(delta)
		return

	# Flotación ambiental.
	_float_time += delta * float_frequency

	var target_v := Vector2(
		cos(_float_time * 0.7) * float_amplitude_x,
		sin(_float_time) * float_amplitude_y
	)

	# Buscar al jugador si todavía no tenemos una referencia válida.
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if not is_instance_valid(_player):
		_state = State.IDLE
		_set_charge(0.0)
		_play_animation(idle_animation)

		velocity = velocity.lerp(target_v, minf(acceleration * delta, 1.0))
		_apply_visual_juice(delta)
		return

	# Dirección hacia el jugador.
	var dx := _player.global_position.x - global_position.x

	if absf(dx) > FACING_DEADZONE:
		_player_dir = signf(dx)

	# Comprobar las áreas.
	_player_in_attack_range = (
		attack_range != null
		and attack_range.overlaps_body(_player)
	)

	var player_in_detection := (
		detection_area != null
		and detection_area.overlaps_body(_player)
	)

	var player_in_near := (
		near_range != null
		and near_range.overlaps_body(_player)
	)

	# --------------------------------------------------------------------------
	# MÁQUINA DE ESTADOS
	# --------------------------------------------------------------------------

	match _state:
		State.IDLE, State.CHASING:
			# 1. HUIR SI EL JUGADOR SE ACERCA DEMASIADO.
			if player_in_near:
				_start_retreating()

				# Si ha comenzado a huir sin teletransportarse,
				# aplicar movimiento desde este mismo ciclo.
				if _state == State.RETREATING:
					target_v = _update_flee_physics(delta, target_v)

			# 2. ATACAR SI ESTÁ DENTRO DEL RANGO DE ATAQUE.
			elif _player_in_attack_range:
				_state = State.CHASING

				_set_charge(_charge_timer + delta)

				if _charge_timer >= charge_time:
					_start_attack()

			# 3. PERSEGUIR.
			elif player_in_detection:
				_state = State.CHASING

				_set_charge(0.0)

				target_v.x += _player_dir * speed_movement

				_follow_player_height(target_v)

				_play_animation(move_animation)

			# 4. REPOSO.
			else:
				_state = State.IDLE

				_set_charge(0.0)

				_play_animation(idle_animation)

		State.RETREATING:
			target_v = _update_flee_physics(delta, target_v)

		State.ATTACKING:
			target_v.x = move_toward(
				target_v.x,
				0.0,
				speed_movement * 0.5 * delta
			)

		State.TELEPORTING:
			pass

	# Orientación visual.
	if _state == State.RETREATING:
		_set_facing_direction(_flee_direction_x < 0.0)
	elif _state != State.IDLE and _state != State.TELEPORTING:
		_set_facing_direction(_player_dir < 0.0)

	# Aplicar la velocidad deseada.
	velocity = velocity.lerp(
		target_v,
		minf(acceleration * delta, 1.0)
	)

	_apply_visual_juice(delta)


# ==============================================================================
# HUIDA
# ==============================================================================

func _start_retreating() -> void:
	if not is_instance_valid(_player):
		return

	# Intentar teletransportarse al iniciar la huida.
	if _can_teleport and randf() < tp_chance_during_flee:
		start_teleport()
		return

	_state = State.RETREATING

	_set_charge(0.0)

	_flee_timer = max_flee_time
	_flee_tp_check_timer = flee_tp_check_interval

	# Calcular la dirección opuesta al jugador.
	var dx := global_position.x - _player.global_position.x

	if absf(dx) > 0.01:
		_flee_direction_x = signf(dx)
	else:
		# Si ambos están alineados, escapar hacia un lado.
		_flee_direction_x = - _player_dir

	if absf(_flee_direction_x) < 0.01:
		_flee_direction_x = 1.0

	_play_animation(move_animation)


func _update_flee_physics(
	delta: float,
	out_target_v: Vector2
) -> Vector2:
	_flee_timer -= delta
	_flee_tp_check_timer -= delta

	# Al finalizar el tiempo de huida, volver a perseguir.
	if _flee_timer <= 0.0:
		_state = State.CHASING
		_set_charge(0.0)
		return out_target_v

	# Intento periódico de teletransporte.
	if _flee_tp_check_timer <= 0.0:
		_flee_tp_check_timer = flee_tp_check_interval

		if _can_teleport and randf() < tp_chance_during_flee:
			start_teleport()
			return Vector2.ZERO

	# Movimiento horizontal de huida.
	out_target_v.x = (
		_flee_direction_x
		* speed_movement
		* retreat_speed_multiplier
	)

	# Seguir la altura del jugador sin perder la velocidad de huida.
	if is_instance_valid(_player):
		var desired_y := _player.global_position.y - hover_height
		var diff_y := desired_y - global_position.y

		out_target_v.y = clampf(
			diff_y * vertical_follow_speed,
			- speed_movement,
			speed_movement
		)

	_play_animation(move_animation)

	return out_target_v


# ==============================================================================
# SEGUIMIENTO VERTICAL
# ==============================================================================

func _follow_player_height(out_target_v: Vector2) -> void:
	if vertical_follow_speed <= 0.0:
		return

	if not is_instance_valid(_player):
		return

	var desired_y := _player.global_position.y - hover_height
	var diff_y := desired_y - global_position.y

	out_target_v.y += clampf(
		diff_y * vertical_follow_speed,
		- speed_movement,
		speed_movement
	)


# ==============================================================================
# ATAQUE
# ==============================================================================

func _start_attack() -> void:
	if _state == State.ATTACKING or _state == State.TELEPORTING:
		return

	_state = State.ATTACKING

	_set_charge(0.0)

	_play_animation(attack_animation, true)

	_shoot_timer.start(maxf(projectile_spawn_delay, 0.01))

	# Efecto visual de compresión.
	if flip_pivot:
		var tw := create_tween()

		tw.tween_property(
			flip_pivot,
			"scale",
			flip_pivot.scale * Vector2(1.2, 0.8),
			0.08
		)

		tw.tween_property(
			flip_pivot,
			"scale",
			Vector2(signf(flip_pivot.scale.x), 1.0),
			0.12
		)


func _on_shoot_timeout() -> void:
	if _is_dead:
		return

	if not projectile_scene or not is_instance_valid(_player):
		start_teleport()
		return

	var projectile := projectile_scene.instantiate() as Node2D

	if not projectile:
		start_teleport()
		return

	var origin: Vector2 = (
		spawn_point.global_position
		if is_instance_valid(spawn_point)
		else global_position
	)

	var dir := (_player.global_position - origin).normalized()

	if "direction" in projectile:
		projectile.set("direction", dir)

	projectile.rotation = dir.angle()
	projectile.z_index = 10

	get_tree().current_scene.add_child(projectile)
	projectile.global_position = origin

	# Tras disparar, intentar teletransportarse.
	if _can_teleport:
		start_teleport()
	else:
		_state = State.IDLE


# ==============================================================================
# TELETRANSPORTE
# ==============================================================================

func start_teleport() -> void:
	if _is_dead:
		return

	if _state == State.TELEPORTING:
		return

	if not _can_teleport:
		return

	_can_teleport = false

	_shoot_timer.stop()

	_set_charge(0.0)

	_state = State.TELEPORTING

	# Detener el movimiento durante el efecto.
	velocity = Vector2.ZERO

	if _has_anim(vanish_animation):
		_play_animation(vanish_animation, true)
	else:
		_execute_teleport()


func _execute_teleport() -> void:
	if _is_dead:
		return

	if is_instance_valid(_player):
		var pos := _find_teleport_position()

		if pos.is_finite():
			global_position = pos
		else:
			# No se ha encontrado una posición segura.
			# Mantener la posición actual en vez de aparecer cerca.
			_end_teleport()
			return

	if _has_anim(appear_animation):
		_play_animation(appear_animation, true)
	else:
		_end_teleport()


func _end_teleport() -> void:
	if _is_dead:
		return

	_state = State.IDLE

	velocity = Vector2.ZERO

	_set_charge(0.0)

	_tp_cooldown_timer.start(tp_cooldown)


func _on_tp_cooldown_timeout() -> void:
	_can_teleport = true


func _on_animation_finished() -> void:
	if not sprite:
		return

	match sprite.animation:
		vanish_animation:
			if _is_dead:
				queue_free()
			elif _state == State.TELEPORTING:
				_execute_teleport()

		appear_animation:
			if not _is_dead and _state == State.TELEPORTING:
				_end_teleport()


# ==============================================================================
# BÚSQUEDA DE UNA POSICIÓN DE TELETRANSPORTE
# ==============================================================================

func _find_teleport_position() -> Vector2:
	if not is_instance_valid(_player):
		return Vector2.INF

	var player_pos := _player.global_position

	for i in range(maxi(tp_attempts, 1)):
		# Elegir un lado aleatorio.
		var side := -1.0 if randf() < 0.5 else 1.0

		# Distancia horizontal.
		var distance_x := randf_range(
			tp_min_distance_x,
			maxf(tp_min_distance_x, tp_max_distance_x)
		)

		# Altura sobre el jugador.
		var height := randf_range(
			tp_min_height_above_player,
			maxf(tp_min_height_above_player, tp_max_height_above_player)
		)

		var candidate := player_pos + Vector2(
			side * distance_x,
			- height
		)

		# Respetar los límites de la cámara.
		var pos := _clamp_to_camera(candidate)

		# Comprobar las distancias después de limitar la posición.
		var actual_dx := absf(pos.x - player_pos.x)
		var actual_dy := player_pos.y - pos.y

		if actual_dx < tp_min_distance_from_player:
			continue

		if actual_dy < tp_min_vertical_separation:
			continue

		# Comprobar colisiones.
		if test_move(Transform2D(0.0, pos), Vector2.ZERO):
			continue

		return pos

	# Ninguna posición cumple los requisitos.
	return Vector2.INF


func _clamp_to_camera(pos: Vector2) -> Vector2:
	var cam := get_viewport().get_camera_2d()

	if not cam:
		return pos

	var center := cam.get_screen_center_position()

	var half := (
		get_viewport_rect().size / cam.zoom / 2.0
		- Vector2.ONE * SCREEN_MARGIN
	)

	# Evitar límites invertidos si la cámara es muy pequeña.
	half.x = maxf(half.x, 0.0)
	half.y = maxf(half.y, 0.0)

	return pos.clamp(
		center - half,
		center + half
	)


# ==============================================================================
# EFECTOS VISUALES
# ==============================================================================

func _apply_visual_juice(delta: float) -> void:
	if not flip_pivot:
		return

	var move_pct := 0.0

	if speed_movement > 0.0:
		move_pct = clampf(
			velocity.x / speed_movement,
			-1.0,
			1.0
		)

	var target_tilt := move_pct * deg_to_rad(max_tilt_angle)

	_current_tilt = lerp_angle(
		_current_tilt,
		target_tilt,
		minf(lean_speed * delta, 1.0)
	)

	flip_pivot.rotation = _current_tilt

	var cycle := sin(_float_time * 2.0)

	var scale_y := 1.0 + cycle * float_squash_amount
	var scale_x := 1.0 - cycle * float_squash_amount * 0.5

	if sprite:
		sprite.scale = Vector2(scale_x, scale_y)


# ==============================================================================
# CARGA DEL ATAQUE
# ==============================================================================

func _set_charge(value: float) -> void:
	_charge_timer = value

	if sprite:
		var charge_ratio := clampf(
			value / maxf(charge_time, 0.001),
			0.0,
			1.0
		)

		sprite.self_modulate = Color.WHITE.lerp(
			charge_tint,
			charge_ratio
		)


# ==============================================================================
# ANIMACIONES Y DAÑO
# ==============================================================================

func _has_anim(anim: StringName) -> bool:
	return (
		sprite != null
		and sprite.sprite_frames != null
		and sprite.sprite_frames.has_animation(anim)
	)


func _is_valid_target(body: Node2D) -> bool:
	return body != self and body.is_in_group("player")


func take_damage(amount: float) -> void:
	if (
		invulnerable_while_teleporting
		and _state == State.TELEPORTING
	):
		return

	super.take_damage(amount)


func _on_death() -> void:
	if _shoot_timer:
		_shoot_timer.stop()

	if _tp_cooldown_timer:
		_tp_cooldown_timer.stop()

	_set_charge(0.0)

	if _body_shape:
		_body_shape.set_deferred("disabled", true)

	if _has_anim(vanish_animation):
		_state = State.TELEPORTING
		_play_animation(vanish_animation, true)
	else:
		queue_free()
