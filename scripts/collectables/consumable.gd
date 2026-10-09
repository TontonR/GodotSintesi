class_name Consumable
extends Items

@export_group("Efectos Consumibles")
@export var heal_amount: int = 0
@export var stamina_amount: int = 0
@export var duration: float = 0.0

func use(target: Node = null) -> void:
	super.use(target) # Llama al método base
	
	if target and target.has_method("heal"):
		target.heal(heal_amount)
		print("Restaurados ", heal_amount, " de vida a ", target.name)
