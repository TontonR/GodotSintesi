# Pasivas por enemigo

_Sección del vault con la tabla de Jorge (2026-11-03). Un `.md` por enemigo (T-0019)._

Cada pasiva es un `Resource` en `resources/*.tres` con `quality` = `Normal` / `Raro`. El
reparto real lo hace `EnemyBase._build_loot_table()` con `PRESET_POOLS`: el enemigo lleva
`loot_preset` en su escena y suelta **una** pasiva de su pool (75 %) más 1–3 monedas
garantizadas. Los `Raro` pesan 0.35 frente a 1.0 de los `Normal` (`rare_loot_weight`).

| Enemigo | Pool | `.md` |
|---|---|---|
| Ogro | `Ogro` (5: 4 Normal + 1 Raro) | [ogro.md](ogro.md) |
| Lobo | `Lobo` (4: 3 Normal + 1 Raro) | [lobo.md](lobo.md) |
| Rana (sapo mutante) | `Rana` (4: 3 Normal + 1 Raro) | [rana.md](rana.md) |
| Arquero | sin pasivas todavía (la tabla venía vacía) | [arquero.md](arquero.md) |
| Slime | `Slime` (4: 3 Normal + 1 Raro) | [slime.md](slime.md) |

Enemigos sin fila en la tabla (fantasma, demonio, esqueleto) siguen con el pool genérico
de `EnemyBase.DROP_ITEMS` (pociones y pasivas antiguas).

## Prelación de las imágenes

La tabla no traía rutas. Los iconos son **provisionales**, del pack `assets/19+ icons`
(versión `W`); para cambiarlos basta la línea `icon` del `.tres`.

## Cómo probarlas

KP2 reparte una pasiva aleatoria de `_DEBUG_PASSIVES` (`scenes/inventory/inventory.gd`),
que ya incluye todas las de esta sección.
