# T-0093 · VFX ambientales gratuitos de Sprite Fusion: hojas y nieve

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | fx |
| Creado | 2026-11-25 |
| Actualizado | 2026-11-25 |
| Relacionado | T-0092, T-0086 |

## Problema

El ambiente de los biomas son dos texturas generadas en código (una hoja de 5×5 y un
copo de 3×3). Sprite Fusion publica 25 efectos pixel art gratuitos con licencia MIT,
entre ellos `falling-leaves` y `snow`, con formas, paletas y movimiento ya resueltos.
Hay que aplicarlos al ambiente de la pradera/bosque rojo y de la nieve sin depender
de una cuenta ni de claves.

## Canal usado

- El MCP (`https://www.spritefusion.com/mcp`) pide OAuth de la cuenta (`401
  unauthorized`) y la API (`/api/v1/vfx-library`) pide bearer token. Sin credenciales
  de Ruben no se pueden usar.
- Los ZIP son descargas públicas y MIT: `downloads/pixel-art-vfx/falling-leaves.zip`
  y `downloads/pixel-art-vfx/snow.zip`, un `.ts` por efecto con la receta completa.
  Se guardan en `assets/vfx/spritefusion/` con su `LICENSE` y enlaces.

## Plan

1. Portar ambas recetas a un emisor propio por `Sprite2D` en espacio de pantalla.
2. Sustituir los `CPUParticles2D` de `biome_particles.gd` sin cambiar el contrato del
   bioma (`ambient = "leaves" | "snow"`).
3. Mantener el fundido de 0,4 s al entrar/salir y precalentar la pantalla al activar.
4. Documentar en `docs/fx.md` y `docs/biomes.md`; validar en headless.

## Criterios de aceptación

- [x] Hojas: 3 siluetas × 4 paletas de otoño, giro, péndulo y flip.
- [x] Nieve: 4 tonos, 3 profundidades (260/150/30), cristales animados y viento.
- [x] `ambient = "leaves" | "snow"` sigue funcionando sin tocar los `.tres`.
- [x] Sin claves ni credenciales en el repo; licencia MIT incluida.
- [ ] F5: comprobar densidad y legibilidad sobre el bosque rojo y la nieve.

## Resultado

Hecho en `feat/vfx-ambiente-spritefusion`. `scripts/world/spritefusion_ambient.gd`
(port de `falling-leaves.ts` y `snow.ts`) crea 80 hojas o 440 copos como `Sprite2D`
y `biome_particles.gd` solo lo activa/desactiva. Comprobado en headless: 80 hojas y
440 copos se mueven con texturas válidas. Pendiente el F5 de Ruben para ajustar
densidad y contraste; las recetas asentaban hojas y nieve en `ground`, pero esta capa
es de pantalla y no tiene terreno, así que renacen arriba (sin litter ni ventisquero).
