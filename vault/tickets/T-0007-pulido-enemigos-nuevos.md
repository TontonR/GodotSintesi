# T-0007 · Pulido de los enemigos nuevos (stats, capas y muerte)

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `cambio` (balance) |
| Prioridad | `media` |
| Dueño | `sin asignar` |
| Sistema | enemies |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0001, T-0008 |
| Ficheros | `scripts/enemies/{demon,mutant_toad,werewolf}.gd` y sus escenas |

## Qué falta

- **Lobo**: 60 HP / 10 ataque son provisionales (el propio doc del compañero lo dice); sin animación de muerte propia, usa la de `EnemyBase`.
- **Sapo**: no usa el flujo de ataque de `EnemyBase` (no hay ataque por contacto); el daño depende solo de los proyectiles. Revisar si eso lo hace demasiado blando.
- **Demonio**: 180 HP y sin defensa; vive fuera del alcance de la espada salvo cuando cae aturdido (borde inferior a 40 px del suelo). Confirmar que la hurtbox 34×60 en `y+10` permite golpearlo al bajar.
- **Capas**: el doc del demonio habla de hurtbox 4 / ataque 12; validar contra 1 mundo / 2 jugador / 3 enemigos / 4 ataque jugador.
- **Colisiones**: sapo y lobo se añaden excepción de colisión mutua con el jugador; los enemigos base sí empujan. Decidir el criterio común.
- **Balance global**: el jugador tiene 100 de vida y golpes de 20; con 5 tipos por chunk la mezcla cambia mucho respecto a `[4 orcos, 1 fantasma]`.

## Criterios de aceptación

- [ ] Stats finales exportados y anotados en `docs/enemies.md` (o doc por enemigo).
- [ ] Los tres enemigos se pueden matar con el combo normal y su loot sale bien.
- [ ] Criterio de colisión con el jugador documentado y aplicado igual en todos.

## Resultado

Pendiente.
