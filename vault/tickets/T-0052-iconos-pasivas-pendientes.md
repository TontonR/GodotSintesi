# T-0052 · Iconos de pasivas pendientes

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `media` |
| Dueño | `opencode-jorge` |
| Sistema | `inventory` |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0051 |

## Problema

Quedan pasivas con iconos provisionales (`iconos/*W.png`) o con sprites
genericos de `item###.png` que no representan el objeto. Ruben pide asignar
imagenes parecidas y no repetir el mismo sprite entre objetos.

## Causa / contexto

- Se eligen sprites de `assets/items/item*.png` por parecido visual:
  colgantes para amuletos, anillo para el anillo, armaduras para armaduras,
  botas para pies ligeros, etc.
- Cada pasiva de la lista recibe un `item###.png` distinto.
- `Focus` no existe en el juego y no se crea (Ruben ya lo aclaro antes).
- `Third-Hit Projectile` no esta en la lista y se queda como esta.
- Se conservan las rutas de los `.tres`; solo cambia el `ext_resource` del icono.

## Plan

1. Asignar un sprite unico a las 34 pasivas de la lista.
2. Actualizar `docs/items.md` con el mapa resumido.
3. Generar `docs/pasivas-antes-despues.png` con objeto, icono viejo e icono nuevo.
4. Verificar que no hay iconos repetidos ni rutas rotas.

## Criterios de aceptación

- [x] Las 34 pasivas tienen un `item###.png` distinto.
- [x] No se repite ningun sprite entre pasivas.
- [x] `Focus` no se ha creado.
- [x] `docs/items.md` y preview actualizados.
- [ ] F5: los iconos se ven en la rejilla de pasivas.

## Resultado

Aplicado en `main` sin commit. Las 34 pasivas usan un `item###.png` distinto:

- Amuletos: Attack `item871`, Critical `item855`, Fury `item869`, Iron Pendant `item890`, Regeneration Talisman `item872`.
- Anillo: Vigor Ring `item892`.
- Armaduras: Light `item226`, Heavy `item259`; Gauntlet `item749`; Light Feet `item730`.
- Lobo: DNA `item735`, Fang `item1185`, Claws `item785`, Pelt `item675`.
- Slime: Mucus Essence `item1122`, Mucus `item1219`, Compact Mucus `item593`.
- Resto: Thorns `item1018`, Guardian's Wrath `item933`, Frog Tongue `item1094`,
  Mace `item918`, Gold Stone `item591`, Iron Heart `item688`, Vampiric Pulse
  `item668`, Burst `item925`, Frog Saliva `item805`, Second Wind `item780`,
  Root Grabbers `item1036`, Skin Tubercles `item910`, Ogre Nail `item778`,
  Vampirism `item1173`, Hunter `item828`, Greed `item762`, Frog Bubble `item804`.

`Focus` sigue sin existir y no se ha creado. `Third-Hit Projectile` no estaba
en la lista y conserva `magicW`. Preview en `docs/pasivas-antes-despues.png`.
F5 pendiente.

Corregido despues en T-0053: Light/Heavy Armor, Greed, Wolf Fang/Claws/Pelt,
Iron Heart, Mucus, Light Feet, `Hunter's Faith` y `Sanguine Ruby`.
