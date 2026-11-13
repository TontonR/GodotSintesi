# T-0062 · Lobo: aturdimiento por parry perfecto y embestida algo más lenta

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | enemies |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0035, T-0058 |

## Problema

Ruben: tras el daño por contacto el lobo está absurdamente OP. Al atravesarte
te golpea igual (el escudo solo cubre de frente y el lobo embiste de espaldas),
es más rápido que el jugador y el daño de contacto se suma al suyo propio, así
que cada pasada se lleva la vida entera.

## Causa

- `player._update_body_contact()` aplicaba los 5 px de contacto genérico también
  al lobo, que ya pega con su propio hitbox (`_try_contact_damage`): 13 + 5 por
  pasada cada 0.5 s.
- `charge_speed` 150 px/s solo iba por debajo del sprint (221) y por encima del
  paseo (130), pero sumado al knockup y al daño doble se sentía imparable.
- El parry perfecto no tenía respuesta: el lobo seguía su embestida como si nada.

## Plan

1. `EnemyBase.uses_custom_contact_damage()` (false por defecto); el lobo devuelve
   `true` y el jugador lo salta en `_update_body_contact()`.
2. `Player.parried(attacker)`: se emite al consumir la ventana de parry.
3. El lobo se conecta a esa señal y, si el atacante es él, entra en `STUN`
   (`parry_stun_time` 0.8 s): se para, no hace daño de contacto, destello
   azulado y después vuelve al aviso de embestida. Si le pillan en el aire,
   espera a aterrizar.
4. `charge_speed` 150 → 140 px/s (sigue por encima del paseo, 130).
5. Documentar en `docs/enemies.md` y `docs/player.md`.

## Criterios de aceptación

- [x] Un parry perfecto contra el lobo lo deja quieto `parry_stun_time`.
- [x] Atravesarlo ya no suma el daño de contacto genérico (solo pega su hitbox).
- [x] La embestida (140) sigue siendo más rápida que el jugador andando (130).
- [ ] F5: se nota la ventana de castigo tras el parry y la pasada se puede esquivar.
- [x] `docs/enemies.md` y `docs/player.md` actualizados.

## Resultado

- `scripts/enemies/enemy_base.gd`: `uses_custom_contact_damage()`.
- `scripts/player.gd`: señal `parried(attacker)`, emisión en `_apply_damage()` y
  salto del lobo en `_update_body_contact()`.
- `scripts/enemies/werewolf.gd`: `State.STUN`, grupo `Stun` con
  `parry_stun_time` 0.8, `_connect_player_parry_signal()`,
  `_on_player_parried()`, `_start_stun()`, `_process_stun()`, `_flash_stun()`,
  `uses_custom_contact_damage() = true` y `charge_speed` 140.
- Verificado headless con script desechable: parry de otro atacante no aturde,
  parry propio deja `state=STUN` 0.8 s, al terminar vuelve a la embestida,
  `_contact_cooldowns` del jugador vacío con el lobo encima y `charge_speed=140`.
  F5 pendiente: sensación de la ventana de castigo y del ritmo de la pasada.
