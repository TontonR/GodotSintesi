class_name DungeonEntrance
extends Node2D
## Dungeon door for the explorable dungeon, drawn with the `tower_test` sprite.
##
## The door is a passive marker: it only joins the `dungeon_entrance` group and
## carries its layout seed. `DungeonLayer` finds it there, shows the "F: enter"
## prompt when the player is close and reads F, so the door keeps working no
## matter what happens to its chunk (rebuild, reload, teleport, camera).

## Dungeon layout seed for this door. 0 derives one from its world position,
## which is stable for a seed because the structure placement is deterministic.
var dungeon_seed: int = 0


func _ready() -> void:
	add_to_group("dungeon_entrance")
	if dungeon_seed == 0:
		dungeon_seed = absi(hash("door:%d:%d" % [roundi(global_position.x), roundi(global_position.y)]))
