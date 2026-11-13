# Gold Stone

_Item · pasiva · `Rare` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Gold Stone** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Rare` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/moneda_oro.png` — aplicada, **provisional** |
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
| `extra_coin_chance` | `0.1` |
| `passive_id` | `"piedra_oro"` |

## Cómo conseguirlo

- **Drop**: Orco — 2 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
