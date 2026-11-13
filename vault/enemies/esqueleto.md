# Esqueleto

_Enemigo · melee · activo · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Skeleton** (`skeleton.tscn`, clase `skeleton`) |
| Escena | `res://scenes/enemies/skeleton.tscn` |
| Script | `res://scripts/enemies/skeleton.gd` |
| Base | `EnemyBase` |
| Estado | `por revisar` (F5 y revisión pendientes) |
| Spawn | Nieve, 2 por chunk |
| Capa / máscara | Capa 3 (`enemies`) · máscara 1 (solo mundo) |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) · [`docs/fx.md`](../../docs/fx.md) |

## Stats

| Stat | Base → final | Notas |
|---|---|---|
| Vida | 40 → **54** | ×1.35 |
| Daño | 10 → **12.5** | ×1.25 |
| Velocidad | 50 px/s | |
| Cooldown | 2.0 s | |
| Ventana de golpe | 0.4 s | la más rápida de los melee |
| Animación de ataque | 0.8 s | |
| Escala | ×2 | |

## Mecánicas

- Melee de ritmo rápido: ventana de 0.4 s y animación corta, pero cooldown de 2 s.
- **El primer golpe que recibe hace 0**: `_first_hit_blocked` se come el primer `take_damage()` y solo hace destellar el sprite. Sirve para "romper" la guardia del jugador con un ataque gratis.
- Cualquier override de `take_damage` debe respetar la firma `(amount, critical = false)` y pasar `critical` a `super`, o la escena no parsea.
- Daño por `Area2D`; el jugador lo atraviesa con coste de contacto.
- Sin drops de objeto: su valor es la densidad (2 por chunk en nieve).

## Drops

| Objeto | Prob. |
|---|---|
| — | **0 %** (no tiene `item_drops`) |

- Moneda: 45 % de serie.
- Pendiente de diseño: asignarle objetos (ver [items.md](../items.md) y [`docs/loot.md`](../../docs/loot.md)).

## Spawn

- `nieve.tres`: `enemy_scenes` = [esqueleto, arquero, lobo], `enemy_counts` = [2, 2, 1] → **2 esqueletos por chunk**.
- Chunks 0–1 al ×0.5; hasta ×1.8 en chunks maduros.
- No sale en pradera ni en bosque rojo.

## Cómo comprobarlo (F5)

- [ ] Aparece en nieve y persigue.
- [ ] El primer golpe que le das **no baja vida** (solo destello) y el segundo sí.
- [ ] Golpea a los ~0.4 s y termina la animación antes de volver a moverse.
- [ ] Al morir no suelta objeto, solo moneda (~45 %).
- [ ] No se puede empujar ni atravesar con daño de cuerpo del jugador sin coste.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo: [items.md](../items.md)
- Sin ficha de pasivas: no tiene drops todavía.
