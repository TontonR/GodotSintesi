# T-0053 · Ajustes de iconos de pasivas

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `media` |
| Dueño | `opencode-jorge` |
| Sistema | `inventory` |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0052 |

## Problema

Ruben corrige varias elecciones de T-0052 y pide cambios concretos de sprite y
un renombrado.

## Plan

- Light Armor -> `item221`; Heavy Armor conserva el icono anterior de Light
  Armor (`item226`).
- Hunter pasa a llamarse `Hunter's Faith`.
- Greed -> `item169`.
- Wolf Fang -> `assets/items/iconos/Icon34.png`.
- Iron Heart -> `item199`.
- Wolf Claws -> `assets/items/Icon12.png`.
- Mucus -> `item310`.
- Wolf Pelt -> `item202`.
- Light Feet -> `item276`.
- Vampiric Pulse -> `Sanguine Ruby`, con `Icon29` copiado como
  `assets/items/sanguine_ruby.png`.

## Criterios de aceptación

- [x] Los 10 iconos y el nombre nuevo estan aplicados.
- [x] No se repite ningun icono entre pasivas.
- [x] `docs/items.md` y preview actualizados.
- [ ] F5: se ven los iconos nuevos.

## Resultado

Aplicado en `main` sin commit:

- Light Armor `item221`; Heavy Armor pasa a `item226` (el icono anterior de Light Armor).
- Hunter -> `Hunter's Faith`; conserva `item828`.
- Greed `item169`; Wolf Fang `Icon34`; Iron Heart `item199`;
  Wolf Claws `Icon12`; Mucus `item310`; Wolf Pelt `item202`;
  Light Feet `item276`.
- Vampiric Pulse -> `Sanguine Ruby`, con `Icon29` copiado a
  `assets/items/sanguine_ruby.png`.

`Icon12`, `Icon34` y `sanguine_ruby.png` aun no tienen `.import`; Godot los
importara al abrir el editor. Preview en `docs/pasivas-cambios-2026-11-13.png`.
F5 pendiente.
