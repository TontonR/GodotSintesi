# Items — catálogo, drops y estado

_2026-11-13 · generado desde `resources/*.tres` y los `item_drops` de `scenes/enemies/*.tscn` · 44 objetos

Catálogo vivo de objetos. Cada fila enlaza a su ficha en [`items/`](items/) y cada drop al enemigo que lo suelta en [`enemies/`](enemies/). La verdad técnica está en [`docs/items.md`](../docs/items.md), [`docs/passives.md`](../docs/passives.md) y [`docs/loot.md`](../docs/loot.md); si este catálogo contradice al código, gana el código.

## Estados

| Estado | Significado |
|---|---|
| `sin empezar` | Ideas o entradas sin recurso todavía. |
| `en proceso` | Se está implementando (script, `.tres` o tabla de loot). |
| `por asignar textura` | Lógica y `.tres` listos, sin icono asignado. |
| `icono asignado` | Icono definitivo asignado; el arte aún puede cambiar. |
| `por revisar` | Terminado, pendiente de F5 o de revisión de otro agente. |
| `listo` | Verificado en el juego y con textura final. |

> **Los 44 objetos están en `icono asignado`**: todos los `.tres` usan ya su `item###.png` (o pociones del pack) definitivo, aunque el arte todavía puede cambiar. `listo` exige además F5.

Dos tipos y ninguno más: **consumibles** (huecos 1/2/3) y **coleccionables** (una pasiva siempre activa o condicional, fuera del inventario). En las tablas aparecen como `Consumible` y `Pasiva` (nombre del código); el nombre de diseño del segundo es *coleccionable*. **No hay armas ni skills.**

## Reglas de drop (resumen)

- **Una sola tirada por enemigo**: se suman los `drop_chance` de su tabla. Si sale, se elige **un** objeto ponderado; dos objetos distintos del mismo enemigo no caen juntos.
- **Pasivas repetidas fuera**: `_available_drops()` descarta las que el jugador ya tiene. Los consumibles no se filtran.
- **Suerte**: `player.luck × 0.01` se suma a la tirada de moneda y otra vez a la de objeto (`minf(total + luck, 1)`).
- **Monedas aparte**: `coin_drop_chance` 0.45 y `coin_drop_amount` 1 por defecto, más 2 monedas por chunk del generador.
- Detalle completo: [`docs/loot.md`](../docs/loot.md).

## Catálogo

| Objeto | Tipo | Calidad | Drops | Textura (icono) | Estado | Ficha |
|---|---|---|---|---|---|---|
| **Werewolf DNA** | Pasiva | `Rare` | [Lobo](enemies/lobo.md) · 2 % | `items/item735.png` | `icono asignado` | [adn_hombre_lobo](items/adn_hombre_lobo.md) |
| **Attack Amulet** | Pasiva | `Normal` | — (sin drop) | `items/item871.png` | `icono asignado` | [amuleto_ataque](items/amuleto_ataque.md) |
| **Critical Amulet** | Pasiva | `Normal` | — (sin drop) | `items/item855.png` | `icono asignado` | [amuleto_critico](items/amuleto_critico.md) |
| **Fury Amulet** | Pasiva | `Normal` | — (sin drop) | `items/item869.png` | `icono asignado` | [amuleto_furia](items/amuleto_furia.md) |
| **Vigor Ring** | Pasiva | `Normal` | — (sin drop) | `items/item892.png` | `icono asignado` | [anillo_vigor](items/anillo_vigor.md) |
| **Light Armor** | Pasiva | `Normal` | — (sin drop) | `items/item221.png` | `icono asignado` | [armadura_ligera](items/armadura_ligera.md) |
| **Heavy Armor** | Pasiva | `Normal` | — (sin drop) | `items/item226.png` | `icono asignado` | [armadura_pesada](items/armadura_pesada.md) |
| **Tonic Drink** | Consumible | `Normal` | — (sin drop) | `potions/potion219.png` | `icono asignado` | [bebida_tonificante](items/bebida_tonificante.md) |
| **Frog Bubble** | Pasiva | `Normal` | [Rana](enemies/rana.md) · 10 % | `items/item804.png` | `icono asignado` | [burbuja_rana](items/burbuja_rana.md) |
| **Hunter's Faith** | Pasiva | `Normal` | — (sin drop) | `items/item828.png` | `icono asignado` | [cazador](items/cazador.md) |
| **Greed** | Pasiva | `Normal` | — (sin drop) | `items/item169.png` | `icono asignado` | [codicia](items/codicia.md) |
| **Iron Pendant** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/item890.png` | `icono asignado` | [colgante_hierro](items/colgante_hierro.md) |
| **Wolf Fang** | Pasiva | `Normal` | [Lobo](enemies/lobo.md) · 10 % | `items/iconos/Icon34.png` | `icono asignado` | [colmillo_lobo](items/colmillo_lobo.md) |
| **Iron Heart** | Pasiva | `Normal` | — (sin drop) | `items/item199.png` | `icono asignado` | [corazon_hierro](items/corazon_hierro.md) |
| **Mucus Essence** | Pasiva | `Rare` | [Slime](enemies/slime.md) · 2 % | `items/item1122.png` | `icono asignado` | [corazon_mucosil](items/corazon_mucosil.md) |
| **Perfect Healing Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion158.png` | `icono asignado` | [elixir_vida](items/elixir_vida.md) |
| **Vigorizing Pie** | Consumible | `Normal` | — (sin drop) | `items/item410.png` | `icono asignado` | [esencia_vital](items/esencia_vital.md) |
| **Thorns** | Pasiva | `Normal` | — (sin drop) | `items/item1018.png` | `icono asignado` | [espinas](items/espinas.md) |
| **Wolf Claws** | Pasiva | `Normal` | [Lobo](enemies/lobo.md) · 10 % | `items/Icon12.png` | `icono asignado` | [garras_lobo](items/garras_lobo.md) |
| **Gauntlet** | Pasiva | `Normal` | — (sin drop) | `items/item749.png` | `icono asignado` | [guantelete](items/guantelete.md) |
| **Guardian's Wrath** | Pasiva | `Normal` | — (sin drop) | `items/item933.png` | `icono asignado` | [ira_guardian](items/ira_guardian.md) |
| **Frog Tongue** | Pasiva | `Normal` | [Rana](enemies/rana.md) · 10 % | `items/item1094.png` | `icono asignado` | [lengua_rana](items/lengua_rana.md) |
| **Mace** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/item918.png` | `icono asignado` | [maza](items/maza.md) |
| **Mucus** | Pasiva | `Normal` | [Slime](enemies/slime.md) · 10 % | `items/item310.png` | `icono asignado` | [moco](items/moco.md) |
| **Compact Mucus** | Pasiva | `Normal` | [Slime](enemies/slime.md) · 10 % | `items/item593.png` | `icono asignado` | [moco_compacto](items/moco_compacto.md) |
| **Gold Stone** | Pasiva | `Rare` | [Orco](enemies/orco.md) · 2 % | `items/item591.png` | `icono asignado` | [piedra_oro](items/piedra_oro.md) |
| **Wolf Pelt** | Pasiva | `Normal` | [Lobo](enemies/lobo.md) · 10 % | `items/item202.png` | `icono asignado` | [piel_lobo](items/piel_lobo.md) |
| **Light Feet** | Pasiva | `Normal` | — (sin drop) | `items/item276.png` | `icono asignado` | [pies_ligeros](items/pies_ligeros.md) |
| **Healing Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion13.png` | `icono asignado` | [pocion_cura](items/pocion_cura.md) |
| **Greater Healing Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion129.png` | `icono asignado` | [pocion_cura_menor](items/pocion_cura_menor.md) |
| **Greater Stamina Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion137.png` | `icono asignado` | [pocion_mayor](items/pocion_mayor.md) |
| **Mucus Potion** | Consumible | `Normal` | [Slime](enemies/slime.md) · 10 % | `items/Icon19.png` | `icono asignado` | [pocion_mocos](items/pocion_mocos.md) |
| **Stamina Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion108.png` | `icono asignado` | [pocion_stamina](items/pocion_stamina.md) |
| **Perfect Stamina Potion** | Consumible | `Normal` | — (sin drop) | `potions/potion166.png` | `icono asignado` | [pocion_stamina_mayor](items/pocion_stamina_mayor.md) |
| **Third-Hit Projectile** | Pasiva | `Normal` | — (sin drop) | `items/iconos/magicW.png` | `icono asignado` | [proyectil_tercer_golpe](items/proyectil_tercer_golpe.md) |
| **Sanguine Ruby** | Pasiva | `Normal` | — (sin drop) | `items/sanguine_ruby.png` | `icono asignado` | [pulso_vampirico](items/pulso_vampirico.md) |
| **Burst** | Pasiva | `Normal` | — (sin drop) | `items/item925.png` | `icono asignado` | [rafaga](items/rafaga.md) |
| **Frog Saliva** | Pasiva | `Normal` | [Rana](enemies/rana.md) · 10 % | `items/item805.png` | `icono asignado` | [saliva_rana](items/saliva_rana.md) |
| **Second Wind** | Pasiva | `Normal` | — (sin drop) | `items/item780.png` | `icono asignado` | [segundo_aliento](items/segundo_aliento.md) |
| **Regeneration Talisman** | Pasiva | `Normal` | — (sin drop) | `items/item872.png` | `icono asignado` | [talisman_regen](items/talisman_regen.md) |
| **Root Grabbers** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/item1036.png` | `icono asignado` | [tapoarrabos](items/tapoarrabos.md) |
| **Skin Tubercles** | Pasiva | `Rare` | [Rana](enemies/rana.md) · 2 % | `items/item910.png` | `icono asignado` | [tuberculos_cutaneos](items/tuberculos_cutaneos.md) |
| **Ogre Nail** | Pasiva | `Normal` | [Orco](enemies/orco.md) · 10 % | `items/item778.png` | `icono asignado` | [una_ogro](items/una_ogro.md) |
| **Vampirism** | Pasiva | `Normal` | — (sin drop) | `items/item1173.png` | `icono asignado` | [vampirismo](items/vampirismo.md) |

## Reparto por enemigo

| Enemigo | Objetos (prob.) | Suma de la tirada |
|---|---|---|
| [Orco](enemies/orco.md) | Root Grabbers 10%, Mace 10%, Ogre Nail 10%, Iron Pendant 10%, Gold Stone 2% | **42 %** |
| [Lobo](enemies/lobo.md) | Wolf Pelt 10%, Wolf Fang 10%, Wolf Claws 10%, Werewolf DNA 2% | **32 %** |
| [Rana](enemies/rana.md) | Frog Saliva 10%, Frog Tongue 10%, Frog Bubble 10%, Skin Tubercles 2% | **32 %** |
| [Slime](enemies/slime.md) | Mucus 10%, Mucus Potion 10%, Compact Mucus 10%, Mucus Essence 2% | **32 %** |
| Esqueleto, arquero, fantasma y demonio | — | 0 % |

## Cómo mantenerlo

1. Al crear o cambiar un `.tres`, actualiza su ficha y su fila (nombre, tipo, calidad, drops, icono, estado).
2. Al tocar `item_drops` de una escena, actualiza el drop aquí **y** en `enemies/<slug>.md`.
3. No marcar `listo` sin el F5 del icono en el HUD y en el inventario.
4. Skill asociada: [`.opencode/skills/estado-items/SKILL.md`](../.opencode/skills/estado-items/SKILL.md).

