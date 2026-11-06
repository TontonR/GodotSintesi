# OffBeaten Path — Entrega 2

_Estat del projecte, canvis des de la primera entrega i pròxims objectius · 6 de novembre de 2026_

## Resum

Des de la primera entrega, el joc ha passat de «un jugador, un fons amb parallax i un orco» a un prototip jugable: combat amb combo, guardia i parry, huit tipus d'enemic, un sistema d'objectes amb passives que canvien les estadístiques, món procedural infinit amb tres biomes, cicle de dia i nit i una capa d'efectes visuals que fa llegible tot el que passa a pantalla.

No obstant això, **no hi ha hagut tant de progrés visible com es podria esperar** perquè hem fet una reestructuració del flux de treball. Hem canviat les eines d'IA, hem creat un canal de comunicació entre elles i hem documentat cada sistema abans de continuar afegint contingut. És temps que no es veu en captures, però que ara ens permet avançar més ràpid i sense repetir feina.

Els **tres objectius immediats** són: posar textures de veritat als objectes, començar la generació d'estructures amb els seus boses, i implementar els objectes i mecàniques que ja estan dissenyats però encara no existeixen.

---

## 1. Recordatori: què és OffBeaten Path

OffBeaten Path és un joc 2D roguelike incremental amb tocs de plataformes i estètica pixel art. El jugador avança sempre cap a la dreta, derrota enemics, aconsegueix objectes amb efectes únics que el fan més fort, recull monedes i s'enfronta a zones cada vegada més difícils.

No hi ha història ni final: el món és infinit i es genera a mesura que avancem. La gràcia és la combinació d'exploració, combat i construcció de personatge a partir del que et van deixant els enemics.

---

## 2. Eines: què ha canviat i per què

### 2.1 Godot i els agents d'IA

El joc es fa amb **Godot**. Des de la primera entrega, la IA no s'utilitza només per generar codi i enganxar-lo, sinó com un agent que treballa **dins del projecte**: llig els fitxers, proposa canvis, els aplica, executa comprovacions i deixa constància del que ha fet.

Durant este temps han canviat les eines de les dos persones de l'equip:

- **Jorge** ha passat de **Gemini Chat** a **OpenCode**. Amb un xat només es pot copiar i enganxar codi; amb OpenCode l'agent treballa directament sobre el repositori, veu l'estructura del projecte i pot executar ordres.
- **Rubén** ha passat d'**OpenCode** a **FreeBuff**. OpenCode funcionava bé, però la connexió que ens dona el centre es gastava enseguida i el treball s'aturava a mitat de la sessió.

### 2.2 Què és FreeBuff

**FreeBuff és un agent de programació amb IA gratuït.** S'hi treballa per conversa, igual que amb OpenCode: li expliques què vols canviar, ell llig els fitxers del projecte, proposa una solució, l'aplica i comprova que el joc continua funcionant.

No és res estrany: és una eina de desenvolupament més, de la mateixa família que OpenCode, Cursor o GitHub Copilot. L'única diferència important és que **no cal pagar una clau d'API ni consumir la connexió del centre**, i que tot el que fa queda escrit en fitxers del propi projecte.

Tampoc no és un bot que juga sol ni un programa que toca el joc a l'atzar. És un assistent de codi: proposa, aplica i documenta, però **les decisions de disseny les continua prenent l'equip**. Si una idea no està clara, s'apunta com a dubte en compte d'inventar-se-la.

### 2.3 Per què este canvi era necessari

Amb dos agents treballant en el mateix repositori hi havia un risc real de xafar-se: un canvia el generador de món, l'altre l'inventari, i al final cap dels dos sap què ha fet l'altre. La solució no ha sigut treballar menys, sinó **treballar amb un mètode**: la bóveda (el *vault*) que expliquem ara.

---

## 3. El vault: com es comuniquen les dos IAs

El vault és una carpeta dins del repositori on els dos agents i la persona que decidiu escriviu el mateix. No és documentació per a la galeria: **és el canal de treball**. Cada fitxer té una funció i unes regles.

| Fitxer | Per a què servix |
|---|---|
| `AGENTS.md` | Les regles que llegixen els dos agents: idioma, convencions, capes del joc, què no tocar. És l'únic fitxer que sempre tenen en context. |
| `docs/` | La veritat tècnica de cada sistema: jugador, enemics, objectes, món, interfície i efectes. |
| `vault/estado.md` | El panell d'«ara mateix»: en quina fase està el projecte, qui toca quins fitxers i què està bloquejat. |
| `vault/roadmap.md` | El que queda per fer, prioritzat, amb enllaç al ticket corresponent. |
| `vault/tickets/` | Un fitxer per treball. Cadascun té objectiu, fitxers afectats, estat i resultat. |
| `vault/changelog.md` | L'historial del que ja està fet. Només s'afig, no es reescriu. |
| `vault/bitacora.md` | El diari de sessions: qui reclama què, quins acords es prenen i què s'ha descobert. |
| `vault/pasivas/` | Una taula per enemic amb les passives que pot deixar anar. |
| `vault/ideas.md` | El catàleg de disseny: què està fet, què està a mitges i què encara no té decisió. |

### Com funciona una sessió de treball

1. L'agent llig `estado.md` i busca si hi ha ticket per al que se li demana.
2. Si no n'hi ha, **crea un ticket** (`T-00NN`) amb l'objectiu i els fitxers que tocarà, i ho anota a la bitàcora amb la seua firma.
3. Treballa només dins d'eixe ticket. Si apareix un treball extra, s'obri un altre ticket.
4. En acabar, escriu el **resultat** al ticket, una línia al `changelog.md` i actualitza `estado.md`.
5. Si el comportament del joc ha canviat, actualitza el `docs/<sistema>.md` corresponent.

### Per què això ens fa avançar més ràpid

- **Memòria externa**: cada agent pot començar una sessió sense la conversa anterior. Llig el vault i sap què passava.
- **Un treball, un ticket**: no hi ha canvis «de pas» que ningú no ha demanat.
- **Un dueño per ticket**: si un altre agent el té en curs, es parla abans de tocar-lo.
- **Traçabilitat**: qualsevol canvi del joc es pot seguir fins al ticket que el va motivar.
- **La veritat és el codi**: si el vault i el codi es contradiuen, mana el codi i es corregeix el vault.

Hi ha una regla especialment útil amb la IA: els agents **no carreguen tota la documentació per defecte**. `AGENTS.md` té un índex i cada agent llig només el fitxer del sistema que necessita. Així el context no es gasta en informació que no fa falta i les respostes són més precises.

---

## 4. Què s'ha fet des de la primera entrega

| Àrea | A l'entrega 1 | Ara |
|---|---|---|
| Combat | Un atac | Combo de tres tajos, guardia, parry i empenta |
| Enemics | L'orco | Huit tipus amb comportaments propis i loot per enemic |
| Món | Fons amb parallax | Chunks infinits, tres biomes, transicions i cicle dia/nit |
| Objectes | — | Cinc espais, més de quaranta objectes i disset passives actives |
| Interfície | Barra de vida | Vida, stamina, monedes, estadístiques, graella de passives i pantalla d'inventari |
| Presentació | — | Menú, caiguda inicial, números de dany, partícules, sacsada i inventari |

### 4.1 El jugador i el combat

- **Combo de tres tajos** amb clic esquerre i una finestra de 0,35 s per encadenar-los. El tercer colp té una hitbox molt més gran, pensada com la estocada final.
- **Guardia** amb clic dret o E: bloqueja el dany frontal a canvi de stamina (15 en alçar-la i 20 per segon).
- **Parry**: si el colp entra en els primers 0,2 s de guardia, no fa dany, et torna 30 de stamina i dispara un efecte propi. Té un refredament de 0,3 s perquè no es puga encadenar mantenint el botó.
- **Estadístiques**: vida 100, dany base 20, velocitat, velocitat d'atac, 5 % de crític amb dany doble i sort, que augmenta les probabilitats de drop.
- **Moviment**: córrer, saltar amb coyote time i buffer, i pujar escalons d'una casella automàticament sense frenar.
- Panell d'estadístiques sempre visible a l'esquerra, amb alpha baixa perquè no tape el joc.

### 4.2 Els enemics

Huit enemics implementats, cadascun amb una idea pròpia:

| Enemic | Comportament |
|---|---|
| Orco | Melé directe, el enemic base. |
| Llop | Ronda la seua zona, embisteix i cada dos embestides fa un salt amb dany doble. |
| Sapo mutant | Salta en arcs alts i cada tres aterratges llança tres projectils destructibles. |
| Arquero | Es manté a distància i dispara fletxes. |
| Esquelet | El primer colp que rep no li fa dany. |
| Slime | Enemic simple, font de les passives de moco. |
| Fantasma | Es teletransporta i és invulnerable durant el teletransport. |
| Dimoni | Vola, escup un doll de foc i queda atordit si li paren amb la guardia. |

A més:

- **Repartiment per bioma**: cada bioma té la seua llista d'enemics i el seu recompte.
- **Densitat progressiva**: els primers chunks tenen pocs enemics i, com més s'avança, més densitat i més vida i dany per enemic.
- **Loot per enemic**: cada enemic té la seua taula de passives, amb qualitats `Normal` i `Rara`.
- **Repartiment ordenat**: els enemics es col·loquen en franges iguals al llarg del chunk, amb una mica de soroll, perquè no s'apelotonen.
- Els dos voladors (fantasma i dimoni) estan en revisió: la idea és reservar-los per al cementeri, però hui els biomes encara els inclouen.

### 4.3 Objectes, passives i inventari

- **Inventari de cinc espais**: dos per a habilitats (encara sense cablejar) i tres per a consumibles, amb les tecles 1-5.
- **Recollida automàtica** en tocar l'objecte, amb física de caiguda, bot i balanceig.
- **Més de quaranta objectes** definits: pocions, amulets, armadures i passives.
- **Disset passives ja cauen del loot** dels enemics corresponents: ogro (5), llop (4), granota (4) i slime (4). Les del arquero, l'esquelet, el fantasma i el dimoni encara no existeixen.
- Les passives **no s'acumulen**: si ja la tens, el joc no te la torna a donar.
- Els objectes que no es recullen **caduquen**: parpellegen i desapareixen, perquè el món no s'òmpliga de brossa.
- **Graella de passives al HUD**, paginada, i **pantalla d'inventari** amb Tab/I que pausa el joc i mostra la descripció de cada objecte.

### 4.4 El món

- **Generació procedural infinita per chunks** de 256×140 caselles, amb càrrega i descàrrega segons la càmera.
- **Persistència dins de la partida**: els enemics morts i les monedes recollides no tornen a aparéixer.
- **Tres biomes**: pradera, bosc roig i neu. El bioma es decidix per blocs, amb una transició suau de 256 blocs, i canvia el color del césped, el to dels boscos, la llum, el relleu i els enemics.
- **Fons tintats per capa**, amb un gris distint per a cada profunditat, perquè els tres plans no queden del mateix color.
- **Cicle de dia i nit**: cinc minuts de dia i tres de nit, amb estrelles, muntanyes més fosques i un vel suau.
- **Ambient per bioma**: fulles roges al bosc i flocs de neu a la zona nevada, generats per codi.
- **Escala de píxel entera** a 2×, perquè el pixel art no tremole en moure la càmera.

### 4.5 Presentació i interfície

- **Menú principal** amb el mateix parallax del joc i el títol.
- **Caiguda inicial** des del cel que fa de pantalla de càrrega.
- **Números de dany** flotants, diferenciats per a enemic, jugador, moneda i curació.
- **Partícules**: chispes al colpejar, sang en morir un enemic, pols en saltar i córrer (del color del bioma), chispes de parry.
- **Feedback de pantalla**: sacsada de càmera, destell i roig en rebre dany, bot del comptador de monedes i batec de la barra de vida quan queda poca.
- **Monedes amb física**: cauen, boten i s'assenten amb un balanceig.

---

## 5. Per què no hi ha hagut tant de progrés

Volem ser transparents: **la diferència entre les dos entregues no és només contingut nou, també és reestructuració**. Han passat estes coses:

1. **Canvi d'eines d'IA** enmig del desenvolupament, amb el temps d'aprendre a fer-les servir bé.
2. **Creació del vault** i de les regles de convivència entre els dos agents, que abans no existien.
3. **Documentació de cada sistema** (`docs/`) perquè les dos persones i les dos IAs treballaren amb la mateixa informació.
4. **Integració del treball del company** (tres enemics i onze objectes) feta a mà, sense un merge cec, perquè la seua branca era anterior al món per chunks.
5. **Reescriptures** de la càmera, de l'escala de pantalla i del generador de món, que van costar diverses iteracions fins que van quedar estables.
6. **Verificació manual**: el projecte no té tests automàtics, així que cada canvi s'ha de provar obrint el joc i jugant un tros.

Cap d'estos punts és treball perdut. És la infraestructura que fa possible que ara dos agents puguen tocar el mateix repositori sense xafar-se i que el projecte cresca sense que ningú no es pregunte «per què està així açò?». La reestructuració ha costat temps, però **ara anem més ràpid del que aniríem sense ella**.

---

## 6. Els pròxims objectius

Estos són els tres objectius que ens marquem a partir d'ara, per este ordre.

### 6.1 Posar textures de veritat als objectes

**El problema:** les icones actuals són **provisionals**. Hem agafat un pack genèric d'icones i hem retallat les que més o menys recordaven l'efecte de cada objecte, a 16×16. El resultat és que un objecte pot portar la icona de gel sense tindre res a vore amb el gel, dos objectes poden compartir icona, i a l'inventari (on es veuen a 64 px) es nota molt que són de prova. **No tenen sentit**: no comuniquen què fa l'objecte.

**Què farem:**

- Fer un llistat tancat d'objectes i efectes, amb el nom i la funció de cadascun.
- Definir un llenguatge visual comú: mida, paleta, contorn, nivell de detall i com es distingixen les qualitats (`Normal` i `Rara`, i més endavant `Èpica` i `Mítica`).
- Dibuixar o encarregar **una icona per objecte**, llegible a 16×16 i que cresca bé a 32 i 64 px.
- Substituir-les totes alhora i provar-les al HUD, a la graella de passives i a la pantalla d'inventari.

### 6.2 Generació d'estructures i els seus boses

**El problema:** el món és infinit i coherent, però encara no té llocs que memoritzar. No hi ha tendes ni combats especials: només terreny i enemics normals.

**Què farem:**

- **Estructures dins del chunk**: començar per la tenda, que a més serà zona segura (els enemics que hi entren es queden quiets i no ataquen).
- Regles de col·locació: la primera tenda a una distància fixa, després aparicions aleatòries amb una distància mínima i, com a molt, una per zona.
- **Un boss per zona**, amb mecàniques pròpies, arena tancada, barra de vida pròpia i recompensa garantida.
- Que les estructures no trenquen la generació existent: s'han de poder encaixar sense costures ni forats al terreny.

### 6.3 Implementació d'objectes i mecàniques

**El problema:** hi ha molt de disseny escrit que encara no existix al joc. De les 32 passives dissenyades, 17 estan implementades; en falten 15 (arquero, esquelet, fantasma i dimoni). A més, els efectes d'estat (verí, cremada, sagnat) no tenen un sistema comú, i els espais 1-2 de l'inventari estan reservats per a habilitats que encara no hi són.

**Què farem:**

- Crear un **sistema d'efectes d'estat** reutilitzable: verí, cremada, sagnat, atordiment i els seus acumulables.
- Implementar les **passives que falten**, amb la seua qualitat i la seua taula de loot.
- Cablejar les **habilitats** dels espais 1-2 i l'intercanvi quan l'inventari està ple.
- Connectar els objectes amb la **tenda** i les monedes, perquè l'economia tinga sentit.

---

## 7. Cap a on va el projecte

Després d'estos tres objectius, el camí previst és:

- **Tenda i economia**: preus, estoc limitat per zona i decisions de compra.
- **Noves zones**: desert amb mòmies i efectes de foc, i cementeri amb fantasmes i teleportació.
- **Perills ambientals**: hidratació al desert, fred a la neu, gel relliscós i arenas movedisses.
- **Progrés del jugador**: habilitats actives amb refredament, nivell i elecció de millores.
- **Guardat de partida**: hui la persistència és només dins de la sessió.
- **So i música**, i una **mort real** (ara el jugador torna a aparéixer sencer, és un placeholder).

Tot el disseny que encara no està implementat, amb el seu estat i les decisions que falten, està recollit en `vault/ideas.md`. No s'inventa res: el que no està decidit es queda apuntat com a dubte fins que l'equip el decidix.

---

## 8. Conclusió

OffBeaten Path ja no és una prova de concepte: és un prototip amb combat, enemics, objectes, món infinit i una base tècnica documentada. El que ha canviat de veritat des de la primera entrega no és només el joc, sinó **com el construïm**: dos agents d'IA que es coordinen a través del vault, un ticket per treball i un registre del que s'ha fet i del que falta.

El pròxim pas és fer que tot això **es veja i es toque**: textures que comuniquen, estructures que donen objectiu a l'exploració i mecàniques que aprofiten els objectes que ja tenim dissenyats.
