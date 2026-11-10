# T-0038 · Quitar skills y dejar 3 consumibles

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | items |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0012, T-0034 |

## Problema

El inventario tenía 5 huecos: 2 de skills (sin objetos) y 3 de consumibles con las teclas
1-5. Ruben quita las skills: quedan solo 3 consumibles, usados con 1, 2 y 3. Más adelante
se podrán comprar más huecos.

## Plan

1. `Inventory`: `MAX_SLOTS = 3`; fuera `SKILL_SLOTS`, el reparto por tipo y la rama
   `Skills` de `add_item`/`use_slot`.
2. `InventoryUI`: sin separador skills/consumibles.
3. `InventoryScreen`: fuera `SkillsFlow`, `_consumable_start` y `_move_left_row`; el
   panel izquierdo queda con una sola fila de consumibles.
4. `inventory_screen.tscn`: borrar `SkillsHeader` y `SkillsFlow`.
5. Borrar `scripts/collectables/Skills.gd` y su `.uid`; quitar `use_slot_4` y
   `use_slot_5` de `project.godot`.
6. Reescribir `docs/items.md` como catálogo completo (stats, pasiva y estado, todo en
   `falta textura`); actualizar `docs/ui.md` y el índice de `AGENTS.md`.

## Criterios de aceptación

- [ ] El HUD y la pantalla muestran 3 huecos, sin cabecera de habilidades.
- [ ] Las teclas 1/2/3 usan el consumible y lo gastan; 4 y 5 no hacen nada.
- [x] `Skills.gd` eliminado y sin referencias.
- [x] `docs/items.md` con todos los objetos y estado `falta textura`.
- [x] `changelog.md` y `estado.md` actualizados.

## Resultado

Inventario de 3 consumibles con teclas 1-3. `docs/items.md` pasa a catálogo: 9
consumibles y 35 pasivas, todas marcadas `falta textura`. F5 pendiente.
