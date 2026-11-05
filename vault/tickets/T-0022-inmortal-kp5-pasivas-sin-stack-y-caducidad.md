# T-0022 · KP5 inmortal, pasivas sin stack y caducidad de pickups

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `feat` + `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player / inventory / enemies |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0015 (debug), T-0017/T-0019 (pasivas), T-0020 (drops) |

## Petición

1. KP5 alterna inmortalidad: una pulsación inmortal, otra normal.
2. Las pasivas/coleccionables no se pueden apilar nunca:
   - al spawnear, un temporizador interno de 1 minuto que borre el loot solo;
   - con la pasiva en el inventario no se puede volver a obtener;
   - si ya está cargada, no se puede volver a dropear.
3. Los pickups parpadean a los 25 s y desaparecen a los 30 s, contando desde que se
   ven por primera vez (no desde que se cargan). Las monedas no cuentan.

## Plan

1. `debug_tools.gd`: tecla KP5 → `player.toggle_immortal()`; aviso en el hint.
2. `player.gd`: `immortal` + corte de `_apply_damage()`.
3. `PlayerPassives.has_passive()` / `add_passive() -> bool` y rechazo en
   `PassiveItems.on_pickup()`.
4. `EnemyBase._available_loot()`: fuera del pool las pasivas ya equipadas.
5. `item_pickup.gd`: caducidad a 60 s desde el spawn y 30 s desde la primera vez
   que entra en cámara, con parpadeo desde los 25 s.

## Criterios de aceptación

- [x] KP5 alterna inmortalidad y el jugador no pierde vida con ella activa.
- [x] Una pasiva equipada no vuelve a salir del loot ni se puede recoger dos veces.
- [x] Pickup sin recoger: parpadea a los 25 s vistos y desaparece a los 30 s; a los
      60 s desde el spawn se borra aunque nunca se haya visto.
- [x] Las monedas no caducan.
- [x] `docs/items.md` y `docs/player.md` actualizados; changelog y estado al día.
- [ ] F5 en editor: tiempos y KP5.

## Resultado

- `scripts/debug_tools.gd`: KP5 en el `match`, `_toggle_immortal()` y etiqueta con
  `inmortal sí/no`.
- `scripts/player.gd`: `immortal`, `toggle_immortal()` y salida temprana en
  `_apply_damage()` (no aplica a empujes de `take_damage_from()`).
- `scripts/collectables/player_passive.gd`: `has_passive()` (instancia, ruta o id) y
  `add_passive()` devuelve `false` en duplicados.
- `scripts/collectables/passive_items.gd`: `on_pickup()` delega en `add_passive()`.
- `scripts/enemies/enemy_base.gd`: `_available_loot()` / `_player_has_passive()`
  filtran el pool antes de tirar; pool vacío = no se tira objeto.
- `item_pickup.gd`: `SPAWN_LIFETIME` 60 s, `BLINK_START` 25 s, `SEEN_LIFETIME` 30 s,
  `BLINK_INTERVAL` 0,2 s; `_is_seen()` usa la cámara y `_update_expiry()` gestiona
  borrado y parpadeo. Las monedas usan `coin.gd` y no cambian.

Verificado por inspección (sin ejecutar Godot, según `AGENTS.md`); falta F5.
