# Items — catálogo, drops y estado

_2026-11-13 · generado desde `resources/*.tres` y los `item_drops` de `scenes/enemies/*.tscn` · 44 objetos

Catálogo vivo de objetos. Cada fila enlaza a su ficha en [`items/`](items/) y cada drop al enemigo que lo suelta en [`enemies/`](enemies/). La verdad técnica está en [`docs/items.md`](../docs/items.md), [`docs/passives.md`](../docs/passives.md) y [`docs/loot.md`](../docs/loot.md); si este catálogo contradice al código, gana el código.

## Estados

| Estado | Significado |
|---|---|
| `sin empezar` | Ideas o entradas sin recurso todavía. |
| `en proceso` | Se está implementando (script, `.tres` o tabla de loot). |
| `por asignar textura` | Lógica y `.tres` listos; el icono es provisional del pack y falta el arte final. |
| `por revisar` | Terminado, pendiente de F5 o de revisión de otro agente. |
| `listo` | Verificado en el juego y con textura final. |

> **Los 44 objetos están en `por asignar textura`**: todos los `.tres` ya tienen `icon` aplicado (potions del pack y pasivas de `assets/items/`), pero es arte provisional. El estado cambia cuando el icono sea el definitivo, no cuando exista un PNG.

## Reglas de drop (resumen)

- **Una sola tirada por enemigo**: se suman los `drop_chance` de su tabla. Si sale, se elige **un** objeto ponderado; dos objetos distintos del mismo enemigo no caen juntos.
- **Pasivas repetidas fuera**: `_available_drops()` descarta las que el jugador ya tiene. Los consumibles no se filtran.
- **Suerte**: `player.luck × 0.01` se suma a la tirada de moneda y otra vez a la de objeto (`minf(total + luck, 1)`).
- **Monedas aparte**: `coin_drop_chance` 0.45 y `coin_drop_amount` 1 por defecto, más 2 monedas por chunk del generador.
- Detalle completo: [`docs/loot.md`](../docs/loot.md).

## Catálogo

| Objeto | Tipo | Calidad | Drops | Textura (icono) | Estado | Ficha |
|---|---|---|---|---|---|---|
| **Werewolf DNA** | Pasiva | `Rare` | [Lobo](enemies/lobo.md) · 2 % | `items/iconos/neuronW.png` | `por asignar textura` | [adn_hombre_lobo](items/adn_hombre_lobo.md) |
| **Attack Amulet** | Pasiva | `Normal` | — (sin drop) | `items/item183.png` | `por asignar textura` | [amuleto_ataque](items/amuleto_ataque.md) |
| **Critical Amulet** | Pasiva | `Normal` | — (sin drop) | `items/item555.png` | `por asignar textura` | [amuleto_critico](items/amuleto_critico.md) |
| **Fury Amulet** | Pasiva | `Normal` | — (sin drop) | `items/item333.png` | `por asignar textura` | [amuleto_furia](items/amuleto_furia.md) |
| **Vigor Ring** | Pasiva | `Normal` | — (sin drop) | `items/item888.png` | `por asignar textura` | [anillo_vigor](items/anillo_vigor.md) |
| **Light Armor** | Pasiva | `Normal` | — (sin drop) | `items/item579.png` | `por asignar textura` | [armadura_ligera](items/armadura_ligera.md) |
| **Heavy Armor** | Pasiva | `Normal` | — (sin drop) | `items/item250.png` | `por asignar textura` | [armadura_pesada](items/armadura_pesada.md) |
| **Tonic Drink** | Consumible | `Normal` | — (sin drop) | `potions/potion7.png` | `por asignar textura` | [bebida_tonificante](items/bebida_tonificante.md) |
| **Frog Bubble** | Pasiva | `Normal` | [Rana](enemies/rana.md) · 10 % | `items/iconos/swirlW.png` | `por asignar textura` | [burbuja_rana](items/burbuja_rana.md) |
| **Hunter** | Pasiva | `Normal` | — (sin drop) | `items/iconos/swingW.png` | `por asignar textura` | [cazador](items/cazador.md) |
| **Greed** | Pasiva | `Normal` | — (sin drop) | `items/moneda_oro.png` | `por asignar textura` | [codicia](items/codicia.md) |
| **Iron Pendant** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/iconos/healthW.png` | `por asignar textura` | [colgante_hierro](items/colgante_hierro.md) |
| **Wolf Fang** | Pasiva | `Normal` | [Lobo](enemies/lobo.md) · 10 % | `items/iconos/swingW.png` | `por asignar textura` | [colmillo_lobo](items/colmillo_lobo.md) |
| **Iron Heart** | Pasiva | `Normal` | — (sin drop) | `items/iconos/healthW.png` | `por asignar textura` | [corazon_hierro](items/corazon_hierro.md) |
| **Mucus Heart** | Pasiva | `Rare` | [Slime](enemies/slime.md) · 2 % | `items/iconos/healthW.png` | `por asignar textura` | [corazon_mucosil](items/corazon_mucosil.md) |
| **Life Elixir** | Consumible | `Normal` | — (sin drop) | `potions/potion15.png` | `por asignar textura` | [elixir_vida](items/elixir_vida.md) |
| **Vital Essence** | Consumible | `Normal` | — (sin drop) | `items/item410.png` | `por asignar textura` | [esencia_vital](items/esencia_vital.md) |
| **Thorns** | Pasiva | `Normal` | — (sin drop) | `items/iconos/shieldW.png` | `por asignar textura` | [espinas](items/espinas.md) |
| **Wolf Claws** | Pasiva | `Normal` | [Lobo](enemies/lobo.md) · 10 % | `items/iconos/fireW.png` | `por asignar textura` | [garras_lobo](items/garras_lobo.md) |
| **Gauntlet** | Pasiva | `Normal` | — (sin drop) | `items/iconos/strenghtenW.png` | `por asignar textura` | [guantelete](items/guantelete.md) |
| **Guardian's Wrath** | Pasiva | `Normal` | — (sin drop) | `items/iconos/fireW.png` | `por asignar textura` | [ira_guardian](items/ira_guardian.md) |
| **Frog Tongue** | Pasiva | `Normal` | [Rana](enemies/rana.md) · 10 % | `items/iconos/weakenW.png` | `por asignar textura` | [lengua_rana](items/lengua_rana.md) |
| **Mace** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/iconos/strenghtenW.png` | `por asignar textura` | [maza](items/maza.md) |
| **Mucus** | Pasiva | `Normal` | [Slime](enemies/slime.md) · 10 % | `items/iconos/starsW.png` | `por asignar textura` | [moco](items/moco.md) |
| **Compact Mucus** | Pasiva | `Normal` | [Slime](enemies/slime.md) · 10 % | `items/iconos/iceW.png` | `por asignar textura` | [moco_compacto](items/moco_compacto.md) |
| **Gold Stone** | Pasiva | `Rare` | [Orco](enemies/orco.md) · 2 % | `items/moneda_oro.png` | `por asignar textura` | [piedra_oro](items/piedra_oro.md) |
| **Wolf Pelt** | Pasiva | `Normal` | [Lobo](enemies/lobo.md) · 10 % | `items/iconos/shieldW.png` | `por asignar textura` | [piel_lobo](items/piel_lobo.md) |
| **Light Feet** | Pasiva | `Normal` | — (sin drop) | `items/iconos/lightningW.png` | `por asignar textura` | [pies_ligeros](items/pies_ligeros.md) |
| **Healing Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion2.png` | `por asignar textura` | [pocion_cura](items/pocion_cura.md) |
| **Minor Healing Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion5.png` | `por asignar textura` | [pocion_cura_menor](items/pocion_cura_menor.md) |
| **Vigor Elixir** | Consumible | `Normal` | — (sin drop) | `items/item912.png` | `por asignar textura` | [pocion_mayor](items/pocion_mayor.md) |
| **Mucus Potion** | Consumible | `Normal` | [Slime](enemies/slime.md) · 10 % | `items/iconos/bombPotionW.png` | `por asignar textura` | [pocion_mocos](items/pocion_mocos.md) |
| **Stamina Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion3.png` | `por asignar textura` | [pocion_stamina](items/pocion_stamina.md) |
| **Greater Stamina Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion10.png` | `por asignar textura` | [pocion_stamina_mayor](items/pocion_stamina_mayor.md) |
| **Third-Hit Projectile** | Pasiva | `Normal` | — (sin drop) | `items/iconos/magicW.png` | `por asignar textura` | [proyectil_tercer_golpe](items/proyectil_tercer_golpe.md) |
| **Vampiric Pulse** | Pasiva | `Normal` | — (sin drop) | `items/item42.png` | `por asignar textura` | [pulso_vampirico](items/pulso_vampirico.md) |
| **Burst** | Pasiva | `Normal` | — (sin drop) | `items/iconos/swirlW.png` | `por asignar textura` | [rafaga](items/rafaga.md) |
| **Frog Saliva** | Pasiva | `Normal` | [Rana](enemies/rana.md) · 10 % | `items/iconos/magicW.png` | `por asignar textura` | [saliva_rana](items/saliva_rana.md) |
| **Second Wind** | Pasiva | `Normal` | — (sin drop) | `items/iconos/boostW.png` | `por asignar textura` | [segundo_aliento](items/segundo_aliento.md) |
| **Regeneration Talisman** | Pasiva | `Normal` | — (sin drop) | `items/item467.png` | `por asignar textura` | [talisman_regen](items/talisman_regen.md) |
| **Root Grabbers** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/iconos/boostW.png` | `por asignar textura` | [tapoarrabos](items/tapoarrabos.md) |
| **Skin Tubercles** | Pasiva | `Rare` | [Rana](enemies/rana.md) · 2 % | `items/iconos/poisonW.png` | `por asignar textura` | [tuberculos_cutaneos](items/tuberculos_cutaneos.md) |
| **Ogre Nail** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/iconos/lightningW.png` | `por asignar textura` | [una_ogro](items/una_ogro.md) |
| **Vampirism** | Pasiva | `Normal` | — (sin drop) | `items/iconos/poisonW.png` | `por asignar textura` | [vampirismo](items/vampirismo.md) |

## Reparto por enemigo

| Enemigo | Objetos (prob.) | Suma de la tirada |
|---|---|---|
| [Orco](enemies/orco.md) | Root Grabbers 10%, Mace 10%, Ogre Nail 10%, Iron Pendant 10%, Gold Stone 2% | **42 %** |
| [Lobo](enemies/lobo.md) | Wolf Pelt 10%, Wolf Fang 10%, Wolf Claws 10%, Werewolf DNA 2% | **32 %** |
| [Rana](enemies/rana.md) | Frog Saliva 10%, Frog Tongue 10%, Frog Bubble 10%, Skin Tubercles 2% | **32 %** |
| [Slime](enemies/slime.md) | Mucus 10%, Mucus Potion 10%, Compact Mucus 10%, Mucus Heart 2% | **32 %** |
| Esqueleto, arquero, fantasma y demonio | — | 0 % |

## Cómo mantenerlo

1. Al crear o cambiar un `.tres`, actualiza su ficha y su fila (nombre, tipo, calidad, drops, icono, estado).
2. Al tocar `item_drops` de una escena, actualiza el drop aquí **y** en `enemies/<slug>.md`.
3. No marcar `listo` sin textura final y F5.
4. Skill asociada: [`.opencode/skills/estado-items/SKILL.md`](../.opencode/skills/estado-items/SKILL.md).

