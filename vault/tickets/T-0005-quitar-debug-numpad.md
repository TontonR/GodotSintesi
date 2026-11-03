# T-0005 · Retirar el debug del numpad al acabar las pruebas

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `chore` |
| Prioridad | `baja` |
| Dueño | `sin asignar` |
| Sistema | inventory |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0002 |
| Ficheros | `scenes/inventory/inventory.gd`, `README.md`, `docs/items.md` |

## Problema

`DEBUG_TOOLS = true` (`scenes/inventory/inventory.gd:15`) da atajos de trampa en partida:

| Tecla | Efecto |
|---|---|
| `KP 0` | Vacía inventario y pasivas |
| `KP 1` | Consumible aleatorio |
| `KP 2` | Pasiva aleatoria |
| `KP 3` | Reservado para skills (T-0002) |

Está documentado en `README.md` y `docs/items.md`; cualquiera que juegue lo puede pulsar.

## Decisión

Mantener el flag hasta cerrar T-0002 (usa `KP 3`) y entonces retirarlo, o eliminarlo ya y dejar el reparto de objetos de prueba fuera del juego.

## Plan

1. Poner `DEBUG_TOOLS = false` y comprobar que `_handle_debug_key` no se ejecuta.
2. Si se retira del todo: borrar `_handle_debug_key`, `_clear_debug_items`, `_give_debug_item` y la tabla de `README.md`.
3. Actualizar la sección de debug de `docs/items.md`.

## Criterios de aceptación

- [ ] Ningún atajo del numpad modifica la partida.
- [ ] README y `docs/items.md` sin la tabla de debug (o con el flag documentado como apagado).
- [ ] `changelog.md` actualizado.

## Resultado

Pendiente.
