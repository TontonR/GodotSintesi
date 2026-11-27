# T-0106 · `icon_max_width` no es propiedad de `Button`

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `bug` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0078, T-0105 |

## Problema

Al abrir la tienda con F, el debugger escupe en cada `open()`:

```
ShopScreen._build_rows: Invalid assignment of property or key 'icon_max_width'
with value of type 'int' on a base object of type 'Button'.
   shop_screen.gd:157 @ _build_rows()
```

Las filas se llegan a crear (el error es de asignación, no corta el bucle), pero el icono de
cada objeto se dibujaba a tamaño completo en vez de a 16 px.

## Causa

`icon_max_width` es una **constante de tema** de `Button`, no una propiedad `@export`. Asignarla
con `=` sobre la instancia es siempre un error de runtime.

## Resultado

Arreglado el 2026-11-27 por `buffy`:

```gdscript
button.add_theme_constant_override("icon_max_width", 16)
```

Si la constante no existiera en esta versión de Godot, el override se ignora sin error y el
icono sale a tamaño nativo; nunca vuelve a romper la apertura de la tienda.

Comprobado por lectura. **F5 pendiente** para ver las filas a 16 px.
