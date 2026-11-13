# Lobo (hombre lobo)

_Enemigo · embestida y salto · activo · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Werewolf** (`werewolf.tscn`, clase `werewolf`) |
| Escena | `res://scenes/enemies/werewolf.tscn` |
| Script | `res://scripts/enemies/werewolf.gd` |
| Base | `EnemyBase` (pero tiene su propia máquina de estados) |
| Estado | `por revisar` (F5 de T-0064 pendiente) |
| Spawn | Bosque rojo y nieve |
| Capa / máscara | Capa 3 (`enemies`) · máscara 1 (solo mundo) |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) · [`docs/player.md`](../../docs/player.md) |

## Stats

| Stat | Valor | Notas |
|---|---|---|
| Vida | 60 → **81** | ×1.35 |
| Daño | 10 → **12.5** | ×1.25 |
| Andar / vagar | 75 / 70 px/s | más lento que el jugador andando (130) |
| Embestida | **140 px/s** | más rápida que andar, más lenta que esprintar (221) |
| Aviso de embestida | 0.25 s | `charge_windup` |
| Recuperación | 1.5 s | `RECOVER`, se queda quieto |
| Golpes por embestida | 1 | `hit_cooldown` 0.5 s |
| Salto | `jump_force` −350 · daño ×2 · radio 40 px | cada 2 embestidas |
| Stun por parry | 0.8 s | `parry_stun_time` |
| Salida del stun | 50 % embestida / 50 % salto | `stun_jump_chance` |
| Escala | ×2 | |

## Mecánicas

- **Vagar**: se mueve alrededor de su chunk (radio 400) con pasos de 80 px y pausas de
  1–2.5 s; si el jugador entra en su rango, pasa a embestir.
- **Embestida**: 0.25 s de aviso, carrera a 140 px/s, un solo golpe por pasada y 1.5 s de
  `RECOVER`. El primer impacto **lanza al jugador por los aires** (`knockup_force` 280,
  bloqueo 0.12 s).
- **Salto**: cada 2 embestidas, la siguiente pasada es un salto (−350 de fuerza, ×2 daño,
  40 px de radio de impacto). Tras aterrizar, `RECOVER` otra vez.
- **Parry**: un parry perfecto emite `Player.parried(attacker)` y corta la pasada en `STUN`
  (0.8 s, destello azulado). No hace daño de contacto mientras está aturdido; si lo paran
  en el aire, primero aterriza. Al salir elige **embestida o salto al azar** (intención de
  un solo uso en `_stun_next_attack`).
- **Contacto**: es el único con `uses_custom_contact_damage() = true`, así que el golpe
  genérico del jugador al atravesarlo no se suma a su hitbox.
- **Bug corregido (T-0064)**: faltaba `State.RECOVER` en el `match` de
  `_update_behavior()`; el lobo se quedaba congelado para siempre tras su primera
  embestida y nunca volvía a vagar.

## Drops

| Objeto | Prob. | Qué hace | Ficha |
|---|---|---|---|
| Wolf Pelt | 10 % | +15 vida máxima y +5 estamina máxima (no cura) | [piel_lobo](../items/piel_lobo.md) |
| Wolf Fang | 10 % | +3 de ataque | [colmillo_lobo](../items/colmillo_lobo.md) |
| Wolf Claws | 10 % | +20 % de ataque por debajo del 30 % de vida | [garras_lobo](../items/garras_lobo.md) |
| Werewolf DNA | 2 % | De noche: +15 % ataque y +15 % velocidad | [adn_hombre_lobo](../items/adn_hombre_lobo.md) |

- **Suma de la tirada: 32 %**; un solo objeto por muerte. Moneda aparte: 45 %.
- `Werewolf DNA` es la única pasiva `Rare` del lobo y la más rara de su tabla.

## Spawn

- `bosque_rojo.tres`: lobo + sapo (`enemy_counts` declara `[1, 1, 1, 2]`, con más valores
  que escenas; ver [`docs/biomes.md`](../../docs/biomes.md)).
- `nieve.tres`: 1 lobo por chunk (junto a 2 esqueletos y 2 arqueros).
- No sale en pradera.

## Cómo comprobarlo (F5)

- [ ] Persigue, embiste y **no se queda quieto para siempre** después de la pasada.
- [ ] Si sales de su rango durante `RECOVER`, vuelve a vagar.
- [ ] Cada 2 embestidas salta y el salto hace el doble de daño en 40 px.
- [ ] Un parry perfecto lo aturde ~0.8 s (destello azul) y no hace daño mientras está quieto.
- [ ] Al salir del stun alterna embestida y salto (repetir 6–8 parries y ver ambas salidas).
- [ ] El primer golpe de la embestida lanza al jugador y no se suma el daño de contacto.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo: [items.md](../items.md)
- Pasivas del lobo: [pasivas/lobo.md](../pasivas/lobo.md)
- Tickets: T-0062 (parry y stun), T-0064 (recuperación y salida del stun)
