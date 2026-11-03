# T-0020 · Arranque, drops raros, dificultad y densidad

| Campo | Valor |
|---|---|
| Estado | `hecho` (pendiente de F5) |
| Tipo | `fix` + `balance` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world / enemies / objects / loot |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0018 (caída), T-0019 (loot por enemigo), T-0017 |

## Petición

1. El inicio del juego seguía bugeado.
2. Balancear los objetos y hacer el drop bastante más raro (menos monedas).
3. Desactivar los objetos que estaban al principio del todo.
4. Enemigos algo más fuertes.
5. Slime más pequeño.
6. Más enemigos en general, menos en los primeros chunks.

## Qué se ha hecho

- **Caída inicial reescrita** (`fall_intro.gd`): fuera `_park_camera` y `follow_after_px`.
  La `Camera2D` es hija del jugador, así que el parqueo viajaba con él y al enganchar a
  los 200 px la vista saltaba ~270 px; además 2200 px a 300 px/s eran 7 s de cielo.
  Ahora la cámara sigue desde el primer frame, la caída es de 520 px (~1,7 s) y
  `max_seconds` 6 s devuelve el control si el aterrizaje se atasca.
- **Drops raros**: `coin_drop_chance` 45 % (1 moneda, antes 1–3 garantizadas),
  `item_drop_chance` 30 % (antes 75 %), `rare_loot_weight` 0.25, `coins_per_chunk` 2
  (antes 8) y fuera el pool genérico `DROP_ITEMS`.
- **Objetos originales desactivados**: los 6 del catálogo inicial (3 pociones, amuleto,
  armadura y talismán) salen del loot, del debug y de `game.tscn` (se borran los dos
  pickups de prueba `drop_pocion_*`). Los `.tres` quedan huérfanos, no borrados.
- **Balance**: `maza` +2 ataque, `colmillo_lobo` +3, `pies_ligeros` 10 % de velocidad,
  `piedra_oro` 10 % de moneda extra.
- **Enemigos más fuertes**: `EnemyBase.health_multiplier` 1.35 y `attack_multiplier`
  1.25 aplicados en `_ready()` (afecta a los 8 enemigos y a sus proyectiles).
- **Slime**: `scale = Vector2(1.2, 1.2)` en `slime.tscn` (los demás siguen a ×2).
- **Más enemigos, pocos al principio**: base `[3, 2, 2, 1, 1, 1, 1, 1]` y nuevo
  `_enemy_count_multiplier()`: chunks 0–1 al 50 % (3 enemigos), +20 % por chunk hasta
  ×1.8 (16).
- **Bug extra encontrado**: los 11 `.tres` del compañero apuntaban a
  `res://assets/icons/pasiva_*.png`, que **no existe**; reapuntados a
  `assets/items/iconos/*.png` (y `moneda_oro.png` para `codicia`).

## Riesgos

- 16 enemigos por chunk maduro: vigilar el rendimiento con varios chunks cargados.
- `health_multiplier`/`attack_multiplier` se aplican una vez por instancia; si se
  recarga una escena ya escalada, no se reaplica (no hay guardado entre partidas).
