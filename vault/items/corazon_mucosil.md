# Mucus Heart

_Item · pasiva · `Rare` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Mucus Heart** |
| Tipo | Pasiva — no ocupa slot, se equipa al tocarla |
| Calidad | `Rare` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/healthW.png` — aplicada, **provisional** |
| Recurso | `res://resources/corazon_mucosil.tres` |
| Script | `res://scripts/collectables/MocoLevelPassive.gd` |
| Lo suelta | [Slime](../enemies/slime.md) · 2 % |
| Doc técnica | [`docs/passives.md`](../../docs/passives.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Doubles the mucus particles you have.

Se equipa al tocarla (`PlayerPassives.add_passive`) y aplica su efecto desde ese momento. No se puede repetir: si ya la tienes, la tirada de loot la filtra.

## Valores del recurso

| Campo | Valor |
|---|---|
| `passive_id` | `"corazon_mucosil"` |
| `level_bonus` | `0` |
| `doubles_level` | `true` |

## Cómo conseguirlo

- **Drop**: Slime — 2 %
- **Debug**: KP2 (pasiva aleatoria)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
