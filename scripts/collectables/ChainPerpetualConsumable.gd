class_name ChainPerpetualConsumable
extends Consumable
## Life sentence: the next enemy that hits the player is burned, or immobilized
## if it was already burning.

@export_group("Life sentence")
## Burn damage per second applied to the attacker.
@export var burn_dps: float = 5.0
## Burn duration in seconds.
@export var burn_seconds: float = 5.0
## Immobilize duration when the target was already burning.
@export var immobilize_seconds: float = 2.0
## Seconds the charge stays armed before it is wasted.
@export var arm_seconds: float = 20.0


func use(target: Node = null) -> void:
	super.use(target)
	if target and target.has_method("arm_chain_perpetua"):
		target.call("arm_chain_perpetua", burn_dps, burn_seconds, immobilize_seconds, arm_seconds)
