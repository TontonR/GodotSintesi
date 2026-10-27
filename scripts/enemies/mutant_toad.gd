class_name mutant_toad
extends EnemyBase
## Sapo mutante: se desplaza a saltos altos. Cada tercer aterrizaje lanza una
## ráfaga de proyectiles hacia el jugador. Si el jugador no está cerca, salta en
## direcciones aleatorias alrededor del punto donde apareció.

enum State { IDLE, JUMP, ATTACK }

## Aterrizajes necesarios entre una ráfaga y la siguiente.
const JUMPS_PER_VOLLEY := 3

@export_group("Salto")
## Fuerza vertical del salto (negativo = hacia arriba).
@export var jump_force: float = -420.0
## Velocidad horizontal durante el salto (px/s).
@export var hop_speed: float = 150.0
## Pausa mínima en el suelo entre saltos (s).
@export var jump_wait_min: float = 0.8
## Pausa máxima en el suelo entre saltos (s).
@export var jump_wait_max: float = 1.4
## Radio (px) alrededor del spawn para los saltos aleatorios sin jugador.
@export var wander_radius: float = 350.0

@export_group("Ataque")
## Proyectiles lanzados en cada ráfaga.
@export var projectiles_per_volley: int = 3
## Desviación aleatoria máxima de cada proyectil respecto al jugador (grados).
@export var projectile_spread_degrees: float = 12.0
## Tiempo de aviso antes de disparar la ráfaga (s).
@export var shoot_delay: float = 0.7
## Color al que parpadea el sapo durante el aviso previo al disparo.
@export var windup_tint: Color = Color(1.8, 1.7, 0.8)

var _state: State = State.IDLE
var _state_timer: float = 0.0
var _jumps_done: int = 0
var _jump_dir: float = 1.0
var _jump_taken_off: bool = false
var _spawn_position: Vector2 = Vector2.ZERO
var _collision_excluded_player: CharacterBody2D = null
var _windup_tween: Tween = null


func _init() -> void:
	max_health = 50.0
	base_attack = 8.0
	idle_animation = &"idle"
	move_animation = &"jump"


func _ready() -> void:
	# Fallbacks por si la escena no trae los exports cableados.
	if not sprite:
		sprite = get_node_or_null("pivot/mutant_toad")
	if not detection_area:
		detection_area = get_node_or_null("pivot/detection_range")
	if not projectile_spawn:
		projectile_spawn = get_node_or_null("pivot/muzzle")
	if not flip_pivot:
		flip_pivot = get_node_or_null("pivot")

	super()

	_spawn_position = global_position
	_state_timer = _pick_wait()
	_play_animation(idle_animation, true)


# ---------------------------------------------------------------------------
# Comportamiento: máquina de estados propia (se ignora la de EnemyBase)
# ---------------------------------------------------------------------------

func _update_behavior(delta: float) -> void:
	_ensure_player_collision_exception()
	match _state:
		State.IDLE:
			_process_idle(delta)
		State.JUMP:
			_process_jump(delta)
		State.ATTACK:
			_process_attack(delta)


# ---------------------------------------------------------------------------
# Saltos y merodeo
# ---------------------------------------------------------------------------

func _process_idle(delta: float) -> void:
	_face_player_if_visible()
	_stop()
	_play_animation(idle_animation)
	_state_timer -= delta
	if _state_timer <= 0.0 and is_on_floor():
		_start_jump()


func _start_jump() -> void:
	var dir: float = 0.0
	if is_instance_valid(_player):
		dir = signf(_player.global_position.x - global_position.x)
		if is_zero_approx(dir):
			dir = -1.0 if _is_facing_left else 1.0
	else:
		# Sin jugador: salto aleatorio, volviendo hacia el spawn si se aleja.
		dir = -1.0 if randf() < 0.5 else 1.0
		var dx: float = global_position.x - _spawn_position.x
		if absf(dx) > wander_radius:
			dir = -signf(dx)

	_set_facing_direction(dir < 0.0)
	_jump_dir = dir
	velocity.x = dir * hop_speed
	velocity.y = minf(jump_force, -1.0)
	_jump_taken_off = false
	_state = State.JUMP
	_play_animation(move_animation, true)


func _process_jump(_delta: float) -> void:
	# El salto cuenta como iniciado cuando la física lo saca del suelo.
	if not _jump_taken_off:
		if not is_on_floor():
			_jump_taken_off = true
		return

	velocity.x = _jump_dir * hop_speed
	if is_on_floor():
		_on_land()


func _on_land() -> void:
	_jumps_done += 1
	if _jumps_done >= JUMPS_PER_VOLLEY:
		_jumps_done = 0
		_start_attack()
	else:
		_state = State.IDLE
		_state_timer = _pick_wait()
		_stop()
		_play_animation(idle_animation, true)


# ---------------------------------------------------------------------------
# Ataque: ráfaga de proyectiles
# ---------------------------------------------------------------------------

func _start_attack() -> void:
	_state = State.ATTACK
	_state_timer = shoot_delay
	_stop()
	_play_animation(attack_animation, true)
	_start_windup_tween()


func _process_attack(delta: float) -> void:
	_stop()
	_face_player_if_visible()
	_state_timer -= delta
	if _state_timer > 0.0:
		return

	_fire_volley()
	_stop_windup_tween()
	_state = State.IDLE
	_state_timer = _pick_wait()
	_play_animation(idle_animation, true)


## Lanza varios proyectiles hacia el jugador con una desviación aleatoria.
func _fire_volley() -> void:
	if not projectile or not is_instance_valid(_player):
		return
	var parent := get_parent()
	if not parent:
		return

	var origin := _get_muzzle_position()
	var base_dir := (_player.global_position - origin).normalized()
	if base_dir.is_zero_approx():
		base_dir = Vector2.LEFT if _is_facing_left else Vector2.RIGHT

	for i in projectiles_per_volley:
		var proj := projectile.instantiate() as Node2D
		if not proj:
			continue
		parent.add_child(proj)
		var stagger := (float(i) - (float(projectiles_per_volley) - 1.0) * 0.5) * 3.0
		proj.global_position = origin + Vector2(0.0, stagger)
		var angle := deg_to_rad(randf_range(-projectile_spread_degrees, projectile_spread_degrees))
		if proj.has_method("setup"):
			proj.setup(base_dir.rotated(angle), projectile_speed, base_attack, self)


## Hace parpadear el sapo para avisar de la ráfaga inminente.
func _start_windup_tween() -> void:
	if not sprite:
		return
	_stop_windup_tween()
	_windup_tween = create_tween()
	var pulse_time := shoot_delay / 6.0
	for _pulse in 3:
		_windup_tween.tween_property(sprite, "modulate", windup_tint, pulse_time)
		_windup_tween.tween_property(sprite, "modulate", Color.WHITE, pulse_time)


## Cancela el aviso y devuelve el sprite a su color normal.
func _stop_windup_tween() -> void:
	if _windup_tween and _windup_tween.is_valid():
		_windup_tween.kill()
	_windup_tween = null
	if sprite:
		sprite.modulate = Color.WHITE


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

func _face_player_if_visible() -> void:
	if not is_instance_valid(_player):
		return
	var dx := _player.global_position.x - global_position.x
	if absf(dx) > 1.0:
		_set_facing_direction(dx < 0.0)


func _get_muzzle_position() -> Vector2:
	if projectile_spawn:
		return projectile_spawn.global_position
	var dir := -1.0 if _is_facing_left else 1.0
	return global_position + Vector2(12.0 * dir, -10.5)


func _pick_wait() -> float:
	return randf_range(jump_wait_min, jump_wait_max)


## Excluye la colisión física con el jugador en ambos sentidos, para no
## empujarlo. Las Area2D (detección y proyectiles) no se ven afectadas.
func _ensure_player_collision_exception() -> void:
	if not is_instance_valid(_player) or _player == _collision_excluded_player:
		return
	_collision_excluded_player = _player
	add_collision_exception_with(_player)
	_player.add_collision_exception_with(self)
