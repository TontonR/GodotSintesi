# T-0102 · Mundo del castillo: escena limpia, sin fugas y pisos alineados

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `bug` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-27 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0079 · T-0095 · T-0100 |

## Petición

> He comunicado en reiteradas ocasiones que cuando entras al castillo debe ser en otra
> escena, pero al tepearte con 6 se bugea todo: sales de la estructura y descubres que el
> mundo está abajo congelado. Además, dentro del castillo siguen estando las partículas de
> caminar con el color del bioma. Escena LITERALMENTE VACÍA sin nada más que la estructura.
> Por cierto, los pisos a partir de ahora estarán uno encima del otro, pero de manera
> escalonada: la puerta de salida y la de entrada estarán siempre en el mismo eje X.

## Problemas a arreglar

1. **Fuga al salir**: el mundo aparece "abajo y congelado" al volver del castillo.
2. **Partículas de caminar con el tinte del bioma** dentro del castillo.
3. **Escena limpia**: dentro solo debe estar la estructura (sin parallax, sin mundo).
4. **Pisos alineados**: entrada y salida en la misma X en todas las plantas, apilados y
   escalonados.

## Criterios de aceptación

- [ ] Al salir del castillo vuelves exactamente al sitio y el mundo sigue vivo (se genera,
      se mueve y se puede jugar) sin reiniciar la partida.
- [ ] Dentro no se ve ni el mundo ni sus partículas de bioma; el polvo al caminar usa el
      tono del castillo.
- [ ] La puerta de entrada y la de siguiente planta caen siempre en la misma columna X.
- [ ] `docs/dungeon.md` actualizado.

## Resultado

Pendiente.
