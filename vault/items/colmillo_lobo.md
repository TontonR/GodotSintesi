# Wolf Fang

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Wolf Fang** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/swingW.png` — aplicada, **provisional** |
| Recurso | `res://resources/colmillo_lobo.tres` |
| Script | `res://scripts/collectables/StatBonusPassive.gd` |
| Lo suelta | [Lobo](../enemies/lobo.md) · 10 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Increases attack by 3.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `bonus_attack` | `3` |
| `passive_id` | `"colmillo_lobo"` |

## Cómo conseguirlo

- **Drop**: Lobo — 10 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
