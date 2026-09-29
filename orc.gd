extends CharacterBody2D

@export var move_speed: float = 90.0
@export var attack_damage: int = 15
@export var attack_cooldown: float = 1.2
# 7 fotogramas a 6.0 FPS = 1.16 segundos hasta el golpe final
@export var damage_delay: float = 1.16 

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _player: CharacterBody2D = null
var _is_attacking: bool = false
var _can_attack: bool = true
var _player_in_attack_zone: bool = false

@onready var sprite: AnimatedSprite2D = $Orc
@onready var detection_area: Area2D = $detection_area
@onready var attack_range: Area2D = $attack_range
@onready var attack_timer: Timer = Timer.new()

func _ready() -> void:
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)
	
	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)
		
	if attack_range:
		attack_range.body_entered.connect(_on_attack_range_body_entered)
		attack_range.body_exited.connect(_on_attack_range_body_exited)

func _physics_process(delta: float) -> void:
	# 1. Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Persecución y lógica de ataque
	if _player != null and not _is_attacking:
		var direction_x = sign(_player.global_position.x - global_position.x)

		# Girar el sprite y reubicar la posición del área sin usar scale
		if direction_x != 0:
			var looking_left = (direction_x < 0)
			sprite.flip_h = looking_left
			if attack_range:
				attack_range.position.x = -abs(attack_range.position.x) if looking_left else abs(attack_range.position.x)

		# Si el jugador está dentro de la zona de ataque y el Orco puede atacar
		if _player_in_attack_zone:
			velocity.x = 0.0
			if _can_attack:
				_start_attack()
			else:
				_play_animation("idle")
		else:
			velocity.x = direction_x * move_speed
			_play_animation("walk")
			
	elif not _is_attacking:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		_play_animation("idle")

	move_and_slide()

# --- SEÑALES DE ÁREAS ---

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body != self and body.has_method("take_damage"):
		_player = body as CharacterBody2D

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body != self:
		_player_in_attack_zone = true

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.has_method("take_damage") and body != self:
		_player_in_attack_zone = false

# --- SISTEMA DE ATAQUE ---

func _start_attack() -> void:
	_is_attacking = true
	_can_attack = false
	
	_play_animation("attack")
	attack_timer.start()

	# Espera exactamente el tiempo que le toma a la animación de 6 FPS llegar al frame 7
	await get_tree().create_timer(damage_delay).timeout
	
	# Si te quedaste en el área hasta que bajó el garrote en el frame 7, te hace daño
	if _player_in_attack_zone and _player and _player.has_method("take_damage"):
		_player.take_damage(attack_damage)

	# Espera un breve instante final para completar la animación y libera el estado de ataque
	await get_tree().create_timer(0.2).timeout
	_is_attacking = false

func _on_attack_timer_timeout() -> void:
	_can_attack = true

func _play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
