class_name skeleton
extends EnemyBase
## Esqueleto básico: se mueve y ataca como el slime, pero el primer golpe que
## recibe hace 0 de daño (solo muestra el flash de impacto).

var _first_hit_blocked: bool = false


func _init() -> void:
	max_health = 40.0
	base_attack = 10.0
	speed_movement = 50.0
	attack_cooldown = 2.0

	idle_animation = &"idle"
	move_animation = &"walk"
	attack_animation = &"attack"

	attack_impact_delay = 0.4
	attack_duration = 0.8


func _ready() -> void:
	# Fallbacks por si la escena no trae los exports cableados.
	if not sprite:
		sprite = get_node_or_null("Pivot/Skeleton")
	if not detection_area:
		detection_area = get_node_or_null("Pivot/detection_area")
	if not attack_range:
		attack_range = get_node_or_null("Pivot/attack_range")
	if not flip_pivot:
		flip_pivot = get_node_or_null("Pivot")

	super()


## El primer golpe recibido no resta vida; a partir del segundo se usa el daño
## normal de EnemyBase.
func take_damage(amount: float) -> void:
	if _is_dead:
		return

	if not _first_hit_blocked:
		_first_hit_blocked = true
		_flash_hit()
		return

	super.take_damage(amount)
