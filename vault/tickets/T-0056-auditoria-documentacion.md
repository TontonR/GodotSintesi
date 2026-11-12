# T-0056 — Auditoría de documentación

- **Estado:** `revision`
- **Dueño:** `buffy`
- **Fecha:** 2026-11-12
- **Sistema:** docs / vault
- **Ficheros:** `docs/*.md`, `README.md`, `AGENTS.md`, `vault/documentacion.md`,
  `vault/README.md`, `vault/pasivas/*.md`, `vault/roadmap.md`, `vault/changelog.md`,
  `vault/estado.md`, `vault/bitacora.md`

## Contexto

`docs/` tenía 7 ficheros, pero varios habían quedado desfasados y faltaban referencias de
sistemas completos. Ruben pidió actualizar toda la documentación y crear en el vault lo que
faltara (enemigos, drops, biomas, items…).

## Alcance

1. Verificar contra el código los datos de cada doc y corregir lo falso.
2. Crear los docs que faltaban: biomas, loot y pasivas.
3. Reescribir el catálogo de enemigos y el de items con los valores reales.
4. Corregir `README.md` (controles y botones del menú).
5. Crear `vault/documentacion.md` con el mapa, la auditoría y los huecos reales.

## Criterios

- [x] Ningún doc afirma algo que el código contradiga (ventana, biomas, sets de enemigos,
      stats, probabilidades, controles, iconos).
- [x] Cada sistema jugable tiene doc canónico en `docs/` o una fila en el mapa del vault.
- [x] El índice de `AGENTS.md` incluye los tres docs nuevos.
- [x] Las probabilidades del vault coinciden con los `drop_chance` de las escenas.
- [x] Los huecos (audio, muerte, skills, progresión, jefe) están listados, no inventados.

## Resultado

- **Reescritos**: `docs/enemies.md` (base + catálogo de 8 enemigos con stats ×1.35/×1.25,
  comportamiento y spawn; fantasma y demonio marcados como no spawneables) y
  `docs/items.md` (44 `.tres` con icono, 9 consumibles reales, 3 slots, debug de 36 rutas).
- **Nuevos**: `docs/biomes.md` (3 biomas con colores/ambiente/pesos/enemigos, runs de
  1024–4096 tiles, transición de 256, tintes y checklist), `docs/loot.md` (moneda 45 % +
  luck + pasivas; objeto en tirada única: orco 42 %, lobo/rana/slime 32 %; física de
  pickups y persistencia) y `docs/passives.md` (`PlayerPassives`, 7 hooks, 35 pasivas).
- **Corregidos**: `docs/world.md` (ventana 1536×864, sets de enemigos por bioma, caída
  260 px a 620 px/s, 56 hojas/440 copos), `docs/ui.md` (texto real de `DebugHint`),
  `docs/player.md` (panel de stats en 5, 82), `docs/historial.md` (3 bugs nuevos) y
  `README.md` (New Game, consumibles 1-3, sin KP3, lista de docs).
- **Vault**: `vault/documentacion.md` (mapa + auditoría + huecos), fila en `vault/README.md`,
  `vault/pasivas/README.md` con totales por enemigo, correcciones Maza +2 / Colmillo +3 /
  Piedra de oro +10 % y probabilidades en cada `.md`.
- **Comprobado** con `grep`/`sed` sobre escenas, `.tres` y scripts (stats de enemigos,
  `item_drops`, `drop_chance`, colores de bioma, exports de `fall_intro`/`day_night`,
  física de pickups) y `wc -l` para el tamaño de los docs. No requiere F5: no se tocó código.
