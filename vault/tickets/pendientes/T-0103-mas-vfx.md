# T-0103 · Más VFX: hojas al entrar y salir del arbusto

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | fx |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0093 · T-0096 |

## Petición

> Actualiza las partículas de entrar en el arbusto por las hojas nuevas, que la acción de
> salir del arbusto genere bastantes partículas.

## Contexto

El arbusto ya reacciona al jugador, pero con las partículas viejas (`fx.gd`), no con las
hojas de Sprite Fusion que ahora usa el ambiente (`spritefusion_ambient.gd`). Al salir no
hay estallido.

## Criterios de aceptación

- [ ] Entrar en un arbusto suelta hojas del sistema nuevo, con el tinte del árbol/bioma.
- [ ] Salir suelta bastantes más hojas que entrar.
- [ ] No rompe el ajuste de partículas (con hojas desactivadas no sale nada).
- [ ] `docs/fx.md` actualizado.

## Resultado

Hecho el 2026-11-27 por `buffy`. `DecorProp` ya no usa el `fx` viejo: pide el estallido al
ambiente de Sprite Fusion (`SpriteFusionAmbient.burst_leaves()`), que reutiliza la piscina de
hojas y las lanza desde la copa con el tinte del bioma. Entrar suelta 7
(`leaves_per_burst`), salir 18 (`leaves_on_exit`). Si no hay ambiente (escenas de prueba) cae
al `fx` de siempre, y con las hojas desactivadas no sale nada.

Comprobado por lectura, **sin F5**: no se ha visto el estallido en el editor.
