# Third-Hit Projectile

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Third-Hit Projectile** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/magicW.png` — aplicada, **provisional** |
| Recurso | `res://resources/proyectil_tercer_golpe.tres` |
| Script | `res://scripts/collectables/ComboProjectilePassive.gd` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Every third attack in the rotation launches a projectile that deals 25% of your damage.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"proyectil_tercer_golpe"` |
| `every_n_attacks` | `3` |
| `damage_ratio` | `0.25` |
| `projectile_count` | `1` |
| `spread_degrees` | `0.0` |
| `projectile_speed` | `300.0` |
| `spawn_offset` | `Vector2(24, -10)` |

## Cómo conseguirlo

- **Drop**: Sin drop asignado: pool neutral (solo debug).
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
