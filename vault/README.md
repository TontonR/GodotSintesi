# Vault — canal de trabajo entre agentes

_2026-11-03 · creado por `buffy` · rama `main`_

Punto de encuentro entre **Buffy (Freebuff)** y el **opencode del compañero (Jorge)** para planificar sin pisarse: qué está roto, quién toca qué, qué se ha hecho y qué queda.

| Dónde | Qué es |
|---|---|
| `docs/*.md` | Verdad técnica de cada sistema. Se lee **antes** de tocar código. |
| `vault/` | Plan y comunicación: tickets, prioridades, estado y bitácora. |
| Código + git | La verdad final. Si el vault contradice al código, gana el código y se corrige el vault en esa tarea. |

## Índice

| Fichero | Qué contiene | Cuándo se toca |
|---|---|---|
| `vault/estado.md` | Panel de "ahora mismo": rama, fase, foco por agente, bloqueos | Al empezar y al cerrar un ticket |
| `vault/roadmap.md` | Lo que queda por hacer, priorizado, con enlace a ticket | Al abrir/cerrar tickets |
| `vault/changelog.md` | Histórico de lo ya hecho (append-only) | Al cerrar un ticket |
| `vault/ideas.md` | Bóveda de ideas: todo el diseño (hecho, parcial, pendiente y por definir) con sus dudas | Al decidir qué construir o al añadir una idea |
| `vault/entrega-2.md` | Texto de la entrega 2 (catalán): cambios desde la entrega 1, flujo con IA y los 3 objetivos | Al preparar entregas del proyecto |
| `vault/bitacora.md` | Diario de sesiones y acuerdos entre agentes (append-only) | Al reclamar/entregar trabajo |
| `vault/documentacion.md` | Mapa de toda la documentación: qué cubre cada `docs/`, qué faltaba y qué huecos quedan | Al crear/mover documentación o cerrar una auditoría |
| `vault/enemies.md` | Lista de los 8 enemigos: drops con probabilidad, stats, mecánicas y estado, con enlace a su ficha | Al tocar enemigos, su loot o su estado |
| `vault/enemies/` | Una ficha por enemigo: stats base → finales, IA, drops, spawn y checklist de F5 | Al cambiar stats, IA, escena o loot |
| `vault/items.md` | Catálogo de los 44 objetos: tipo, calidad, drop, textura y estado, con el reparto por enemigo | Al crear/cambiar un `.tres` o una tabla de loot |
| `vault/items/` | Una ficha por objeto: efecto, `.tres`, script, ruta de la textura in-game y quién lo suelta | Al tocar un objeto o su icono |
| `.opencode/skills/estado-enemigos` · `estado-items` | Skills para consultar y actualizar el estado sin releer escenas (también hay entrada en `.agents/skills/`) | Al empezar o cerrar trabajo de enemigos/objetos |
| `vault/tickets/` | Un fichero por trabajo, con estado y resultado | Siempre que haya trabajo |
| `vault/tickets/plantilla.md` | Copia base para abrir un ticket | — |

## Firmas

| Firma | Quién |
|---|---|
| `buffy` | Buffy, agente de Freebuff |
| `opencode-jorge` | opencode del compañero (Jorge) |
| `humano-ruben` | Ruben, decisiones de diseño y merge |

## Estados de un ticket

| Estado | Significado |
|---|---|
| `abierto` | Nadie lo está tocando. Se puede reclamar. |
| `en-curso` | Tiene dueño y ficheros declarados. **No se toca sin acordarlo en la bitácora.** |
| `bloqueado` | Espera una decisión, otra rama o un ticket previo. |
| `revision` | Código hecho; falta verificar en el editor o revisar por el otro agente. |
| `cerrado` | Tiene `## Resultado`, su línea en el changelog y el roadmap actualizado. |

## Flujo de trabajo

1. **Antes de tocar código**: lee `vault/estado.md` y el ticket del sistema en `roadmap.md`. Si no hay ticket, créalo.
2. **Reclamar**: copia `tickets/plantilla.md` como `T-00NN-slug-corto.md` (id incremental, nunca reciclar), pon `Estado: en-curso` y `Dueño: <firma>`, y añade una entrada en `bitacora.md` con fecha, firma y ficheros que vas a tocar.
3. **Durante**: si cambias de alcance, actualiza el ticket y deja nota en la bitácora. Si te bloqueas, `bloqueado` + motivo.
4. **Rama**: cada feature sale de `main` actualizado en su propia rama `feat/<slug>` (o `fix/<slug>`, `docs/<slug>`). Una rama por feature, aunque lleve varios tickets; **nunca se commitea a `main` directamente**.
5. **Entregar**: commit en la rama, push y **PR a `main`**. El PR lleva título `feat: ...`, el ticket enlazado, qué cambia y cómo se comprobó. Rellena `## Resultado` y deja el ticket en `revision` hasta que el PR esté aprobado.
6. **Revisión y merge**: revisa `humano-ruben` (o a quién él indique). Un PR = una feature, sin cambios de paso. Merge con squash para que `main` quede con una entrada por feature.
7. **Cerrar**: tras el merge, `cerrado`, resumen en `changelog.md`, marca el roadmap y actualiza `estado.md`.
8. **Documentación obligatoria**: si cambió comportamiento, actualiza `docs/<sistema>.md` según `AGENTS.md`. El ticket enlaza el doc tocado.

## Reglas de convivencia

- **Un trabajo = un ticket.** No hay cambios "de paso" sin ticket; si aparece algo suelto, se abre ticket y se sigue.
- **`main` solo recibe merges de PR.** Si aparece un commit directo, se avisa en la bitácora.
- **Una rama por feature**, no por ticket: los tickets de la misma feature comparten rama y PR.
- **Nombres de rama**: `feat/<slug>`, `fix/<slug>`, `docs/<slug>`; slug corto, en minúsculas y con guiones.
- **Un dueño por ticket.** Si otro agente lo tiene `en-curso`, se habla en la bitácora antes de tocarlo.
- `changelog.md` y `bitacora.md` son **append-only**: no se reescribe la historia, se añade.
- `estado.md` es el único fichero que se reescribe entero.
- Nada de código pegado: referencias `ruta:línea` y nombres de nodos/clases.
- No se duplica aquí lo que ya dice `docs/`: se enlaza.
- Los ids `T-00NN` no se reutilizan aunque el ticket se cierre en falso.
