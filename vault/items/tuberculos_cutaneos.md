# Skin Tubercles

_Item · pasiva · `Rare` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Skin Tubercles** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Rare` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/poisonW.png` — aplicada, **provisional** |
| Recurso | `res://resources/tuberculos_cutaneos.tres` |
| Script | `res://scripts/collectables/PoisonCloudPassive.gd` |
| Lo suelta | [Rana](../enemies/rana.md) · 2 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> When you take damage, you release a poison cloud on the ground that damages enemies.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"tuberculos_cutaneos"` |
| `cooldown_seconds` | `4.0` |
| `radius` | `44.0` |
| `damage_per_tick` | `2.0` |
| `cloud_lifetime` | `4.0` |

## Cómo conseguirlo

- **Drop**: Rana — 2 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
