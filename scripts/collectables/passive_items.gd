class_name PassiveItems
extends Collectable

@export_group("Configuración Pasiva")
@export var passive_id: String = "pasiva_basica"

## Se llama automáticamente cuando el objeto entra al inventario
func on_equip(player: Node) -> void:
	print("Pasiva equipada: ", item_name)

## Se llama automáticamente cuando el objeto sale del inventario
func on_unequip(player: Node) -> void:
	print("Pasiva desequipada: ", item_name)

## Evento: cuando el jugador ataca
func on_player_attack(target: Node, damage: float) -> float:
	return damage # Devuelve el daño modificado

## Evento: al iniciar un ataque de la rotación (paso 1-based)
func on_player_attack_started(_player: Node, _step: int, _direction: Vector2) -> void:
	pass

## Evento: cuando el jugador recibe daño
func on_player_take_damage(amount: float, _attacker: Node = null) -> float:
	return amount # Devuelve el daño recibido modificado

## Evento: cuando el jugador bloquea un ataque frontal
func on_player_blocked(_player: Node) -> void:
	pass

## Evento: cuando el jugador mata a un enemigo
func on_enemy_killed(_player: Node, _enemy: Node) -> void:
	pass

## Evento: procesamiento por frame o tiempo (opcional)
func on_update(player: Node, delta: float) -> void:
	pass

## Al recogerlo se equipa como pasiva activa del jugador
func on_pickup(player: Node) -> bool:
	# Acceso por nombre para no crear referencia cíclica con PlayerPassives
	var passives := player.get_node_or_null("PlayerPassives")
	if passives == null or not passives.has_method("add_passive"):
		return false
	# Cada recogida usa una copia propia: así los contadores/cooldowns de dos
	# copias de la misma pasiva no comparten estado.
	var copy := duplicate() as PassiveItems
	if copy == null:
		return false
	passives.add_passive(copy)
	return true
