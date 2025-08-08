#### Contexte du projet

- Advanced Air Transport Technology (AATT) NASA Projet
- Collaboration entre la NASA et Boeing (début du projet : fin 2017) ([page. 2](zotero://open-pdf/library/items/C6LB9F5Q?page=2&annotation=CABSMZ2S))

> [!quote|yellow]+ Image ([page. 11](zotero://open-pdf/library/items/R73R9NG2?page=11&annotation=CHYIDZ8N))
> ![[Zotero/narkDesignAdvancedInlet2019/Images/narkDesignAdvancedInlet2019-11-x142-y497.png]]

#### Design du MDOF Low Drag Liner

- Utilisation du code [[Ducted fan noise propagation and radiation code CDUCT-LARC (CH3DPA)|CDUCT-LARC]].
- L'optimisation de l'impédance cible est construite directement à partir de l'atténuation
- *Deux modèles de prédiction* : transmission line model (matrices de transfert) et lumped-element (masse-ressort). L'impédance des différentes cavités est prise en compte dans un modèle d'impédance en parallèle (somme des admittances) et supposée uniforme par la suite ([page. 4](zotero://open-pdf/library/items/R73R9NG2?page=4&annotation=S94CQT63)) 
- Impédance bornée ([page. 5](zotero://open-pdf/library/items/R73R9NG2?page=5&annotation=LZXS4MNZ))
- *Fréquences ciblées* : fréquences centrales de bandes réparties entre 400 Hz et 10000 Hz en tiers d'octave
- Ecoulements réalistes : pondération relative aux conditions de de "takeoff" (décollage), "cutback" (stabilisation après décollage), "approach" (atterrissage) 
- *Liners candidats* : configurations multicouches, structure nid d'abeille. Impédance indépendante pour chaque cellule, deux mesh caps autorisés pour chaque cellule (3DOF)
- *Optimisation* : Evaluation pondérée sur l'impédance globale, avec les routines de Python (Scipy). La pondération dépend du type de vol  ([page. 6](zotero://open-pdf/library/items/R73R9NG2?page=6&annotation=TX2Q8RQD)).

> [!quote|yellow]+ Image ([page. 6](zotero://open-pdf/library/items/R73R9NG2?page=6&annotation=YJ2EYNTI))
> ![[Zotero/narkDesignAdvancedInlet2019/Images/narkDesignAdvancedInlet2019-6-x176-y573.png]]

- Eléments concernant la fabrication des plaques dans un article associé 

- *Prédiction* : Avec le code de propagation par rayonnement par éléments finis ([page. 7](zotero://open-pdf/library/items/R73R9NG2?page=7&annotation=N68ERIGK)), approche statistique pour décrire la source ([page. 7](zotero://open-pdf/library/items/R73R9NG2?page=7&annotation=EGCTU8UZ))
- *Evaluation réaliste* : réduction du niveau de bruit lors d'un campagne de mesure ([page. 8](zotero://open-pdf/library/items/R73R9NG2?page=8&annotation=VD59Z7AH))

#### Fabrication du traitement

- fabriqué par Hexcel Corporation 

> [!quote|green]+ Highlight ([page. 2](zotero://open-pdf/library/items/C6LB9F5Q?page=2&annotation=YGRRTAUD))
> The core design contains two layers of Polyetheretherketone (PEEK) mesh septa within each honeycomb cell 

> [!quote|yellow]+ Image ([page. 2](zotero://open-pdf/library/items/C6LB9F5Q?page=2&annotation=PXJ6IYNF))
> ![[Zotero/wongFlightTestMethodology2019/Images/wongFlightTestMethodology2019-2-x102-y127.png]]

#### Intégration du traitement dans le carénage

étapes de fabrication  ([page. 3](zotero://open-pdf/library/items/C6LB9F5Q?page=3&annotation=VWUHYWNH))
- fabrication du traitement (Hexcel)
- formage du traitement pour l'ajuster dans deux "*core blankets*" (Hexcel)
- installation des "*blankets*" dans le "*acoustic barrel*"
- pose des brides et du carénage (fixation et pièces aérodynamiques) autour du "barrel" (Boeing)
- Fixation du carénage sur la nacelle d'un modèle Boeing 737MAX-7 
#### Campagne de mesure

Juillet, Aout 2018
#### Evaluation préalable du liner avec un impédance-mètre portatif

> [!quote|yellow]+ Image ([page. 4](zotero://open-pdf/library/items/C6LB9F5Q?page=4&annotation=RVRE742Q))
> ![[Zotero/wongFlightTestMethodology2019/Images/wongFlightTestMethodology2019-4-x123-y419.png]]


> [!quote|yellow]+ Image ([page. 4](zotero://open-pdf/library/items/C6LB9F5Q?page=4&annotation=DVKG32FA))
> ![[Zotero/wongFlightTestMethodology2019/Images/wongFlightTestMethodology2019-4-x114-y161.png]]


#### Configurations du traitement testées

> [!quote|yellow]+ Image ([page. 5](zotero://open-pdf/library/items/C6LB9F5Q?page=5&annotation=XYG7WEDZ))
> ![[Zotero/wongFlightTestMethodology2019/Images/wongFlightTestMethodology2019-5-x100-y469.png]]

Le test est effectué sur une nacelle pourvue d'un traitement déjà installé juste en amont de la pâle ('*forward fan case*"). Pour tester spécifiquement le traitement au niveau du "*barrel*", un traitement alternatif neutre (sans perforations) à état fourni par Safran ([page. 5](zotero://open-pdf/library/items/C6LB9F5Q?page=5&annotation=9HC7GWTD)) 

3 traitements sont testés ([page. 5](zotero://open-pdf/library/items/C6LB9F5Q?page=5&annotation=DX589CCB)) :
- Un traitement industriel standard de Boeing (2DOF, perforations circulaires)
- Le *NASA MDOF Low Drag inlet* développé pour la campagne de test
- Une condition rigide en appliquant un "*acoustic tape*" sur le traitement 3DOF.

#### Conditions de vol

- Carénage test sur le "engine" droit uniquement.
- Série de décollages et d'atterrissage autour d'un réseau de microphones au sol

#### Séparation des sources


#### Traitement des données
- 