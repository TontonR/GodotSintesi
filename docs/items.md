# Objetos e inventario — diseño y estado

_2026-11-03_

## Jerarquía

`Items` → `Collectable` (`on_pickup(player) -> bool`) → `Consumable` / `PassiveItems` → `AttackBonusPassive`, `DamageReductionPassive`, `RegenPassive`, `ComboProjectilePassive`, `SecondWindPassive`, `HunterPassive`, `GauntletPassive`, `IronHeartPassive`, `LightFeetPassive`, `VampirismPassive`, `GreedPassive`, `ThornsPassive`, `GuardianWrathPassive`.
`Skills` sigue en `Items` (equipamiento sin cablear). Pickup genérico: `item_pickup.gd/.tscn` con `@export var item: Items`.

## Huecos y teclas (5 huecos)

| Huecos | Tipo | Teclas (`use_slot_1..5`) |
|---|---|---|
| 1-2 | **Skills** (no se gastan al usarlas) | 1, 2 |
| 3-5 | **Consumibles** (se gastan al activarse) | 3, 4, 5 |

- `Inventory.add_item` enruta por tipo: `Skills` → 1-2, resto → 3-5; barra llena de su tipo = **no pasa nada**.
- Destino fuera del inventario: pasivas → `PlayerPassives`. Las skills sin `on_pickup` entran por fallback en `item_pickup.gd`.
- `interact` = F. `use_slot_4` = 4, `use_slot_5` = 5.

## HUD

- `ConsumableBar` (`InventoryUI`) arriba-izquierda: huecos 18×18 (iconos 16 a 1:1), separación 2, borde 1 px; separador de 4 px entre skills y consumibles.
- Vida/stamina arriba-derecha: barras 94×12, fuentes 10, borde 1 px. Monedas: fuente 10.
- **Pasivas** (`PassiveUI` en `UILayer/PassiveBar`, arriba-derecha bajo las barras): columna de iconos 12×12 con alpha 0.55. `PlayerPassives` emite `passives_changed`.

## Catálogo (17)

**Consumibles (3)**

| .tres | Efecto |
|---|---|
| `pocion_cura` | +30 vida |
| `pocion_stamina` | +40 stamina |
| `pocion_mayor` | +60 vida |

**Pasivas (14)**

| .tres | Efecto |
|---|---|
| `amuleto_ataque` | +6 daño por golpe |
| `armadura_ligera` | −25% daño recibido |
| `talisman_regen` | +1 vida/s |
| `proyectil_tercer_golpe` | 3.er ataque: 1 proyectil al frente, 25% del daño base |
| `rafaga` | 3.er ataque: 3 proyectiles en abanico (±12°), 15% cada uno |
| `segundo_aliento` | Bajo 30% de vida: +2 vida/s |
| `cazador` | +20% daño a enemigos bajo 30% de vida |
| `guantelete` | Cada 5.º ataque, el siguiente impacto hace x2 |
| `corazon_hierro` | +25 vida máxima y cura 25 al recogerla |
| `pies_ligeros` | +15% velocidad de movimiento |
| `vampirismo` | +2 vida por enemigo muerto |
| `codicia` | +1 moneda por enemigo muerto |
| `espinas` | Devuelve 20% del daño al atacante; tope 15, CD 2 s |
| `ira_guardian` | Al bloquear: +30% daño durante 10 s (se refresca) |

## Hooks de pasivas (2026-11-03)

- `on_player_attack_started(player, paso, direccion)`: se llama al **iniciar** cada ataque (paso 1-3), aunque no impacte.
- `on_player_attack(target, damage)`: al impactar; modifica el daño.
- `on_player_take_damage(amount, attacker)`: recibe el atacante (para Espinas).
- `on_player_blocked(player)`: al bloquear un golpe frontal (Ira del guardián).
- `on_enemy_killed(player, enemy)`: `EnemyBase._die()` avisa al grupo `player` antes de liberarse.
- `on_update(player, delta)`: temporizadores y regeneración.
- Las pasivas de estadísticas (`corazon_hierro`, `pies_ligeros`) aplican en `on_equip`. **No se revierten** porque aún no hay `unequip`; al añadir intercambio habrá que pasar a modificadores.
- Cada recogida hace `duplicate()` del recurso: dos copias de la misma pasiva mantienen contadores/cooldowns independientes.

## Proyectil del jugador

- `scenes/collectables/player_projectile.tscn` + `player_projectile.gd`: `Area2D` capa 16, máscara 13 (mundo + enemigos + proyectiles enemigos).
- Ignora al jugador y al `shooter`; daña enemigos, destruye proyectiles enemigos y desaparece contra el mundo. Vida 1.5 s.
- `ComboProjectilePassive` instancia la escena y llama a `setup(dir, velocidad, daño, jugador)`.

## Cómo salen los objetos

- **Loot de enemigos**: `LootDropItem.item_pool` con los 17 objetos; `enemy_base.gd` suelta `item_pickup.tscn` con uno al azar al **75%** (además de monedas 100%). El `item` se asigna antes de `add_child`.
- **Escena**: 2 drops en `game.tscn` a y=350 (x=110/150).
- **Sin pesos/rareza todavía**: todos los objetos tienen la misma probabilidad dentro del pool.

## Física de los drops (`item_pickup.gd`)

- **Recogida automática** con `body_entered`; si el hueco está ocupado, no pasa nada.
- **Gravedad** 900 px/s², **rebote** 0.45 (se asienta bajo 35 px/s) y **vaivén** `sin(t·2.5 + fase)` de 1.5 px.
- El suelo se busca en el **primer tick de física**; `_drop_loot` asigna posición antes de `add_child`. Si no hay suelo, flota.

## Pendiente

- Equipamiento (`Skills`): `use()` llama a `equip()` pero el jugador no lo tiene.
- Intercambio de pasivas/objetos y revertir estadísticas al desequipar.
- Pesos/rareza en `LootDropItem`.
- `player.tscn` legacy de la raíz sin `Inventory`/`PlayerPassives`.
