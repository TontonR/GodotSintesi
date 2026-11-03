# T-0001 · Integrar los enemigos del compañero (demonio, sapo mutante y lobo)

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `feat` (integración) |
| Prioridad | `alta` |
| Dueño | `sin asignar` |
| Sistema | enemies + world |
| Rama origen | `origin/feat/enemigos-demon-toad-werewolf` · `685bc30` (2026-10-27) |
| Base de la rama | `58c4a0f` (2026-10-15) → 1 commit tras el merge-base con `main` |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0006, T-0007, T-0008 |

## Qué hay en la rama

Tres enemigos completos (escena + script + doc + assets), más cambios en jugador y generador:

| Enemigo | Scripts | Escenas | Doc |
|---|---|---|---|
| Demonio volador | `demon.gd`, `demon_fire.gd` | `scenes/enemies/demon.tscn`, `demon_fire.tscn` | `docs/enemigo_demon.md` |
| Sapo mutante | `mutant_toad.gd`, `toad_projectile.gd` | `scenes/enemies/mutant_toad.tscn`, `toad_projectile.tscn` | `docs/enemigo_mutant_toad.md` |
| Lobo | `werewolf.gd` | `scenes/enemies/werewolf.tscn` (+ `werewolf.tscn` en la raíz) | `docs/enemigo_werewolf.md` |

- Demonio: 180 vida, escala 0.6, vuela ~80 px sobre el spawn; ciclo FLY 3 s → aviso 0.75 s → chorro 3 s; chorro con `RayCast2D` al suelo, 5 daño / 0.5 s; bloqueado de frente se apaga y el demonio queda aturdido 5 s o 3 golpes.
- Sapo: máquina `IDLE/JUMP/ATTACK` propia (no usa el ataque de `EnemyBase`), salto alto, ráfaga de 3 proyectiles destructibles cada 3 aterrizajes. Los charcos tóxicos del diseño original están eliminados.
- Lobo: merodeo por zona, daño por contacto (círculo r22 cada frame físico), ciclo 2 embestidas + 1 salto, `knockup_force` 280 y bloqueo de control 0.12 s. Usa `player.apply_knockup()`.
- Assets nuevos en `assets/enemies/{demon,mutant-toad,werewolf}` y `All_Fire_Bullet_Pixel_16x16_03.png`.

## Por qué no es un merge

La rama nace **antes** del mundo por chunks (`19d7363`) y de los arreglos de cámara/escala (T-0009, T-0010). Un merge ciego revierte esas mejoras y rompe conceptos que ya no existen.

| Fichero | Rama del compañero | `main` hoy | Acción |
|---|---|---|---|
| `scripts/world_generator.gd` | `enemy_counts_per_zone` + zonas | `enemy_counts_per_chunk` + `KEEP_CHUNKS_SIDE` + persistencia `_defeated_spawns` | Portar: añadir los 3 `preload` a `enemy_scenes` y sus conteos a `enemy_counts_per_chunk` (`[4, 1]` → p. ej. `[4, 1, 1, 1, 1]`) |
| `scripts/player.gd` | `apply_knockback`, `apply_knockup`, `is_guarding`, `_apply_damage() -> bool`, `take_damage_from()` con knockback | movimiento, auto-subida y cámara reescritos | Reaplicar **solo** la API de knockback encima del jugador actual |
| Movimiento | vuelve a leer `KEY_LEFT`/`KEY_RIGHT` | flechas reservadas a la UI | **No** reintroducir flechas en el movimiento |
| `ghost.tscn` / `orc.tscn` (raíz) | modificados | legado sin referencias; el juego usa `scenes/enemies/` | Descartar; portar a `scenes/enemies/` si hiciera falta |
| `.opencode/` | **borra** `command/guardar.md` y `skills/godot-escenas/SKILL.md` | vigentes | **No aplicar** |
| `AGENTS.md` | reescribe el índice con sus 3 docs | índice actual + `vault/` | Fusionar a mano al cerrar T-0006 |

## Trampas

- `enemy_scenes` y `enemy_counts_per_chunk` van **en el mismo orden**; añadir al final para no reasignar conteos.
- El lobo busca el generador en el grupo `world_generator`, que `main` **no** añade (`_ready` no hace `add_to_group`). Portar esa línea o el lobo merodeará en un radio fijo.
- El sapo y el lobo se añaden `add_collision_exception_with` mutua con el jugador: interacción con `take_damage_from` y con el empuje de los enemigos base, a verificar en partida.
- Los spawns nuevos deben respetar `safe_start_tiles` y el margen de 2 tiles; el chunk 0 no genera enemigos.
- Capas del demonio documentadas como hurtbox 4 / ataque 12: validar contra 1 mundo / 2 jugador / 3 enemigos / 4 ataque jugador.
- El doc del sapo dice `Spritesheets/` y el commit mete `Sprites/`: la doc de la rama no es fiable al 100 % (T-0006).

## Plan de integración

1. Crear rama de integración desde `main`.
2. Portar assets (`assets/enemies/*`) y las 5 escenas/5 scripts tal cual, ajustando rutas a `scenes/enemies/`.
3. Portar a mano la API de knockback en `scripts/player.gd` (sin tocar cámara, auto-subida ni flechas).
4. Registrar los 3 enemigos al final de `enemy_scenes` / `enemy_counts_per_chunk` y añadir `add_to_group("world_generator")`.
5. F5: los 3 aparecen en chunks nuevos, mueren, dan loot y no rompen la persistencia (`_defeated_spawns`).
6. Cerrar T-0006 (docs) y T-0007 (balance/capas) antes de dar el ticket por cerrado.

## Criterios de aceptación

- [ ] Los 3 enemigos aparecen en el mundo y respetan zona segura y persistencia.
- [ ] Knockback/knockup funcionan y el jugador sigue sin flechas en el movimiento.
- [ ] Sin regresiones de cámara, escala ni drops (T-0009, T-0010, T-0011).
- [ ] `docs/enemies.md` + índice de `AGENTS.md` actualizados.
- [ ] `changelog.md` y `estado.md` al día.

## Resultado

Pendiente.
