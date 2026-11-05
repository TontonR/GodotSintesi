# T-0031 · Rehacer el parry y mostrar estadísticas del jugador

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player / ui / enemies |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0030, T-0028 |

## Problema

- El parry de T-0030 se siente raro: la ventana se abría en el mismo frame que la
  guardia, se podía rearmar spameando el clic y el golpe parado seguía empujando
  al jugador (el knockback se aplica después de `_apply_damage`). Además parrear
  no devolvía nada de stamina.
- Faltan las estadísticas base del jugador: velocidad de ataque, daño crítico,
  probabilidad de crítico, velocidad y suerte. No se ven en ningún sitio.

## Plan

1. Parry: ventana de 0,2 s, enfriamiento de 0,3 s entre ventanas, aviso dorado al
   abrirla y `_apply_damage()` devolviendo si el golpe llegó (guardia/parry no
   empujan).
2. Stamina del parry: cada intento cuesta la guardia normal; un parry correcto
   devuelve `parry_stamina_refund` (30) y no drena la barra con el golpe.
3. Estadísticas nuevas en `player.gd`: `attack_speed`, `crit_chance`,
   `crit_damage`, `luck` (la velocidad es `move_speed`). Crítico base aplicado en
   `_deal_damage()`; `attack_speed` escala la animación de ataque.
4. Suerte: puntos porcentuales extra al drop de `enemy_base._drop_loot()`.
5. Panel `UILayer/StatsPanel` a la izquierda, 5 filas, alpha 0,6.

## Criterios de aceptación

- [ ] Levantar la guardia abre 0,2 s de parry; spamear no encadena ventanas.
- [ ] Parry correcto: chispas, `¡PARRY!`, +30 stamina y sin empuje.
- [ ] Las 5 estadísticas se ven siempre a la izquierda, translúcidas.
- [ ] Un crítico se nota (chispas doradas y número más grande).
- [ ] `docs/player.md`, `docs/ui.md`, `docs/fx.md` y `docs/enemies.md` al día.
- [ ] Entrada en `changelog.md` y `estado.md` al cerrar.

## Resultado

Pendiente de F5. Código en `scripts/player.gd`, `scripts/fx.gd` y
`scripts/enemies/enemy_base.gd`; docs y vault actualizados en el mismo cierre.

Fix tras el primer arranque: los overrides de `take_damage()` del fantasma,
esqueleto y demonio no aceptaban `critical` y Godot daba «function signature
doesn't match the parent». Ya repiten `(amount: float, critical: bool = false)`
y pasan `critical` al `super`.
