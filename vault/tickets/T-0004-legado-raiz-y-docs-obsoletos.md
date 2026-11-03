# T-0004 · Limpieza del legado de la raíz y afirmaciones obsoletas

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `chore` |
| Prioridad | `baja` |
| Dueño | `sin asignar` |
| Sistema | repo / docs |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Ficheros | `player.tscn`, `orc.tscn`, `documentation.md`, `scenes/game.tscn`, `AGENTS.md` |

## Qué sobra de verdad (verificado 2026-11-03)

| Fichero | Por qué |
|---|---|
| `player.tscn` (raíz) | Sin referencias (`grep res://player` vacío); el juego usa `scenes/player.tscn`; no tiene `Inventory` ni `PlayerPassives` |
| `orc.tscn` (raíz) | Sin referencias; el generador precarga `scenes/enemies/orc.tscn` |
| `documentation.md` | Histórico de 396 líneas; `AGENTS.md` ya lo marca como arqueología |
| Nodo `coin` en `scenes/game.tscn:425` | Instancia legacy de `scenes/collectables/coin.tscn` a `y=0` (fuera de cámara); los pickups reales los genera el chunk |

## Ojo: esto NO es legado

- **`item_pickup.gd/.tscn` (raíz) están vivos**: `scripts/enemies/enemy_base.gd:54` precarga `res://item_pickup.tscn` y `scenes/game.tscn` lo instancia. `AGENTS.md` los llama legacy por error: la corrección es el texto, **no** borrar los ficheros.
- `_diag.gd` es una herramienta de diagnóstico citada en `docs/player.md`; se queda.

## Plan

1. Confirmar con el editor de Godot cerrado en esas escenas (reserializa al guardar).
2. `git rm` de los tres ficheros sin referencias, uno por commit o en un solo `chore`.
3. Quitar el nodo `coin` de `scenes/game.tscn` y comprobar que las monedas siguen saliendo por chunk.
4. Corregir la línea de "legacy" en `AGENTS.md`, `README.md` y `docs/items.md`.

## Criterios de aceptación

- [ ] F5 sin errores de recurso ni nodos huérfanos.
- [ ] `grep` de `res://player`, `res://orc` y `res://item_pickup` coherente con lo que queda.
- [ ] Docs sin afirmaciones falsas sobre la raíz.

## Resultado

Pendiente.
