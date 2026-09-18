extends CharacterBody2D

# Velocidad máxima horizontal en píxeles por segundo
@export var move_speed: float = 320.0
# Aceleración al acelerar / frenar (suaviza el movimiento)
@export var acceleration: float = 1800.0
@export var friction: float = 2400.0
# Salto y gravedad
@export var jump_velocity: float = -650.0
@export var gravity: float = 1800.0
# Al caer la gravedad es mayor: el salto se siente más ágil
@export var fall_gravity_multiplier: float = 1.6
# Margen para saltar justo después de dejar el suelo
@export var coyote_time: float = 0.1
# Margen para registrar el salto pulsado un poco antes de tocar suelo
@export var jump_buffer_time: float = 0.12

@onready var animated_sprite = $AnimatedSprite2D

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_was_pressed: bool = false
var _facing_right: bool = true

func _physics_process(delta: float) -> void:
	# --- Gravedad ---
	var current_gravity: float = gravity
	if velocity.y > 0.0:
		current_gravity *= fall_gravity_multiplier
	velocity.y += current_gravity * delta

	# --- Movimiento horizontal con aceleración y rozamiento ---
	var direction: float = 0.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction -= 1.0

	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * move_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# --- Dirección del sprite ---
	if direction > 0.0:
		_facing_right = true
	elif direction < 0.0:
		_facing_right = false
	animated_sprite.flip_h = not _facing_right

	# --- Salto ---
	var jump_pressed: bool = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	var jump_just_pressed: bool = jump_pressed and not _jump_was_pressed

	# Buffer: recuerda la pulsación unos instantes
	if jump_just_pressed:
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

	# Coyote time: unos instantes después de dejar el suelo
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	# Salto variable: si sueltas pronto, el salto es más corto
	if not jump_pressed and _jump_was_pressed and velocity.y < 0.0:
		velocity.y *= 0.45
	_jump_was_pressed = jump_pressed

	move_and_slide()
	_update_animation()

func _update_animation() -> void:
	if not is_on_floor():
		if velocity.y < 0.0:
			animated_sprite.play("movement_right")
		else:
			animated_sprite.play("idle_right")
	elif absf(velocity.x) > 10.0:
		animated_sprite.play("movement_right")
	else:
		animated_sprite.play("idle_center")
