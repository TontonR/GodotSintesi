# Greater Stamina Potion

_Item · consumible · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Greater Stamina Potion** |
| Tipo | Consumible — ocupa uno de los 3 slots y se gasta al usarlo |
| Calidad | `Normal` |
| Estado | `icono asignado` |
| Textura en el juego | `res://assets/potions/potion137.png` — aplicada, puede cambiar el arte |
| Recurso | `res://resources/pocion_mayor.tres` |
| Script | `res://scripts/collectables/consumable.gd` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/items.md`](../../docs/items.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Restores 50 stamina.

Se usa con las teclas `1`/`2`/`3` y se gasta al usarlo. Si la barra de 3 slots está llena no se puede recoger (el objeto se queda en el suelo).

## Valores del recurso

| Campo | Valor |
|---|---|
| `stamina_amount` | `50` |

## Cómo conseguirlo

- **Drop**: Sin drop asignado: pool neutral (solo debug).
- **Debug**: KP1 (consumible aleatorio)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [x] Icono definitivo asignado en el `.tres` (el arte aún puede cambiar).
- [ ] F5 con el icono en el HUD y en el inventario.
