# Bóveda de ideas — diseño de OffBeaten Path

_2026-11-06 · `buffy` · fuente: notas de `humano-ruben` (texto pegado sin formato)_

Este documento reúne **todo el diseño propuesto** en un solo sitio: lo que ya está
hecho, lo que falta y lo que todavía no tiene decisión. No sustituye a `docs/`
(verdad técnica) ni a `vault/tickets/` (trabajo en curso): sirve para decidir **qué
se construye después** y para que otra persona o IA lo retome sin la conversación
original.

## Cómo leerlo

| Estado | Significado |
|---|---|
| `hecho` | Está en `main` y funciona según el código y `docs/`. |
| `parcial` | Existe una pieza, pero no el sistema completo. |
| `idea` | Diseñada y entendible, sin implementar. |
| `por definir` | La nota no alcanza para implementar: falta una decisión de diseño. |
| `por buscar` | No hay ni diseño cerrado ni assets: hay que explorar. |

- Estados comprobados contra el código de `main` el **2026-11-06**. Si este documento
  y el código discrepan, gana el código y se corrige aquí.
- Nombres, cifras y calidades se mantienen como los escribió Ruben. Cuando el balance
  implementado cambia una cifra, se anota en la columna de estado/notas.
- `—` = dato que falta en la nota original.
- La tabla original tenía una columna **`Imagen (ruta)`** que quedó vacía en todas las
  filas. Los objetos implementados usan iconos provisionales de 16×16 en
  `assets/items/iconos/`; el resto no tiene icono asignado.
- El encabezado original puntuaba Personaje, Enemigos, De/buffs y Objetos con un "2"
  sin definir la escala, así que **no** se usa como prioridad.

## 1. Personaje

| Idea | Estado | Dónde / notas |
|---|---|---|
| 3 tajos diferentes | `hecho` | Combo `attack_1`/`attack_2`/`attack_3` con clic izquierdo y ventana de 0,35 s (`scripts/player.gd`). |
| 1 estocada | `hecho`, por confirmar | No hay acción aparte: el 3.er golpe (`attack_3`) lleva una hitbox mucho mayor (`AttackHitbox3`, 71×48 px). Confirmar si "estocada" es ese tercer golpe o falta una tecla propia. |
| Escudo | `hecho` | Guardia con clic derecho o E (coste 15 + 20/s), parry de 0,2 s con enfriamiento y devolución de stamina. Ver `docs/player.md`. |

No hay ataque a distancia ni magia para el jugador en el diseño actual.

## 2. Enemigos

| Enemigo | Zona del diseño | Estado | Notas |
|---|---|---|---|
| Ogro | Bosque | `hecho` | `scenes/enemies/orc.tscn`; en código se llama orco. Melee. |
| Lobo | Bosque | `hecho` | `werewolf.tscn`; merodea, embiste y cada 2 embestidas salta con daño doble. |
| Rana (sapo mutante) | Bosque | `hecho` | `mutant_toad.tscn`; salta y cada 3 aterrizajes lanza 3 proyectiles destructibles. |
| Arquero | Bosque | `hecho` | `archer.tscn`; dispara flechas. **Sin pasivas propias todavía.** |
| Esqueleto | Desierto | `hecho` | `skeleton.tscn`; hoy aparece en Nieve, no en Desierto. |
| Slime | _(no estaba en la lista)_ | `hecho` | `slime.tscn`; añadido con el trabajo del compañero. |
| Momia | Desierto | `por buscar` | Sin escena, script ni assets. |
| Fantasma | Cementerio | `hecho`, aparcado | `ghost.tscn`; se teletransporta y es invulnerable durante el TP. |
| Demonio | Cementerio | `hecho`, aparcado | `demon.tscn`; vuela y escupe fuego. Si le paran el chorro, queda aturdido. |

Notas de verificación:

- **Aparcado no significa desactivado.** `WorldGenerator.DISABLED_ENEMY_SCENES` nombra
  fantasma y demonio, pero la constante **no se usa** y `pradera.tres` /
  `bosque_rojo.tres` todavía los listan. Hay que comprobar en F5 si aparecen y
  arreglarlo antes de dar por cerrada la lista de enemigos activos.
- Todos los enemigos del compañero están escalados ×2; el slime, ×1,2.
- El reparto actual por bioma no coincide con el diseño: Pradera mezcla orco y
  fantasma; Bosque rojo, lobo/sapo/demonio; Nieve, esqueleto/arquero/lobo. El diseño
  pide ogro/lobo/rana en el bosque y deja esqueleto y momia para el desierto.

## 3. Efectos y estados

No existe un sistema común de efectos. Lo único implementado es la nube de veneno de
los túberculos y el aturdimiento del demonio; todo lo demás es diseño y depende de
que se cree ese sistema.

### 3.1 Daño en el tiempo (DOT)

| Efecto | Regla de diseño | Estado | Dudas abiertas |
|---|---|---|---|
| Veneno | DOT puro, sin efecto extra. Si el enemigo muere envenenado, el veneno se propaga a los cercanos. | `parcial` | `poison_cloud.gd` hace 2 de daño cada 0,5 s en 44 px durante 4 s, pero no hay DOT sobre el enemigo ni propagación al morir. Falta radio/duración de la propagación. |
| Quemadura | DOT que se propaga y se acumula. | `idea` | ¿Cuántos stacks? ¿Cómo se refresca? ¿Se propaga al morir o al golpear? |
| Pena | Quemadura especial, un 25 % más fuerte que la base. **No** cuenta para el límite de quemaduras normales. | `idea` | Se activa con más de 3 quemaduras; falta definir si el umbral es ">3" o "≥3". |
| Sangrado | Daño verdadero (ignora defensa) + un porcentaje de la vida actual. | `idea` | ¿Porcentaje por tick, por golpe o al moverse? ¿Cada cuánto? ¿Tope? |
| Alma en pena | Mientras el enemigo tenga veneno, quemadura o similar, recibe +10 % de daño de todas las fuentes. | `idea` | Depende de que exista el sistema de DOT. |

### 3.2 Estados y control

| Efecto | Regla de diseño | Estado | Dudas abiertas |
|---|---|---|---|
| Blind | Los ataques pueden fallar. Si lo recibe el jugador, la pantalla se oscurece un poco. | `idea` | ¿Probabilidad? ¿Solo ataques básicos o también proyectiles? ¿Cuánto oscurece? |
| Electrocutado | Al atacar al primer enemigo, este recibe 2 stacks de "superconductor". Los enemigos muy cercanos que reciben daño de superconductor conducen 1 stack a otro enemigo y se quedan con otro; la cadena no tiene límite. El superconductor hace un 5 % del daño base. | `idea` | ¿Qué aplica el estado? ¿Radio de la cadena? ¿Los stacks suman daño? |
| CC (control) | Empujes y aturdimiento. | `parcial` | Hay `knockback`, `knockup` y el aturdimiento del demonio (5 s o 3 golpes), pero no un estado "aturdido" reutilizable. |
| Inmovilizar | No puedes moverte, pero sí atacar o usar objetos. | `idea` | ¿Aplica a jugador y enemigos? Al inmovilizado, ¿se le puede empujar? |
| Rabia | Más daño, pero con fuego amigo. | `idea` | ¿Es buff del jugador o de un enemigo? ¿El fuego amigo daña a otros enemigos? |
| Inmune | Inmune a los efectos especiales; el daño normal sí entra. | `idea` | ¿Temporal o permanente? ¿A todos los DOT y CC o solo a algunos? |
| Invulnerable | Inmune a todo el daño. | `parcial` | Existen la inmortalidad de debug (KP5) y el TP del fantasma, pero no es un estado de diseño del jugador. |
| Vortex | Atrae a los enemigos y tiene propiedades de knock-up. | `idea` | Radio, duración y si también afecta al jugador. |

Reglas transversales que faltan por decidir: cómo se acumulan y refrescan los
efectos, quién puede aplicarlos (jugador, enemigos u objetos), si hay resistencias e
inmunidades por enemigo, y si los efectos activos se muestran en el HUD.

## 4. Objetos e inventario

### 4.1 Estructura

| Hueco | Hoy | Diseño propuesto |
|---|---|---|
| 1-2 | Skills (sin objetos cableados) | Consumibles (2): curación, buff de ataque temporal, etc. |
| 3-5 | Consumibles | Armas mejorables (3): hacen un efecto base y se mejoran con el tiempo. |
| Fuera de la UI | Pasivas en una rejilla paginada del HUD | Mejoras permanentes de estadísticas, **no visibles en la UI**. |

Decisiones abiertas: qué pasa con las skills, cómo se mejoran las armas (¿monedas,
materiales o uso?) y si las mejoras permanentes se ocultan o se dejan en la rejilla
actual.

### 4.2 Pasivas por enemigo

17 de las 32 ideas de la tabla están implementadas y ya entran en el loot del enemigo
correspondiente mediante `EnemyBase.PRESET_POOLS`. Las calidades implementadas son
`Normal` y `Raro`; `Épico` y `Mítico` del diseño **no existen todavía** en `Items`.

**Ogro** — las cinco implementadas y en su pool de drop:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Tapoarrabos | +10 de estamina base | Normal | `hecho` |
| Maza | +1 de ataque | Normal | `hecho`; implementado con +2 por balance (T-0020). |
| Uña de ogro | +5 de velocidad | Normal | `hecho` (`una_ogro.tres`). |
| Colgante de hierro (forma de corazón) | +25 de vida máxima; no cura | Normal | `hecho` |
| Piedra con oro | +5 % de probabilidad de monedas al matar | Raro | `hecho`; implementado con +10 % (T-0020). |

**Lobo** — las cuatro implementadas y en su pool:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Piel de lobo | +15 de vida base y +5 de estamina base | Normal | `hecho` |
| Colmillo de lobo | +2 de ataque | Normal | `hecho`; implementado con +3 (T-0020). |
| Garras de lobo | Con menos del 30 % de vida, +20 % de ataque | Normal | `hecho` (×1,2 mientras dure). |
| ADN de hombre lobo | De noche, +15 % de ataque y +15 % de velocidad | Raro | `hecho` (×1,15 de noche). |

**Rana** — las cuatro implementadas y en su pool:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Saliva de rana | Al terminar el combo, lanza un proyectil de saliva hacia delante: 25 % del daño base y atraviesa todo | — | `hecho`; en código salta en el 3.er golpe, no al cortar el combo. |
| Lengua de rana | Al golpear a un enemigo, le bajas la velocidad | — | `hecho` (×0,5 durante 3 s). |
| Burbuja de rana | Al terminar el combo, lanza 3 proyectiles de saliva en abanico: 15 % del daño base y atraviesan todo | — | `hecho` |
| Túberculos cutáneos | Al recibir daño, generas una nube de veneno | Raro | `hecho`; nube de 44 px, 2 de daño cada 0,5 s durante 4 s. |

**Slime** — las cuatro implementadas y en su pool:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Moco | Sueltas partículas de moco permanentemente | Normal | `hecho`; cada nivel da +0,5 de defensa plana. |
| Poción de mocos | Aumenta el salto durante 60 s (consumible) y sueltas partículas de moco | Normal | `hecho`; salto ×1,3 y +1 nivel de moco. |
| Moco compacto | Generas moco permanentemente; cuantas más partículas, más defensa | Normal | `hecho` (+1 nivel de moco). |
| Corazón mucosil | Duplicas las partículas de moco | Raro | `hecho`; dobla el nivel de moco. |

**Arquero** — ninguna implementada; `vault/pasivas/arquero.md` sigue con huecos:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Arco básico | Mantienes pulsado el ataque un poco más y lanzas una flecha de 5 de daño; +150 % si mantuviste 2 s antes de soltar | — | `idea`; el arquero enemigo ya dispara, el jugador no tiene arco. |
| Capa de caza | +10 de vida y +5 % de estamina | — | `idea`; "+5 % de estamina" es ambiguo (¿máxima o regeneración?). |
| Maestría a distancia | Al hacer daño a cierta distancia, infliges un 15 % más | — | `idea`; falta definir la distancia mínima. |
| Fuerza del bosque | Cada cierto tiempo invocas una rata invulnerable que daña a los enemigos a su paso y puede bloquear ataques | — | `idea`; faltan intervalo, duración y daño. |

**Esqueleto** — ninguna implementada:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Mangual | +2 de ataque | — | `idea` |
| Venganza | Al quedarte sin estamina, 20 s con 20 % de probabilidad de crítico; se pierde al superar el 75 % de estamina | — | `idea` |
| Cráneo | −20 de vida máxima; al recibir daño reflejas el 5 % de tu vida por tick de daño | — | `idea`; falta aclarar si el 5 % es de vida actual o máxima y qué cuenta como tick. |
| Fragmento | Parece que no hace nada; quizá al obtenerlo 5 veces haga algo | — | `por definir` |

**Fantasma** — ninguna implementada. La nota marca varias como `cons`; se interpreta
como **consumible**, pendiente de confirmar:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Capa de inv | Consumible: esquivas el siguiente ataque recibido dentro de una ventana de 2 s | — | `idea` |
| Teleport | Consumible: te teletransportas hacia delante una cierta distancia, con tiempo de casteo antes | — | `idea`; faltan distancia y casteo. |
| Códice del bromista | Tras cada salto (máximo 3), tu siguiente ataque lanza un proyectil por salto (5 % del ataque) con probabilidad de empujar | — | `idea` |
| Alma en pena | El daño de veneno, quemadura y similares hace que el enemigo reciba un 10 % más de daño de todas las fuentes | — | `idea`; depende del sistema de DOT. |

**Demonio** — ninguna implementada; todas dependen del sistema de quemadura:

| Objeto | Efecto | Calidad | Estado / notas |
|---|---|---|---|
| Cadena perpetua | Consumible: quemas al siguiente enemigo que entre en contacto; si ya está quemado, lo inmovilizas | — | `idea` |
| Cenizas de sufrimiento | Cada ataque aplica una quemadura del 5 % de tu ataque durante 5 s; se acumula hasta 5 quemaduras activas | — | `idea` |
| Pena | Si el enemigo tiene más de 3 quemaduras, sufre Pena: una quemadura un 25 % más fuerte que las base, especial y fuera del conteo normal | — | `idea` |

Fuera de esta tabla siguen existiendo los objetos antiguos del compañero y de T-0017
(amuleto de ataque, armaduras, pociones, `vampirismo`, `espinas`, `codicia`…). Están
en el debug, pero no en el diseño de arriba ni en el loot: decidir si se conservan.

## 5. Tienda y estructuras

**Estado: `idea`.** No hay código de tienda, moneda de tienda ni sistema de
estructuras. Las monedas actuales (`current_coins`) son el único candidato a moneda.

Diseño tal como está escrito:

1. La **primera tienda** aparece a una distancia fija (X por definir).
2. Después, las tiendas aparecen de forma aleatoria con una **distancia mínima**
   respecto a la anterior.
3. Como máximo hay **una tienda por zona**.
4. Una tienda por zona **no está asegurada**; la excepción sería la zona siguiente.
   La frase original ("no es asegurado a menos que sea a la siguiente zona") es
   ambigua: falta aclarar si la tienda de la zona siguiente sí está garantizada.
5. La tienda es una **zona segura**: los enemigos se quedan parados en su animación
   actual, sin atacar.
6. Surtido: probabilidad fija de tener **3 objetos**, con un **máximo de 5**.
7. "Solo uno puede ser de categoría: común, raro, épico o mítico" admite dos lecturas:
   un objeto de cada rareza, o un único objeto de rareza alta. **Por definir.**

Faltan además: precios, si se puede comprar varias veces, qué pasa al salir de la
zona segura y si hay más estructuras aparte de la tienda (la nota solo dice
"¿Estructuras?").

## 6. Biomas

| Bioma | Rol | Enemigos del diseño | Gimmick | Estado |
|---|---|---|---|---|
| Bosque (Pradera en código) | Zona inicial | Ogro, hombre lobo, sapo mutante | Nada especial | `hecho` como bioma; la composición actual (orco + fantasma) no coincide. |
| Bosque rojo | Inicial-medio | Ogro, hombre lobo, sapo mutante | Nada especial; es una variante de color con relieve más marcado | `hecho`; hoy tiene lobo, sapo y demonio. |
| Desierto | Medio | Esqueletos y momia, con efectos de fuego más probables | Arenas movedizas, filtro de desierto, idea de deshidratación que se cura rompiendo cactus | `idea`; no existe el bioma, ni la momia, ni el sistema de fuego. |
| Zona nevada | — | Enemigos con efectos de frío más probables | Hielo resbaladizo, nieve constante, idea de congelación que se evita con antorchas | `parcial`; el bioma y los copos existen, pero no el hielo, el frío ni las antorchas. |
| Cementerio | — | Mayoría de fantasmas, teletransporte y quizá más de una vida por enemigo; muchos DOT | Sin definir | `idea`; no existe el bioma. Fantasma y demonio están aparcados. |

Notas:

- La nota del bioma nevado dice "objetos con elemento fuego más probable", pero por
  contexto debería ser **frío**. Confirmar.
- El desierto y el cementerio no existen como recursos `Biome`; el generador solo
  tiene `pradera.tres`, `bosque_rojo.tres` y `nieve.tres`.
- "Bosque" y "Bosque rojo" figuran los dos como zona inicial. El reparto de pesos
  actual es 0,55 / 0,3 / 0,2.

## 7. Decisiones pendientes

Sistemas:

1. ¿Un único sistema de efectos para jugador y enemigos, o los efectos solo los
   aplican los enemigos al jugador?
2. ¿Cómo se acumulan y refrescan los stacks? ¿Hay límite por efecto?
3. ¿Los efectos activos se muestran en el HUD con icono y contador?
4. ¿"Rabia", "Vortex", "Inmune" e "Invulnerable" son estados del jugador, de los
   enemigos o efectos de objetos?
5. ¿BLIND afecta solo a ataques básicos o también a proyectiles?
6. Superconductor: ¿qué lo aplica, cuál es el radio de la cadena y cuánto suma cada
   stack?
7. Sangrado: ¿porcentaje de vida actual por tick? ¿Cada cuánto? ¿Ignora defensa?
8. ¿Inmune e invulnerable son temporales? ¿Qué fuentes los otorgan?

Contenido:

9. ¿La momia es el enemigo principal del desierto? ¿Qué mecánica la distingue?
10. ¿Se recuperan fantasma y demonio para el cementerio? ¿Se arregla antes la
    constante `DISABLED_ENEMY_SCENES`, que hoy no se usa?
11. ¿El cementerio necesita enemigos con "más de una vida"? ¿Cómo se representa?
12. ¿El slime entra en la lista oficial de enemigos?
13. ¿Se implementan las cuatro pasivas del arquero tal cual? Falta la calidad de
    todas y el efecto exacto de dos.

Inventario y tienda:

14. ¿Se cambia el inventario de 5 huecos (2 skills + 3 consumibles) por 2
    consumibles + 3 armas mejorables?
15. ¿Qué son las "armas mejorables" y con qué se mejoran?
16. ¿Las mejoras permanentes se ocultan de la UI o se quedan en la rejilla actual?
17. Tienda: ¿qué moneda usa, qué precios tiene y se puede comprar más de una vez?
18. Tienda: ¿"una por zona, no asegurada salvo la siguiente" significa que la
    primera es fija y luego hay como máximo una por zona?
19. Tienda: ¿el surtido es un objeto de cada rareza o un único objeto de rareza alta?
20. ¿Hay más estructuras además de la tienda?

Mundo:

21. ¿Hidratación, calor y frío son barras nuevas o modificadores de stamina?
22. ¿Arenas movedizas e hielo resbaladizo son tiles con física o hazards con daño?
23. ¿El "filtro México" del desierto es post-proceso de pantalla, tinte o assets?

## 8. Trazabilidad

| Dónde | Qué aporta |
|---|---|
| `docs/player.md` | Combo, guardia, parry y estadísticas implementadas. |
| `docs/enemies.md` | Enemigos activos, IA por tipo y estado de los voladores. |
| `docs/items.md` | Inventario, pasivas implementadas y reglas de drop. |
| `docs/world.md` | Biomas, generación y partículas de ambiente. |
| `docs/fx.md` | Efectos visuales ya existentes (chispas, sangre, parry, daño). |
| `vault/pasivas/` | Tabla por enemigo del loot implementado; `arquero.md` sigue vacío. |
| `vault/tickets/` | T-0001 (enemigos del compañero), T-0007 (pulido), T-0008 (biomas), T-0019/T-0020 (loot y balance), T-0031/T-0032 (stats). |

Este documento no abre tickets: cada idea que se apruebe debe pasar a
`vault/roadmap.md` con su ticket antes de tocar código.
