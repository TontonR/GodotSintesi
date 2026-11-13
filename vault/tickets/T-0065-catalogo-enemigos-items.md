# T-0065 · Catálogo de enemigos e items en el vault (con estado y skills)

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `docs` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | docs |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0056 |

## Problema

El vault no tenía una vista de conjunto de enemigos ni de objetos: el reparto de drops
estaba repartido entre `vault/pasivas/` (solo pasivas, solo 5 enemigos) y `docs/`, y no
había forma de saber de un vistazo qué falta (texturas, revisión) sin abrir escenas.

## Plan

1. `vault/enemies.md`: lista de los 8 enemigos con drops y probabilidad, stats, mecánicas,
   estado y enlace a su ficha.
2. `vault/enemies/<slug>.md`: una ficha por enemigo con stats base → finales, IA, tabla de
   drops con enlace al objeto, spawn y checklist de F5.
3. `vault/items.md`: catálogo de los 44 objetos con tipo, calidad, drop, textura y estado,
   más las reglas de tirada y el reparto por enemigo.
4. `vault/items/<slug>.md`: una ficha por objeto con nombre in-game, qué hace, `.tres`,
   script, ruta de la textura aplicada y quién lo suelta.
5. Skills `estado-enemigos` y `estado-items` para consultar y actualizar el estado sin
   releer escenas; entrada también en `.agents/skills/` para Freebuff.

## Criterios de aceptación

- [x] Los 8 enemigos tienen fila y ficha, con drops y probabilidad reales.
- [x] Los 44 objetos tienen fila y ficha; 17 con drop y 9 consumibles.
- [x] Todos los objetos en `por asignar textura`; todos los enemigos en `por revisar`.
- [x] Las rutas de textura de las fichas son las `icon` reales de cada `.tres`.
- [x] Enlaces cruzados y skills documentadas.
- [ ] Revisión del otro agente / merge del PR.

## Resultado

- `vault/enemies.md` + 8 fichas en `vault/enemies/`.
- `vault/items.md` + 44 fichas en `vault/items/` (generadas desde `resources/*.tres` y los
  `item_drops` de las escenas; totales orco 42 %, lobo 32 %, rana 32 %, slime 32 %).
- `.opencode/skills/estado-enemigos/SKILL.md`, `.opencode/skills/estado-items/SKILL.md` y
  entradas equivalentes en `.agents/skills/`.
- `vault/README.md` y `vault/documentacion.md` enlazan el catálogo.
- Sin cambios de código: no hay F5 que hacer; la comprobación es de enlaces y datos.
