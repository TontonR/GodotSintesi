# Pasivas por enemigo

_Sección del vault con la tabla de Jorge (2026-11-03). Un `.md` por enemigo (T-0019)._

Cada pasiva es un `Resource` en `resources/*.tres` con `quality` = `Normal` / `Raro`. El
reparto es **por enemigo**: su escena define `item_drops` (`Array[LootEntry]`) con un
objeto, su `drop_chance` y su cantidad. Las probabilidades se suman en **una sola tirada**
(30 % + 10 % = 40 %) y, si sale, se elige un objeto ponderado. La moneda va siempre aparte
(`coin_drop_chance` / `coin_drop_amount`, puede ser más de una). Sin presets compartidos:
una variante nueva rehace su tabla.

| Enemigo | Objetos | `.md` |
|---|---|---|
| Ogro | 5: 4 Normal + 1 Raro | [ogro.md](ogro.md) |
| Lobo | 4: 3 Normal + 1 Raro | [lobo.md](lobo.md) |
| Rana (sapo mutante) | 4: 3 Normal + 1 Raro | [rana.md](rana.md) |
| Arquero | sin pasivas todavía | [arquero.md](arquero.md) |
| Slime | 4: 3 Normal + 1 Raro | [slime.md](slime.md) |

Fantasmas, demonios y esqueletos no sueltan objetos hasta que se les añada `item_drops`.

## Prelación de las imágenes

La tabla no traía rutas. Los iconos son **provisionales**, del pack `assets/19+ icons`
(versión `W`); para cambiarlos basta la línea `icon` del `.tres`.

## Cómo probarlas

KP2 reparte una pasiva aleatoria de `_DEBUG_PASSIVES` (`scenes/inventory/inventory.gd`),
que ya incluye todas las de esta sección.
