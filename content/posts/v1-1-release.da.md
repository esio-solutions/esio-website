---
title: "v1.1: Hurtigere prognoser og PDF-eksport"
description: "Prognoser kører nu 3× hurtigere, og hver rapport har PDF-eksport til revisor eller bestyrelse — hvad der landede i denne uges udgivelse."
date: 2026-04-25
---

To store forbedringer i denne build, plus en håndfuld mindre.

## Prognoser kører ~3× hurtigere

Vi har omskrevet prognosemotoren, så den beregner de næste 18 måneder i ét gennemløb i stedet for rekursivt. På rigtige kundedata afsluttes simulationer, der tog 2,4 sekunder, nu på 0,7. Du mærker det mest, når du flytter scenarie-input.

## PDF-eksport

Hver rapport har nu en "Download PDF"-knap øverst til højre. Praktisk når du skal sende prognoser til din revisor, til bestyrelsen, eller til de 18 måneder hvor du uundgåeligt får brug for at printe en.

## Mindre ændringer

- Momskalenderen håndterer nu 1. marts-deadlinen korrekt.
- Valutaformatering bruger lokaliseringen fra det forbundne regnskabssystem, ikke browseren.
- Rettet en off-by-one-fejl i månedlige sammenligninger, der påvirkede ~3 % af brugerne (undskyld).

Hvis du støder på skæve kanter, når **support@esio.dk** et menneske.
