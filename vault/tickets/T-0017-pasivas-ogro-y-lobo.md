# T-0017 · Pasivas de ogro y lobo (9 objetos)

| Campo | Valor |
|---|---|
| Estado | `en curso` (recursos creados y parseando, drops sin cablear) |
| Tipo | `feat` (contenido) |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | objetos / pasivas / loot |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Ficheros | `resources/*.tres`, `scripts/collectables/*Passive.gd`, `docs/items.md` |

## Tabla pedida por Jorge

| Nombre | Qué hace | Enemigo | Calidad | Imagen |
|---|---|---|---|---|
| Tapoarrabos | +10 estamina base | Ogro | Normal | `assets/19+ icons/boostW.png` |
| Maza | +1 ataque | Ogro | Normal | `assets/19+ icons/strenghtenW.png` |
| Uña de ogro | +5 velocidad | Ogro | Normal | `assets/19+ icons/lightningW.png` |
| Colgante de hierro (forma de corazón) | +25 vida máx (no cura) | Ogro | Normal | `assets/19+ icons/healthW.png` |
| Piedra con oro | +5% spawneo de monedas al matar | Ogro | Raro | `assets/items/moneda_oro.png` (recorte de `coins/MonedaD`) |
| Piel de lobo | +15 vida base + 5 estamina base | Lobo | Normal | `assets/19+ icons/shieldW.png` |
| Colmillo de lobo | +2 ataque | Lobo | Normal | `assets/19+ icons/swingW.png` |
| Garras de lobo | por debajo del 30% de vida, ataque +20% | Lobo | Normal | `assets/19+ icons/fireW.png` |
| ADN de hombre lobo | de noche +15% ataque y +15% velocidad | Lobo | Raro | `assets/19+ icons/neuronW.png` |

## Recursos creados

| Objeto | `.tres` | Script |
|---|---|---|
| Tapoarrabos | `resources/tapoarrabos.tres` | `StatBonusPassive` (`+10` estamina) |
| Maza | `resources/maza.tres` | `StatBonusPassive` (`+1` ataque) |
| Uña de ogro | `resources/una_ogro.tres` | `StatBonusPassive` (`+5` velocidad) |
| Colgante de hierro | `resources/colgante_hierro.tres` | `StatBonusPassive` (`+25` vida máx) |
| Piedra con oro | `resources/piedra_oro.tres` | `CoinDropBonusPassive` (`0.05`) |
| Piel de lobo | `resources/piel_lobo.tres` | `StatBonusPassive` (`+15` vida, `+5` estamina) |
| Colmillo de lobo | `resources/colmillo_lobo.tres` | `StatBonusPassive` (`+2` ataque) |
| Garras de lobo | `resources/garras_lobo.tres` | `LowHealthAttackPassive` (`0.3`, `1.2`) |
| ADN de hombre lobo | `resources/adn_hombre_lobo.tres` | `NightBonusPassive` (`1.15`, `1.15`) |

## Decisiones

- Cuatro scripts nuevos en vez de uno por objeto: `StatBonusPassive` (bonus planos), `CoinDropBonusPassive`, `LowHealthAttackPassive` y `NightBonusPassive`. Cada `.tres` solo cambia valores.
- `Items.quality` (`Normal` / `Raro`) nuevo en la clase base para guardar la columna de calidad; los `.tres` antiguos se quedan en `Normal` por defecto.
- Vida/estamina máximas y ataque/velocidad se tocan con métodos nuevos de `player.gd` (`add_max_health`, `add_max_stamina`, `add_attack_bonus`, `add_speed_bonus`); la vida máxima **no** cura.
- Las dinámicas (garras, ADN) guardan el daño/velocidad sin su bonus y aplican un delta, para no pisar los bonus planos de otras pasivas ni acumular multiplicadores cada frame.
- `NightBonusPassive` pregunta a `../day_night` con `is_night()` (nuevo en `DayNightCycle`, factor de noche ≥ 0.5).
- `EnemyBase._drop_loot()` suma `_coin_drop_bonus()` a la probabilidad de la entrada de moneda; es lo único que se ha tocado fuera de objetos.
- Imágenes: la tabla no traía rutas, así que se han buscado iconos del pack `assets/19+ icons` (versión `W`). Para la Piedra con oro, la moneda de `assets/coins` es una tira de animación, así que se recortó el primer frame de 16×16 a `assets/items/moneda_oro.png`. Son **provisionales**; cambiar solo la línea `icon` del `.tres`.
- Los 9 están en `_DEBUG_PASSIVES` de `scenes/inventory/inventory.gd`, así que KP2 los reparte para probarlos.

## Fixes posteriores al primer arranque

- `scripts/world/day_night.gd`: `_night_factor_at` y `_apply_state` estaban pegados a la línea anterior por una edición previa → `Parse Error: There is already a variable named "cycle"`. Recompuestas las declaraciones. El local `is_night` de `_apply_state` pasa a `show_night` para no tapar el método nuevo `is_night()`.
- `scripts/collectables/NightBonusPassive.gd`: `Cannot infer the type of "night_now"` → `var night_now := false` + `bool(_night.call("is_night"))` con `is_instance_valid`.
- `scenes/enemies/ghost_projectile.tscn`: `ext_resource, invalid UID` del PNG del proyectil; se quitó el `uid` (queda la ruta).
- `WARNING: NaN` en `JSON.stringify()`: no hay ninguna llamada en el proyecto; viene del editor, no se toca.

## Pendiente

- Cablear drops por enemigo y calidad: hoy no están en `EnemyBase.DROP_ITEMS`. El lobo aún no está integrado (T-0001), así que los seis de lobo saldrían del orco si se meten ya en el pool global.
- Iconos definitivos.
