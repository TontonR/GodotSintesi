# T-0100 · Puertas negras con F y contenido dentro del castillo

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0095 · T-0079 · T-0076 |

## Problema

Dentro del castillo no había forma de salir sin subir todas las plantas (`exit_requested`
solo se emitía en la última) y el pad de siguiente planta era un rectángulo ámbar que se
disparaba al pisarlo, sin control. El hall estaba además completamente vacío: ni cajas, ni
monedas, ni enemigos.

## Causa / contexto

`dungeon.tscn` traía un único `Area2D` `Exit` con `Visual` ámbar y el generador escuchaba
`body_entered`, así que cruzar el pad subía una planta sin querer. Salir solo era posible
desde la última planta.

## Plan

1. `Leave`: `Area2D` nuevo en `dungeon.tscn`, 32×64 px, negro como el `Exit`.
2. Pintar los dos como rectángulos negros (`Color(0, 0, 0, 1)`).
3. Cambiar `body_entered` por `interact` (F) con radio `INTERACT_RADIUS_PX` (56 px) y bloqueo
   de 0,35 s tras cada reconstrucción.
4. Prompt propio en `CanvasLayer` (layer 8): `F: enter` en la escalera, `F: exit` en la
   puerta de atrás y en la escalera de la última planta.
5. Colocar `Leave` `LEAVE_GAP_TILES` (4) tiles detrás del spawn, sobre la altura real de su
   columna.
6. Contenido por planta: `crates_per_floor` 3, `coins_per_floor` 6, `archers_per_floor` 3,
   con RNG propio (`seed ^ (floor * 7919) ^ 0x00C0FFEE`) y nodo `Contents` que se vacía en
   cada `start()`.

## Criterios de aceptación

- [ ] En F5, detrás del spawn hay una puerta negra: F la usa y vuelve al mundo en el mismo sitio.
- [ ] La escalera del fondo también es negra y solo sube al pulsar F.
- [ ] El prompt dice `F: enter` o `F: exit` según la puerta (y `F: exit` en la última planta).
- [ ] Cada planta tiene cajas, monedas y arqueros, y al cambiar de planta no se mezclan.
- [x] `docs/dungeon.md` actualizado.
- [x] Entrada en `changelog.md`, `estado.md`, `roadmap.md` y `bitácora.md`.

## Resultado

Hecho el 2026-11-27 por `buffy` en la misma rama que T-0099 por ser continuación del
castillo (`feat/estructuras-detras-castillo-grande`). `Leave` nuevo, pads negros, F en vez
de `body_entered`, prompt enter/exit, contenido determinista por planta. **F5 pendiente**:
no se ha visto ninguna puerta ni el contenido en el editor.
