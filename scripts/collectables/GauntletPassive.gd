class_name GauntletPassive
extends PassiveItems
## Potencia el impacto que sigue a cada N ataques de la rotación.

@export_group("Guantelete")
## Cada cuántos ataques se potencia el siguiente impacto.
@export var every_n_attacks: int = 5
## Multiplicador aplicado al golpe potenciado.
@export var damage_multiplier: float = 2.0

var _attacks: int = 0
var _empowered: bool = false


func on_equip(player: Node) -> void:
	super.on_equip(player)
	_attacks = 0
	_empowered = false


func on_player_attack_started(_player: Node, _step: int, _direction: Vector2) -> void:
	# Si el ataque potenciado anterior no llegó a impactar, se pierde.
	_empowered = false
	_attacks += 1
	if every_n_attacks > 0 and _attacks % every_n_attacks == 0:
		_empowered = true


func on_player_attack(_target: Node, damage: float) -> float:
	if not _empowered:
		return damage
	_empowered = false
	return damage * damage_multiplier
