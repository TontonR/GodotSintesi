# Gold Stone

_Item · pasiva · `Rare` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Gold Stone** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Rare` |
| Estado | `icono asignado` |
| Textura en el juego | `res://assets/items/item591.png` — aplicada, puede cambiar el arte |
| Recurso | `res://resources/piedra_oro.tres` |
| Script | `res://scripts/collectables/CoinDropBonusPassive.gd` |
| Lo suelta | [Orco](../enemies/orco.md) · 2 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Increases the chance of an enemy dropping a coin on death by 10%.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"piedra_oro"` |
| `extra_coin_chance` | `0.1` |

## Cómo conseguirlo

- **Drop**: Orco — 2 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [x] Icono definitivo asignado en el `.tres` (el arte aún puede cambiar).
- [ ] F5 con el icono en el HUD y en el inventario.
