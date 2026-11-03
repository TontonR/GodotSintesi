class_name SlowOnHitPassive
extends PassiveItems
## Lengua de rana: al golpear a un enemigo le baja la velocidad un tiempo.

@export_group("Ralentización")
## Multiplicador de velocidad que se le deja al enemigo (0.5 = la mitad).
@export_range(0.1, 1.0, 0.05) var slow_multiplier: float = 0.5
## Segundos que dura la ralentización.
@export var slow_seconds: float = 3.0


func on_player_attack(target: Node, damage: float) -> float:
	if target == null:
		return damage
	# El golpe puede llegar al cuerpo del enemigo o a un Area2D hijo.
	var enemy: Node = target
	if not enemy.has_method("apply_slow"):
		enemy = enemy.get_parent()
	if enemy and enemy.has_method("apply_slow"):
		enemy.call("apply_slow", slow_multiplier, slow_seconds)
	return damage
