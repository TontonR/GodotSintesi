# Mucus Potion

_Item · consumible · `Normal` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Mucus Potion** |
| Tipo | Consumible — ocupa uno de los 3 slots y se gasta al usarlo |
| Calidad | `Normal` |
| Estado | `por asignar textura` |
| Textura en el juego | `res://assets/items/iconos/bombPotionW.png` — aplicada, **provisional** |
| Recurso | `res://resources/pocion_mocos.tres` |
| Script | `res://scripts/collectables/MocoPotion.gd` |
| Lo suelta | [Slime](../enemies/slime.md) · 10 % |
| Doc técnica | [`docs/items.md`](../../docs/items.md) · [`docs/loot.md`](../../docs/loot.md) |

## Qué hace

> Increases jump for 60 s and leaves the player emitting mucus particles.

Se usa con las teclas `1`/`2`/`3` y se gasta al usarlo. Si la barra de 3 slots está llena no se puede recoger (el objeto se queda en el suelo).

## Valores del recurso

| Campo | Valor |
|---|---|
| `duration` | `60.0` |
| `jump_multiplier` | `1.3` |
| `moco_levels` | `1` |

## Cómo conseguirlo

- **Drop**: Slime — 10 %
- **Debug**: KP1 (consumible aleatorio)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Asignar textura definitiva (hoy hay icono provisional del pack).
