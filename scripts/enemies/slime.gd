class_name slime
extends EnemyBase
## Slime básico: persigue al jugador y ataca cuerpo a cuerpo.
## Toda la IA (detección, persecución, ataque, daño, loot y muerte) vive en EnemyBase.


func _init() -> void:
	max_health = 20.0
	base_attack = 6.0
	speed_movement = 35.0
	attack_cooldown = 1.8

	idle_animation = &"idle"
	move_animation = &"walk"
	attack_animation = &"attack"

	attack_impact_delay = 0.5
	attack_duration = 1.2


func _ready() -> void:
	# Fallbacks por si la escena no trae los exports cableados.
	if not sprite:
		sprite = get_node_or_null("Pivot/Slime")
	if not detection_area:
		detection_area = get_node_or_null("Pivot/detection_area")
	if not attack_range:
		attack_range = get_node_or_null("Pivot/attack_range")
	if not flip_pivot:
		flip_pivot = get_node_or_null("Pivot")

	super()
