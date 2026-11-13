# Orco (ogre)

_Enemigo · melee · activo · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Orc** (`orc.tscn`, clase `orc`) |
| Escena | `res://scenes/enemies/orc.tscn` |
| Script | `res://scripts/enemies/orc.gd` |
| Base | `EnemyBase` (`scripts/enemies/enemy_base.gd`) |
| Estado | `por revisar` (F5 y revisión pendientes) |
| Spawn | Pradera, 3 por chunk |
| Capa / máscara | Capa 3 (`enemies`) · máscara 1 (solo mundo) |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) · [`docs/loot.md`](../../docs/loot.md) |

## Stats

| Stat | Base → final | Notas |
|---|---|---|
| Vida | 50 → **67.5** | ×1.35 en `_ready()` |
| Daño | 15 → **18.75** | ×1.25 en `_ready()` |
| Velocidad | 75 px/s | no se multiplica |
| Cooldown | 2.0 s | entre ataques |
| Ventana de golpe | 0.66 s | `attack_impact_delay` |
| Animación de ataque | 2.5 s | se queda quieto hasta terminarla |
| Escala | ×2 | sprite, collider y áreas |

## Mecánicas

- Melee simple: detecta al jugador, lo persigue y ataca al entrar en rango.
- Si la escena no define `attack_range`, el script usa un desplazamiento de 35 px.
- El daño viaja por `Area2D` (`orc_hitbox`), nunca por el cuerpo: atravesarlo no empuja.
- Prioridad de IA de la base: huir > atacar > perseguir (el orco no huye).
- Sangre por defecto de `EnemyBase` (`blood_color` 0.82, 0.11, 0.1).
- Muere con `fx.enemy_death()` y dispara las pasivas de kill (`trigger_kill_passives`).

## Drops

| Objeto | Prob. | Qué hace | Ficha |
|---|---|---|---|
| Root Grabbers | 10 % | +10 de estamina máxima | [tapoarrabos](../items/tapoarrabos.md) |
| Mace | 10 % | +2 de ataque | [maza](../items/maza.md) |
| Ogre Nail | 10 % | +5 de velocidad | [una_ogro](../items/una_ogro.md) |
| Iron Pendant | 10 % | +25 de vida máxima (no cura) | [colgante_hierro](../items/colgante_hierro.md) |
| Gold Stone | 2 % | +10 % de probabilidad de moneda | [piedra_oro](../items/piedra_oro.md) |

- **Suma de la tirada: 42 %** (la más alta del juego). Si sale, cae **un solo** objeto ponderado.
- Moneda aparte: 45 % de serie, 1 moneda, más suerte y bonus de pasivas.
- Las pasivas que el jugador ya tiene se filtran antes de tirar.

## Spawn

- `pradera.tres`: `enemy_scenes` = [orco, slime, sapo], `enemy_counts` = [3, 3, 1] → **3 orcos por chunk**.
- Chunks 0–1 al ×0.5 (puede no salir ninguno); después +20 % por chunk hasta ×1.8.
- Reparto en ranuras iguales con ±25 % de ruido, 2 tiles de margen y 70 tiles de gracia desde el spawn.

## Cómo comprobarlo (F5)

- [ ] Aparece en pradera y persigue al jugador.
- [ ] Se detiene a atacar y el golpe entra a los ~0.66 s, no al empezar.
- [ ] Al morir suelta moneda ~45 % y objeto ~42 % (probar 10–15 muertes).
- [ ] Una pasiva que ya tienes no vuelve a caer.
- [ ] No empuja al jugador al atravesarlo; el golpe de contacto lo cobra el jugador.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo de objetos: [items.md](../items.md)
- Tickets relacionados: T-0001 (integración), T-0043 (sangre por enemigo), T-0058 (atravesar enemigos)
- Estado del proyecto: [estado.md](../estado.md)
