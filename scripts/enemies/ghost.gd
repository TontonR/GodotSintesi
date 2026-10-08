extends CharacterBody2D

@export_group("Configuración Visual")
@export var sprite_faces_right: bool = true   # Cambia a 'false' en el Inspector si tu sprite por defecto mira a la izquierda

@export_group("Vida y Salud")
@export var max_health: float = 40.0
var health: float = 40.0

@export_group("Movimiento Espectral")
@export var speed: float = 80.0
@export var evade_speed_multiplier: float = 1.2 # 1.2x al aproximarse en ataque
@export var flee_speed_multiplier: float = 1.5  # 1.5x al huir velozmente tras atacar
@export var float_amplitude: float = 12.0
@export var float_frequency: float = 2.0

@export_group("Tiempos de Ataque y Recuperación")
@export var charge_time: float = 0.5            # Carga de 0.5s previa al golpe
@export var flee_time: float = 1.0              # 1.0s de huida en dirección opuesta
@export var idle_recovery_time: float = 0.5     # 0.5s de reposo en idle

@export_group("Ataque a Distancia")
@export var projectile_scene: PackedScene       # Asigna ghost_projectile.tscn en el Inspector
@export var projectile_spawn_delay: float = 0.2  # Momento exacto del disparo durante la animación de ataque

@export_group("Teletransporte (TP)")
@export var tp_cooldown: float = 6.0
@export var tp_min_distance_x: float = 40.0         # Distancia horizontal mínima respecto al jugador
@export var tp_max_distance_x: float = 120.0        # Distancia horizontal máxima respecto al jugador
@export var tp_min_height_above_player: float = 10.0  # Ajustado: Mínimo 10px arriba del jugador
@export var tp_max_height_above_player: float = 35.0  # Ajustado: Máximo 35px arriba del jugador (para que no quede inalcanzable)

# Referencias a nodos
@onready var animated_sprite: AnimatedSprite2D = $Pivot/ghost
@onready var pivot: Node2D = $Pivot
@onready var detection_area: Area2D = $Pivot/detection_area
@onready var detection_shape: CollisionShape2D = $Pivot/detection_area/detection_hitbox
@onready var attack_range_area: Area2D = $Pivot/attack_range
@onready var spawn_point: Node2D = $Pivot/SpawnPoint # Asegúrate de tener este Marker2D o Node2D en $Pivot

var player: Node2D = null
var float_timer: float = 0.0
var is_teleporting: bool = false
var is_dead: bool = false

# Sensores y memoria
var player_in_detection_area: bool = false
var player_in_attack_range: bool = false
var has_seen_player: bool = false

# Control de estados
var is_attacking: bool = false
var is_fleeing: bool = false
var is_recovering: bool = false
var charge_timer: float = 0.0

# Direcciones
var flee_direction_x: float = 1.0

func _ready() -> void:
	health = max_health

	# Asegurarse de pertenecer al grupo "ghost" para evitar autodaño con el proyectil
	if not is_in_group("ghost"):
		add_to_group("ghost")

	# Desactivar colisión física con la capa del jugador (Capa 2)
	set_collision_mask_value(2, false)

	player = get_tree().get_first_node_in_group("player")

	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)
		animated_sprite.play("idle")

	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)

	if attack_range_area:
		attack_range_area.body_entered.connect(_on_attack_range_body_entered)
		attack_range_area.body_exited.connect(_on_attack_range_body_exited)

	_start_tp_timer()

func _set_pivot_facing_direction(dir_x: float) -> void:
	if not pivot or dir_x == 0.0:
		return
	
	var face_right = dir_x > 0
	if not sprite_faces_right:
		face_right = !face_right

	pivot.scale.x = 1.0 if face_right else -1.0

func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	if is_dead or is_teleporting:
		return

	# Dirección hacia el jugador
	var player_dir_x = sign(player.global_position.x - global_position.x)
	if player_dir_x == 0:
		player_dir_x = 1.0

	# --- ESTADO 1: EJECUCIÓN DEL ATAQUE EN CURSO ---
	if is_attacking:
		velocity.x = 0
		charge_timer = 0.0
		_set_pivot_facing_direction(player_dir_x)
		_apply_floating(delta)
		move_and_slide()
		return

	# --- ESTADO 2: HUIDA RÁPIDA TRAS ATACAR ---
	if is_fleeing:
		if is_on_wall():
			flee_direction_x *= -1.0

		velocity.x = flee_direction_x * (speed * flee_speed_multiplier)
		_set_pivot_facing_direction(flee_direction_x)

		if animated_sprite and animated_sprite.animation != "chase":
			animated_sprite.play("chase")

		_apply_floating(delta)
		move_and_slide()
		return

	# --- ESTADO 3: REPOSO OBLIGADO / IDLE TRAS HUIR ---
	if is_recovering:
		velocity.x = 0
		charge_timer = 0.0
		_set_pivot_facing_direction(player_dir_x)
		
		if animated_sprite and animated_sprite.animation != "idle":
			animated_sprite.play("idle")

		_apply_floating(delta)
		move_and_slide()
		return

	# --- ESTADO NORMAL: EVALUACIÓN DE SENSORES Y PERSECUCIÓN ---
	_update_sensor_states()

	if player_in_attack_range:
		_set_pivot_facing_direction(player_dir_x)
		velocity.x = player_dir_x * (speed * evade_speed_multiplier)

		if animated_sprite and animated_sprite.animation != "chase":
			animated_sprite.play("chase")

		charge_timer += delta
		if charge_timer >= charge_time:
			charge_timer = 0.0  # Reset del temporizador para evitar bucle infinito
			_execute_attack()

	elif has_seen_player:
		_set_pivot_facing_direction(player_dir_x)
		charge_timer = 0.0
		velocity.x = player_dir_x * speed

		if animated_sprite and animated_sprite.animation != "chase":
			animated_sprite.play("chase")
	else:
		_set_pivot_facing_direction(player_dir_x)
		charge_timer = 0.0
		velocity.x = 0
		if animated_sprite and animated_sprite.animation != "idle":
			animated_sprite.play("idle")

	_apply_floating(delta)
	move_and_slide()

func _apply_floating(delta: float) -> void:
	float_timer += delta * float_frequency
	velocity.y = sin(float_timer) * float_amplitude

# ==============================================================================
# SISTEMA DE DAÑO
# ==============================================================================
func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("¡Fantasma golpeado! Vida restante: ", health)

	# Efecto visual de parpadeo rojo al recibir un espadazo
	if animated_sprite:
		animated_sprite.modulate = Color(1, 0.2, 0.2)
		get_tree().create_timer(0.15).timeout.connect(func():
			if is_instance_valid(animated_sprite):
				animated_sprite.modulate = Color.WHITE
		)

	if health <= 0:
		die()

# ==============================================================================
# SECUENCIA DE ATAQUE Y RECUPERACIÓN
# ==============================================================================
func _execute_attack() -> void:
	if is_attacking or is_fleeing or is_recovering:
		return

	is_attacking = true
	charge_timer = 0.0
	velocity = Vector2.ZERO

	# Instanciar el proyectil con el tiempo de retraso configurado
	get_tree().create_timer(projectile_spawn_delay).timeout.connect(func():
		if not is_dead:
			_spawn_projectile()
	, CONNECT_ONE_SHOT)

	if animated_sprite and animated_sprite.sprite_frames.has_animation("attack"):
		animated_sprite.play("attack")
		
		var frames_count = animated_sprite.sprite_frames.get_frame_count("attack")
		var fps = animated_sprite.sprite_frames.get_animation_speed("attack")
		var attack_duration = (frames_count / fps) if fps > 0 else 0.5

		get_tree().create_timer(attack_duration).timeout.connect(func():
			if is_attacking and not is_dead:
				_start_flee_and_recovery_sequence()
		, CONNECT_ONE_SHOT)
	else:
		_start_flee_and_recovery_sequence()

func _spawn_projectile() -> void:
	if not projectile_scene:
		print("ERROR: Falta asignar 'projectile_scene' en el Inspector del Ghost.")
		return

	if not player:
		print("ERROR: No se encuentra al objeto 'player'.")
		return

	var projectile = projectile_scene.instantiate()
	if not projectile:
		return

	# Obtener posición global de origen
	var spawn_pos = spawn_point.global_position if spawn_point else global_position
	projectile.global_position = spawn_pos
	
	# Dirección en 2D apuntando al centro del jugador
	var dir = (player.global_position - spawn_pos).normalized()
	
	if "direction" in projectile:
		projectile.direction = dir
	
	projectile.rotation = dir.angle()

	# Forzar capa Z alta para evitar que aparezca detrás del mapa
	if projectile is Node2D:
		projectile.z_index = 10

	# Añadir al nodo raíz del nivel actual
	get_tree().current_scene.add_child(projectile)
	print("Proyectil generado con éxito en: ", spawn_pos)

func _start_flee_and_recovery_sequence() -> void:
	is_attacking = false
	is_fleeing = true
	is_recovering = false
	charge_timer = 0.0

	if player:
		var dir_from_player = sign(global_position.x - player.global_position.x)
		flee_direction_x = dir_from_player if dir_from_player != 0 else (1.0 if randf() > 0.5 else -1.0)
	else:
		flee_direction_x = 1.0 if randf() > 0.5 else -1.0

	get_tree().create_timer(flee_time).timeout.connect(func():
		if not is_dead and is_fleeing:
			is_fleeing = false
			is_recovering = true
			
			get_tree().create_timer(idle_recovery_time).timeout.connect(func():
				if not is_dead:
					is_recovering = false
					_update_sensor_states()
			, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)

# ==============================================================================
# TELETRANSPORTE
# ==============================================================================
func _start_tp_timer() -> void:
	get_tree().create_timer(tp_cooldown).timeout.connect(func():
		if not is_dead and not is_teleporting:
			_perform_teleport_sequence()
	)

func _perform_teleport_sequence() -> void:
	is_teleporting = true
	is_attacking = false
	is_fleeing = false
	is_recovering = false
	charge_timer = 0.0
	velocity = Vector2.ZERO

	if animated_sprite:
		animated_sprite.play("vanish")

func _teleport_to_new_position() -> void:
	if not player:
		return

	var dir_x = 1.0 if randf() > 0.5 else -1.0
	var offset_x = dir_x * randf_range(tp_min_distance_x, tp_max_distance_x)
	var offset_y = -randf_range(tp_min_height_above_player, tp_max_height_above_player)

	var target_position = player.global_position + Vector2(offset_x, offset_y)

	var camera = get_viewport().get_camera_2d()
	if camera:
		var cam_pos = camera.get_screen_center_position()
		var viewport_size = get_viewport_rect().size / camera.zoom
		
		var min_x = cam_pos.x - (viewport_size.x / 2.0) + 30.0
		var max_x = cam_pos.x + (viewport_size.x / 2.0) - 30.0
		var min_y = cam_pos.y - (viewport_size.y / 2.0) + 30.0
		var max_y = cam_pos.y + (viewport_size.y / 2.0) - 30.0

		target_position.x = clamp(target_position.x, min_x, max_x)
		target_position.y = clamp(target_position.y, min_y, max_y)

	global_position = target_position

	if animated_sprite:
		animated_sprite.play("appear")

func _update_sensor_states() -> void:
	if player:
		if attack_range_area:
			player_in_attack_range = attack_range_area.get_overlapping_bodies().has(player)
		if detection_area:
			player_in_detection_area = detection_area.get_overlapping_bodies().has(player)

# ==============================================================================
# EVENTOS Y SEÑALES
# ==============================================================================
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body == player:
		player_in_detection_area = true
		has_seen_player = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body == player:
		player_in_detection_area = false

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body == player:
		player_in_attack_range = true
		has_seen_player = true

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body == player:
		player_in_attack_range = false

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	# Desactivar colisiones si existen
	var col = get_node_or_null("ghost_hitbox")
	if col:
		col.set_deferred("disabled", true)

	if animated_sprite:
		animated_sprite.play("vanish")
	else:
		queue_free()

func _on_animation_finished() -> void:
	if not animated_sprite:
		return

	match animated_sprite.animation:
		"vanish":
			if is_dead:
				queue_free()
			else:
				_teleport_to_new_position()
		"appear":
			is_teleporting = false
			_update_sensor_states()
			_start_tp_timer()
			if not player_in_attack_range and has_seen_player:
				animated_sprite.play("chase")
			else:
				animated_sprite.play("idle")
