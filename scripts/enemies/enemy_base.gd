class_name EnemyBase
extends CharacterBody2D
## Se emite al morir; el generador del mundo lo usa para no reaparecerlo.
signal died
## Enemigo base: persigue al jugador, ataca (cuerpo a cuerpo o a distancia),
## puede huir si el jugador se acerca demasiado y suelta loot al morir.
## Los enemigos voladores (flying_enemy) se mueven libremente en 2D y sin gravedad.

@export_group("Basic Stats")
## Maximum hit points.
@export var max_health: float = 10.0
## Base damage dealt on hit.
@export var base_attack: float = 5.0
## Flat defense that reduces incoming damage.
@export var base_defense: float = 0.0
## Resistance to knockback force.
@export var knockback_defense: float = 0.0
## Movement speed in pixels per second.
@export var speed_movement: float = 50.0
## Seconds between two consecutive attacks.
@export var attack_cooldown: float = 2.0
## Auto-subida de escalones de 1 tile (16px) para enemigos terrestres.
@export var step_height: float = 16.0
## Tiempo total de la subida (s) – controla la suavidad.
@export var step_duration: float = 0.15

var _step_time_left: float = 0.0
var _step_start_y: float = 0.0
var _step_target_y: float = 0.0

@export_group("Enemy Config")
## No gravity; moves freely on X and Y.
@export var flying_enemy: bool = false
@export_subgroup("Ranged")
## Attack spawns a projectile instead of a melee hit.
@export var ranged_enemy: bool = false
## Projectile scene. Must implement setup(direction, speed, damage, shooter).
@export var projectile: PackedScene
## Projectile speed in pixels per second.
@export var projectile_speed: float = 200.0
## Projectile damage. Negative value uses base_attack.
@export var projectile_damage: float = -1.0
## Where the projectile spawns. Null = enemy center. Child of flip_pivot to auto-flip.
@export var projectile_spawn: Node2D
@export_subgroup("Flee")
## Enemy flees when the player gets too close.
@export var flee_enemy: bool = false
## "Too close" zone: if the player enters, the enemy flees.
@export var flee_area: Area2D

@export_group("Attack")
## Seconds from animation start until the hit (or shot) lands.
@export var attack_impact_delay: float = 0.5
## Total attack length; the enemy stands still during this time.
@export var attack_duration: float = 1.0

const DEFAULT_COIN: PackedScene = preload("res://scenes/collectables/coin.tscn")
const ITEM_PICKUP_SCENE: PackedScene = preload("res://item_pickup.tscn")
## Pool de objetos que pueden soltarse al morir (uno al azar por drop)
const DROP_ITEMS: Array[Items] = [
	preload("res://resources/pocion_cura.tres"),
	preload("res://resources/pocion_stamina.tres"),
	preload("res://resources/pocion_mayor.tres"),
	preload("res://resources/amuleto_ataque.tres"),
	preload("res://resources/armadura_ligera.tres"),
	preload("res://resources/talisman_regen.tres"),
]

@export_group("Loot")
## Items dropped on death, with chance and amount per entry.
@export var loot_table: Array[LootDropItem] = [
	LootDropItem.new(DEFAULT_COIN, 1.0, 1, 3),
	LootDropItem.new(ITEM_PICKUP_SCENE, 0.75, 1, 1, DROP_ITEMS)
]
## Horizontal spread (px) when dropping loot.
@export var loot_drop_spread: float = 15.0
## Vertical spread (px) when dropping loot.
@export var loot_drop_y: float = 15.0

@export_group("Nodes")
## Main sprite of the enemy.
@export var sprite: AnimatedSprite2D
## Area that detects the player.
@export var detection_area: Area2D
## Zone where the enemy can attack. For ranged, set it large (shot range).
@export var attack_range: Area2D
## Node scaled on X to flip sprite, hitbox and markers together (optional).
@export var flip_pivot: Node2D

@export_group("Animations")
## Animation name for idle / standing still.
@export var idle_animation: StringName = &"idle"
## Animation name for walking / chasing.
@export var move_animation: StringName = &"walk"
## Animation name for attacking.
@export var attack_animation: StringName = &"attack"
## True if the sprite's default facing is to the right.
@export var sprite_faces_right: bool = true


var health: float = 0.0
var defence: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _player: CharacterBody2D = null
var _player_in_attack_range: bool = false
var _player_in_flee_range: bool = false
var _is_attacking: bool = false
var _can_attack: bool = true
var _attack_timer: Timer
var _attack_range_offset_x: float = 0.0
var _projectile_spawn_offset_x: float = 0.0
var _is_dead: bool = false
var _is_facing_left: bool = false
var _hit_tween: Tween


func _ready() -> void:
	health = max_health
	defence = base_defense

	# Modo flotante: sin suelo ni "arriba/abajo", ideal para voladores.
	if flying_enemy:
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	# Timer de cooldown: cuando termina, el enemigo puede volver a atacar.
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.wait_time = attack_cooldown
	_attack_timer.timeout.connect(func(): _can_attack = true)
	add_child(_attack_timer)

	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)

	if attack_range:
		# Guardamos el offset original para poder espejarlo al girar.
		_attack_range_offset_x = absf(attack_range.position.x)
		attack_range.body_entered.connect(_on_attack_range_body_entered)
		attack_range.body_exited.connect(_on_attack_range_body_exited)

	if flee_area:
		flee_area.body_entered.connect(_on_flee_area_body_entered)
		flee_area.body_exited.connect(_on_flee_area_body_exited)

	if projectile_spawn:
		_projectile_spawn_offset_x = absf(projectile_spawn.position.x)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# Subida de escalón animada (sin teletransporte).
	if _step_time_left > 0.0:
		_step_time_left -= delta
		var t := clampf((step_duration - _step_time_left) / step_duration, 0.0, 1.0)
		position.y = lerpf(_step_start_y, _step_target_y, t)
		return

	# Los voladores no sufren gravedad.
	if not flying_enemy and not is_on_floor():
		velocity.y += gravity * delta

	# Mientras ataca se frena; si no, decide qué hacer.
	if _is_attacking:
		_decelerate()
	else:
		_update_behavior(delta)

	# Auto-subida de escalones para enemigos terrestres.
	if not flying_enemy and is_on_floor() and velocity.x != 0.0:
		_try_step_up(signf(velocity.x))
		if _step_time_left > 0.0:
			return

	move_and_slide()


func _try_step_up(direction: float) -> void:
	# Solo para enemigos terrestres en el suelo con movimiento horizontal.
	if flying_enemy or not is_on_floor() or direction == 0.0:
		return
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var half_width := 8.0
	if collision_shape and collision_shape.shape is RectangleShape2D:
		half_width = (collision_shape.shape as RectangleShape2D).size.x * 0.5 * collision_shape.scale.x
	var from := global_position + Vector2(half_width * direction, 0.0)
	var to := from + Vector2(16.0 * direction, 0.0)
	var query := PhysicsRayQueryParameters2D.create(from, to, 1 << 0)
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result:
		var from_up := from + Vector2(0.0, -step_height)
		var to_up := to + Vector2(0.0, -step_height)
		query.from = from_up
		query.to = to_up
		var result_up := get_world_2d().direct_space_state.intersect_ray(query)
		if not result_up:
			_step_start_y = position.y
			_step_target_y = position.y - step_height
			_step_time_left = step_duration


# ---------------------------------------------------------------------------
# Movimiento (separado por tipo: suelo = solo X, volador = X e Y)
# ---------------------------------------------------------------------------

## Frena poco a poco.
func _decelerate() -> void:
	if flying_enemy:
		velocity = velocity.move_toward(Vector2.ZERO, speed_movement)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed_movement)


## Se detiene en seco (usado al atacar o al estar en rango).
func _stop() -> void:
	if flying_enemy:
		velocity = Vector2.ZERO
	else:
		velocity.x = 0.0


## to_player: vector desde el enemigo hasta el jugador.
func _chase(to_player: Vector2) -> void:
	if flying_enemy:
		velocity = to_player.normalized() * speed_movement
	else:
		velocity.x = signf(to_player.x) * speed_movement
	_play_animation(move_animation)


## Se aleja del jugador (dirección contraria a to_player).
func _flee(to_player: Vector2) -> void:
	if flying_enemy:
		velocity = - to_player.normalized() * speed_movement
	else:
		velocity.x = - signf(to_player.x) * speed_movement
	_play_animation(move_animation)


# ---------------------------------------------------------------------------
# Comportamiento
# ---------------------------------------------------------------------------

## Vuelve a comprobar las áreas respecto al jugador.
## Útil tras teletransportes u otros cambios bruscos de posición,
## porque las señales body_entered/exited quedan obsoletas.
func _refresh_area_flags() -> void:
	if not is_instance_valid(_player):
		return
	if attack_range:
		_player_in_attack_range = attack_range.overlaps_body(_player)
	if flee_area:
		_player_in_flee_range = flee_area.overlaps_body(_player)


## Prioridad: huir > atacar > perseguir.
func _update_behavior(_delta: float) -> void:
	if not is_instance_valid(_player):
		_decelerate()
		_play_animation(idle_animation)
		return

	var to_player := _player.global_position - global_position
	# El enemigo siempre mira al jugador (el margen evita parpadeos al estar encima).
	if absf(to_player.x) > 5.0:
		_set_facing_direction(to_player.x < 0.0)

	if flee_enemy and _player_in_flee_range:
		_flee(to_player)
	elif _player_in_attack_range:
		_stop()
		if _can_attack:
			_start_attack()
		else:
			_play_animation(idle_animation)
	else:
		_chase(to_player)


# ---------------------------------------------------------------------------
# Ataque
# ---------------------------------------------------------------------------

func _start_attack() -> void:
	_is_attacking = true
	_can_attack = false
	_attack_timer.start(attack_cooldown)
	_play_animation(attack_animation, true)

	# Espera al momento del impacto (sincronizado con la animación).
	await get_tree().create_timer(attack_impact_delay).timeout
	if _is_dead:
		return
	_perform_attack()

	# Espera a que termine la animación antes de liberar al enemigo.
	var remaining := attack_duration - attack_impact_delay
	if remaining > 0.0:
		await get_tree().create_timer(remaining).timeout
	if _is_dead:
		return

	_is_attacking = false


## Punto de decisión: proyectil si es a distancia, golpe directo si no.
func _perform_attack() -> void:
	if ranged_enemy:
		_shoot_projectile()
	else:
		_perform_melee_hit()


func _perform_melee_hit() -> void:
	if not attack_range:
		return
	for body in attack_range.get_overlapping_bodies():
		if _is_valid_target(body):
			_deal_damage_to(body)


## Instancia el proyectil y le pasa dirección, velocidad y daño.
## El proyectil es quien debe encargarse de colisionar y dañar.
func _shoot_projectile() -> void:
	if not projectile:
		push_warning("%s es ranged_enemy pero no tiene 'projectile' asignado." % name)
		return

	var parent := get_parent()
	if parent == null:
		return

	var proj := projectile.instantiate() as Node2D
	if not proj:
		push_warning("La raíz de la escena 'projectile' debe ser un Node2D.")
		return

	# Primero se añade al árbol y luego se posiciona, para que global_position sea fiable.
	parent.add_child(proj)
	var spawn_pos := _get_projectile_spawn_position()
	proj.global_position = spawn_pos
	var dir := _get_projectile_direction(spawn_pos)

	# Contrato esperado: setup(direction: Vector2, speed: float, damage: float, shooter: Node2D)
	if proj.has_method("setup"):
		proj.setup(dir, projectile_speed, _get_projectile_damage(), self)
	elif "direction" in proj:
		# Compatibilidad con proyectiles antiguos que solo exponen la propiedad 'direction'.
		proj.set("direction", dir)
		proj.rotation = dir.angle()
	else:
		push_warning("La escena del proyectil no tiene setup(direction, speed, damage, shooter) ni 'direction'.")


func _get_projectile_spawn_position() -> Vector2:
	if projectile_spawn:
		return projectile_spawn.global_position
	return global_position


## Apunta al jugador si sigue detectado; si no, dispara hacia donde mira el enemigo.
func _get_projectile_direction(from: Vector2) -> Vector2:
	if is_instance_valid(_player):
		return (_player.global_position - from).normalized()
	return Vector2.LEFT if _is_facing_left else Vector2.RIGHT


func _get_projectile_damage() -> float:
	return base_attack if projectile_damage < 0.0 else projectile_damage


func _deal_damage_to(body: Node2D) -> void:
	# Si el objetivo soporta knockback le pasamos nuestra posición.
	if body.has_method("take_damage_from"):
		body.take_damage_from(base_attack, global_position)
	else:
		body.take_damage(base_attack)


# ---------------------------------------------------------------------------
# Orientación y animación
# ---------------------------------------------------------------------------

func _set_facing_direction(look_left: bool) -> void:
	if _is_facing_left == look_left:
		return
	_is_facing_left = look_left

	# Si el sprite original mira a la izquierda, la lógica de flip se invierte.
	var flipped := look_left if sprite_faces_right else not look_left

	# Con flip_pivot se voltea todo de una vez.
	if flip_pivot:
		flip_pivot.scale.x = -1.0 if flipped else 1.0
		return

	# Sin pivot: volteamos el sprite y espejamos a mano hitbox y punto de disparo.
	if sprite:
		sprite.flip_h = flipped
	if attack_range:
		attack_range.position.x = - _attack_range_offset_x if look_left else _attack_range_offset_x
	if projectile_spawn:
		projectile_spawn.position.x = - _projectile_spawn_offset_x if look_left else _projectile_spawn_offset_x


## Con force = true reinicia la animación aunque ya sea la actual (útil al atacar).
func _play_animation(anim_name: StringName, force: bool = false) -> void:
	if _is_attacking and not force:
		return
	if not sprite or not sprite.sprite_frames:
		return
	if not sprite.sprite_frames.has_animation(anim_name):
		return

	if sprite.animation != anim_name or force:
		sprite.play(anim_name)


# ---------------------------------------------------------------------------
# Detección
# ---------------------------------------------------------------------------

## Comprueba si el cuerpo es un objetivo válido (principalmente el jugador).
func _is_valid_target(body: Node2D) -> bool:
	return body.is_in_group("player")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player = body as CharacterBody2D


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_player_in_attack_range = false
		_player_in_flee_range = false


func _on_attack_range_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_attack_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_attack_range = false


func _on_flee_area_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_flee_range = true


func _on_flee_area_body_exited(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_flee_range = false


# ---------------------------------------------------------------------------
# Vida y muerte
# ---------------------------------------------------------------------------

func take_damage(amount: float) -> void:
	if _is_dead:
		return
	var damage := amount * (amount / (amount + defence))
	health = maxf(health - damage, 0.0)
	if health <= 0.0:
		_die()
	else:
		_flash_hit()


func _die() -> void:
	_is_dead = true
	died.emit()
	_is_attacking = false
	_can_attack = false
	_player = null
	_player_in_attack_range = false
	_player_in_flee_range = false
	velocity = Vector2.ZERO
	if sprite:
		sprite.stop()
	# set_deferred porque no se puede cambiar 'monitoring' durante un callback de física.
	if detection_area:
		detection_area.set_deferred("monitoring", false)
	if attack_range:
		attack_range.set_deferred("monitoring", false)
	if flee_area:
		flee_area.set_deferred("monitoring", false)
	_drop_loot()
	_on_death()


## Los hijos pueden sobrescribirlo para animaciones de muerte.
func _on_death() -> void:
	queue_free()


func _drop_loot() -> void:
	if loot_table.is_empty():
		return
	var parent := get_parent()
	if parent == null:
		return

	for drop_entry in loot_table:
		# 'continue' para que una entrada inválida no cancele el resto del loot.
		if not drop_entry or not drop_entry.item_scene:
			continue

		if randf() <= drop_entry.drop_chance:
			var amount := randi_range(drop_entry.min_amount, drop_entry.max_amount)
			for i in amount:
				var item := drop_entry.item_scene.instantiate()
				if item:
					# El objeto se asigna ANTES de entrar en escena: _ready lee `item`
					if drop_entry.item_pool.size() > 0 and "item" in item:
						item.set("item", drop_entry.item_pool.pick_random())
					var offset_x := randf_range(-loot_drop_spread, loot_drop_spread)
					var offset_y := randf_range(-loot_drop_y, loot_drop_y)
					# Posición ANTES de add_child: la búsqueda de suelo de `_ready`
					# debe hacerse con el objeto ya colocado, nunca en (0, 0)
					item.global_position = global_position + Vector2(offset_x, offset_y)
					parent.add_child(item)


## Parpadeo rojo al recibir daño.
func _flash_hit() -> void:
	if not sprite:
		return
	if _hit_tween:
		_hit_tween.kill()
	sprite.modulate = Color(1.0, 0.2, 0.2)
	_hit_tween = create_tween()
	_hit_tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
