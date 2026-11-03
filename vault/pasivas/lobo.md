# Pasivas del Lobo

_2026-11-03 · tabla de Jorge · loot: `loot_preset = "Lobo"` en `scenes/enemies/werewolf.tscn`_

| Nombre | Qué hace | Calidad | `.tres` | Script |
|---|---|---|---|---|
| Piel de lobo | +15 vida base y +5 estamina base | Normal | `resources/piel_lobo.tres` | `StatBonusPassive` |
| Colmillo de lobo | +2 ataque | Normal | `resources/colmillo_lobo.tres` | `StatBonusPassive` |
| Garras de lobo | Por debajo del 30% de vida, +20% de ataque | Normal | `resources/garras_lobo.tres` | `LowHealthAttackPassive` |
| ADN de hombre lobo | De noche +15% de ataque y +15% de velocidad | Raro | `resources/adn_hombre_lobo.tres` | `NightBonusPassive` |

- Las garras guardan el ataque sin su bonus y aplican un delta, así que no pisan los
  bonus planos ni acumulan multiplicadores por frame.
- El ADN pregunta a `../day_night` con `is_night()` (factor de noche ≥ 0.5).
- Iconos provisionales: `shieldW`, `swingW`, `fireW` y `neuronW`.
- El lobo que los suelta es el de la rama del compañero, ya integrado en `enemy_scenes`
  (T-0001/T-0019).
