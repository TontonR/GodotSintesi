# Frog Bubble

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Frog Bubble** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/swirlW.png` — aplicada, **provisional** |
| Recurso | `res://resources/burbuja_rana.tres` |
| Script | `res://scripts/collectables/ComboProjectilePassive.gd` |
| Lo suelta | [Rana](../enemies/rana.md) · 10 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> At the end of the combo, launches 3 saliva projectiles in a fan (15% of base damage each) that pierce all enemies.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"burbuja_rana"` |
| `every_n_attacks` | `3` |
| `damage_ratio` | `0.15` |
| `projectile_count` | `3` |
| `spread_degrees` | `40.0` |
| `projectile_speed` | `300.0` |
| `spawn_offset` | `Vector2(24, -10)` |
| `piercing` | `true` |

## Cómo conseguirlo

- **Drop**: Rana — 10 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
