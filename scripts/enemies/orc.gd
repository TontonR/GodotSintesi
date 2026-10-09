extends EnemyBase

func _init() -> void:
	max_health = 50.0
	base_attack = 15.0
	speed_movement = 75.0
	attack_cooldown = 2.0

	idle_animation = &"idle"
	move_animation = &"walk"
	attack_animation = &"attack"

	attack_impact_delay = 0.66
	attack_duration = 2.5


func _ready() -> void:
	if not sprite:
		sprite = $Pivot/Orc
	if not detection_area:
		detection_area = $Pivot/detection_area
	if not attack_range:
		attack_range = $Pivot/attack_range

	super()

	if _attack_range_offset_x == 0.0:
		_attack_range_offset_x = 35.0