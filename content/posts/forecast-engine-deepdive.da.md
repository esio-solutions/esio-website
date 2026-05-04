---
title: "Sådan fungerer prognosemotoren"
description: "Et kort teknisk indlæg til kunder, der gerne vil vide, hvad der kører under motorhjelmen."
date: 2026-03-15
---

Et par kunder har spurgt: hvordan ved ESIO, hvad din bankkonto vil stå på i oktober? Her er den korte version.

## Tre signaler, én model

Vi kombinerer tre strømme:

1. **Tilbagevendende mønstre** — løn, husleje, abonnementer, regelmæssige indtægter. Hentes fra din regnskabsintegration; klassificeres via en lille klassifikator, vi har trænet på 12 måneders anonymiserede data.
2. **Kendte begivenheder** — fakturaer der allerede er udstedt (med deres forfaldsdatoer), skattedeadlines fra kalenderen, planlagte ansættelser.
3. **Variabilitet** — støjen i dine historiske data. Vi lader ikke som om prognoser er deterministiske; i stedet rapporteres hvert dagligt saldotal med et konfidensbånd.

Det kombineres til en daglig simulation 540 dage frem. Genberegnes ved hver dataopdatering.

## Hvor er den god, og hvor er den ikke

Den er nøjagtig inden for 5 % på 30-dages-horisonten for virksomheder med 6+ måneders historik. Usikkerhedsbåndet udvides efter 6 måneder — det er ikke en fejl, det er virkeligheden. Vi viser usikkerheden frem for at skjule den, fordi ét enkelt tal med falsk præcision er værre end et interval med ærlige tal.

Den er mindre præcis for meget ujævne virksomheder (projektbaserede bureauer, salg af store ordrer). Til dem er scenarieplanlæggeren det bedre værktøj.
