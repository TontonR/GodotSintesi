# T-0047 · El fondo del menú igual que el del spawn

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | ui / mundo |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0018, T-0016 |

## Problema

En el menú principal se veía un hueco de cielo entre las dos capas de pinos y las
montañas: los bosques aparecían separados. Al dar a Nueva partida el fondo encajaba, así
que el menú parecía una pantalla de carga distinta del juego.

## Causa

Las propiedades del parallax eran **idénticas** en `main_menu.tscn` y `game.tscn`
(`scroll_scale`, `scroll_offset`, `scale`, `repeat_size`, texturas del mismo tamaño). Lo
que cambiaba era la **cámara**: `Parallax2D` desplaza cada capa según
`posición de la cámara × scroll_scale`, y la del menú estaba en (0, 0) mientras la del
juego está sobre el jugador en el spawn. Con `scroll_scale.y` distinto por capa (0.1 y
0.25), esa diferencia de cámara separaba los pinos 116 px entre sí.

## Plan

1. Poner la `Camera2D` del menú en la posición de la cámara en reposo del spawn:
   x = `safe_start_tiles` 50 × 16 + 8 = 808; y = fila del suelo (`base_height` 50) × 16 −
   media altura del colisionador (17 × 3.2 / 2 = 27.2) ≈ 773.
2. Dejar el `offset (60, -70)` del jugador, que ya coincidía.
3. Documentarlo en `docs/ui.md` y en la cabecera de `main_menu.gd`.

## Criterios de aceptación

- [x] El menú usa la misma cámara (posición + offset) que el juego en el spawn.
- [x] Documentado el motivo y de dónde salen los números.
- [ ] F5: el fondo del menú encaja igual que el del spawn, sin huecos entre pinos.

## Resultado

`scenes/main_menu.tscn` (posición de la cámara) y comentario en `scripts/ui/main_menu.gd`.
No se tocó ninguna propiedad de parallax: el desajuste era solo de cámara. Si cambian
`safe_start_tiles`, `base_height` o el colisionador del jugador, hay que recalcular los dos
números. F5 pendiente.
