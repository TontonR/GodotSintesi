# Pasivas del Slime

_2026-11-03 · tabla de Jorge · loot: `loot_preset = "Slime"` en `scenes/enemies/slime.tscn`_

| Nombre | Qué hace | Calidad | `.tres` | Script |
|---|---|---|---|---|
| Moco | Sueltas partículas de moco permanentemente | Normal | `resources/moco.tres` | `MocoLevelPassive` |
| Poción de mocos | **Consumible**: +salto durante 60 s y sueltas partículas de moco | Normal | `resources/pocion_mocos.tres` | `MocoPotion` |
| Moco compacto | Partículas de moco permanentes; cuantas más, más defensa | Normal | `resources/moco_compacto.tres` | `MocoLevelPassive` |
| Corazón mucosil | Duplica las partículas de moco | Raro | `resources/corazon_mucosil.tres` | `MocoLevelPassive` |

- El moco vive en el nodo `MocoEmitter` que el jugador crea bajo demanda
  (`scripts/collectables/moco_emitter.gd`): `CPUParticles2D` con textura de gota
  generada por código (no hay asset de moco en el proyecto).
- Cada nivel = 5 partículas y **+0.5 de defensa plana** (`defense_per_level`), que
  `player._apply_damage()` resta al daño entrante. Moco compacto suma 3 niveles;
  el corazón dobla el nivel actual.
- La poción multiplica el salto (`jump_velocity * 1.3` durante 60 s) y deja 1 nivel de
  moco permanente.
- Iconos provisionales: `starsW`, `bombPotionW`, `iceW` y `healthW`.
