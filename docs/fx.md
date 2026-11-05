# FX y feedback de combate

_2026-11-05_

- `scripts/fx.gd` (nodo `fx` en `game.tscn`, grupo `fx`): crea partículas, números de daño y capas de pantalla en código. No hay escenas ni texturas nuevas: el píxel blanco de las partículas se genera con `Image`.
- Partículas de mundo (`CPUParticles2D` de un solo uso): chispas al golpear un enemigo, estallido al morir, polvo al saltar/aterrizar/correr y chispas al recoger monedas, objetos o curarse.
- Números flotantes: `Label` en `CanvasLayer` 8, colocados con `get_canvas_transform()` (tamaño fijo aunque la cámara tenga zoom), suben 18 px y se desvanecen en 0,65 s. Enemigo en blanco cálido, jugador en rojo, moneda `+1` dorada, curación `+N` verde.
- Daño al jugador: `shake()` mueve `Camera2D.offset` con caída durante 0,18 s y `damage_flash()` pone un `ColorRect` rojo (CanvasLayer 9, debajo del HUD) con alfa 0,3 → 0 en 0,32 s.
- HUD: `add_coin()` hace un pop de escala del contador; la barra de vida late en rojo por debajo del 30 %.
- Para enganchar más efectos: `fx.enemy_hit()`, `fx.enemy_death()`, `fx.player_hit()`, `fx.coin_pickup()`, `fx.item_pickup()`, `fx.heal()`, `fx.dust()`, `fx.shake()`. Los consumidores buscan el nodo por el grupo `fx`.
- Polvo: el jugador lo emite en `_feet_offset()` (mitad inferior de su hitbox, 27 px bajo el origen), así que sale a ras de suelo al saltar, aterrizar y correr, con gravedad propia (240) para quedarse abajo.
- Muerte de enemigo: cuatro capas de sangre (chorro oscuro de 32 partículas con gota 2×5 alineada a la velocidad, salpicadura roja, niebla grande y chispas blancas, hasta 300 px/s) más `shake(1.4, 0.12)`. `_burst()` acepta `gravity`, `radius`, `spread` y `align_to_velocity`.
- Moco (`scripts/collectables/moco_emitter.gd`): emisión en caja de 14×48 px que cubre la hitbox del jugador, así gotea de todo el cuerpo en vez de un punto central.
- Partículas de bioma (`scripts/world/biome_particles.gd`): hojas y copos entran/salen con un fundido de 0,4 s y llevan viento lateral; ya no aparecen de golpe al cruzar la frontera.
