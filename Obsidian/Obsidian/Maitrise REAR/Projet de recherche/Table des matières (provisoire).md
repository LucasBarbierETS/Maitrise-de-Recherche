1. **Introduction**

	- Contexte et enjeux
	- Objectifs de la recherche
	- Méthodologie générale et approche adoptée
	- Structure du mémoire

2. **Etat de l'art sur les solutions acoustiques en aéronautique** (15 p.)

	-  [[Description qualitative du champ acoustique dans le rotor]]
	-  [[Stratégies industrielles pour la réduction de bruit en aéronautique]]  
	-  [[Utilisation de matériaux innovants dans l'aéronautique]] 
	-  [[Etat de l'art des méthodologies de caractérisation et d'optimisation]] 
	-  [[Cartographie des approches industrielles pour la réduction de bruit en  aéronautique]] (présentation de la méthodologie dans le cadre du projet Airbus, plus généralement, difficulté générale d'établir une méthodologie de *prédiction*)

3. **Cadre épistémologique** (10 p.)

- [[Besoin d'un cadre épistémologique]] 
- [[Introduction aux phénomènes acoustiques]] (Approche énergétique, dissipation, propagation etc.)
- [[Causalité en acoustique]] 
- Description générale du problème acoustique (Phénomènes et relations, types de mesures, grandeurs observées et relations entre elles)
- Types de mesures acoustiques réalisables à l'ETS, spécificités et limitations (méthodes d'acquisition, type de phénomène observé, commensurabilité des grandeurs, exemple : absorption en cabine vs absorption en tube, est-ce la même absorption)
- Types de mesures numériques possibles
	- Reconstitution du champ
- [[Impédance, grandeur clé du problème]]
- [[Modèles analytiques à constantes localisées]] (hypothèses, simplifications associées)

1. **Choix des solutions : pourquoi ces solutions?** (approche pas à pas) (5 p.)
	- Distinction qualitatifs des phénomènes réactifs et dissipatifs
		- Quart d'onde
		- Quart d'onde - plaque
		- Quart d'onde plaque avec changement de section (fente : effet diaphragme)
		-  Multi-plaques (comparaison entre stratif. 1, stratif. 2 et stratif. réunie)

2. **Présentation du modèle analytique des solutions acoustiques développées** (30 p.)
	- Objectif du modèle : prédire qualitativement (et non précisément) les performances, suivre les tendances réelles associées aux effets d'excitation réalistes
	- Modèles de plaques perforées + modèles de correction de longueur (JCAL)
	- Modèles pour trous noirs acoustiques (Webster, TMM)
	- [[Utilisation de la TMM pour les trous noirs acoustiques]] (limites de l'approche, domaine d'application, dimensions, etc...) 
	- Approche phénoménologique + mise en physique du problème de fort niveau (fonction de la vitesse acoustique RMS, totale…) avec la formulation de Forchheimer (coefficient de forme), et de Laly (coefficient de décharge si Forchheimer non connu/ mesuré)
	- Adaptation des modèles multi-plaques de la littérature aux solutions développée (MTMM pour une solution avec perforations disposées sur un motif carré avec approximation volumique)
	- Intégration du modèle fort niveau de Laly avec une approche multi-plaques (approche itérative, possibilité d'utiliser les matrices de transfert ou non, un niveau de pression totale, etc.)
	- [[Incidence oblique]] 
	- [[Ecoulement rasant]] 

3. **Validation et évaluation des modèles** (5 p.)

	- Validation numérique 2D et 3D (régime linéaire)
	- Validation expérimentale en condition de laboratoire (normale, rasante)
	- **Etude de sensibilité du modèle** (rayons des perforations et longueurs de correction d'épaisseur surtout), mise en comparaison avec les tolérances industrielles prévues

4. **Etude des solutions** (10 p.)

	- Définition des plages de validité des modèles 
	- Définition des conditions d'applicabilité industrielle (réduction du nombre de plaques, taille limite de perforations, largeur limite des solutions pour respecter les hypothèses des modèles etc.)
	- Etude multiparamétrique (rayons des perfs notamment)
	- Mise en évidence de l’effet trou noir acoustique sur la solution développée
		*Pour ce faire **je compte créer aléatoirement un jeu de configuration ainsi qu'un certain nombre de configurations dérivées crées par permutation de l'ordre des plaques afin de vérifier les effets de la disposition (régularité, monotonie, dispersion) des perforations sur les performances**. Est-ce une bonne approche?*
		- [[Etude de l'effet trou-noir acoustique]] 
	-  Mise en évidence de l’effet diaphragme
		*De même que pour l'effet trou noir, **je compte crée des solutions dont les taux de perforations sont semblables en faisant uniquement varier la densité des perforations pour mettre en évidence la présence d'un potentiel effet "diaphragme"**.*

5. **Application au projet REAR** (10 p.)

	- Présentation du projet
	- Présentation du cahier des charges acoustique
		- *Comment doit-on s'y prendre pour définir le cahier des charges définitif? **Doit-on faire une proposition et la faire valider à Bell**? **Doit-on organiser une réunion spécifique pour traiter ce point**?*
	- Présentation de la cartouche finale avec méthode d'intégration de la solution de l'ETS
	- Optimisation de plusieurs solutions avec prise en compte en parallèle des solutions développées par les autres équipes
		- *A un moment ou à un autre, il faudra nécessairement tenir compte des contributions acoustiques des solutions de l'équipe de Polytechnique. Est-ce qu'on décide d'en tenir compte d'après les résultats expérimentaux qu'ielles pourront nous fournir ou bien est-il impératif de développer un modèle analytique pour ces solutions en vue d'une optimisation globale?*
		- *Pour renseigner nos modèles fort-niveaux, il est nécessaire de pouvoir fournir un paramètre d'entrée au modèle, soit une information sur le niveau sonore au niveau de la surface du carénage. **Comment l'acquisition de cette information est-elle sensé être faite**? **Doit-on planifier avec Manuel une nouvelle mesure expérimentale ou doit-on se référer aux résultats de la littérature à ce sujet**?*
	- Validation expérimentale (en tube et en cabine)
		- *L'adaptation des tubes du laboratoire pour tester plusieurs solutions (4) de 10 cm de long et 3 * 3 cm de large en incidence rasante et normale est elle à prévoir?* 
	- Campagne de mesure et quantification de l'impact sur le bruit résultant
	- Propositions d'améliorations potentielle
		- Utilisation d'un écran résistif
		- Utilisation du design LEONAR pour les résonateurs de Helmholtz

6. **Annexe : Développement des outils de modélisation et de validation** (10 p.)

	- Code et application
		- Présentation de la structure du code
		- Présentation de l'application avec interface graphique
		- Possibilité d'ajouter son propre coefficient de Forcheimer si connu
		- Estimation manuel des facteurs de corrections (Cd, Forcheimer)

	-  Adaptation des bancs
		- Assemblages et pièces, 
		- Techniques d'usinage

7. **Bibliographie** 

Nombre de page totale (fourchette basse) : 100 p. sans la bibliographie