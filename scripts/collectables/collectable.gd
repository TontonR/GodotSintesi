class_name Collectable
extends Items

## Runs when the item is picked up from the ground.
## Returns `true` when stored (the pickup frees itself) and `false` when full.
func on_pickup(_player: Node) -> bool:
	return true
