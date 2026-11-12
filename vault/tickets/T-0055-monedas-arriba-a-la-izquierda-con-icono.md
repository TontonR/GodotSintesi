# T-0055 · Monedas arriba a la izquierda con icono

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `ui` |
| Prioridad | `baja` |
| Dueño | `buffy` |
| Sistema | ui |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0032, T-0054 |

## Petición

`humano-ruben`: el contador de monedas aparece debajo de las stats. Quiere el número
**arriba a la izquierda**, junto a un **icono de moneda**.

## Causa

`UILayer/coins` tenía `anchors_preset = 15` (pantalla completa) con el texto centrado: en
768×432 caía en (10, 63), pero en un viewport mayor (pantalla completa adaptativa) la Y
baja con la pantalla y el número acaba sobre el panel de stats, que sí está anclado
arriba a la izquierda.

## Plan

1. `UILayer/coins` a rect fijo arriba a la izquierda: (26, 26)–(120, 42), alineado a la
   izquierda, 12 px.
2. `UILayer/coin_icon`: `TextureRect` 16×16 en (6, 26) con el primer frame de
   `assets/coins/MonedaD.png` como `AtlasTexture`.
3. Mantener el nombre y la ruta `UILayer/coins` (`player.gd::_ensure_coins_ui()` lo busca
   así) y alinear el fallback que crea el código.
4. Documentar en `docs/ui.md`.

## Criterios de aceptación

- [x] Icono y número en la esquina superior izquierda, sin tapar la barra de consumibles
      (y 4..22) ni el panel de stats (y 82).
- [x] El contador no se mueve al cambiar el tamaño del viewport.
- [x] El pop al recoger una moneda sigue funcionando.
- [ ] F5 en editor.

## Resultado

`scenes/game.tscn`: `UILayer/coins` pasa de `anchors_preset = 15` con texto centrado a un
rect fijo (26, 26)–(120, 42), alineado a la izquierda y 12 px; al lado se añade
`UILayer/coin_icon`, un `TextureRect` de 16×16 en (6, 26) con un `AtlasTexture` del primer
frame de `assets/coins/MonedaD.png`. Se mantiene el nombre y la ruta `UILayer/coins`
porque `player.gd::_ensure_coins_ui()` lo busca así, y el fallback que crea el código usa
el mismo rect.

Comprobado con script headless sobre `game.tscn` en dos tamaños de viewport: a 768×432 y
a 960×540 el label sigue en (26, 26) con tamaño 94×17 y el icono en (6, 26) con 16×16;
consumibles en (4, 4)–(108, 22) y stats en (5, 82) no se tocan. Tras `add_coin(7)` el
texto pasa a "7" y el tween de pop desplaza el label (pivote) sin cambiar el sitio final.
F5 pendiente para verlo.
