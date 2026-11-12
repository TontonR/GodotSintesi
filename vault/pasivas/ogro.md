# Pasivas del Ogro

_2026-11-03 · tabla de Jorge · loot: `item_drops` de `scenes/enemies/orc.tscn`_

| Nombre | Qué hace | Calidad | `.tres` | Script |
|---|---|---|---|---|
| Tapoarrabos | +10 estamina base | Normal | `resources/tapoarrabos.tres` | `StatBonusPassive` |
| Maza | +2 ataque | Normal | `resources/maza.tres` | `StatBonusPassive` |
| Uña de ogro | +5 velocidad | Normal | `resources/una_ogro.tres` | `StatBonusPassive` |
| Colgante de hierro (forma de corazón) | +25 vida máx (no cura) | Normal | `resources/colgante_hierro.tres` | `StatBonusPassive` |
| Piedra con oro | +10% de probabilidad de moneda al matar | Raro | `resources/piedra_oro.tres` | `CoinDropBonusPassive` |

- El colgante sube el máximo y deja el hueco nuevo vacío (`health = mini(health, max_health)`).
- La piedra con oro no depende del pool: `EnemyBase._drop_loot()` le suma
  `_coin_drop_bonus()` a la probabilidad de la entrada de monedas de cualquier enemigo.
- Probabilidades: 10 % por cada objeto Normal y 2 % la Piedra con oro; en total 42 %
  de soltar algo en una sola tirada.
- Iconos provisionales: `boostW`, `strenghtenW`, `lightningW`, `healthW` y
  `assets/items/moneda_oro.png` (recorte del primer frame de `coins/MonedaD.png`).
