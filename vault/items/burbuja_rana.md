# Frog Bubble

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Frog Bubble** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `icono asignado` |
| Textura en el juego | `res://assets/items/item804.png` — aplicada, puede cambiar el arte |
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
| `projectile_scene` | `ExtResource("2_proj")` |
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

- [x] Icono definitivo asignado en el `.tres` (el arte aún puede cambiar).
- [ ] F5 con el icono en el HUD y en el inventario.
