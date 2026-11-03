class_name MocoPotion
extends Consumable
## Poción de mocos: sube el salto 60 s y deja al jugador soltando partículas de
## moco permanentemente (el moco se queda al terminar el efecto).

@export_group("Poción de mocos")
## Multiplicador de salto mientras dura el efecto.
@export var jump_multiplier: float = 1.3
## Niveles de moco que añade (permanentes).
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
