# Arquero

_Enemigo · a distancia · activo · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Archer** (`archer.tscn`, clase `archer`) |
| Escena | `res://scenes/enemies/archer.tscn` |
| Script | `res://scripts/enemies/archer.gd` |
| Base | `EnemyBase` |
| Estado | `por revisar` (F5 y revisión pendientes) |
| Spawn | Nieve, 2 por chunk |
| Capa / máscara | Capa 3 (`enemies`) · máscara 1 (solo mundo) |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) · [`docs/loot.md`](../../docs/loot.md) |

## Stats

| Stat | Base → final | Notas |
|---|---|---|
| Vida | 30 → **40.5** | ×1.35 |
| Daño | 8 → **10** | ×1.25 (lo usa la flecha) |
| Velocidad | 55 px/s | |
| Cooldown | 2.2 s | |
| Ventana de golpe | 0.6 s | `attack_impact_delay` |
| Animación de ataque | 1.1 s | |
| Proyectil | 240 px/s | `projectile_speed` |
| Escala | ×2 | |

## Mecánicas

- `ranged_enemy = true`: se detiene dentro de su rango (grande) y dispara en vez de cuerpo a cuerpo.
- La flecha sale de `Pivot/muzzle` y apunta al jugador mientras lo detecta; la escena del proyectil es `archer_projectile.tscn` (escala 0.6).
- El daño del proyectil sale de `base_attack` (no define `projectile_damage` propio).
- Se queda quieto durante la animación de ataque (1.1 s): es la ventana para acercarse.
- Sin `item_drops`: solo moneda (45 %).
- Trampa: el campo se llama `projectile`, **no** `projectile_scene`; y el root del proyectil debe ser `Node2D` con `setup(direction, speed, damage, shooter)`.

## Drops

| Objeto | Prob. |
|---|---|
| — | **0 %** (no tiene `item_drops`) |

- Moneda: 45 % de serie.
- Pendiente de diseño: asignarle objetos (ver [items.md](../items.md) y [`docs/loot.md`](../../docs/loot.md)).

## Spawn

- `nieve.tres`: `enemy_scenes` = [esqueleto, arquero, lobo], `enemy_counts` = [2, 2, 1] → **2 arqueros por chunk**.
- Chunks 0–1 al ×0.5; hasta ×1.8 en chunks maduros.
- No sale en pradera ni en bosque rojo.

## Cómo comprobarlo (F5)

- [ ] Aparece en nieve, se para a distancia y dispara al jugador.
- [ ] La flecha sale del arco (`Pivot/muzzle`), no del centro del cuerpo, y viaja a ~240 px/s.
- [ ] Bloquear con la guardia el proyectil no rompe la animación del arquero.
- [ ] Al morir no suelta objeto, solo moneda.
- [ ] Si el jugador se aleja, deja de disparar y vuelve a su rango.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo: [items.md](../items.md)
- Sin ficha de pasivas: no tiene drops todavía.
