class_name Items
extends Resource

@export_group("Información Básica")
@export var id: String = ""
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var max_stack: int = 99
@export var value: int = 10

## Método virtual que ejecutará la lógica al usar el objeto
func use(target: Node = null) -> void:
	print("Usando item: ", item_name)
