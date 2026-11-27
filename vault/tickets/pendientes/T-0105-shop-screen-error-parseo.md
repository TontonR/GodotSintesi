# T-0105 · Error de parseo en `shop_screen.gd` (`var sold :=`)

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `bug` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0078 |

## Problema

Al abrir el proyecto, el debugger de Godot escupe **27 errores** y el primero es:

```
Parser Error: Cannot infer the type of "sold" variable because the value doesn't have a set type.
   at res://scripts/ui/shop_screen.gd:176
```

Con ese error la ventana de la tienda no compila, así que el mercader no abre nada.

## Causa

`_merchant` es deliberadamente sin tipo (para no crear una referencia cíclica con `Merchant`),
así que `_merchant != null and _merchant.is_sold(item)` devuelve `Variant` y `:=` no puede
inferir el tipo de `sold`.

## Resultado

Arreglado el 2026-11-27 por `buffy`: tipo explícito y llamada dinámica.

```gdscript
var sold: bool = _merchant != null and bool(_merchant.call("is_sold", item))
```

Comprobado por lectura: es la única inferencia `:=` de esa función que dependía de una llamada
sin tipo (`_player()`, `_rows`, `int(...)` sí están tipadas). No se ha abierto Godot.
