# Slime

_Enemigo · melee · activo · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Slime** (`slime.tscn`, clase `slime`) |
| Escena | `res://scenes/enemies/slime.tscn` |
| Script | `res://scripts/enemies/slime.gd` |
| Base | `EnemyBase` |
| Estado | `por revisar` (F5 y revisión pendientes) |
| Spawn | Pradera, 3 por chunk |
| Capa / máscara | Capa 3 (`enemies`) · máscara 1 (solo mundo) |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) · [`docs/passives.md`](../../docs/passives.md) |

## Stats

| Stat | Base → final | Notas |
|---|---|---|
| Vida | 20 → **27** | la más baja del juego |
| Daño | 6 → **7.5** | el más bajo del juego |
| Velocidad | 35 px/s | el más lento |
| Cooldown | 1.8 s | el más corto de los melee |
| Ventana de golpe | 0.5 s | `attack_impact_delay` |
| Animación de ataque | 1.2 s | |
| Escala | **×1.2** | excepción: el resto es ×2 |

## Mecánicas

- Melee simple y lento: persigue despacio y ataca en cuanto lo alcanza.
- Es el enemigo más pequeño (×1.2): el sprite y el collider no están duplicados como en el resto.
- El daño va por `Area2D`; el jugador lo atraviesa y paga el golpe de contacto genérico.
- Sin huida ni ataque a distancia: su peligro es el número (3 por chunk en pradera).
- Suelta el único consumible que cae de un enemigo: **Mucus Potion**.

## Drops

| Objeto | Prob. | Qué hace | Ficha |
|---|---|---|---|
| Mucus | 10 % | +1 nivel de moco permanente (5 partículas y +0.5 defensa por nivel) | [moco](../items/moco.md) |
| Mucus Potion | 10 % | Consumible: salto ×1.3 durante 60 s y +1 nivel de moco permanente | [pocion_mocos](../items/pocion_mocos.md) |
| Compact Mucus | 10 % | +3 niveles de moco | [moco_compacto](../items/moco_compacto.md) |
| Mucus Heart | 2 % | Duplica el nivel de moco actual | [corazon_mucosil](../items/corazon_mucosil.md) |

- **Suma de la tirada: 32 %**; un solo objeto por muerte.
- Moneda aparte: 45 % de serie.
- El emisor es `MocoEmitter` (`CPUParticles2D` sobre la hitbox); la defensa por nivel se resta en `player._apply_damage()`.
- La Mucus Potion ocupa slot de consumible aunque sea "poción de slime": no se equipa como pasiva.

## Spawn

- `pradera.tres`: 3 slimes por chunk (mismo reparto que el orco).
- Chunks 0–1 al ×0.5, luego +20 % hasta ×1.8.
- No sale en bosque rojo ni en nieve.

## Cómo comprobarlo (F5)

- [ ] Aparece en pradera, persigue lento y golpea a los ~0.5 s.
- [ ] Al morir puede soltar Mucus Potion y esta **ocupa un slot** (teclas 1–3), no la barra de pasivas.
- [ ] Mucus/Compact Mucus suben el nivel y se ven más partículas; Mucus Heart lo duplica.
- [ ] Con la barra llena, la poción se queda en el suelo.
- [ ] No empuja al jugador al atravesarlo.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo: [items.md](../items.md)
- Pasivas del slime en el vault: [pasivas/slime.md](../pasivas/slime.md)
- Doc de pasivas: [`docs/passives.md`](../../docs/passives.md)
