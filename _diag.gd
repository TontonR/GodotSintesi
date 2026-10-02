extends SceneTree
var frame: int = 0
var started: bool = false
func _initialize() -> void:
	var scene: Node = load("res://icon.tscn").instantiate()
	root.add_child(scene)
	physics_frame.connect(_on_physics)
func _run() -> void:
	for i in range(30):
		await physics_frame
	var scene: Node = root.get_child(0)
	var tl: TileMapLayer = scene.get_node("TileMapLayer")
	print("nombre raiz=", scene.name, " transform=", scene.transform)
	print("ground_level=", tl.ground_level, " coin_ground_offset=", tl.coin_ground_offset, " coins_per_zone=", tl.coins_per_zone)
	print("claves loaded_zones=", tl.loaded_zones.keys())
	for z in tl.loaded_zones.keys():
		var content: Dictionary = tl.loaded_zones[z]
		print("zona ", z, " -> ", content.keys(), " orcs=", content["orcs"].size(), " coins=", content["coins"].size())
		var c: Node2D = content["coins"][0]
		print("   primera moneda: local=", c.position, " global=", c.global_position, " padre=", c.get_parent().name)
	var coins: Array = get_nodes_in_group("coins")
	print("total monedas en grupo=", coins.size())
	for i in range(mini(4, coins.size())):
		print("  grupo[", i, "] local=", coins[i].position, " global=", coins[i].global_position)
	quit(0)
func _on_physics() -> void:
	frame += 1
	if not started and frame > 2:
		started = true
		_run()
