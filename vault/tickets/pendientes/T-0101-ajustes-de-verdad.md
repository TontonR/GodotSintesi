# T-0101 · Ajustes de verdad: controles, vídeo e idioma

| Campo | Valor |
|---|---|
| Estado | `abierto` |
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

Pendiente.
