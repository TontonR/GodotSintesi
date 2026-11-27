# T-0078 · Tienda: puesto de mercader, stock y precios

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world / ui |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0074 · T-0077 · T-0085 |

## Problema

La tienda estaba `bloqueado` en el roadmap desde el 2026-11-18 esperando decisiones
(`planning-estructuras.md` § Decisiones pendientes): moneda, precios, surtido, recompra y
zona segura. No existía ni estructura, ni UI, ni forma de gastar monedas.

## Causa / contexto

Las monedas ya existen (`Player.current_coins`, `add_coin()`, `spend_coins()`), el inventario
tiene 3 huecos (`Inventory.add_item()` devuelve `false` si están llenos) y los 12 consumibles
son `.tres` con `heal_amount`/`stamina_amount`. Faltaba decidir y montar el resto.

Decisiones tomadas (el recorte que ya preveía el planning para el 11 dic):

- Moneda: `current_coins`. Sin moneda nueva.
- Surtido: **3 objetos garantizados, distintos**, del catálogo de consumibles.
- Precio: derivado de las stats, no una tabla (`max(5, round((heal+stamina)/4))`; efectos
  especiales sin números, 20).
- Sin recompra: lo comprado queda `sold` en ese puesto.
- Zona segura: **pendiente**, hoy los enemigos siguen campando.

## Plan

1. Arte: `assets/map/structures/merchant_stall.png`, 96×96 con alfa, generado y limpiado
   (clave de magenta, recorte, downscale y cuantización a 26 colores).
2. `scenes/shop/merchant.tscn` + `scripts/world/merchant.gd` (`Merchant`): grupo `merchant`,
   stock por hash de posición, prompt `F: shop` a 56 px, abre la ventana.
3. `resources/world/structures/shop_test.tres`: `scene` + `pixel_size` 96 + `size_tiles` 6 +
   `flatten_ground` + 4 px de hundido.
4. Alta en `WorldGenerator.structures` y en `structure_kinds`/`structure_chances` de
   `pradera.tres` y `bosque_rojo.tres` (0.2).
5. `scripts/ui/shop_screen.gd` (`ShopScreen`): panel a código, pausa del árbol, teclado y
   ratón, chequeo monedas → hueco → cobro → `add_item()`.

## Criterios de aceptación

- [ ] En F5 aparece un puesto cada ~5 chunks en prado y bosque rojo, apoyado en el suelo.
- [ ] `F: shop` cerca del puesto y la ventana se abre pausando el juego.
- [ ] Comprar con monedas suficientes y hueco libre mete el objeto y descuenta el precio.
- [ ] Sin monedas o sin hueco avisa y no cobra.
- [ ] El objeto comprado queda en `sold` y no se puede repetir.
- [x] `docs/shop.md` creado y enlazado en el índice de `AGENTS.md`; `docs/world.md` al día.
- [x] Entrada en `changelog.md`, `estado.md`, `roadmap.md` y `bitácora.md`.

## Resultado

Hecho el 2026-11-27 por `buffy` en `feat/estructuras-detras-castillo-grande`. Puesto de
mercader con sprite nuevo generado a 96 px, stock determinista de 3 consumibles, precios
derivados de las stats y ventana de compra a código que pausa el juego y cobra con
`spend_coins()`. **F5 pendiente**: ni el sprite en el mundo, ni la ventana, ni la compra se
han visto en el editor. Fuera de alcance: zona segura, persistencia del stock entre recargas
del chunk, stock por bioma y objetos exclusivos (T-0083/T-0084).
