class_name MocoPotion
extends Consumable
## Slime potion: raises the jump for 60 s and leaves the player shedding slime
## particles permanently (the slime stays after the effect ends).

@export_group("Slime potion")
## Jump multiplier while the effect lasts.
@export var jump_multiplier: float = 1.3
## Slime levels it adds (permanent).
@export var moco_levels: int = 1


func use(target: Node = null) -> void:
	super.use(target)
	if target == null:
		return
	if target.has_method("apply_jump_bonus"):
		var seconds: float = duration if duration > 0.0 else 60.0
		target.call("apply_jump_bonus", jump_multiplier, seconds)
	if target.has_method("moco_emitter"):
		var emitter: Node = target.call("moco_emitter")
		if emitter:
			emitter.call("add_level", moco_levels)
