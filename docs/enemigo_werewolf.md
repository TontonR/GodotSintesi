# Enemigo: Lobo (`werewolf`)

Última actualización: 2026-10-23

## Dónde está

- Escena: `scenes/enemies/werewolf.tscn`
- Script: `scripts/enemies/werewolf.gd` (`class_name werewolf`, extiende `EnemyBase`)
- Sprites: `assets/enemies/werewolf/` (idle 5 frames, run 6, jump 2, fall 2; miran a la derecha)
- Tamaño: sprite y cuerpo a escala 0.6 (un poco más grandes que el jugador);
  `detection_range` no se escala, pero `attack_range` sí se ciñó al cuerpo (radio 22).

## Comportamiento

Máquina de estados propia; no usa el flujo de ataque de `EnemyBase`
(no hay animación `attack` para este enemigo).

1. **Merodeo**: pasea con `run` entre puntos aleatorios dentro de *su* zona
   del `world_generator` (misma fórmula de índice de zona), con pausas en
   `idle`. Si no encuentra el generador (grupo `world_generator`), merodea en
   un radio fijo alrededor del spawn.
2. **Daño por contacto**: `attack_range` se comprueba **cada frame físico**
   (`get_overlapping_bodies`), sin depender de los frames del sprite; cada
   golpe respeta `hit_cooldown`. El hitbox es un círculo de radio **22 px**
   centrado en el cuerpo (≈1,2 × su media diagonal): pegado a la silueta.
3. **Embestida**: al entrar el jugador en `detection_range`, aviso quieto
   (`charge_windup`) mirando al jugador y embestida en **línea recta** a
   `charge_speed` (220 px/s) hasta recorrer el diámetro del área de detección.
   No se gira a media carga: al terminar la línea se decide:
   - Si golpeó y el jugador sigue en visión → **un único giro** y pasada de
     vuelta de medio diámetro (sin segundo knockup).
   - Si no golpeó → recuperación **corriendo hacia el jugador** (re-traza
     ruta) y después nueva embestida re-apuntada.
   El primer golpe de cada embestida recibe **knockup** (`knockup_force` 280,
   sin empuje horizontal, bloqueo de control 0,12 s); los siguientes contactos
   solo dañan. El jugador lo implementa con `player.apply_knockup()`.
4. **Ciclo 2 + 1**: 1ª y 2ª vuelta = embestida; la 3ª = salto (contador
   persistente aunque se pierda de vista; se reinicia al aterrizar).
5. **Salto**: arco hacia el x del jugador (`jump_force`, tope
   `jump_speed_max`), animaciones `jump`/`fall`; al aterrizar golpe en área
   de radio `impact_radius` con `base_attack × jump_damage_multiplier`.

## Integración

- `world_generator.gd` lo incluye en `enemy_scenes` (1 por zona) y se
  registra en el grupo `world_generator` para que el lobo lea la zona.
- Capas: cuerpo 4/3, `attack_range` 16/2, `detection_range` 0/2.
- **Sin colisión física con el jugador**: al detectarlo, el lobo añade una
  excepción de colisión mutua (`add_collision_exception_with` en ambos
  sentidos) para no arrastrarlo. Las `Area2D` de detección y ataque no se
  ven afectadas.
- Tras cada embestida/salto hay una pausa (`attack_recovery`) antes de decidir
  la siguiente vuelta; si el jugador ya no está detectado, vuelve a merodear.

## Pendiente / ajustes

- Números de stats son provisionales (60 HP, 10 ataque): todos exportados en
  el inspector.
- Sin animación de muerte propia (usa la de `EnemyBase`).
