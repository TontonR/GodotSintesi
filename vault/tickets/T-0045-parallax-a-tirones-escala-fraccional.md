# T-0045 · Parallax a tirones en pantalla completa (escala fraccional)

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui / render |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0010, T-0041, T-0042 |

## Problema

En pantalla completa el fondo da tirones al andar. Poco, pero se nota, y **solo en las
montañas** (la capa de parallax más lenta). En ventana, con resoluciones que son múltiplo
exacto del viewport, no pasa.

## Causa

El panel de ajustes (T-0041/T-0042) ponía `content_scale_stretch = fractional` cuando la
ventana no era múltiplo de 768×432 y también en los dos modos de pantalla completa, para
que la imagen llenara la pantalla. En 1920×1080 eso es un factor 2.5: las texturas con
filtro nearest cambian de tamaño de téxel cada frame y la capa que se mueve más despacio es
la que lo delata. Es exactamente el temblor que T-0010 arregló con `scale_mode="integer"`
(2026-10-29), reintroducido al añadir los ajustes.

## Plan

1. Quitar `STRETCH_FRACTIONAL` y la elección por tamaño: `_apply_stretch()` fija siempre
   `STRETCH_INTEGER`, igual que `project.godot`.
2. `_apply_window()` vuelve a ocuparse solo del modo y del tamaño de la ventana.
3. Documentar en `docs/ui.md` y `docs/world.md`, con el precio (bandas negras).

## Criterios de aceptación

- [x] `content_scale_stretch` es siempre `1` (entero) en cualquier modo y resolución.
- [ ] F5 en fullscreen 1080p: montañas sin tirones (2× con bandas).
- [ ] F5 en ventana 1600×900: sin tirones (letterbox).
- [x] `docs/ui.md` y `docs/world.md` actualizados.

## Resultado

**Sustituido por T-0046**: las bandas se quitan con un viewport adaptativo en vez de
renunciar a llenar la pantalla; lo que se conserva de este ticket es que la escala vuelve
a ser siempre entera.

`scripts/ui/settings_panel.gd`. Se sacrifica llenar la pantalla: con pixel-art y filtro
nearest no hay forma de llenar 1080p sin un factor fraccional, y ese factor es el tirón.
Si se quiere pantalla completa sin bandas, la vía correcta es una resolución de contenido
que sea divisor exacto de la pantalla (960×540), que cambia el campo de visión y se dejó
fuera a propósito. F5 pendiente.
