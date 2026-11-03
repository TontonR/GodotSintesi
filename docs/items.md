# Objetos e inventario — estado

_2026-10-14 · rama `feat/items-demo` · 2026-10-20 · rama `feat/skills-and-complex-passives`_

## Jerarquía

`Items` → `Collectable` (`on_pickup(player) -> bool`) → `Consumable` / `PassiveItems` → `AttackBonusPassive`, `DamageReductionPassive`, `RegenPassive`. `Skills` sigue en `Items` (equipamiento sin cablear). Pickup genérico: `item_pickup.gd/.tscn` con `@export var item: Items`.

## Huecos (5) y teclas

| Huecos | Tipo                    | Teclas (`use_slot_1..5`) |
| ------ | ----------------------- | ------------------------ |
| 1-2    | Skills (no se gastan)   | 1, 2                     |
| 3-5    | Consumibles (se gastan) | 3, 4, 5                  |

- `Inventory.add_item` enruta por tipo; si la barra del tipo está llena, el objeto se queda en el suelo.
- Pasivas → `PlayerPassives`. Recogida automática al tocar (`body_entered`); F (`interact`) ya no recoge.

## Catálogo (6 + 9 + 8 + 11)

- **Los 6 originales están desactivados (2026-11-03)**: `pocion_cura`, `pocion_stamina`,
  `pocion_mayor`, `amuleto_ataque`, `armadura_ligera` y `talisman_regen` ya no salen de
  ningún enemigo, ni están en el debug, ni hay pickups de prueba en `game.tscn`. Los
  `.tres` siguen en `resources/` sin referencias, por si se quieren recuperar.
- Ello deja `pocion_mocos` como único consumible.

## Pasivas de ogro y lobo (9, T-0017 · 2026-11-03)

- Los 9 `.tres` viven en `resources/` y usan cuatro scripts: `StatBonusPassive` (planos), `CoinDropBonusPassive`, `LowHealthAttackPassive`, `NightBonusPassive`.
- Planos: `tapoarrabos` +10 estamina, `maza` +1 ataque, `una_ogro` +5 velocidad, `colgante_hierro` +25 vida máx (no cura), `piel_lobo` +15 vida y +5 estamina, `colmillo_lobo` +2 ataque.
- `piedra_oro` (+5% moneda al matar): `EnemyBase._drop_loot()` suma `_coin_drop_bonus()` a la entrada de moneda del `loot_table`.
- `garras_lobo` (vida <30% → ataque ×1.2) y `adn_hombre_lobo` (noche → ataque y velocidad ×1.15) aplican un delta sobre el valor sin su bonus, así que no pisan otros bonus ni se acumulan por frame. `DayNightCycle.is_night()` (factor ≥ 0.5) es la fuente del estado noche.
- `Items.quality` (`Normal` / `Raro`) es nuevo en la clase base; los `.tres` viejos quedan en `Normal`.
- Iconos provisionales del pack `assets/19+ icons` (`boostW`, `strenghtenW`, `lightningW`, `healthW`, `shieldW`, `swingW`, `fireW`, `neuronW`) y `assets/items/moneda_oro.png` (primer frame de 16×16 recortado de `assets/coins/MonedaD.png`, que es una tira de animación).
- Todos están en `_DEBUG_PASSIVES` (KP2) para probarlos. **No** están en `DROP_ITEMS`: falta el cableado por enemigo/calidad y el lobo (T-0001).

## Drops

- `enemy_base.gd` (2026-11-03): moneda al 45 % (`coin_drop_chance`, 1 moneda) y un objeto
  del pool del enemigo al 30 % (`item_drop_chance`); `rare_loot_weight` 0.25. El pool
  genérico anterior (`DROP_ITEMS`, los 6 originales) está eliminado: el arquero y el
  esqueleto solo sueltan moneda hasta que tengan tabla propia. Las 2 monedas por chunk
  del generador son pickups independientes del loot enemigo.
- El drop se parenta primero y luego recibe `global_position`; asignarla antes hacía que el offset del chunk se sumara dos veces. No añadir pickups de prueba en `game.tscn`.
- Física (`item_pickup.gd`): gravedad 900, rebote 0.45 hasta <35 px/s, vaivén 1,5 px, `z_index` 1; suelo fijado en el primer tick.
- Recogida al doble: icono 32 px (`Sprite2D` ×2), `HALF_HEIGHT` 16 y radio de recogida 16; el tooltip sube 8 px.
- Tooltip de proximidad a 40 px (nombre + descripción); el HUD está en `docs/ui.md`.

## Balance y limpieza (2026-11-03)

- Suben los planos de ataque, que se quedaban cortos frente a 20 de daño base: `maza`
  +1 → +2 y `colmillo_lobo` +2 → +3.
- `pies_ligeros` 15 % → 10 % de velocidad (la velocidad era la estadística más rentable).
- `piedra_oro` 5 % → 10 % de moneda extra: con la moneda al 45 %, un +5 % no se notaba.
- Prueba de humo del balance: 12 objetos del pool por enemigo, moneda 45 %, objeto 30 %
  y `Raro` 0.25 → una pasiva cada ~3,3 enemigos y una moneda cada ~2,2.

## Debug (temporal, `scenes/inventory/inventory.gd`)

- Numpad `0` vacía inventario y pasivas; `1` añade un consumible aleatorio; `2` una pasiva aleatoria; `3` reservado para skills (aún sin objetos).
- Se añaden directamente (consumibles a los huecos 3-5, pasivas a `PlayerPassives`); si el inventario está lleno, el objeto se descarta.
- Para quitarlo: `DEBUG_TOOLS = false` (o borrar `_handle_debug_key`, `_clear_debug_items` y `_give_debug_item`).

## Pendiente

- `Skills`: `use()` llama a `equip()` pero el jugador no lo tiene; sin objetos skill.
- Intercambio con barra llena (hoy queda en el suelo).
- `player.tscn` legacy de la raíz sin `Inventory`/`PlayerPassives` (no se usa).

## Pasivas de rana y slime (8, T-0019 · 2026-11-03)

Tabla completa por enemigo en `vault/pasivas/`. Aquí va lo técnico:

- **Saliva de rana** (`saliva_rana.tres`, `ComboProjectilePassive`): cada 3er ataque lanza
  un `player_projectile` al 25 % del daño base con `piercing = true`. **Burbuja de rana**
  usa el mismo script con 3 proyectiles, 40° de abanico y 15 % de daño.
- Combo: `player._try_attack()` avisa a `PlayerPassives.trigger_attack_started_passives()`
  con el paso 1-3 antes de arrancar la animación.
- **Lengua de rana** (`SlowOnHitPassive`): `on_player_attack` llama a
  `EnemyBase.apply_slow(0.5, 3 s)` (`speed_movement * _slow_factor`).
- **Túberculos cutáneos** (`PoisonCloudPassive` + `poison_cloud.gd`): al recibir daño,
  `Area2D` de 44 px durante 4 s que pega 2 cada 0.5 s a lo que esté dentro (capa 4);
  se instancia diferido.
- **Moco / Moco compacto / Corazón mucosil** (`MocoLevelPassive`): suben el nivel del
  `MocoEmitter` del jugador (partículas `CPUParticles2D` generadas por código). Cada nivel
  da +0.5 de defensa plana que resta `player._apply_damage()`; el corazón dobla el nivel.
- **Poción de mocos** (`MocoPotion`, consumible): `jump_velocity × 1.3` durante 60 s y
  +1 nivel de moco permanente.
- Los 8 están en `_DEBUG_PASSIVES` (KP2), junto con los 11 objetos del compañero.
- Iconos provisionales: `assets/items/iconos/*.png`, versiones de **16×16**
  (`convert -filter point -resize 16x16`) de `magicW`, `weakenW`, `swirlW`, `poisonW`,
  `starsW`, `bombPotionW`, `iceW` y `healthW` del pack `assets/19+ icons`. Los originales
  del pack miden 380×380 y a tamaño real no cabían en pantalla (los 9 de T-0017 también
  pasaron a estos recortes).
