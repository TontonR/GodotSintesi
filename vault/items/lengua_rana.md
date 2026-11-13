# Frog Tongue

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Frog Tongue** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/weakenW.png` — aplicada, **provisional** |
| Recurso | `res://resources/lengua_rana.tres` |
| Script | `res://scripts/collectables/SlowOnHitPassive.gd` |
| Lo suelta | [Rana](../enemies/rana.md) · 10 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Hitting an enemy slows it down for 3 s.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"lengua_rana"` |
| `slow_multiplier` | `0.5` |
| `slow_seconds` | `3.0` |

## Cómo conseguirlo

- **Drop**: Rana — 10 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
