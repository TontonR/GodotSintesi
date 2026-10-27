# Demonio volador

Fecha: 2026-10-22

## Diseño

Enemigo volador de una zona. Ronda al jugador por el aire y cada 3 s se detiene
encima de él para lanzar un chorro de fuego desde la boca hasta el suelo.

- Vida: **180** (9 golpes de 20). Sin defensa ni daño por contacto.
- Escala visual: **0.6** (más grande que el resto).
- Vuela a **80 px** sobre el punto de spawn y se mece horizontalmente alrededor
  del jugador. No colisiona físicamente: el cuerpo usa una hurtbox `Area2D`
  en la capa 4 para que la espada le acierte igualmente.
- **Alcance**: la hurtbox es 34×60 centrada en `y + 10`, así que cubre también
  la parte baja del cuerpo. Volando sigue fuera del alcance de la espada
  (borde inferior a 40 px del suelo), pero **al caer aturdido llega hasta el
  suelo** y se le puede golpear. Capas correctas: hurtbox 4 / ataque del
  jugador 12.
- Ciclo: `FLY` 3 s → `BREATH` (aviso 0.75 s + 3 s de fuego) → `FLY`.
- Durante el aviso se coloca para que la boca quede sobre el jugador.

## Fuego

- Escena `demon_fire.tscn`: `Area2D` con forma que va de la boca al suelo.
- Un `RayCast2D` busca el suelo (capa 1) **en la dirección del chorro** y ajusta
  su longitud (mín. 24, máx. `max_length` 220).
- El chorro cae **inclinado hacia delante** (`lean_degrees` 12°) respecto a la
  vertical, en el sentido al que mira el demonio, como en el arte del ataque.
  La forma de daño (ancho 48) y el rayo se rotan con esa inclinación; el ancho
  está calculado para que el jugador bajo la boca siga dentro.
- Arte `breath.png` (**llama azul**): encendido → loop → apagado, con un
  crecimiento visual rápido al encenderse (`grow_time` 0,12 s).
- Daño: **5 cada 0.5 s** mientras el jugador está dentro.
- Si el jugador bloquea con el escudo (`is_guarding()`) y el fuego viene de
  frente, el chorro se apaga y el demonio entra en aturdimiento.

## Aturdimiento

- Dura **5 s** o hasta recibir **3 golpes**, lo que ocurra antes.
- Se detiene, deja de atacar, baja 40 px y se tiñe de azul claro.
- Al salir vuelve a volar 3 s antes del siguiente ataque.

## Archivos

- `scripts/enemies/demon.gd`
- `scenes/enemies/demon.tscn`
- `scripts/enemies/demon_fire.gd`
- `scenes/enemies/demon_fire.tscn`
- Registrado en `scripts/world_generator.gd` con 1 por zona.
