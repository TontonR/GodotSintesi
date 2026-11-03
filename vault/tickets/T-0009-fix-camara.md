# T-0009 · Cámara: seguimiento, redondeo a píxel y subida de escalón

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-10-29) |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `humano-ruben` |
| Sistema | player |
| Creado | 2026-11-03 (registro retroactivo) |
| Actualizado | 2026-10-29 |
| Ficheros | `scripts/player.gd`, `scenes/player.tscn`, `scripts/world_generator.gd`, `_diag.gd` |

## Síntomas

1. Tirones al andar y desfase que no se recuperaba nunca.
2. Salto visible de la cámara al subir un escalón de 1 tile.
3. Temblor del parallax (las texturas nearest cambiaban de tamaño de texel al moverse en fracciones de píxel).

## Causa

- El suavizado se calculaba sobre `camera.global_position` en vez de la posición del jugador: el error del suavizado se volvía permanente.
- La cámara se movía en coordenadas fraccionarias y el render nearest redondeaba distinto cada frame.
- La auto-subida movía la Y del jugador 16 px de golpe y la cámara lo copiaba en un solo frame.

## Cambios

- Objetivo de seguimiento = `player.global_position`; `process_callback` en física.
- Posición global de la cámara redondeada a píxel entero cada frame.
- La Y del escalón se reparte en 3 frames (máx. 6 px/frame) mientras el desfase sea ≤18 px.
- Subida de 1 tile sin frenar la X (prueba 1 px por delante, sube 17 px) y `2` chunks extra cargados para que los enemigos no desaparezcan.

## Comprobación

`_diag.gd` durante 1200 frames en semillas `12345`, `67890` y `20261029`: desfase máximo 10.21 px, movimiento máximo de cámara 6 px/frame y desfase final tras asentarse <0.28 px.

Commits: `acc7b90`, `d6b1f1c`, `30b45de`, `6f79135`, `09d1679`, `932d79b`, `47647cb`. Doc: `docs/player.md` → Cámara.

## Resultado

Cámara estable y verificada por semilla. La investigación de escala que salió de aquí está en T-0010.
