# Thorns

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Thorns** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/shieldW.png` — aplicada, **provisional** |
| Recurso | `res://resources/espinas.tres` |
| Script | `res://scripts/collectables/ThornsPassive.gd` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Returns 20% of damage taken to the attacker. Maximum 15 damage and 2 second cooldown.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"espinas"` |
| `damage_ratio` | `0.2` |
| `max_reflect` | `15` |
| `cooldown` | `2.0` |

## Cómo conseguirlo

- **Drop**: Sin drop asignado: pool neutral (solo debug).
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
