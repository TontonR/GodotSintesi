# Fantasma

_Enemigo · volador, huida, teletransporte · **desactivado** · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Ghost** (`ghost.tscn`, clase `ghost`) |
| Escena | `res://scenes/enemies/ghost.tscn` |
| Script | `res://scripts/enemies/ghost.gd` |
| Proyectil | `res://scenes/enemies/ghost_projectile.tscn` |
| Base | `EnemyBase` |
| Estado | `por revisar` · **no aparece en runs** |
| Spawn | Ninguno: ningún bioma lo lista y `enemy_scenes` no lo incluye |
| Capa / máscara | Capa 3 · máscara 1 (no colisiona con el jugador) |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) |

## Stats

| Stat | Valor | Notas |
|---|---|---|
| Vida | 40 → **54** | ×1.35 |
| Daño | 5 → **6.25** | ×1.25 (lo usa el proyectil) |
| Velocidad | 85 px/s | el más rápido de los que existen |
| Cooldown | 2.0 s | |
| Ventana de golpe | 0.6 s | `attack_impact_delay` |
| Animación de ataque | 1.75 s | |
| Vuelo | `flying_enemy = true` | sin gravedad |
| Teletransporte | cooldown 8 s · distancia mínima 80 px | 12 intentos por salto |
| Escala | ×2 · `spawn_y_offset` 6 px | la cola dibuja por debajo del collider |

## Mecánicas

- **Vuela**: se mueve flotando, sin gravedad, y huye del jugador cuando se acerca
  (`flee_enemy`), con prioridad huir > atacar > perseguir.
- **A distancia**: dispara `ghost_projectile` y mantiene la distancia.
- **Teletransporte**: salta a un anillo elíptico entre su rango de huida y el de ataque,
  nunca por encima del jugador (`offset.y = minf(offset.y, 0)`). Es **invulnerable
  mientras se teletransporta**; si no encuentra sitio en 12 intentos, no se mueve.
- `tp_cooldown` 8 s y `tp_min_travel` 80 px para no repetir salto en el sitio.
- Sin drops de objeto: solo moneda (45 %) si algún día se activa.

## Por qué está desactivado

- `ghost.tscn` y su script siguen en el proyecto, pero **ningún `.tres` de bioma lo
  incluye** y `enemy_scenes` de `world_generator.gd` ya no lo lista.
- Para devolverlo a una run hay que añadir su escena a `enemy_scenes` **y** su cuenta a
  `enemy_counts` del bioma (mismo orden) y quitarlo de `DISABLED_ENEMY_SCENES`.
- Antes de activarlo, revisar el balance: vuela, huye y se teletransporta a la vez.

## Drops

| Objeto | Prob. |
|---|---|
| — | **0 %** (no tiene `item_drops`) |

## Cómo comprobarlo (si se reactiva)

- [ ] Vuela sin caer y mantiene distancia con el jugador.
- [ ] Se teletransporta dentro del anillo, nunca encima del jugador.
- [ ] Es invulnerable durante el teletransporte y vuelve a ser hittable al aparecer.
- [ ] Dispara el proyectil y acierta al jugador en movimiento.
- [ ] Al morir solo suelta moneda.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo: [items.md](../items.md)
- Ideas y estado del sistema: [`vault/ideas.md`](../ideas.md) · [`docs/enemies.md`](../../docs/enemies.md)
