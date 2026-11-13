# Fury Amulet

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Fury Amulet** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/item333.png` — aplicada, **provisional** |
| Recurso | `res://resources/amuleto_furia.tres` |
| Script | `res://scripts/collectables/AttackBonusPassive.gd` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Adds 12 damage to each hit.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `bonus` | `12.0` |
| `passive_id` | `"amuleto_furia"` |

## Cómo conseguirlo

- **Drop**: Sin drop asignado: pool neutral (solo debug).
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
