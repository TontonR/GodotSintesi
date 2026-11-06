# T-0034 · Pantalla de inventario al doble

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | inventory / ui |
| Creado | 2026-11-06 |
| Actualizado | 2026-11-06 |
| Relacionado | T-0010, T-0012 |

## Problema

La pantalla de inventario (Tab/I) se ve a la mitad de tamaño que el resto de la
interfaz: ventana de 372×190 con fuentes de 8-10 px y huecos de 20×20 sobre un
viewport de 768×432.

## Causa / contexto

`project.godot` pasó a 768×432 (`window/size/viewport_width/height`) con escala
entera ×2 en T-0010, pero `scenes/inventory/inventory_screen.tscn` conservó las
medidas de la época de 384×216: la ventana, paneles, márgenes y fuentes están
pensados para la mitad de resolución. El HUD no se toca: solo el inventario.

## Plan

1. Duplicar en el `.tscn` ventana (744×380, offsets ±372/±190), márgenes (16/8),
   radios (12/8), bordes (2), separaciones (20 y 8), paneles (168/272/232),
   retrato (144×104), botones de página (32×32), icono de preview (128) y
   fuentes (9→18, 8→16, 10→20).
2. En `inventory_screen.gd`: `SLOT_SIZE` 40×40, `COLLECTIBLE_SLOT_SIZE` 32×32 y
   `expand_icon` en los huecos de esta pantalla (el HUD reutiliza el mismo
   `InventorySlot` a 18×18).
3. Documentar en `docs/ui.md`.

## Criterios de aceptación

- [ ] Con Tab/I la ventana ocupa el doble y cabe entera en 768×432, centrada.
- [ ] Los 5 huecos de skills/consumibles y los 36 coleccionables se ven al doble,
      con el icono llenando el hueco y sin desbordar su columna.
- [ ] El HUD (barra de 5 huecos) sigue a 18×18.
- [ ] `docs/ui.md` actualizado; changelog y estado al cerrar.

## Resultado

`scenes/inventory/inventory_screen.tscn` y `scenes/inventory/inventory_screen.gd`
con todas las medidas duplicadas; iconos escalados dentro del hueco solo en esta
pantalla. El ancho interior (744 − 32) coincide exacto con las tres columnas y
sus separaciones (168 + 272 + 232 + 2×20 = 712). Sin ejecutar Godot (regla de
`AGENTS.md`): falta F5.
