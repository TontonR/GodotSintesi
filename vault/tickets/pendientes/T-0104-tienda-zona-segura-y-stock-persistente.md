# T-0104 · Tienda: zona segura y stock persistente

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `sin asignar` |
| Sistema | world / ui |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0078 · T-0080 |

## Problema

T-0078 dejó la tienda jugable, pero quedan dos huecos que se notan en F5:

1. **No es zona segura**: los enemigos siguen patrullando y pueden golpear al jugador
   mientras compra. Peor: la ventana pausa el árbol, así que el golpe queda congelado hasta
   cerrar y se come al volver al juego.
2. **El stock no se guarda**: `Merchant.sold` vive en el nodo del puesto y el puesto vive
   dentro del chunk. Al descargarlo (`WorldGenerator.unload_chunks()`, por ejemplo al entrar
   al castillo) y volver, la tienda reaparece con los tres objetos a la venta. Se puede
   comprar sin límite paseando de un lado a otro.

## Causa / contexto

- `Merchant._ready()` solo se da de alta en el grupo `merchant`; no hay radio de calma en
  `EnemyBase`, que ataca por área y máscara de colisión.
- El guardado ya persiste ids por chunk (`[world] defeated/collected/broken` en
  `save_game.gd` → `WorldGenerator.save_persistent_state()`), y el puesto ya lleva su
  `spawn_id` en `set_meta("spawn_id", "s:x:y:index")`: la vía natural es una lista
  `[world] sold` con `spawn_id|recurso`, igual que los bloques rotos.
- El stock se elige con `hash("merchant:x:y")`, así que reconstruirlo no depende del RNG del
  chunk: basta con filtrar los vendidos al volver.

## Plan

1. Zona segura: que `EnemyBase` (o un nodo de zona) mire la distancia al `merchant` más
   cercano y frene ataque y persecución dentro de un radio (96 px), sin tocar
   `WorldStructure`.
2. Persistencia: `Merchant` lee su `spawn_id` de la meta, consulta `sold` al construir el
   stock y lo declara al guardar; `WorldGenerator` lo serializa junto a
   `defeated/collected/broken` y lo restaura antes de instanciar los chunks.
3. Compatibilidad: partidas sin `[world] sold` cargan como siempre.

## Criterios de aceptación

- [ ] En F5 ningún enemigo ataca ni persigue dentro del radio de la tienda, y retoman fuera.
- [ ] Comprar, entrar al castillo, volver y guardar/cargar mantiene el objeto como `sold`.
- [ ] Una partida vieja sin la sección nueva carga sin errores.
- [ ] `docs/shop.md` actualizado.
- [ ] Entrada en `changelog.md` y `estado.md` al cerrar.

## Resultado

Hecho el 2026-11-27 por `buffy`.

- **Zona segura:** `EnemyBase._in_shop_zone()` (grupo `merchant`, 96 px) corta la IA antes del
  ataque: el enemigo frena y se queda quieto, sin dañar mientras el jugador compra.
- **Stock persistido:** `Merchant.mark_sold()` avisa al generador
  (`mark_item_sold(spawn_id, resource_path)`), que lo guarda en `_sold_spawns` y en
  `save_persistent_state()["sold"]`; al reaparecer el chunk, `restore_sold()` vuelve a marcar
  lo vendido. Sin recompra tras recargar ni al volver a pasar.
- Comprobado por lectura. **F5 pendiente.**

