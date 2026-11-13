# Demonio

_Enemigo · volador, chorro de fuego · **desactivado** · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Demon** (`demon.tscn`, clase `demon`) |
| Escena | `res://scenes/enemies/demon.tscn` |
| Script | `res://scripts/enemies/demon.gd` |
| Ataque | `res://scenes/enemies/demon_fire.tscn` |
| Base | `EnemyBase` |
| Estado | `por revisar` · **no aparece en runs** |
| Spawn | Ninguno: ningún bioma lo lista y `enemy_scenes` no lo incluye |
| Capa / máscara | Capa 3 · máscara 1 |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) · [`docs/player.md`](../../docs/player.md) |

## Stats

| Stat | Valor | Notas |
|---|---|---|
| Vida | 180 → **243** | el más tanque del juego |
| Daño | 5 → **6.25** | ×1.25; el daño real es el chorro |
| Vuelo | 70 px/s | `flying_enemy` |
| Altura | `fly_height` 80 px sobre su spawn | |
| Ciclo | 3 s volando | |
| Aviso | 0.75 s | antes de encender el chorro |
| Chorro | 3 s | `demon_fire`, se estira hasta el suelo |
| Escala | ×2 | |

## Mecánicas

- Ciclo fijo: 3 s volando a 80 px sobre su spawn, 0.75 s de aviso y 3 s de **chorro de
  fuego vertical** que llega al suelo.
- El chorro (`demon_fire.tscn`, escala 1 × 0.55) es el ataque real: `base_attack` solo
  marca el daño base.
- **La guardia lo castiga**: bloquear el chorro lo aturde 5 s o hasta recibir 3 golpes.
  Es la única ventana clara para matarlo.
- Ignora la gravedad mientras vuela; se coloca sobre `fly_height` y no persigue a pie.
- Sin drops de objeto: solo moneda (45 %) si algún día se activa.

## Por qué está desactivado

- `demon.tscn` y su script siguen en el proyecto, pero **ningún `.tres` de bioma lo
  incluye** y `enemy_scenes` de `world_generator.gd` ya no lo lista.
- Para devolverlo a una run hay que añadir su escena a `enemy_scenes` **y** su cuenta a
  `enemy_counts` del bioma (mismo orden) y quitarlo de `DISABLED_ENEMY_SCENES`.
- Con 243 HP y un chorro de 3 s, meterlo en pradera rompería el ritmo actual: necesita
  bioma o zona propia.

## Drops

| Objeto | Prob. |
|---|---|
| — | **0 %** (no tiene `item_drops`) |

## Cómo comprobarlo (si se reactiva)

- [ ] Se mantiene 80 px sobre su spawn y no cae.
- [ ] El ciclo es 3 s de vuelo, 0.75 s de aviso y 3 s de chorro.
- [ ] El chorro llega al suelo y hace daño en toda su altura.
- [ ] Bloquearlo con la guardia lo aturde 5 s o hasta 3 golpes.
- [ ] Al morir solo suelta moneda.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo: [items.md](../items.md)
- Ideas y estado del sistema: [`vault/ideas.md`](../ideas.md) · [`docs/enemies.md`](../../docs/enemies.md)
