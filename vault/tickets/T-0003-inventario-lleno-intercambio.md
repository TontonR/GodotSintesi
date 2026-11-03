# T-0003 · Intercambio cuando la barra está llena

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `feat` (regla de juego) |
| Prioridad | `media` |
| Dueño | `sin asignar` |
| Sistema | inventory |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Ficheros | `scenes/inventory/inventory.gd`, `item_pickup.gd`, `scenes/inventory/inventory_screen.gd` |

## Problema

`Inventory.add_item` enruta por tipo; si la barra del tipo está llena, el objeto **se queda en el suelo** (ver `docs/items.md`). No hay forma de decidir qué soltar, así que un drop repetido es basura inamovible.

## Opciones

| Opción | Comportamiento | Coste |
|---|---|---|
| A. Reemplazo del hueco seleccionado | Sustituye el hueco activo; el anterior cae al suelo | La selección ya existe (`A/D/W/S` en `inventory_screen.gd`) |
| B. Rechazo con aviso | El pickup no se recoge y muestra un mensaje | Menor, pero frustra |
| C. Intercambio con el suelo | El jugador elige entre soltar el actual o descartar el nuevo | Mayor, necesita UI nueva |

## Notas

- La recogida es automática al tocar (`item_pickup.gd` / `body_entered`), así que A necesita saber qué hueco está "activo" aunque la pantalla de inventario esté cerrada.
- Un consumible apilable o del mismo tipo podría sumar en lugar de ocupar hueco: decidir antes de implementar.
- Si se rechaza (B), el pickup debe quedar en el suelo sin consumirse ni parpadear.

## Criterios de aceptación

- [ ] Con la barra llena hay un comportamiento definido y documentado, no un drop huérfano.
- [ ] `docs/items.md` recoge la regla elegida.
- [ ] `changelog.md` actualizado.

## Resultado

Pendiente.
