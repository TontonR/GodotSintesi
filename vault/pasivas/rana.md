# Pasivas de la Rana (sapo mutante)

_2026-11-03 · tabla de Jorge · loot: `item_drops` de `scenes/enemies/mutant_toad.tscn`_

| Nombre | Qué hace | Calidad | `.tres` | Script |
|---|---|---|---|---|
| Saliva de rana | Al acabar el combo lanza un proyectil de saliva hacia delante (25% del daño base) que atraviesa todo | Normal | `resources/saliva_rana.tres` | `ComboProjectilePassive` |
| Lengua de rana | Al atacar a un enemigo le bajas la velocidad (×0.5 durante 3 s) | Normal | `resources/lengua_rana.tres` | `SlowOnHitPassive` |
| Burbuja de rana | Al acabar el combo lanza 3 proyectiles de saliva en abanico (15% del daño base cada uno) que atraviesan todo | Normal | `resources/burbuja_rana.tres` | `ComboProjectilePassive` |
| Túberculos cutáneos | Al recibir daño generas una nube de veneno | Raro | `resources/tuberculos_cutaneos.tres` | `PoisonCloudPassive` |

- "Al acabar el combo" = cada 3er ataque de la rotación: `PlayerPassives` avisa a las
  pasivas al empezar cada ataque (`on_player_attack_started`) con el paso 1-3.
- Los proyectiles usan `scenes/collectables/player_projectile.tscn` con `piercing = true`
  (nuevo): no desaparecen al primer impacto y no les paran el terreno ni los pickups.
- La nube de veneno es un `Area2D` dibujado por código (`poison_cloud.gd`, 44 px, 2 de
  daño cada 0.5 s, 4 s de vida); se lanza con `call_deferred` para no crear áreas dentro
  de una señal de física.
- Limpieza provisional: `boostW`-style → `magicW`, `weakenW`, `swirlW` y `poisonW`.
