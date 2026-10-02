extends Node
var frames: int = 0
var done: bool = false
func _ready() -> void:
	var scene: Node = load("res://icon.tscn").instantiate()
	add_child(scene)
	for i in range(40):
		await get_tree().process_frame
	var game: Node = scene.get_node("game")
	var player: Node = scene.get_node("player"
	)
	var best: Node2D = null
	for child in game.get_children():
		if child.has_method("take_damage") and child != player:
			if best == null or absf(child.position.x - player.position.x) < absf(best.position.x - player.position.x):
				best = child
	if best == null:
		print("NO HAY OGRO")
	else:
		player.position.x = best.position.x - 26.0
		player.velocity.x = 0.0
		await get_tree().process_frame
		best.take_damage(9999)
		print("ogro muerto cerca del jugador")
	for i in range(15):
		await get_tree().process_frame
	done = true
func _process(_d: float) -> void:
	frames += 1
	if done and frames % 10 == 0:
		get_viewport().get_texture().get_image().save_png("/tmp/opencode/drop_check.png")
		print("captura guardada, monedas=", get_tree().get_nodes_in_group("coins").size())
		get_tree().quit(0)
