# Historial — bugs que ya picaron

_2026-10-20 · rama `feat/skills-and-complex-passives`_

No cargar salvo que algo huela a esto. Lo vigente está en su doc de sistema.

## Drops e inventario

- **2026-10-15 · parpadeo infinito**: el rayo de suelo se lanzaba por frame; con `v < 35 px/s` no llegaba al suelo, el rebote mínimo era inalcanzable y entraba en micro-bucle a ~7 Hz. Fix: buscar el suelo una vez (`_ground_y`) y comparar contra altura fija.
- **2026-10-14 · drops "que no spawnean"**: estaban a y=0 y el suelo está en y=400. La gravedad lo corrige; el `coin` legacy de `game.tscn` sigue mal.
- **2026-10-14 · pasiva de curación**: eliminada (`heal_potion_passive.tres`, `HealPassive.gd`); git la conserva.
- **2026-10-14 · `Skills.gd`**: hacía falta `EquipSlot { NONE = 0 }` para que el export compilara.

## Enemigos

- **2026-10-14 · fantasma sin loot**: `ghost.tscn` tenía un override de `loot_table` con entrada vacía; eliminado.
