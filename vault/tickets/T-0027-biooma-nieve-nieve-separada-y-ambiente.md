# T-0027 · Nieve separada, bioma de nieve y ambiente por bioma

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0024, T-0025, T-0026 (fondos tintables) |

## Petición

- La punta de nieve de la montaña salía teñida con el bioma: no debe pasar.
- Separar la nieve y dibujarla encima: en pradera y bosque rojo el mismo color; en
  nieve, piedra gris abajo y nieve blanca arriba.
- Añadir el bioma de nieve.
- Suavizar la variación de terreno del bosque rojo y aplanar muy poco la pradera.
- Ambiente: hojas rojas cayendo en el bosque rojo y muchos copos en nieve.

## Qué se ha hecho

- **Bug de la punta**: `mountain2_gray.png` se había regenerado con toda la
  montaña (piedra y nieve incluidas) en vez de solo el bosque; como el overlay
  está en `forest_tint_paths`, se teñía entera. Ahora solo tiene los dos tonos
  del bosque (grises 172/211) y el resto es transparente.
- **Nieve aparte**: `mountain2_snow.png` contiene solo los píxeles de nieve
  originales y se dibuja en `Sprite2DSnow`, encima de la piedra y del bosque. No
  está en `forest_tint_paths`: es igual en pradera y bosque rojo y sigue blanca
  en nieve.
- **Piedra por bioma**: `Biome.rock_color` + `WorldGenerator.rock_tint_paths`
  tiñen `mountains/Sprite2D` (blanco salvo nieve, `(0.75, 0.78, 0.82)`).
- **Bioma de nieve**: `resources/world/biomes/nieve.tres` con césped
  `(0.93, 0.96, 1)`, bosque `(0.82, 0.88, 0.96)`, 2 esqueletos + 2 arqueros + 1
  lobo y peso 0.2. Pesos: pradera 0.55 y bosque rojo 0.3.
- **Terreno**: bosque rojo 1.35/1.1 (antes 1.7/1.25) y pradera 0.95 de amplitud.
- **Ambiente**: `Biome.ambient` (`none`/`leaves`/`snow`) y
  `scripts/world/biome_particles.gd` (CanvasLayer 5) con dos `CPUParticles2D`:
  28 hojas rojas con giro y 220 copos lentos. Consulta
  `WorldGenerator.biome_at_world_x()` cada 0,25 s.

## Criterios de aceptación

- [x] La nieve de la montaña no recibe el tinte del bioma.
- [x] La nieve está en su propia capa por encima de piedra y bosque.
- [x] Pradera y bosque rojo comparten el color de la nieve.
- [x] Nieve: piedra gris y nieve blanca.
- [x] Existe el bioma de nieve y entra en el reparto.
- [x] Bosque rojo menos abrupto y pradera algo más plana.
- [x] Hojas en bosque rojo y copos en nieve.
- [ ] F5: comprobar que se ve y que el coste de 220 copos es aceptable.

## Verificación

- PIL: overlay solo en y=73..126 con grises 172/211 (25213 px); nieve 5945 px en
  y=0..95 con los colores originales. Preview con el bosque teñido de rojo y la
  nieve sin teñir revisado a ojo.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente.
