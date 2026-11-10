# T-0046 · Pantalla completa sin bandas y sin tirones (viewport adaptativo)

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui / render |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0010, T-0045 |

## Problema

En T-0045 se quitó la escala fraccional (que causaba el tirón de las montañas) a cambio
de bandas negras. Ruben quiere las dos cosas: ni tirones ni bandas, y además más
resoluciones donde elegir.

## Causa

Con pixel-art y filtro nearest, estirar con factor no entero cambia el tamaño de téxel
cada frame: es el origen del shimmer, y no tiene arreglo sin dejar de ser nearest. La
alternativa estándar en plataformas pixel-art (Celeste, Hyper Light Drifter y la propia
guía de Godot) no es estirar la imagen, sino **cambiar el tamaño del viewport**: el área
de juego crece para llenar la pantalla y cada píxel de arte cae en un bloque entero de
píxeles de pantalla.

## Plan

1. `_apply_layout(size)`: `content_scale_size = size / factor` y `content_scale_stretch`
   siempre `integer`.
2. `factor = min(size.x / 768, size.y / 432)` redondeado hacia abajo: el mayor tamaño de
   píxel entero que aún deja sitio a la UI; el viewport nunca baja de 768×432 porque el
   inventario mide 744×380.
3. Aplicarlo en los tres modos: fullscreen y borderless con `screen_get_size()`, ventana
   con el tamaño elegido (también al cambiar de resolución).
4. Ampliar la lista a 18 tamaños y filtrarla por el área útil de la pantalla.
5. Documentar en `docs/ui.md` y `docs/world.md`.

## Criterios de aceptación

- [x] `content_scale_stretch` es siempre entero.
- [x] Cualquier tamaño de ventana o de pantalla llena sin bandas (a lo sumo `factor - 1` px de resto).
- [x] El viewport nunca queda por debajo de 768×432.
- [x] Lista de resoluciones ampliada y filtrada por pantalla.
- [ ] F5 en fullscreen 1080p: sin bandas, montañas sin tirones, HUD e inventario bien.
- [ ] F5 en fullscreen 4K/1440p si hay pantalla: mismo resultado (3× y 5×).
- [x] `docs/ui.md` y `docs/world.md` actualizados.

## Resultado

`scripts/ui/settings_panel.gd`: `_apply_layout()`, `_best_factor()`, `WINDOW_SIZES`
ampliada y `_build_sizes()`. A 1080p el viewport pasa a 960×540 a 2× (se ve un 25 % más de
mundo que antes y los sprites miden lo mismo que con 1536×864). A 1440p 853×480 a 3× y a
4K 768×432 a 5×. F5 pendiente.
