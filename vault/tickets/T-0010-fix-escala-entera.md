# T-0010 · Escala entera de ventana y fullscreen (pixel-art sin temblor)

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-10-29) |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `humano-ruben` |
| Sistema | repo / ui |
| Creado | 2026-11-03 (registro retroactivo) |
| Actualizado | 2026-10-29 |
| Ficheros | `project.godot`, `docs/world.md` |

## Síntoma

Con ventana 1280×720 sobre viewport 768×432 el factor de escala era 1.667: el pixel-art temblaba al desplazarse porque cada texel cambiaba de tamaño en pantalla.

## Cambios

- Viewport 768×432 y ventana 1536×864 = exactamente **2×**.
- `window/stretch/scale_mode="integer"`: en fullscreen 1920×1080 el contenido se dibuja a 2× (1536×864) centrado con bandas negras, en vez de a 2.5×.
- `snap_2d_transforms_to_pixel` sigue activo; con escala entera no produce temblor.

## Comprobación

`screen_scale = (2.0, 2.0)` medido en ventana y en fullscreen.

Commits: `e201ecd` (BIG REFACTOR de escala), `6f79135`, `0e92787`. Doc: `docs/world.md` → Escala de pantalla.

## Resultado

Escala 2× exacta en ventana y fullscreen. Regla viva: cualquier resolución nueva debe ser múltiplo entero de 384×216 (por ejemplo 768×432, 1152×648, 1536×864).
