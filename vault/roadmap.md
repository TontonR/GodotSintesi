# Roadmap — lo que queda por hacer

_2026-11-03 · primera versión sobre el estado de `main` + rama del compañero_

Estados: `abierto` · `en-curso` · `bloqueado` · `revision` · `cerrado` (los cerrados se van al `changelog.md`).

## P0 — Desbloquea el resto

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0001](tickets/T-0001-integrar-enemigos-companero.md) | enemigos | Integrar demonio, sapo mutante y lobo de `feat/enemigos-demon-toad-werewolf` | `abierto` |
| [T-0006](tickets/T-0006-converger-docs-enemigos.md) | docs | Converger los tres docs del compañero con `docs/enemies.md` | `abierto` (va con T-0001) |

## P1 — Huecos funcionales del juego

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0002](tickets/T-0002-cablear-skills.md) | inventario | Cablear skills: no hay `equip()` en el jugador ni objetos skill | `abierto` |
| [T-0003](tickets/T-0003-inventario-lleno-intercambio.md) | inventario | Intercambio/rechazo cuando la barra está llena (hoy el drop se queda en el suelo) | `abierto` |
| [T-0007](tickets/T-0007-pulido-enemigos-nuevos.md) | enemigos | Balance, capas y muerte de los enemigos nuevos | `abierto` |

## P2 — Deuda y limpieza

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0004](tickets/T-0004-legado-raiz-y-docs-obsoletos.md) | repo | Borrar legado real (`player.tscn`, `orc.tscn`, `coin` de `game.tscn`) y corregir docs falsos | `abierto` |
| [T-0005](tickets/T-0005-quitar-debug-numpad.md) | inventario | Retirar el debug del numpad cuando acabe la fase de pruebas | `abierto` |
| [T-0056](tickets/T-0056-auditoria-documentacion.md) | docs | Auditoría completa: `docs/` al día, biomas/loot/pasivas nuevos y mapa en `vault/documentacion.md` | `revision` |
| [T-0058](tickets/T-0058-atravesar-enemigos-con-dano.md) | player | Atravesar enemigos cuesta vida en vez de empujarlos | `revision` |
| [T-0059](tickets/T-0059-pantalla-de-muerte-y-fin-de-run.md) | player | Pantalla de muerte y fin de la run (sin revivir) | `revision` |
| [T-0060](tickets/T-0060-guardado-en-tres-slots.md) | ui | Guardado en tres slots de run, sobrescribibles y con aviso antes de reemplazar | `revision` |
| [T-0061](tickets/T-0061-contador-de-metros.md) | ui | Contador de metros (bloques) arriba al centro y en las filas de Load | `revision` |

## P3 — Contenido

| Id | Sistema | Qué | Estado |
|---|---|---|---|
| [T-0008](tickets/T-0008-mundo-biomas-y-densidad.md) | mundo | Biomas/zonas, densidad y variedad de spawns con 5 tipos de enemigo | `abierto` |
| [T-0057](tickets/T-0057-decoraciones.md) | world | Decoraciones de bioma: escala grande, densidad y tipos por bioma, rocas al fondo y arbustos con bamboleo y hojas | `revision` |

## Ideas sin ticket

El catálogo completo, con estado y dudas abiertas, está en [ideas.md](ideas.md).
No empezar ninguna sin abrir ticket y acordarlo en la bitácora:

- Guardado de partida (hoy la persistencia es por sesión: `_defeated_spawns` vive en memoria).
- Habilidades activas con cooldown y barra propia.
- Progresión: nivel, subida de stats, elección de pasivas.
- Jefe de zona y salas especiales.
- Sonido y música.
- Muerte real del jugador (`_die()` hoy es un placeholder que respawnea lleno).
