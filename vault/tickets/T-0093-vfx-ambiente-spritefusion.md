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
- [x] Partículas a escala 1 px y con colisión/reposo sobre el terreno.
- [x] Crossfade de ~64 tiles atado al blend de biomas.
- [ ] F5: comprobar densidad y legibilidad sobre el bosque rojo y la nieve.

## Resultado

Hecho en `feat/vfx-ambiente-spritefusion`. `scripts/world/spritefusion_ambient.gd`
(port de `falling-leaves.ts` y `snow.ts`) crea 80 hojas o 440 copos como `Sprite2D`
y `biome_particles.gd` lo alimenta con el peso del blend de biomas.

### Ronda 2 (2026-11-25): escala, suelo y transición

- **Tamaño**: `pixel_scale` a 1 px por píxel de arte (antes 2), así que hojas y
  copos ocupan la mitad.
- **Suelo**: `ground_y_at()` se muestrea a través de la transformada de cámara cada
  0,1 s; las hojas y las dos capas cercanas de nieve se posan, descansan 1–5 s con
  fundido y renacen. Los copos de fondo desaparecen al tocar. Sin generador (mazmorra)
  el fondo de pantalla hace de suelo.
- **Transición**: `WorldGenerator.ambient_weight_at_world_x(world_x, ambient)` devuelve
  la cuota del blend de ±32 tiles; `set_strength()` la persigue con un tween de 0,5 s,
  así que hojas y nieve se funden a lo largo de ~64 tiles en vez de cambiar de golpe.
- Headless: ambos emisores se mueven, se posan a la altura del stub de suelo, usan
  texturas válidas y el peso de bioma queda en 0..1. Falta F5 para densidad/contraste.
- Pendiente menor: las recetas dibujan litter de hojas y ventisquero de nieve; no se
  portaron para no ensuciar la capa de pantalla cuando la cámara se mueve.
