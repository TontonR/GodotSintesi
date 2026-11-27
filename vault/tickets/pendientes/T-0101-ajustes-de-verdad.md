# T-0101 · Ajustes de verdad: controles, vídeo e idioma

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | ui |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0046 · T-0096 |

## Petición

> Quiero ajustes que permitan cambiar controles, cambiar más ajustes gráficos (como calidad
> gráfica (con postprocesado o cosas para que se vea más bonito), vsync, gestionar fps..) e
> idioma.

## Contexto

`scripts/ui/settings_panel.gd` + `scenes/ui/settings_panel.tscn` solo tenían: modo de
ventana, resolución, tamaño de píxel entero, partículas de hojas y físicas VFX. Las teclas
están en `InputMap` del `project.godot` sin UI, y no hay ni vsync, ni tope de FPS, ni idioma.

## Alcance

1. **Vídeo**: VSync, tope de FPS (30/60/120/144/sin límite) y calidad gráfica (alto/bajo:
   densidad de partículas ambientales y de combate).
2. **Idioma**: inglés/castellano para los textos de la UI (HUD, menús, prompts y tienda).
3. **Controles**: remapeo de las acciones de juego desde el panel.
4. Todo se guarda en `user://settings.cfg` junto a lo que ya escribe `VfxSettings`.

## Criterios de aceptación

- [ ] Los ajustes nuevos sobreviven a cerrar y abrir el juego.
- [ ] VSync y tope de FPS se aplican al instante.
- [ ] Cambiar el idioma cambia los textos sin reiniciar.
- [ ] Remapear una tecla funciona y persiste; se puede volver a los valores por defecto.
- [ ] `docs/ui.md` actualizado.

## Resultado

Hecho el 2026-11-27 por `buffy`.

- **Vídeo**: VSync (`Off`/`On`/`Adaptive`) y tope de FPS (`30/60/120/144/Unlimited`) se
  aplican al instante y al arrancar (`DisplayServer.window_set_vsync_mode`, `Engine.max_fps`).
  Calidad gráfica `High`/`Low`: la baja reduce a la mitad el presupuesto de partículas del
  ambiente (`SpriteFusionAmbient.spawn_chance`, también la capa de detrás del terreno) y de
  los estallidos de `Fx`.
- **Idioma**: `GameSettings` lleva el diccionario EN/ES. Las etiquetas estáticas de las
  escenas llevan `metadata/locale_key` y `localize_tree()` las reescribe; lo que se construye
  por código (tienda, prompts, panel de stats, contador de páginas, filas de slots) se
  refresca con `language_changed`. Cambia sin reiniciar.
- **Controles**: remapeo de `movement` (derecha e izquierda), `interact`, `inventory`
  (Tab e I) y `use_slot_1..3`; los valores por defecto se capturan de `project.godot` al
  arrancar, se guardan en `[input] bindings` y `Reset keys` los devuelve.
- **Persistencia**: `[video]`, `[language]`, `[input]` y `[debug]` en `user://settings.cfg`,
  junto a `[display]` y `[vfx]` sin pisarlos.
- **Debug tools**: el nodo del numpad se enciende y apaga desde el panel (T-0107).

Verificado con un probe headless: panel con 2 columnas, 8 filas de teclas, título en ES/EN,
placeholder de semilla traducido, remapeo aplicado al `InputMap` y `Reset keys` devolviendo
F, `particle_scale` 0.5/1.0 y `DebugHint` creado/eliminado al alternar la casilla. **F5
pendiente** de verlo en el editor.
