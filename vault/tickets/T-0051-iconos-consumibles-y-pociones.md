# T-0051 · Iconos de consumibles y rework de pociones

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `media` |
| Dueño | `opencode-jorge` |
| Sistema | `inventory` |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0038, T-0050 |

## Problema

Los iconos actuales de los consumibles son provisionales y no coinciden con
los sprites elegidos. Además, las pociones no tienen un sistema claro de
tiers: hay valores de 15/30/60/100 y 40/70 sin norma comun.

## Causa / contexto

- Se aplica el mapa de sprites confirmado por el usuario.
- Las pociones de vida y estamina pasan a tres tiers: normal (20), greater
  (50) y perfect (100).
- Los `.tres` conservan su ruta para no romper saves; cambian `item_name`,
  `description`, `heal_amount`/`stamina_amount`, `icon` y `id`.
- Los iconos de pasivas no se tocan: aun no hay PNG asignado para ellas.
- `Vital Essence` pasa a llamarse `Vigorizing Pie`.
- `Mucus Heart` (`corazon_mucosil`) pasa a llamarse `Mucus Essence`; su icono
  no cambia.

## Plan

1. Actualizar los 9 `.tres` de consumibles con nombre, efecto e icono.
2. Renombrar `esencia_vital` a `Vigorizing Pie` y `corazon_mucosil` a
   `Mucus Essence`.
3. Actualizar la tabla de consumibles de `docs/items.md` y el conteo.
4. Generar `docs/pociones-antes-despues.png` con objeto, sprite viejo, sprite
   nuevo y efecto.
5. Verificar en F5 que las pociones curan/restauran 20/50/100 y que los
   iconos se ven en el HUD.

## Criterios de aceptación

- [x] Las 6 pociones de vida/estamina usan 20/50/100.
- [x] Los 9 consumibles tienen el icono confirmado.
- [x] `Vigorizing Pie` y `Mucus Essence` se muestran con esos nombres.
- [x] Las pasivas conservan sus iconos actuales.
- [x] `docs/items.md` actualizado.
- [x] PNG de antes/despues generado y revisado.
- [ ] F5: curar/restaurar 20/50/100 y ver los iconos en el HUD.

## Resultado

Aplicado en `main` sin commit:

- `pocion_cura` -> Healing Potion, +20, `potion13`.
- `pocion_cura_menor` -> Greater Healing Potion, +50, `potion129`.
- `elixir_vida` -> Perfect Healing Potion, +100, `potion158`.
- `pocion_stamina` -> Stamina Potion, +20, `potion108`.
- `pocion_mayor` -> Greater Stamina Potion, +50, `potion137`.
- `pocion_stamina_mayor` -> Perfect Stamina Potion, +100, `potion166`.
- `bebida_tonificante` -> Tonic Drink, `potion219`.
- `esencia_vital` -> Vigorizing Pie, `item410`.
- `pocion_mocos` -> Mucus Potion, `Icon19`.
- `corazon_mucosil` -> `item_name` = Mucus Essence; icono sin cambios.

Las rutas de los `.tres` no cambian. `Icon19.png` todavia no tiene `.import`:
Godot lo importara al abrir el editor. Preview en
`docs/pociones-antes-despues.png`. F5 pendiente.
