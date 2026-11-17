# Vigor Ring

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Vigor Ring** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `icono asignado` |
| Textura en el juego | `res://assets/items/item892.png` — aplicada, puede cambiar el arte |
| Recurso | `res://resources/anillo_vigor.tres` |
| Script | `res://scripts/collectables/RegenPassive.gd` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Restores 2 stamina per second.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"anillo_vigor"` |
| `heal_per_tick` | `0` |
| `stamina_per_tick` | `2` |
| `interval` | `1.0` |

## Cómo conseguirlo

- **Drop**: Sin drop asignado: pool neutral (solo debug).
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [x] Icono definitivo asignado en el `.tres` (el arte aún puede cambiar).
- [ ] F5 con el icono en el HUD y en el inventario.
