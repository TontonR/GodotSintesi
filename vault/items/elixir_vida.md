# Life Elixir

_Item · consumible · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Life Elixir** |
| Tipo | Consumible — ocupa uno de los 3 slots y se gasta al usarlo |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/potions/potion15.png` — aplicada, **provisional** |
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

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
