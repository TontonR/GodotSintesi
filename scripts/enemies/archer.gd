class_name archer
extends EnemyBase
## Arquero: se queda a distancia y dispara flechas al jugador.
## La comprobación de rango y el disparo los resuelve EnemyBase.


func _init() -> void:
	max_health = 30.0
	base_attack = 8.0
	speed_movement = 55.0
	attack_cooldown = 2.2

	ranged_enemy = true
	projectile_speed = 240.0

	idle_animation = &"idle"
	move_animation = &"walk"
	attack_animation = &"attack"

	attack_impact_delay = 0.6
	attack_duration = 1.1


func _ready() -> void:
	# Fallbacks por si la escena no trae los exports cableados.
	if not sprite:
		sprite = get_node_or_null("Pivot/Archer")
	if not detection_area:
		detection_area = get_node_or_null("Pivot/detection_area")
	if not attack_range:
		attack_range = get_node_or_null("Pivot/attack_range")
	if not projectile_spawn:
		projectile_spawn = get_node_or_null("Pivot/muzzle")
	if not flip_pivot:
		flip_pivot = get_node_or_null("Pivot")

	super()
