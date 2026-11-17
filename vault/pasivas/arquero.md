# Pasivas del Arquero

_2026-11-03 · tabla de Jorge · **implementado 2026-11-17**_

## Estado

- El arquero está integrado (`scenes/enemies/archer.tscn` en `enemy_scenes`): vive a
  distancia y dispara flechas (`archer_projectile.gd`).
- Ya tiene `item_drops`: los cuatro objetos de la tabla, con `drop_chance = 0.1` cada uno.
- El arco del jugador usa `scenes/collectables/player_arrow.tscn`; el ataque cargado
  vive en `scripts/player.gd` + `scripts/collectables/BowPassive.gd`.

## Objetos implementados

| Nombre | Qué hace | `.tres` |
|---|---|---|
| Basic Bow | Mantén el ataque para disparar una flecha de 5; +150 % a los 2 s. Un toque corto sigue siendo melee. | `arco_basico` |
| Hunter's Cloak | +10 de vida máxima y +5 de estamina máxima. | `capa_caza` |
| Ranged Mastery | +15 % de daño a objetivos a 80 px o más. | `maestria_distancia` |
| Forest's Might | Invoca cada 15 s una rata invulnerable de 8 s; 3 de daño cada 0.5 s y bloquea proyectiles enemigos. | `fuerza_bosque` |

`Fragmento` no se ha creado: sigue `por definir`.
