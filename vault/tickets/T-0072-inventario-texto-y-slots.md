# T-0072 · Inventario: texto más pequeño, slots fijos y objetos al día

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `media` |
| Dueño | `opencode-jorge` |
| Sistema | inventory / docs |
| Creado | 2026-11-17 |
| Actualizado | 2026-11-17 |
| Relacionado | T-0069, T-0070, T-0071 |

## Problema

- El inventario in-game es feo: el texto del panel derecho (nombre 20 px, stats y
  descripción 18 px) es demasiado grande, y cuando el nombre o la descripción son largos
  el panel crece y "alarga" el HUD.
- Los slots de consumibles se adaptaban al tamaño de la textura: 4 iconos son de 32×32
  (`Icon12`, `Icon19`, `Icon34`, `sanguine_ruby`) y estiraban el slot de 18×18 del HUD.
- Los cambios de `docs/items.md` que trajo Jorge (iconos definitivos, tiers de poción,
  renombres) no estaban todos en las fichas de `vault/items/`.

## Causa

- `inventory_screen.tscn`: fuentes grandes y `ItemDescription` con `autowrap` sin
  `clip_text`; su altura mínima con texto largo empujaba el mínimo de la ventana de
  248 a 404 px (medido headless).
- `inventory_slot.tscn` no tenía `expand_icon`: el `Button` sumaba el tamaño del icono a
  su tamaño mínimo (32 px en vez de 18/40).
- Las fichas del vault se generaron antes del merge de iconos: seguían con la tabla de
  valores antigua (p. ej. `pocion_mayor` como `heal_amount 60`) y el pendiente de textura.

## Plan

1. Bajar fuentes del panel derecho (nombre 15; stats y descripción 12), cabeceras 13,
   contador 11 y preview 96 px.
2. `clip_text` en `ItemDescription` para que el texto largo se recorte dentro del panel.
3. `expand_icon = true` en `inventory_slot.tscn`: el slot manda y el icono se adapta.
4. Regenerar la tabla `## Valores del recurso` de las 44 fichas desde los `.tres` y
   actualizar el pendiente de textura.

## Criterios de aceptación

- [x] El icono de 32×32 ya no cambia el tamaño del slot: 18×18 en el HUD y 40×40 en el
  inventario (comprobado headless).
- [x] Con nombre, stats y descripción largos la ventana sigue en 744×380 (mínimo 248 px).
- [x] Las 44 fichas de `vault/items/` cuadran con su `.tres` (nombre, icono, valores).
- [x] `docs/ui.md` y `vault/items.md` al día.
- [ ] F5: abrir el inventario con el Mucus Potion y un objeto de texto largo; ver que no
  se estira nada y que se lee bien.

## Resultado

- `scenes/inventory/inventory_screen.tscn`: fuentes 15/12/13/11, preview 96 px,
  `ItemDescription.clip_text = true`.
- `scenes/inventory/inventory_slot.tscn`: `expand_icon = true`; fuera la línea duplicada
  de `inventory_screen.gd`.
- `vault/items/*.md` (44): tabla de valores regenerada desde el `.tres` y pendiente de
  textura marcado como asignado, con F5 pendiente.
- Verificado headless: slots 18×18/40×40 con icono de 16 y de 32; ventana 744×380 con
  mínimo 248. Sin F5.
