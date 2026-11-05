# T-0028 · Efectos de combate y feedback de HUD

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | fx/ui |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0027 (partículas de bioma) |

## Petición

- Añadir muchas mejoras de efectos de partículas y de UX.

## Qué se ha hecho

- Nodo `fx` (`scripts/fx.gd`, grupo `fx`) que centraliza VFX y feedback:
  - Chispas al golpear enemigos y estallido al morir.
  - Números de daño flotantes (enemigo, jugador, `+1` de moneda, `+N` de cura).
  - Polvo al saltar, aterrizar y correr.
  - Chispas al recoger monedas y objetos.
  - Sacudida de cámara y flash rojo al recibir daño.
- HUD: pop del contador de monedas y latido rojo de la barra de vida por debajo
  del 30 %.
- Partículas de bioma: entrada/salida con fundido de 0,4 s y viento lateral.
- Enganches: `player.gd`, `enemy_base.gd`, `coin.gd`, `item_pickup.gd` y
  `biome_particles.gd`. Todo se crea en código; sin escenas ni texturas nuevas.

## Criterios de aceptación

- [x] Cada golpe a un enemigo muestra número y chispas.
- [x] La muerte de un enemigo deja un estallido.
- [x] El jugador ve número, chispas, flash y sacudida al ser golpeado.
- [x] Saltar, aterrizar y correr levantan polvo.
- [x] Monedas y objetos brillan al recogerse; la moneda suma `+1`.
- [x] El HUD hace pop con las monedas y late con poca vida.
- [x] Hojas y copos entran/salen con fundido y viento.
- [ ] F5: comprobar legibilidad de los números y que la sacudida no marea.

## Verificación

- Sin ejecutar Godot (regla de `AGENTS.md`): revisión de código y del `.tscn`.
  F5 pendiente. Si los números salen pequeños o la sacudida es excesiva, se
  ajustan `font_size` en `_number()` y `shake(2.5, 0.18)` en `player_hit()`.
