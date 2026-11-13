# Enemies — lista general, drops y estado

_2026-11-13 · tabla contrastada con `scenes/enemies/*.tscn` y los scripts de `scripts/enemies/`_

Punto de entrada a los enemigos. Cada fila enlaza a su ficha completa en [`enemies/`](enemies/); cada drop enlaza al objeto en [`items/`](items/). La verdad técnica está en [`docs/enemies.md`](../docs/enemies.md) y [`docs/loot.md`](../docs/loot.md): si esta tabla contradice al código, gana el código y se corrige aquí.

## Cómo leer la tabla

- **Stats** van en `base → final`: el `_ready()` de `EnemyBase` aplica `health_multiplier` 1.35 y `attack_multiplier` 1.25. La velocidad y el cooldown no se multiplican.
- **Drops** es la suma de los `drop_chance` de `item_drops`; la tirada es **única** (si sale, cae un solo objeto ponderado). La moneda va aparte: 45 % de serie.
- **Mecánicas** resume el comportamiento; el detalle (ventanas de golpe, estados, rangos) está en la ficha.
- **Estado** sigue el vocabulario de [`items.md`](items.md#estados). Todos los enemigos están en `por revisar`: funcionan, pero falta F5 y revisión del otro agente.

## Estados

| Estado | Significado |
|---|---|
| `sin empezar` | Idea o escena sin implementar. |
| `en proceso` | Se está tocando ahora (stats, IA, escena). |
| `por asignar textura` | Lógica lista, arte provisional. |
| `por revisar` | Código hecho; falta F5 o revisión. |
| `listo` | Verificado en el juego y aprobado en el PR. |

## Lista

| Enemigo | Drops (prob.) | Stats | Mecánicas | Estado | Ficha |
|---|---|---|---|---|---|
| **Orco** (ogre) | Root Grabbers 10 %, Mace 10 %, Ogre Nail 10 %, Iron Pendant 10 %, Gold Stone 2 % · **42 %** | 50 → 67.5 HP · 15 → 18.75 dmg · 75 spd · cd 2.0 s | Melee simple; se para a atacar, golpea a los 0.66 s y la animación dura 2.5 s | `por revisar` | [orco](enemies/orco.md) |
| **Slime** | Mucus 10 %, Mucus Potion 10 %, Compact Mucus 10 %, Mucus Heart 2 % · **32 %** | 20 → 27 HP · 6 → 7.5 dmg · 35 spd · cd 1.8 s | Melee lento y corto; escala ×1.2 (el más pequeño) | `por revisar` | [slime](enemies/slime.md) |
| **Esqueleto** | — · **0 %** | 40 → 54 HP · 10 → 12.5 dmg · 50 spd · cd 2.0 s | Melee; el **primer golpe que recibe hace 0** (solo destello) | `por revisar` | [esqueleto](enemies/esqueleto.md) |
| **Arquero** | — · **0 %** | 30 → 40.5 HP · 8 → 10 dmg · 55 spd · cd 2.2 s | A distancia: flecha a 240 px/s, se detiene dentro de su rango y apunta mientras te ve | `por revisar` | [arquero](enemies/arquero.md) |
| **Lobo** (hombre lobo) | Wolf Pelt 10 %, Wolf Fang 10 %, Wolf Claws 10 %, Werewolf DNA 2 % · **32 %** | 60 → 81 HP · 10 → 12.5 dmg · 75 andar / 140 embestida | Vaga, embiste con 0.25 s de aviso y 1.5 s de recuperación; cada 2 embestidas salta (×2 daño, 40 px); el parry perfecto lo aturde 0.8 s y al salir elige embestida o salto (50/50) | `por revisar` | [lobo](enemies/lobo.md) |
| **Sapo mutante** (rana) | Frog Saliva 10 %, Frog Tongue 10 %, Frog Bubble 10 %, Skin Tubercles 2 % · **32 %** | 50 → 67.5 HP · 8 → 10 dmg · salto 150 px/s | Salta alto (`jump_force` −420), espera 0.8–1.4 s y cada 3 aterrizajes dispara 3 proyectiles en abanico | `por revisar` | [rana](enemies/rana.md) |
| **Fantasma** \* | — · **0 %** | 40 → 54 HP · 5 → 6.25 dmg · 85 spd · cd 2.0 s | Vuela, huye, dispara y se teletransporta a un anillo entre sus rangos; invulnerable al teletransportarse. **No aparece en runs** | `por revisar` | [fantasma](enemies/fantasma.md) |
| **Demonio** \* | — · **0 %** | 180 → 243 HP · 5 → 6.25 dmg · vuela a 70 | Ciclos de 3 s volando a 80 px, 0.75 s de aviso y 3 s de chorro de fuego; bloquearlo con la guardia lo aturde 5 s o 3 golpes. **No aparece en runs** | `por revisar` | [demonio](enemies/demonio.md) |

\* Fantasma y demonio existen como escena y script, pero **ningún bioma los lista** y `enemy_scenes` ya no los incluye: son inalcanzables en una run normal. Volver a meterlos exige tocar a la vez `enemy_scenes` y `enemy_counts` del bioma (mismo orden) y quitarlos de `DISABLED_ENEMY_SCENES`.

## Base compartida (`EnemyBase`)

- `scripts/enemies/enemy_base.gd` (`CharacterBody2D`): detección, persecución/huida, ataque, daño, loot y muerte. Cada escena afina stats en su `_init()` y solo sobreescribe lo que cambia.
- Prioridad de IA: **huir > atacar > perseguir**. `take_damage(amount, critical = false)`: cualquier override debe repetir la firma y pasar `critical` a `super`.
- Colisión: solo contra el mundo (`collision_mask` 1) y capa 3 (`enemies`); el jugador los atraviesa y eso le cuesta un golpe de contacto (`uses_custom_contact_damage()` lo desactiva en el lobo).
- Ataque: `attack_impact_delay` 0.5 s y `attack_duration` 1.0 s por defecto; el enemigo se queda quieto mientras ataca.
- Loot: `coin_drop_chance` 0.45, `coin_drop_amount` 1, `item_drops: Array[LootEntry]`, dispersión ±15 px. Reglas en [`docs/loot.md`](../docs/loot.md) y catálogo en [`items.md`](items.md).

## Spawn

| Bioma | Enemigos (`enemy_scenes`) | Densidad (`enemy_counts`) |
|---|---|---|
| Pradera | orco, slime, sapo | 3 orcos, 3 slimes, 1 sapo |
| Bosque rojo | lobo, sapo | `[1, 1, 1, 2]` — array con más valores que escenas, ver [`docs/biomes.md`](../docs/biomes.md) |
| Nieve | esqueleto, arquero, lobo | 2 esqueletos, 2 arqueros, 1 lobo |

- Chunks 0–1 al ×0.5, luego +20 % por chunk hasta ×1.8; el número final es `floori(base × multiplier)`.
- Reparto en ranuras iguales a lo ancho del chunk con ±25 % de ruido; 2 tiles de margen; ids estables `e:x:y:index` guardados en la run (los muertos no vuelven).
- El bioma de un chunk manda: `enemy_scenes`/`enemy_counts_per_chunk` de `world_generator.gd` es solo respaldo.

## Cómo mantenerlo

1. Al cambiar stats, IA, escena o `item_drops`: actualiza la fila de esta tabla **y** la ficha `enemies/<slug>.md`.
2. Si cambia el comportamiento, actualiza también [`docs/enemies.md`](../docs/enemies.md) (regla de `AGENTS.md`).
3. Al añadir un enemigo: ficha nueva, fila aquí, escena en el bioma con su cuenta en el mismo orden, y ticket.
4. Skills: [`.opencode/skills/estado-enemigos/SKILL.md`](../.opencode/skills/estado-enemigos/SKILL.md) y [`estado-items`](../.opencode/skills/estado-items/SKILL.md).
