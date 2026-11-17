class_name TeleportConsumable
extends Consumable
## Teleport: casts for a moment, then moves the player forward.

@export_group("Teleport")
## Forward distance in px.
@export var distance: float = 96.0
## Cast time before the movement (s).
@export var cast_time: float = 0.6


func use(target: Node = null) -> void:
	super.use(target)
	if target == null:
		return
	if target.has_method("apply_control_lock"):
		target.call("apply_control_lock", cast_time)
	var tree := target.get_tree()
	if tree == null:
		return
	await tree.create_timer(cast_time).timeout
	if is_instance_valid(target) and target.has_method("teleport_forward"):
		target.call("teleport_forward", distance)
