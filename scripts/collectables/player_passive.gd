class_name PlayerPassives
extends Node

## Emitted when the list of active passives changes
signal passives_changed

# The only Array storing every active passive object
var active_passives: Array[PassiveItems] = []

func _ready() -> void:
	# Binds the UI list (same pattern as Inventory with its bar)
	var player := get_parent()
	if player == null or player.get_parent() == null:
		return
	var bar := player.get_parent().get_node_or_null("UILayer/PassiveBar")
	if bar:
		bar.call("bind", self)

## Adds a new passive item once; duplicates are refused (collectables never stack).
func add_passive(passive: PassiveItems) -> bool:
	if passive == null or has_passive(passive):
		return false
	active_passives.append(passive)
	passive.on_equip(get_parent()) # 'get_parent()' assumes it is the Player node
	passives_changed.emit()
	return true

## True when that passive is already equipped (same instance, resource or id).
func has_passive(passive: PassiveItems) -> bool:
	if passive == null:
		return false
	for owned in active_passives:
		if owned == null:
			continue
		if owned == passive:
			return true
		if not owned.resource_path.is_empty() and owned.resource_path == passive.resource_path:
			return true
		if not owned.passive_id.is_empty() and owned.passive_id == passive.passive_id:
			return true
	return false

## Removes a passive item from the array
func remove_passive(passive: PassiveItems) -> void:
	if passive in active_passives:
		passive.on_unequip(get_parent())
		active_passives.erase(passive)
		passives_changed.emit()

## Resource paths of the equipped passives, in order. Used by the save.
func serialized_passives() -> PackedStringArray:
	var paths := PackedStringArray()
	for passive in active_passives:
		if passive and not passive.resource_path.is_empty():
			paths.append(passive.resource_path)
	return paths


## Re-equips the passives of a save (Continue); their equip effects run again.
func restore_from_save(paths: Array) -> void:
	while not active_passives.is_empty():
		remove_passive(active_passives.back())
	for path in paths:
		var item := load(String(path)) as PassiveItems
		if item:
			add_passive(item)


## Runs when the player attacks
func trigger_attack_passives(target: Node, base_damage: float) -> float:
	var current_damage = base_damage
	for passive in active_passives:
		current_damage = passive.on_player_attack(target, current_damage)
	return current_damage

## Runs when the player takes damage
func trigger_take_damage_passives(base_damage: float, attacker: Node = null) -> float:
	var current_damage = base_damage
	for passive in active_passives:
		current_damage = passive.on_player_take_damage(current_damage, attacker)
	return current_damage

## Runs when the player starts an attack (step = 1, 2, 3... of the combo)
func trigger_attack_started_passives(player: Node, step: int, direction: Vector2) -> void:
	for passive in active_passives:
		passive.on_player_attack_started(player, step, direction)

## Runs when the player blocks a frontal hit
func trigger_blocked_passives(player: Node) -> void:
	for passive in active_passives:
		passive.on_player_blocked(player)

## Runs when the player kills an enemy
func trigger_kill_passives(player: Node, enemy: Node) -> void:
	for passive in active_passives:
		passive.on_enemy_killed(player, enemy)

## Update loop for passives with timers/regeneration
func _process(delta: float) -> void:
	for passive in active_passives:
		passive.on_update(get_parent(), delta)
