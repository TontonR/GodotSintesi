# Second Wind

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Second Wind** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/boostW.png` — aplicada, **provisional** |
| Recurso | `res://resources/segundo_aliento.tres` |
| Script | `res://scripts/collectables/SecondWindPassive.gd` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> If you drop below 30% health, you recover 2 health per second.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"segundo_aliento"` |
| `health_threshold` | `0.3` |
| `heal_per_second` | `2.0` |

## Cómo conseguirlo

- **Drop**: Sin drop asignado: pool neutral (solo debug).
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
