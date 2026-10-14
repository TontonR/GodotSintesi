class_name DamageReductionPassive
extends PassiveItems

@export_group("Defensa")
## Fracción de daño recibido que se anula (0.0 - 1.0)
@export_range(0.0, 1.0, 0.05) var reduction: float = 0.25

func on_player_take_damage(amount: float) -> float:
	return amount * (1.0 - reduction)
