# T-0019 · Traer todo lo del compañero y repartir el loot por enemigo

| Campo | Valor |
|---|---|
| Estado | `en curso` (integrado, sin F5) |
| Tipo | `feat` (integración + contenido) |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | enemies / loot / objetos |
| Rama origen | `origin/feat/enemigos-demon-toad-werewolf` (`a5b95d9`, `639d294`, `685bc30`) |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0001 (queda absorbido), T-0017 |

## Qué se ha traído

| Enemigo | Script | Escena | Loot |
|---|---|---|---|
| Demonio | `demon.gd`, `demon_fire.gd` | `demon.tscn`, `demon_fire.tscn` | genérico |
| Sapo mutante (rana) | `mutant_toad.gd`, `toad_projectile.gd` | `mutant_toad.tscn`, `toad_projectile.tscn` | `Rana` |
| Lobo | `werewolf.gd` | `werewolf.tscn` | `Lobo` |
| Slime | `slime.gd` | `slime.tscn` | `Slime` |
| Esqueleto | `skeleton.gd` | `skeleton.tscn` | genérico |
| Arquero | `archer.gd`, `archer_projectile.gd` | `archer.tscn`, `archer_projectile.tscn` | genérico (tabla vacía) |

- Traídos con `git checkout <rama> -- <ruta>`, sin merge: `main` tiene el mundo por
  chunks y la cámara nuevas y un merge ciego las revertiría.
- Assets copiados **solo** los que referencian esas escenas/frames (18 ficheros), no los
  packs completos (la rama trae 759 PNG del pack de slimes).
- 11 objetos del compañero: `cazador`, `codicia`, `corazon_hierro`, `espinas`,
  `guantelete`, `ira_guardian`, `pies_ligeros`, `proyectil_tercer_golpe`, `rafaga`,
  `segundo_aliento`, `vampirismo` + sus 10 scripts + `player_projectile`.

## API adaptada en `main`

- `player.take_damage_from(amount, pos, knockback, knockup_lock, knockup, attacker)`:
  antes solo `(amount, pos)`. Aplica empuje, lanzamiento vertical y bloqueo de control
  (`_control_lock_timer`).
- `player.is_guarding()`, `player.multiply_move_speed()`, `player.apply_jump_bonus()`,
  `player.moco_emitter()`, `player.moco_defense()`.
- `PlayerPassives`: hooks nuevos `on_player_attack_started`, `on_player_blocked`,
  `on_enemy_killed` y `on_player_take_damage(amount, attacker)`.
- `EnemyBase`: `apply_slow()`, aviso de muerte a las pasivas del jugador,
  `PRESET_POOLS` + `loot_preset` + elección con peso por calidad.
- `WorldGenerator`: los 6 enemigos al final de `enemy_scenes` con
  `enemy_counts_per_chunk = [2, 1, 1, 1, 1, 1, 1, 1]` y `add_to_group("world_generator")`
  (el lobo lo busca por grupo para merodear).

## Loot por enemigo

- `loot_preset` en la escena (Ogro/Lobo/Rana/Slime) → `EnemyBase._build_loot_table()`
  monta 1–3 monedas garantizadas + una pasiva del pool al 75 %.
- Peso por calidad: `Normal` 1.0, `Raro` 0.35 (`rare_loot_weight`).
- Tablas completas y una entrada por enemigo en `vault/pasivas/`.

## Ajustes posteriores (2026-11-03)

- Enemigos traídos al **doble de tamaño**: `scale = Vector2(2, 2)` en la raíz de
  `demon`, `mutant_toad`, `werewolf`, `slime`, `skeleton` y `archer` (los hijos con
  escala propia, 0.6/0.75/1.5, se quedan como estaban).
- Objetos gigantes: los iconos del pack `assets/19+ icons` son de **380×380** y se veían
  a tamaño real. Los 15 usados se han recortado a 16×16 en `assets/items/iconos/*.png` y
  los 16 `.tres` apuntan ya a esos recortes (incluidos los 9 de T-0017).
- Spawn más cerca: `enemy_safe_gap_tiles` (20) y el chunk 0 ya genera enemigos a partir
  de `safe_start_tiles + 20` tiles, en vez de dejar todo el chunk vacío.

## Pendiente

- F5: los 6 enemigos nuevos spawnean, mueren, dan su pasiva y la persistencia
  (`_defeated_spawns`) sigue bien. El lobo necesita el mundo para merodear.
- Revisar capas de colisión del demonio y del sapo en partida.
- Las 4 filas del arquero siguen vacías (`vault/pasivas/arquero.md`).
