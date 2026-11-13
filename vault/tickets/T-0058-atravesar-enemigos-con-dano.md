# T-0058 · Atravesar enemigos cuesta vida en vez de empujarlos

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0043, T-0035 |

## Problema

Ruben: andando se puede empujar a los enemigos sin querer, como si fueran
muebles. Prefiere atravesarlos, pero que atravesarlos duela.

## Causa / contexto

- `scenes/player.tscn:438`: el jugador tiene `collision_mask = 1`, así que él
  nunca choca con los cuerpos enemigos.
- `slime.tscn:40`, `skeleton.tscn:17` y `archer.tscn:18` tenían
  `collision_mask = 3` (mundo + jugador): el `move_and_slide()` del enemigo
  resolvía el solape empujándose a sí mismo fuera del jugador, y eso se lee
  como que el jugador lo empuja. El resto de enemigos ya estaba en 1.
- Nada dolía al cruzar un cuerpo: `EnemyBase` solo hace daño por `Area2D`
  (`attack_range`), y el lobo, por su propio hitbox de contacto.

## Plan

1. Bajar `collision_mask` a 1 en slime, esqueleto y arquero (la convención de
   `docs/enemies.md`: solo colisionan con el mundo).
2. Daño de contacto en `player.gd`: `body_contact_damage` (5) y
   `body_contact_cooldown` (1 s por enemigo), consultando el espacio físico con
   el collider del jugador y la máscara de enemigos (`ENEMY_LAYER` 4).
3. Aplicarlo por `take_damage_from()`, sin knockback, para que el guardia y el
   parry frontales sigan parándolo.
4. Documentar en `docs/player.md` y `docs/enemies.md`.

## Criterios de aceptación

- [x] El jugador atraviesa a todos los enemigos sin desplazarlos.
- [x] Cruzar un cuerpo enemigo quita `body_contact_damage` una vez y no vuelve
      a quitar hasta `body_contact_cooldown` segundos después.
- [x] El guardia frontal (y el parry dentro de la ventana) paran el daño de
      contacto; la inmortalidad de debug (KP5) también lo anula.
- [x] `body_contact_damage = 0` desactiva la mecánica.
- [ ] F5: empujar ya no ocurre y atravesar duele.
- [x] `docs/player.md` y `docs/enemies.md` actualizados.

## Resultado

- `scripts/player.gd`: exports `body_contact_damage` / `body_contact_cooldown`,
  constante `ENEMY_LAYER`, diccionario `_contact_cooldowns` y
  `_update_body_contact()` (consulta `intersect_shape` con
  `$CollisionShape2D.global_transform`, tolera 12 resultados y solo acepta
  `EnemyBase`).
- `scenes/enemies/{slime,skeleton,archer}.tscn`: `collision_mask` 3 → 1.
- Comprobado por inspección (sin F5): máscaras de los tres enemigos alineadas
  con el resto, el daño entra por `take_damage_from()` (guardia/parry y KP5
  respetados) y el `Dictionary` se purga solo al caducar cada entrada. F5
  pendiente: sensación de empuje y ritmo del daño de contacto.
