class_name SecondWindPassive
extends PassiveItems
## Regenera vida mientras el jugador está por debajo de un umbral.

@export_group("Segundo aliento")
## Fracción de vida por debajo de la cual se activa (0.3 = 30%).
@export_range(0.0, 1.0, 0.05) var health_threshold: float = 0.3
## Vida recuperada por segundo mientras está activo.
@export var heal_per_second: float = 2.0

var _accum: float = 0.0


func on_equip(player: Node) -> void:
	super.on_equip(player)
	_accum = 0.0


func on_update(player: Node, delta: float) -> void:
	if not ("health" in player) or not ("max_health" in player):
		return
	var max_h := float(player.get("max_health"))
	if max_h <= 0.0:
		return
	var health := float(player.get("health"))
	if health / max_h >= health_threshold:
		_accum = 0.0
		return
	if not player.has_method("heal"):
		return

	_accum += heal_per_second * delta
	if _accum < 1.0:
		return
	var amount := int(_accum)
	_accum -= float(amount)
	player.call("heal", amount)
