# T-0011 · Loot de enemigos y física de drops

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-10-29) |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `humano-ruben` |
| Sistema | inventory / enemies |
| Creado | 2026-11-03 (registro retroactivo) |
| Actualizado | 2026-10-29 |
| Ficheros | `scripts/enemies/enemy_base.gd`, `item_pickup.gd`, `item_pickup.tscn`, `docs/items.md` |

## Síntomas y causas

| Síntoma | Causa | Fix |
|---|---|---|
| Drops que "no spawnean" | Se colocaban a `y=0` y el suelo está cientos de px más abajo | Gravedad hasta el suelo, con `_ground_y` buscado una sola vez |
| Parpadeo infinito del drop | El rayo de suelo se lanzaba por frame; con `v < 35 px/s` el rebote mínimo era inalcanzable y entraba en micro-bucle a ~7 Hz | Suelo fijado en el primer tick y rebote 0.45 hasta `< 35 px/s` |
| Drops desplazados dentro del chunk | Se asignaba `global_position` antes de parentar y el offset del chunk se sumaba dos veces | Parentar primero y después fijar `global_position` |
| Fantasma que atacaba al aparecer | Poco margen de spawn entre jugador y enemigo | `30b45de`: más holgura de spawn |

## Detalles vigentes

- Loot: 1–3 monedas garantizadas + 1 objeto del pool (75 %); los 8 `coins` de cada chunk son pickups aparte.
- Los `ItemPickup` siguen usando `res://item_pickup.tscn` (vivo, no es legado: T-0004).
- Icono 32 px (`Sprite2D` ×2), `HALF_HEIGHT` 16, radio de recogida 16, tooltip de proximidad a 40 px.
- Recogida automática al tocar (`body_entered`); `F` ya no recoge.

## Comprobación

Partida con enemigos de chunk: drops aterrizan, se pueden recoger y no parpadean. Documentado en `docs/items.md` y `docs/historial.md`.

Commits: `58c4a0f`, `30b45de`, `a914593`.

## Resultado

Loot estable. Queda pendiente el caso de barra llena (T-0003) y el `coin` legacy de `game.tscn` (T-0004).
