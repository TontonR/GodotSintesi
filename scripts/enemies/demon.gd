class_name demon
extends EnemyBase
## Demonio volador: ronda al jugador por el aire y, cada pocos segundos, se
## detiene encima de él para lanzar un chorro de fuego desde la boca hasta el
## suelo. Si el jugador bloquea el fuego con el escudo, queda aturdido hasta
## recibir 3 golpes o hasta que pasen 5 segundos.

enum State { FLY, BREATH, STUN }

## Color del demonio mientras está aturdido.
const STUN_TINT: Color = Color(0.65, 0.82, 1.0)

@export_group("Vuelo")
## Velocidad horizontal mientras ronda al jugador (px/s).
@export var fly_speed: float = 70.0
## Altura sobre el punto donde apareció (px).
@export var fly_height: float = 80.0
## Segundos volando con el idle entre ataque y ataque.
@export var fly_duration: float = 3.0
## Amplitud del vaivén horizontal alrededor del jugador (px).
@export var hover_sway: float = 22.0

@export_group("Aliento")
## Escena del chorro de fuego.
@export var fire_scene: PackedScene
## Segundos que permanece el chorro encendido.
@export var breath_duration: float = 3.0
## Tiempo de la animación de ataque antes de abrir la boca y encender el fuego.
@export var breath_windup: float = 0.75

@export_group("Aturdimiento")
## Segundos máximo que dura el aturdimiento.
@export var stun_duration: float = 5.0
## Golpes necesarios para cortar el aturdimiento.
@export var stun_hits_required: int = 3
## Cuánto baja el demonio mientras está aturdido (px).
@export var stun_drop: float = 40.0

@export_group("Nodos")
## Punto de la boca desde el que sale el fuego.
@export var muzzle: Node2D

var _state: State = State.FLY
var _state_timer: float = 0.0
var _bob_time: float = 0.0
var _spawn_position: Vector2 = Vector2.ZERO
var _fly_y: float = 0.0
var _fire: Node2D = null
var _stun_hits: int = 0
var _idle_sprite: AnimatedSprite2D
var _attack_sprite: AnimatedSprite2D


func _init() -> void:
	max_health = 180.0
	base_attack = 5.0
	flying_enemy = true
	sprite_faces_right = false
	idle_animation = &"idle"
	move_animation = &"idle"
	attack_animation = &"attack"


func _ready() -> void:
	# Fallbacks por si la escena no trae los exports cableados.
	if not sprite:
		sprite = get_node_or_null("visual/idle")
	if not detection_area:
		detection_area = get_node_or_null("detection_range")
	if not flip_pivot:
		flip_pivot = get_node_or_null("visual")
	if not muzzle:
		muzzle = get_node_or_null("visual/muzzle")

	_idle_sprite = sprite
	_attack_sprite = get_node_or_null("visual/attack")

	super()

	# El arte mira a la izquierda por defecto.
	_is_facing_left = true
	if flip_pivot:
		flip_pivot.scale.x = 1.0

	_spawn_position = global_position
	global_position.y -= fly_height
	_fly_y = global_position.y

	_state = State.FLY
	_state_timer = fly_duration
	_show_idle()
	_play_animation(idle_animation, true)


# ---------------------------------------------------------------------------
# Comportamiento
# ---------------------------------------------------------------------------

func _update_behavior(delta: float) -> void:
	match _state:
		State.FLY:
			_process_fly(delta)
		State.BREATH:
			_process_breath(delta)
		State.STUN:
			_process_stun(delta)


func _process_fly(delta: float) -> void:
	_bob_time += delta
	_face_player_if_visible()

	var target_x := _spawn_position.x
	if is_instance_valid(_player):
		target_x = _player.global_position.x + sin(_bob_time * 1.4) * hover_sway
	_move_horizontal_to(target_x, delta, fly_speed)

	var target_y := _fly_y + sin(_bob_time * 2.0) * 3.0
	velocity.y = clampf((target_y - global_position.y) * 5.0, -fly_speed, fly_speed)
	_play_animation(idle_animation)

	_state_timer -= delta
	if _state_timer <= 0.0:
		if is_instance_valid(_player):
			_start_breath()
		else:
			_state_timer = fly_duration


func _process_breath(delta: float) -> void:
	_face_player_if_visible()

	# Fuego encendido: quieto hasta que se apague.
	if is_instance_valid(_fire):
		_stop()
		_state_timer -= delta
		if _state_timer <= 0.0:
			_end_breath()
		return

	# Aviso: se coloca para que la boca quede sobre el jugador.
	if is_instance_valid(_player):
		var target_x := _player.global_position.x - _muzzle_offset_x()
		_move_horizontal_to(target_x, delta, fly_speed)
	else:
		velocity.x = move_toward(velocity.x, 0.0, fly_speed * 6.0 * delta)
	velocity.y = clampf((_fly_y - global_position.y) * 6.0, -fly_speed, fly_speed)

	_state_timer -= delta
	if _state_timer <= 0.0:
		_spawn_fire()
		_state_timer = breath_duration
		_stop()


func _process_stun(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, fly_speed * 6.0 * delta)
	var target_y := _fly_y + stun_drop
	velocity.y = clampf((target_y - global_position.y) * 4.0, -fly_speed, fly_speed)

	_state_timer -= delta
	if _state_timer <= 0.0:
		_end_stun()


# ---------------------------------------------------------------------------
# Ataque y aturdimiento
# ---------------------------------------------------------------------------

func _start_breath() -> void:
	_state = State.BREATH
	_state_timer = breath_windup
	_stop()
	_face_player_if_visible()
	_show_attack()


func _spawn_fire() -> void:
	if not fire_scene:
		return

	var fire := fire_scene.instantiate() as Node2D
	if not fire:
		return

	add_child(fire)
	if muzzle:
		fire.global_position = muzzle.global_position
	else:
		fire.global_position = global_position + Vector2(0.0, 20.0)

	if fire.has_method("setup"):
		fire.setup(self, breath_duration, _is_facing_left)
	_fire = fire


func _end_breath() -> void:
	_clear_fire()
	_state = State.FLY
	_state_timer = fly_duration
	_show_idle()
	_play_animation(idle_animation, true)


## Llamado por el chorro de fuego cuando el jugador lo bloquea con el escudo.
func on_fire_parried() -> void:
	if _is_dead or _state == State.STUN:
		return
	_enter_stun()


func _enter_stun() -> void:
	_state = State.STUN
	_state_timer = stun_duration
	_stun_hits = 0
	_stop()
	_clear_fire()
	_show_idle()
	_play_animation(idle_animation, true)
	if _idle_sprite:
		_idle_sprite.modulate = STUN_TINT


func _end_stun() -> void:
	_state = State.FLY
	_state_timer = fly_duration
	_bob_time = 0.0
	if _hit_tween:
		_hit_tween.kill()
	if _idle_sprite:
		_idle_sprite.modulate = Color.WHITE
	if _attack_sprite:
		_attack_sprite.modulate = Color.WHITE
	_show_idle()
	_play_animation(idle_animation, true)


func take_damage(amount: float) -> void:
	if _is_dead:
		return

	var was_stunned := _state == State.STUN
	super.take_damage(amount)
	if _is_dead:
		return

	# Durante el aturdimiento, los golpes lo acortan.
	if was_stunned and _state == State.STUN:
		_stun_hits += 1
		if _stun_hits >= stun_hits_required:
			_end_stun()


func _flash_hit() -> void:
	var target := _idle_sprite
	if _attack_sprite and _attack_sprite.visible:
		target = _attack_sprite
	if not target:
		return

	if _hit_tween:
		_hit_tween.kill()
	target.modulate = Color(1.0, 0.2, 0.2)
	_hit_tween = create_tween()
	var final_color := STUN_TINT if _state == State.STUN else Color.WHITE
	_hit_tween.tween_property(target, "modulate", final_color, 0.15)


func _on_death() -> void:
	_clear_fire()
	super._on_death()


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

func _clear_fire() -> void:
	if is_instance_valid(_fire):
		if _fire.has_method("stop_breath"):
			_fire.stop_breath()
		else:
			_fire.queue_free()
	_fire = null


func _move_horizontal_to(target_x: float, delta: float, max_speed: float) -> void:
	var diff := target_x - global_position.x
	if absf(diff) < 1.0:
		velocity.x = move_toward(velocity.x, 0.0, max_speed * 6.0 * delta)
		return
	velocity.x = clampf(diff * 5.0, -max_speed, max_speed)


func _face_player_if_visible() -> void:
	if not is_instance_valid(_player):
		return
	var dx := _player.global_position.x - global_position.x
	if absf(dx) > 1.0:
		_set_facing_direction(dx < 0.0)


func _muzzle_offset_x() -> float:
	if muzzle:
		return muzzle.global_position.x - global_position.x
	return -17.4 if _is_facing_left else 17.4


func _show_idle() -> void:
	if _attack_sprite:
		_attack_sprite.visible = false
		_attack_sprite.stop()
	if _idle_sprite:
		_idle_sprite.visible = true


func _show_attack() -> void:
	if _idle_sprite:
		_idle_sprite.visible = false
	if _attack_sprite:
		_attack_sprite.visible = true
		_attack_sprite.frame = 0
		_attack_sprite.play(attack_animation)
