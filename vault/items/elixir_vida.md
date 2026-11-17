# Perfect Healing Potion

_Item · consumible · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Perfect Healing Potion** |
| Tipo | Consumible — ocupa uno de los 3 slots y se gasta al usarlo |
| Calidad | `Normal` |
| Estado | `icono asignado` |
| Textura en el juego | `res://assets/potions/potion158.png` — aplicada, puede cambiar el arte |
| Recurso | `res://resources/elixir_vida.tres` |
| Script | `res://scripts/collectables/consumable.gd` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/items.md`](../../docs/items.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Restores 100 health.

Se usa con las teclas `1`/`2`/`3` y se gasta al usarlo. Si la barra de 3 slots está llena no se puede recoger (el objeto se queda en el suelo).

## Valores del recurso

| Campo | Valor |
|---|---|
| `heal_amount` | `100` |

## Cómo conseguirlo

- **Drop**: Sin drop asignado: pool neutral (solo debug).
- **Debug**: KP1 (consumible aleatorio)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [x] Icono definitivo asignado en el `.tres` (el arte aún puede cambiar).
- [ ] F5 con el icono en el HUD y en el inventario.
