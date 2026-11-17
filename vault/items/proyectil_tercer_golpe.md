# Third-Hit Projectile

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Third-Hit Projectile** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `icono asignado` |
| Textura en el juego | `res://assets/items/iconos/magicW.png` — aplicada, puede cambiar el arte |
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
| `projectile_scene` | `ExtResource("2_proj")` |
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

- [x] Icono definitivo asignado en el `.tres` (el arte aún puede cambiar).
- [ ] F5 con el icono en el HUD y en el inventario.
