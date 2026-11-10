class_name slime
extends EnemyBase
## Basic slime: chases the player and attacks in melee.
## All the AI (detection, chase, attack, damage, loot and death) lives in EnemyBase.


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
	# Fallbacks in case the scene does not have the exports wired.
	if not sprite:
		sprite = get_node_or_null("Pivot/Slime")
	if not detection_area:
		detection_area = get_node_or_null("Pivot/detection_area")
	if not attack_range:
		attack_range = get_node_or_null("Pivot/attack_range")
	if not flip_pivot:
		flip_pivot = get_node_or_null("Pivot")

	super()
