class_name Consumable
extends Collectable

@export_group("Efectos Consumibles")
@export var heal_amount: int = 0
@export var stamina_amount: int = 0
@export var duration: float = 0.0

func use(target: Node = null) -> void:
	super.use(target) # Llama al método base

	if target == null:
		return

	if heal_amount > 0 and target.has_method("heal"):
		target.heal(heal_amount)
		print("Restaurados ", heal_amount, " de vida a ", target.name)

	if stamina_amount > 0 and target.has_method("restore_stamina"):
		target.restore_stamina(stamina_amount)
		print("Restaurada ", stamina_amount, " de stamina a ", target.name)

## Ocupa el primer hueco libre de la barra; si está llena, no pasa nada
func on_pickup(player: Node) -> bool:
	var inventory := player.get_node_or_null("Inventory") as Inventory
	if inventory == null:
		return false
	return inventory.add_item(self)
