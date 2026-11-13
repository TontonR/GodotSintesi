# Wolf Pelt

_Item · pasiva · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Wolf Pelt** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/shieldW.png` — aplicada, **provisional** |
| Recurso | `res://resources/piel_lobo.tres` |
| Script | `res://scripts/collectables/StatBonusPassive.gd` |
| Lo suelta | [Lobo](../enemies/lobo.md) · 10 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Increases max health by 15 and max stamina by 5. Does not heal.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"piel_lobo"` |
| `bonus_max_health` | `15` |
| `bonus_max_stamina` | `5.0` |

## Cómo conseguirlo

- **Drop**: Lobo — 10 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
