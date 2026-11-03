# T-0021 · Voladores fuera, enemigos repartidos y banda bajo las montañas

| Campo | Valor |
|---|---|
| Estado | `hecho` (pendiente de F5) |
| Tipo | `balance` + `fix` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world / enemies / ui |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0019 (enemigos del compañero), T-0020 (densidad), T-0018 (menú) |

## Petición

1. Desactivar el fantasma y el demonio (los voladores) por el momento.
2. Enemigos más repartidos por el chunk.
3. Banda plana `#283D43` bajo las montañas, siempre.
4. Documentar todo y subirlo a git.

## Qué se ha hecho

- `enemy_scenes` se queda en `orc`, `mutant_toad`, `werewolf`, `slime`, `skeleton` y
  `archer`, con `enemy_counts_per_chunk = [4, 2, 1, 2, 2, 2]` (13). Las dos escenas
  aparcadas quedan listadas en `WorldGenerator.DISABLED_ENEMY_SCENES`; no se han
  borrado ni tocado sus scripts.
- Reparto: `_generate_chunk` monta primero la lista de tipos del chunk, parte
  `enemy_min_x..max_x` en un hueco por enemigo y coloca cada uno en el centro de su
  hueco con ruido de ±25 % (`jitter`). El RNG se sigue consumiendo una vez por enemigo,
  así que las posiciones son estables con la misma semilla y las bajas se respetan.
- `MountainBase` (`ColorRect` hijo de `mountains`) añadido a `scenes/game.tscn` y el del
  menú pasa a `#283D43` (`Color(0.157, 0.239, 0.263)`): la banda plana se ve en menú y
  en partida, y el ciclo día/noche la oscurece junto al resto del parallax.
- Documentado en `docs/ui.md`, `docs/world.md`, `docs/enemies.md`, más `changelog`,
  `bitácora` y `estado`. Todo commiteado (sin push).

## Riesgos

- Los voladores vuelven a entrar a mano: hay que devolver sus preloads a `enemy_scenes`
  **y** sus cuentas a `enemy_counts_per_chunk` en el mismo orden.
- El ruido del reparto es del 25 % del hueco; con un chunk muy poblado el ruido baja
  porque el hueco se estrecha (se recalcula solo).
