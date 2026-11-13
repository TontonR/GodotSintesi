# Rana (sapo mutante)

_Enemigo · saltos y abanico de proyectiles · activo · `por revisar` · 2026-11-13_

| Campo | Valor |
|---|---|
| Nombre en el juego | **Mutant Toad** (`mutant_toad.tscn`, clase `mutant_toad`) |
| Escena | `res://scenes/enemies/mutant_toad.tscn` |
| Script | `res://scripts/enemies/mutant_toad.gd` |
| Proyectil | `res://scenes/enemies/toad_projectile.tscn` |
| Base | `EnemyBase` (ignora su IA: tiene estados propios) |
| Estado | `por revisar` (F5 y revisión pendientes) |
| Spawn | Pradera y bosque rojo |
| Capa / máscara | Capa 3 (`enemies`) · máscara 1 (solo mundo) |
| Doc técnica | [`docs/enemies.md`](../../docs/enemies.md) |

## Stats

| Stat | Valor | Notas |
|---|---|---|
| Vida | 50 → **67.5** | ×1.35 |
| Daño | 8 → **10** | ×1.25 |
| Salto horizontal | `hop_speed` 150 px/s | |
| Fuerza de salto | `jump_force` −420 | salto alto |
| Espera entre saltos | 0.8–1.4 s | aleatoria |
| Salto sin jugador | radio 350 px alrededor del spawn | |
| Ráfaga | cada **3 aterrizajes** | 3 proyectiles |
| Aviso antes de disparar | 0.7 s | destello `windup_tint` |
| Dispersión | ±12° | por proyectil |
| Proyectil | 230 px/s | `toad_projectile`, un golpe lo destruye |
| Escala | ×2 | |

## Mecánicas

- Máquina de estados propia `IDLE → JUMP → ATTACK`; no usa la de `EnemyBase`.
- Salta alto hacia el jugador si lo detecta y en direcciones aleatorias si no hay nadie
  cerca (siempre alrededor de su spawn).
- Cada 3 aterrizajes se queda quieto, destella 0.7 s y dispara un **abanico de 3
  proyectiles** con ±12° de desviación.
- Excluye la colisión con el jugador mientras salta para no empujarlo ni quedarse trabado.
- El jugador lo atraviesa y paga el golpe de contacto genérico cuando toca.

## Drops

| Objeto | Prob. | Qué hace | Ficha |
|---|---|---|---|
| Frog Saliva | 10 % | Cada 3.er ataque del combo lanza un proyectil perforante (25 % del daño) | [saliva_rana](../items/saliva_rana.md) |
| Frog Tongue | 10 % | Los golpes ralentizan al enemigo a ×0.5 durante 3 s | [lengua_rana](../items/lengua_rana.md) |
| Frog Bubble | 10 % | Al final del combo lanza 3 proyectiles en abanico (15 % cada uno) | [burbuja_rana](../items/burbuja_rana.md) |
| Skin Tubercles | 2 % | Al recibir daño suelta una nube de veneno (2 dmg / 0.5 s, 4 s) | [tuberculos_cutaneos](../items/tuberculos_cutaneos.md) |

- **Suma de la tirada: 32 %**; un solo objeto por muerte. Moneda aparte: 45 %.
- Saliva y Burbuja son la misma familia (`ComboProjectilePassive`) con distinto abanico:
  si tienes las dos, se acumulan los disparos del tercer golpe.

## Spawn

- `pradera.tres`: 1 sapo por chunk (junto a 3 orcos y 3 slimes).
- `bosque_rojo.tres`: junto al lobo (`enemy_counts` `[1, 1, 1, 2]`, ver
  [`docs/biomes.md`](../../docs/biomes.md)).
- No sale en nieve.

## Cómo comprobarlo (F5)

- [ ] Salta alto, espera 0.8–1.4 s y vuelve a saltar.
- [ ] Sin jugador cerca, salta en direcciones aleatorias sin alejarse del spawn.
- [ ] Cada 3 aterrizajes destella y lanza 3 proyectiles en abanico.
- [ ] Los proyectiles se destruyen con un golpe y no atraviesan el suelo.
- [ ] No empuja al jugador al saltar encima; el contacto lo cobra el jugador.
- [ ] Al morir puede soltar las 4 pasivas con sus probabilidades.

## Enlaces

- Lista general: [enemies.md](../enemies.md) · catálogo: [items.md](../items.md)
- Pasivas de la rana: [pasivas/rana.md](../pasivas/rana.md)
- Doc de pasivas: [`docs/passives.md`](../../docs/passives.md)
