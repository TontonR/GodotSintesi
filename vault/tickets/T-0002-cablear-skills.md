# T-0002 · Cablear las skills (huecos 1-2)

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `sin asignar` |
| Sistema | inventory |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0005 |
| Ficheros | `scripts/collectables/Skills.gd`, `scenes/inventory/inventory.gd`, `scripts/player.gd`, `resources/` |

## Problema

- `Skills.use()` llama a `target.equip(self)` si el objetivo tiene ese método (`Skills.gd:21`), pero `scripts/player.gd` **no define `equip()`**: usar una skill no hace nada.
- No existe ningún `.tres` de skill: el catálogo son 3 consumibles y 3 pasivas.
- Los huecos 1-2 del inventario (teclas `1`/`2`, "no se gastan") están modelados y visibles en el HUD, pero sin objeto que meter.
- El debug del numpad reserva `KP 3` "para skills" (`scenes/inventory/inventory.gd`).

## Decisiones abiertas

- ¿Skill = equipo permanente con bonus, habilidad activa con cooldown o buff temporal? El panel derecho del inventario ya sabe leer `bonus` de `Skills`, así que la opción de equipo es la de menor coste.
- ¿Dónde vive el estado de equipado: en el jugador o en un gestor al lado de `PlayerPassives`?

## Plan

1. Decidir el modelo (nota en este ticket + `docs/items.md`).
2. Añadir `equip()`/`unequip()` (o el gestor) reutilizando el patrón de `PlayerPassives`.
3. Crear 1-2 skills de prueba en `resources/` y añadirlas al debug (`KP 3`).
4. Verificar `1`/`2` y la columna de habilidades del inventario.

## Criterios de aceptación

- [ ] Usar `1`/`2` aplica el efecto de la skill y no consume el objeto.
- [ ] HUD e inventario muestran la skill y su detalle.
- [ ] `docs/items.md` sin el "pendiente" de skills; `changelog.md` actualizado.

## Resultado

Pendiente.
