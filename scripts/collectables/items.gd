class_name Items
extends Resource

@export_group("Basic Information")
@export var id: String = ""
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var max_stack: int = 99
@export var value: int = 10

## Virtual method running the logic when the item is used
func use(target: Node = null) -> void:
	print("Usando item: ", item_name)
