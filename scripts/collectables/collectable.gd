class_name Collectable
extends Items

## Se ejecuta al recoger el objeto del suelo.
## Devuelve `true` si queda recogido (el pickup se libera) y `false` si no cabe.
func on_pickup(_player: Node) -> bool:
	return true
