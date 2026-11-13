# Werewolf DNA

_Item · pasiva · `Rare` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Werewolf DNA** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Rare` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/neuronW.png` — aplicada, **provisional** |
| Recurso | `res://resources/adn_hombre_lobo.tres` |
| Script | `res://scripts/collectables/NightBonusPassive.gd` |
| Lo suelta | [Lobo](../enemies/lobo.md) · 2 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> At night: +15% attack and +15% speed.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"adn_hombre_lobo"` |
| `damage_multiplier` | `1.15` |
| `speed_multiplier` | `1.15` |

## Cómo conseguirlo

- **Drop**: Lobo — 2 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
