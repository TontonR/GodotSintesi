extends CharacterBody2D

@export var move_speed: float = 75.0
@export var attack_damage: int = 15
@export var attack_cooldown: float = 2.0

# Tiempos de animación Ping-Pong (15 frames a 6 FPS)
@export var impact_delay: float = 0.66
@export var total_attack_duration: float = 2.50

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _player: CharacterBody2D = null
var _is_attacking: bool = false
var _can_attack: bool = true
var _player_in_attack_range: bool = false
var _is_facing_left: bool = false

# Distancia X original del attack_range respecto al centro
var _attack_range_offset_x: float = 0.0

# Nodos
@onready var sprite: AnimatedSprite2D = $Pivot/Orc
@onready var detection_area: Area2D = $Pivot/detection_area
@onready var attack_range: Area2D = $Pivot/attack_range
@onready var attack_timer: Timer = Timer.new()

func _ready() -> void:
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

	# Guardamos la posición X original de tu attack_range
	if attack_range:
		_attack_range_offset_x = abs(attack_range.position.x)
		if _attack_range_offset_x == 0:
			_attack_range_offset_x = 35.0

	# Conexión de señales de áreas
	if detection_area:
		if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
			detection_area.body_entered.connect(_on_detection_area_body_entered)
		if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
			detection_area.body_exited.connect(_on_detection_area_body_exited)

	if attack_range:
		if not attack_range.body_entered.is_connected(_on_attack_range_body_entered):
			attack_range.body_entered.connect(_on_attack_range_body_entered)
		if not attack_range.body_exited.is_connected(_on_attack_range_body_exited):
			attack_range.body_exited.connect(_on_attack_range_body_exited)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	# Si está atacando, no se mueve ni se gira
	if _is_attacking:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		move_and_slide()
		return

	if is_instance_valid(_player):
		var dist_x = _player.global_position.x - global_position.x

		# Se gira SIEMPRE hacia donde esté el jugador
		if abs(dist_x) > 5.0:
			_set_facing_direction(dist_x < 0)

		# Comprobación de estado
		if _player_in_attack_range:
			velocity.x = 0.0
			if _can_attack:
				_start_attack()
			else:
				_play_animation("idle")
		else:
			var dir = sign(dist_x)
			velocity.x = dir * move_speed
			_play_animation("walk")
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		_play_animation("idle")

	move_and_slide()

# --- GIRO CORRECTO QUE SÍ MUEVE LA HITBOX Y NO ROMPE FÍSICAS ---

func _set_facing_direction(look_left: bool) -> void:
	if _is_facing_left == look_left:
		return
		
	_is_facing_left = look_left
	
	# Volteamos la imagen del sprite
	if sprite:
		sprite.flip_h = look_left

	# Movemos la Area2D físicamente a la izquierda o derecha
	if attack_range:
		attack_range.position.x = -_attack_range_offset_x if look_left else _attack_range_offset_x

# --- SEÑALES ---

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body != self and body.has_method("take_damage"):
		_player = body as CharacterBody2D

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_player_in_attack_range = false

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body != self and body.has_method("take_damage"):
		_player_in_attack_range = true

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body != self and body.has_method("take_damage"):
		_player_in_attack_range = false

# --- ATAQUE CON TU AREA2D ---

func _start_attack() -> void:
	_is_attacking = true
	_can_attack = false
	
	if sprite:
		sprite.play("attack")
		
	attack_timer.start()

	# Espera al fotograma del golpe de garrote (0.66s)
	await get_tree().create_timer(impact_delay).timeout
	
	# Aplica daño usando las colisiones detectadas por tu attack_range
	if attack_range and _is_attacking:
		var overlapping_bodies = attack_range.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body != self and body.has_method("take_damage"):
				body.take_damage(attack_damage)

	# Espera el resto de la animación
	var remaining_time = total_attack_duration - impact_delay
	if remaining_time > 0:
		await get_tree().create_timer(remaining_time).timeout
	
	_is_attacking = false

func _on_attack_timer_timeout() -> void:
	_can_attack = true

func _play_animation(anim_name: String) -> void:
	if _is_attacking:
		return
		
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
