# T-0086 · Texturas de caja rompible (PixelForge)

| Campo | Valor |
|---|---|
| Estado | `en-curso` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `pixelforge` |
| Sistema | assets |
| Rama | — (entrega PNGs; los mete `opencode-jorge`) |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-24 |
| Relacionado | T-0076, T-0085, [`planning-estructuras.md`](../planning-estructuras.md) |

## Problema

La caja rompible de T-0076 usa un placeholder de 16×16 dibujado a mano
(`assets/map/structures/crate.png`). El arte definitivo lo genera **PixelForge**
(`C:\Users\Usuario\Documents\programacion\personal\pixelart_ai`, local, sin límite, puede
fallar) y por ahora solo se prueba con cajas de madera.

## Plan

1. Prompt autocontenido para PixelForge (lo pasa Ruben): caja de madera **16×16 lógicos**,
   vista lateral plana, PNG con alfa, contorno de 1 px, 3–4 tonos de marrón, sin antialias
   ni sombra en el suelo. Dos estados: intacta y agrietada.
2. PixelForge trabaja en su repo (no puede escribir en este): genera a 64×64 con su
   pipeline SDXL + pixel-art-xl + LCM, elige con su post V5 y baja a 16×16 con vecino más
   cercano. Entrega los PNG y una hoja de muestras.
3. Ruben pasa las rutas; `opencode-jorge` copia a `assets/map/structures/` y Godot
   reimporta. Si el resultado no convence, se queda el placeholder.

## Criterios de aceptación

- [ ] PNG de 16×16 con canal alfa, contorno legible sobre el muro teal/pizarra de la ruina.
- [ ] Sin antialias, sin sombra, sin marco ni texto; se lee a 1× y a 4×.
- [ ] Dos estados (intacta, agrietada) en la misma paleta y encuadre.
- [ ] El juego carga la textura sin tocar código; el placeholder se sustituye o se queda
      según el resultado.

## Resultado

Pendiente. Prompt y especificación en la bitácora del 2026-11-24.
