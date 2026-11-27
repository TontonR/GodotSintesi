# T-0054 · Crear los objetos pendientes de `ideas.md`

| Campo | Valor |
|---|---|
| Estado | `cerrado` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | `inventory` |
| Creado | 2026-11-17 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0051, T-0052, T-0053 |

## Problema

`vault/ideas.md` tiene 15 objetos diseñados que nunca se implementaron. Faltan
sus `.tres`, sus scripts, sus iconos y su entrada en el loot del enemigo que
los suelta. `Fragmento` queda fuera porque sigue `por definir`.

## Plan

### Tanda 1 · Sistemas existentes (esqueleto)
- `capa_caza.tres`: `StatBonusPassive`, +10 vida y +5 estamina máximas.
- `mangual.tres`: `StatBonusPassive`, +2 ataque.
- `venganza.tres`: crítico temporal al llegar a 0 de estamina.
- `craneo.tres`: -20 vida máxima y reflejo del 5 % de la vida actual.

### Tanda 2 · Arquero
- `arco_basico.tres`: ataque cargado con flecha; 5 de daño, +150 % a los 2 s.
- `maestria_distancia.tres`: +15 % si el objetivo está a 80 px o más.
- `fuerza_bosque.tres`: invoca una rata invulnerable que daña y bloquea proyectiles.

### Tanda 3 · Fantasma
- `capa_inv.tres`: consumible, 2 s para esquivar el siguiente golpe.
- `teleport.tres`: consumible, 96 px con 0.6 s de casteo.
- `codice_bromista.tres`: hasta 3 saltos cargan proyectiles para el siguiente ataque.
- `alma_pena.tres`: +10 % de daño contra enemigos con DOT.

### Tanda 4 · Demonio y DOT
- Sistema común de quemadura en `EnemyBase` (`apply_burn`, `has_dot`, inmovilizar).
- `cadena_perpetua.tres`: consumible; quema al siguiente agresor o lo inmoviliza.
- `cenizas_sufrimiento.tres`: cada ataque aplica 5 % del ataque durante 5 s, máximo 5.
- `pena.tres`: con más de 3 quemaduras, aplica una quemadura especial +25 %.

## Criterios de aceptación

- [x] Los 14 objetos existen con `id`, nombre, descripción, icono y script.
- [x] Cada uno está en el `item_drops` de arquero/esqueleto/fantasma/demonio.
- [x] No se repite ningún icono entre los objetos nuevos ni con los existentes.
- [x] `Fragmento` no se crea.
- [x] `docs/items.md`, `docs/enemies.md` y `docs/player.md` actualizados.
- [ ] F5: los objetos se recogen, se equipan, se usan y sus efectos se ven.

## Resultado

Hecho el 2026-11-17 en `fix-items.icons`: 14 `.tres` nuevos, 11 pasivas y
3 consumibles. Se añadieron `BowPassive`, `RangedMasteryPassive`,
`ForestForcePassive` + `ForestRat`, `VengeancePassive`, `SkullPassive`,
`InvulnerabilityConsumable`, `TeleportConsumable`, `TricksterCodexPassive`,
`AlmaPenaPassive`, `ChainPerpetualConsumable`, `AshesPassive` y `PenaPassive`.
`player.gd` gana `jumped`, carga de arco, invulnerabilidad, teleport y cadena;
`enemy_base.gd` gana quemaduras, ticks, `has_dot()` e inmovilización. Loot
añadido a `archer.tscn`, `skeleton.tscn`, `ghost.tscn` y `demon.tscn`.
`Fragmento` queda fuera. F5 pendiente.

Mergeado en `main` con el PR #8 (commit de merge, sin squash) el 2026-11-17. Sigue en
`revision` hasta el F5 en el editor.
