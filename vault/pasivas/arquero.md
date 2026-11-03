# Pasivas del Arquero

_2026-11-03 · tabla de Jorge · **sin contenido todavía**_

La tabla traía cuatro filas con el nombre del enemigo (`Arquero`) y todas las demás
columnas vacías: ni nombre de pasiva, ni efecto, ni calidad.

## Estado

- El arquero **sí** está integrado (`scenes/enemies/archer.tscn` en `enemy_scenes`):
  vive a distancia y dispara flechas (`archer_projectile.gd`).
- No tiene `loot_preset` propio: al morir usa el pool genérico de
  `EnemyBase.DROP_ITEMS` (pociones y pasivas antiguas), no una tabla del arquero.
- Cuando Jorge mande los cuatro objetos, crear sus `.tres` + scripts, añadir el preset
  `"Arquero"` a `EnemyBase.PRESET_POOLS` y `loot_preset = "Arquero"` en
  `scenes/enemies/archer.tscn`.

## Huecos a rellenar

| Nombre | Qué hace | Calidad |
|---|---|---|
| _(vacío)_ | _(vacío)_ | _(vacío)_ |
| _(vacío)_ | _(vacío)_ | _(vacío)_ |
| _(vacío)_ | _(vacío)_ | _(vacío)_ |
| _(vacío)_ | _(vacío)_ | _(vacío)_ |
