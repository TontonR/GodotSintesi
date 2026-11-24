# T-0092 · Investigar Sprite Fusion: export a Godot, MCP y API de pixel art

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `chore` |
| Prioridad | `media` |
| Dueño | `sin asignar` |
| Sistema | docs |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-24 |
| Relacionado | T-0090, T-0086 |

## Problema

El mapa y el atlas del castillo salen de Sprite Fusion (`map.zip`), y Ruben quiere
aprovecharlo más. Hay que investigar qué se puede automatizar, qué no, cuánto cuesta y
cómo usarlo sin filtrar claves.

## Lo ya verificado (2026-11-24)

- **Editor de tilemaps**: gratis en web; el panel de export genera el mapa para Godot
  (además de Unity, Defold, Phaser, etc.) y hay app de escritorio 100 % offline de pago
  único. **No tiene API pública** para descargar mapas: el flujo es exportar el
  `.tscn`/`tileset.tres` e integrarlo a mano, como se hizo con `map.zip`.
- **Generador de pixel art (API HTTP)**: base `https://www.spritefusion.com/api/v1`,
  clave en Account → API keys y `Authorization: Bearer $SPRITE_FUSION_API_KEY`.
  Endpoints: `POST /generate` (generate, edit, style-reference, direction-set, animate;
  SSE), `POST /normal-maps` y `POST /palette-snaps` (gratis), `POST /uploads`,
  `GET /credits`. El endpoint responde (`401 invalid_token` sin clave).
- **MCP**: servidor en `https://www.spritefusion.com/mcp` con login OAuth (sin clave).
  Herramientas: `generate_sprites`, `edit_sprite`, `generate_sprites_in_style`,
  `create_8_directions`, `animate_sprite`, `snap_to_palette`, `create_normal_map`,
  `list_vfx`/`get_vfx`. Lo generado va a la librería y el agente lo descarga al proyecto.
- **Seguridad**: la clave es confidencial; no puede ir en el repo, en el juego, en URLs
  ni en logs, y las generaciones consumen créditos. Si se expone, revocar y crear otra.

## Plan

1. Leer en detalle los docs de export del editor (capas, colisión, autotiles, tamaño de
   tile) y de costes de créditos.
2. Probar el export de escritorio sobre una copia del castillo: ¿respeta capas, colisión y
   tiles de 32 px? ¿el `.tres` necesita retoques?
3. Decidir el canal para arte nuevo (T-0086 y siguientes): MCP con OAuth o API con clave
   en variable de entorno; probar `GET /credits` y una generación pequeña.
4. Escribir la receta segura (sin claves en git) y una estimación de créditos por asset.
5. Si convence, proponer integrar el MCP en el cliente de cada agente y decidir el flujo
   para el arte de cajas y enemigos.

## Criterios de aceptación

- [ ] Nota de decisión con el flujo exacto export → proyecto y sus límites.
- [ ] Export del castillo probado (capas, colisión y escala) y diferencias anotadas.
- [ ] Coste por asset y si el saldo gratuito cubre lo previsto.
- [ ] Receta de clave/MCP segura, sin secretos en el repo.
- [ ] Recomendación concreta para T-0086 (arte de la caja rompible).

## Resultado

Sin cerrar. Parte de la comprobación necesita la cuenta/credenciales de Ruben.
