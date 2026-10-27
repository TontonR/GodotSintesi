class_name werewolf
extends EnemyBase
## Lobo: merodea su zona y, al ver al jugador, embiste de punta a punta
## su área de detección. Cada dos embestidas, la siguiente vuelta es un
## salto que al aterrizar golpea con el doble del ataque base.
## El daño por contacto usa el hitbox real y se comprueba cada frame físico;
## la embestida siempre recorre su línea recta antes de decidir si gira.

enum State { WANDER, WINDUP, CHARGE, JUMP, RECOVER }

## Embestidas normales antes de que la siguiente vuelta sea un salto.
const CHARGES_BEFORE_JUMP := 2

@export_group("Merodeo")
## Velocidad de paseo por la zona (px/s).
@export var wander_speed: float = 70.0
## Margen (px) respecto a los bordes de la zona para no salirse.
@export var wander_edge_margin: float = 64.0
## Distancia mínima (px) al elegir el siguiente punto de paseo.
@export var wander_min_step: float = 80.0
## Pausa mínima entre puntos de paseo (s).
@export var wander_pause_min: float = 1.0
## Pausa máxima entre puntos de paseo (s).
@export var wander_pause_max: float = 2.5
## Radio de merodeo (px) si no encuentra el WorldGenerator (para probarlo suelto).
@export var wander_radius: float = 400.0

@export_group("Embestida")
## Velocidad de la embestida (px/s).
@export var charge_speed: float = 220.0
## Tiempo de aviso quieto antes de embestir (s).
@export var charge_windup: float = 0.25
## Pausa tras cada embestida o salto antes de decidir la siguiente vuelta (s).
@export var attack_recovery: float = 0.35
## Daño por contacto: segundos mínimos entre dos golpes al mismo objetivo.
@export var hit_cooldown: float = 0.5
## Fuerza del lanzamiento vertical al primer golpe de cada embestida (px/s).
@export var knockup_force: float = 280.0
## Tiempo (s) que el jugador pierde el control tras el lanzamiento.
@export var knockup_lock: float = 0.12

@export_group("Ataque de Salto")
## Fuerza del salto hacia arriba.
@export var jump_force: float = -350.0
## Multiplicador de daño al caer.
@export var jump_damage_multiplier: float = 2.0
## Radio de impacto al tocar suelo (px).
@export var impact_radius: float = 40.0
## Velocidad horizontal máxima durante el salto (px/s).
@export var jump_speed_max: float = 320.0

# ---------------------------------------------------------------------------
# Estado interno
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
## El giro de vuelta solo se permite una vez por embestida.
var _charge_turned: bool = false
## El primer golpe de una embestida lanza al jugador por los aires (knockup).
var _charge_hit_done: bool = false
## La recuperación se hace corriendo hacia el jugador (embestida fallida).
var _recover_chasing: bool = false
var _charges_done: int = 0
## Jugador con el que ya se ha excluido la colisión física.
var _collision_excluded_player: CharacterBody2D = null
var _jump_vx: float = 0.0
var _jump_taken_off: bool = false
## Segundos que faltan para poder volver a golpear por contacto.
var _hit_cooldown_left: float = 0.0


func _init() -> void:
	max_health = 60.0
	base_attack = 10.0
	speed_movement = 75.0
	idle_animation = &"idle"
	move_animation = &"run"


func _ready() -> void:
	# Fallbacks por si la escena no trae los exports cableados (como orc.gd).
	if not sprite:
		sprite = get_node_or_null("pivot/werewolf")
	if not detection_area:
		detection_area = get_node_or_null("pivot/detection_range")
	if not attack_range:
		attack_range = get_node_or_null("pivot/attack_range")
	if not flip_pivot:
		flip_pivot = get_node_or_null("pivot")

	super()

	_charge_distance = _get_detection_diameter()

	_setup_wander_bounds()
	_pick_wander_target()
	_play_animation(idle_animation, true)


# ---------------------------------------------------------------------------
# Comportamiento: máquina de estados propia (se ignora la de EnemyBase)
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


# ---------------------------------------------------------------------------
# Merodeo por la zona
# ---------------------------------------------------------------------------

## Limita el paseo a la zona del mundo donde apareció el lobo.
func _setup_wander_bounds() -> void:
	var gen := get_tree().get_first_node_in_group("world_generator")
	var zone_tiles := 0
	var safe_tiles := 0
	if gen:
		if gen.get("zone_width_tiles") != null:
			zone_tiles = int(gen.get("zone_width_tiles"))
		if gen.get("safe_start_tiles") != null:
			safe_tiles = int(gen.get("safe_start_tiles"))

	if zone_tiles > 0:
		var zone_width_px := float(zone_tiles) * 16.0
		var zone_index := floori(global_position.x / zone_width_px)
		_zone_min_x = zone_index * zone_width_px + wander_edge_margin
		_zone_max_x = (zone_index + 1) * zone_width_px - wander_edge_margin
		# En la zona inicial, no invade el tramo seguro del jugador.
		if zone_index == 0 and safe_tiles > 0:
			_zone_min_x = maxf(_zone_min_x, float(safe_tiles) * 16.0 + wander_edge_margin)
	else:
		_zone_min_x = global_position.x - wander_radius
		_zone_max_x = global_position.x + wander_radius

	# Zona demasiado estrecha: mejor un radio fijo alrededor del spawn.
	if _zone_max_x - _zone_min_x < wander_edge_margin * 2.0:
		_zone_min_x = global_position.x - wander_radius
		_zone_max_x = global_position.x + wander_radius


## Elige un punto de paseo aleatorio dentro de la zona.
func _pick_wander_target() -> void:
	var x := randf_range(_zone_min_x, _zone_max_x)
	for _i in 4:
		if absf(x - global_position.x) >= wander_min_step:
			break
		x = randf_range(_zone_min_x, _zone_max_x)
	_wander_target_x = x


func _process_wander(delta: float) -> void:
	# Pausa entre puntos: quieto en idle.
	if _wander_pause > 0.0:
		_wander_pause -= delta
		_stop()
		_play_animation(idle_animation)
		if _wander_pause <= 0.0:
			_pick_wander_target()
		return

	# ¿Llegó al punto? Entonces descansa y luego busca otro.
	if absf(_wander_target_x - global_position.x) <= 4.0:
		_wander_pause = randf_range(wander_pause_min, wander_pause_max)
		return

	var dir := signf(_wander_target_x - global_position.x)
	_set_facing_direction(dir < 0.0)
	velocity.x = dir * wander_speed
	_play_animation(move_animation)


# ---------------------------------------------------------------------------
# Ataque: ciclo de 2 embestidas + 1 salto
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

	# Quieto y mirando al jugador: aviso antes de embestir.
	_set_facing_direction(_dir_to_player() < 0.0)
	_stop()
	_state_timer -= delta
	if _state_timer <= 0.0:
		_launch_attack()


## Decide la vuelta: cada dos embestidas, la tercera es un salto.
func _launch_attack() -> void:
	if _charges_done >= CHARGES_BEFORE_JUMP:
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
	# Solo el terreno corta la embestida; al jugador se lo atraviesa.
	if _is_blocked_by_world():
		_begin_recovery()
		return

	# Línea recta: no se gira a media carga, aunque el jugador cambie de lado.
	velocity.x = _charge_dir * charge_speed
	_charge_remaining -= charge_speed * delta
	if _charge_remaining <= 0.0:
		_finish_charge_pass()


## Se llama al terminar la línea actual: solo entonces se decide girar o no.
func _finish_charge_pass() -> void:
	var player_in_sight := (
		is_instance_valid(_player)
		and detection_area != null
		and detection_area.overlaps_body(_player)
	)

	if _charge_hit_done and not _charge_turned and player_in_sight:
		# Golpeó: una única pasada de vuelta en sentido contrario.
		_charge_turned = true
		_charge_dir = -_charge_dir
		_set_facing_direction(_charge_dir < 0.0)
		_charge_remaining = _charge_distance * 0.5
		_play_animation(move_animation, true)
		return

	# Si no golpeó, vuelve a trazar ruta persiguiendo al jugador.
	_begin_recovery(not _charge_hit_done and is_instance_valid(_player))


func _start_jump() -> void:
	if not is_instance_valid(_player):
		_return_to_wander()
		return

	var dx := _player.global_position.x - global_position.x
	_set_facing_direction(_dir_to_player() < 0.0)

	# Velocidad horizontal para caer sobre el jugador dentro de la duración del arco.
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
		# Se considera despegado en cuanto la física lo saca del suelo.
		if not is_on_floor():
			_jump_taken_off = true
		return

	# Subiendo: "jump"; bajando: "fall".
	if velocity.y < 0.0:
		_play_animation(&"jump")
	else:
		_play_animation(&"fall")

	# Aterrizaje: golpe en área con el doble del ataque base.
	if is_on_floor():
		_deal_impact_damage()
		_charges_done = 0
		_begin_recovery()


## Daño en área al aterrizar (radio impact_radius), el doble del ataque base.
func _deal_impact_damage() -> void:
	var damage := base_attack * jump_damage_multiplier
	for target in get_tree().get_nodes_in_group("player"):
		var node := target as Node2D
		if not node:
			continue
		if node.global_position.distance_to(global_position) <= impact_radius:
			_hit_target(node, damage)


func _begin_recovery(chase_target: bool = false) -> void:
	_state = State.RECOVER
	_state_timer = attack_recovery
	_recover_chasing = chase_target
	if chase_target:
		_play_animation(move_animation, true)
	else:
		_stop()
		_play_animation(idle_animation, true)


func _process_recovery(delta: float) -> void:
	# Embestida fallida: re-traza ruta corriendo hacia el jugador.
	if _recover_chasing and is_instance_valid(_player):
		var dir := _dir_to_player()
		_set_facing_direction(dir < 0.0)
		velocity.x = dir * speed_movement
		_play_animation(move_animation)
	else:
		_stop()
		_play_animation(idle_animation)

	_state_timer -= delta
	if _state_timer > 0.0:
		return
	_recover_chasing = false
	if is_instance_valid(_player):
		_start_windup()
	else:
		_return_to_wander()


## Vuelve al merodeo (el contador del ciclo 2 + 1 se conserva).
func _return_to_wander() -> void:
	_state = State.WANDER
	_wander_pause = 0.0
	_stop()
	_pick_wander_target()


# ---------------------------------------------------------------------------
# Daño por contacto (hitbox real, cada frame físico)
# ---------------------------------------------------------------------------

## Golpea al jugador si el hitbox real lo solapa y el enfriamiento lo permite.
## Se comprueba cada frame físico (no depende de los frames del sprite).
func _try_contact_damage() -> void:
	if _is_dead or _hit_cooldown_left > 0.0 or not attack_range:
		return
	# Daña durante la embestida y al correr merodeando (no quieto en idle).
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
		# Solo el primer golpe de cada embestida lanza al jugador por los aires.
		if _state == State.CHARGE and not _charge_hit_done:
			_charge_hit_done = true
			_hit_target(target, base_attack, knockup_force)
		else:
			_hit_target(target, base_attack)
		return


## Aplica daño pasando nuestra posición (guardia frontal del jugador).
func _hit_target(body: Node2D, amount: float, knockup: float = 0.0) -> void:
	var damage := roundi(amount)
	if body.has_method("take_damage_from"):
		body.take_damage_from(damage, global_position, 0.0, knockup_lock, knockup)
	elif body.has_method("take_damage"):
		body.take_damage(damage)


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

## True si el choque de pared actual no es con el jugador (el lobo lo atraviesa).
func _is_blocked_by_world() -> bool:
	if not is_on_wall():
		return false
	for i in get_slide_collision_count():
		var collider := get_slide_collision(i).get_collider()
		if collider != _player:
			return true
	return false


## Excluye la colisión con el jugador en cuanto lo detecta (pass-through).
func _on_detection_area_body_entered(body: Node2D) -> void:
	super(body)
	_ensure_player_collision_exception()


## Dirección horizontal (-1/1) hacia el jugador; sin jugador, hacia donde mira.
func _dir_to_player() -> float:
	if is_instance_valid(_player):
		var dx := _player.global_position.x - global_position.x
		if not is_zero_approx(dx):
			return signf(dx)
	return -1.0 if _is_facing_left else 1.0


## Diámetro efectivo del área de detección (radio mayor × 2).
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


## Excluye la colisión física con el jugador en ambos sentidos, para no
## arrastrarlo. Las Area2D (detección y ataque) no se ven afectadas.
func _ensure_player_collision_exception() -> void:
	if not is_instance_valid(_player) or _player == _collision_excluded_player:
		return
	_collision_excluded_player = _player
	add_collision_exception_with(_player)
	_player.add_collision_exception_with(self)
