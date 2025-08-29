1. **Introduction** (5 p.)

	- [[Contexte et enjeux]] 
	- [[Objectifs de la recherche]] (après la bibliographie)
	- [[Méthodologie générale et approche adoptée]] 
	- Structure du mémoire

- **Sommaire** 

1. **Etat de l'art sur les solutions acoustiques pour la réduction de bruit en  aéronautique** (15 p.)
	- [[Chapitre 1 - Introduction]] 
	- [[Deux approches, la description géométrique et la description énergétique]]
	- [[Introduction au formalisme]] grandeurs clés (pression, vitesse, équations fondamentales )
	- [[Interprétation des phénomènes dissipatifs]] 
	- [[Fonctionnement des solutions acoustiques élémentaires, résonateur quart d'onde, matériau poreux et résonateur de Helmholtz,]] 
	- [[Solutions industrielles courantes]] 
	- [[Cartographie des approches industrielles pour la réduction de bruit en aéronautique|Cartographie des approches industrielles]] de dimensionnement impliquant le design de solutions acoustiques (nacelles, Projet BLUECOPTER) (tableau regroupant et distinguant les différentes approches industrielles)

2. **Méthodologie de conception : enjeux et approches** (15 p.)

	**Tableaux récapitulatifs**
	- [[Revue des méthodologies]] 
	- [[Enjeux liés à la complexité d'une problématique d'aéroacoustique]] (schéma interactionnel)
	- [[Reconcevoir la réduction de bruit en aéronautique]] 
	- Prédiction quantitative (causalité complète) vs prédiction qualitative (modélisation simplifiée) 
	- Hypothèses de problématisation, domaine d'application (réaction localisée)
	- [[Revue et explication des types de mesures expérimentales réalisables]] (à l'ETS et ailleurs en général)
	- Présentation des sauts épistémologiques possibles (exemple : [[Impédance formelle en incidence normale vs impédance effective en incidence rasante, le problème méthodologique de l'impédance]])
	- [[Revue des modélisation numériques réalisables]]  
	- Revue des approches analytiques complémentaires pour tenter de boucler la chaine de causalité (reconstruction de sources, fonctions de Green, approche modale, etc.)

3. **Présentation du modèle analytique général** 

- [[Chapitre 3 - Introduction]]  
- [[Hypothèses et cadre d'étude des milieux stratifiés]] 
- Formulation en terme d'impédance de surface, coefficient d'absorption et interprétation [[Matériau stratifié, grandeurs d'expression des performances acoustiques]]  
- Hypothèse géométrique, transmission line, écriture en matrice de transfert, choix de la convention
- TM des éléments simples, cavités, jonction [[Matrice de transfert des éléments simples]] (voir rapport Mael)
- Modèles JCA
- Application du modèles JCA à certains sous-éléments (QWL, Junction avec pertes, plaques) [[Modèles de plaques perforées]] 

Structure générale du code : 
- [[Structure du code analytique, blocs en série et en parallèle]]
- Ecriture du code (programmation orientée objet, intégration dans une application)
- Fonctionnalités supplémentaire (TL, mise en jonction, mise en jonction multiple)
- Modification des paramètres semi-empiriques, coefficient de décharge

Validation
- Littérature
- Validation numérique
- Expérimentale

3. **Choix des solutions : pourquoi ces solutions?** (approche pas à pas) (10 p.)

	- Approche pas à pas de la construction des solutions
		- Quart d'onde
		- [[Plaque perforées]] 
		- [[Quart d'onde - plaque + comparaison (HR)]] 
		- Solutions multi-plaques, exploration des résonances localisées et des couplages possibles entre plusieurs plaques
		- [[Réduction du pore central]] (introduction de cavités latérales)
	- Présentation du concept de trou noir acoustique, du modèle analytique (Webster) et des applications du concept dans la littérature (métamatériaux)
	- 

4. **Présentation et validation du modèle utilisé (TMM) des solutions acoustiques développées** (30 p.)

	- [[Modèle JCA]] équivalent
	- Expression sous forme de matrice de transfert, relation entre expression matricielle et grandeurs clés (alpha, Z, etc.)
	- [[Matrice de transfert des éléments simples]] 
	- Revue des [[Modèles de plaques perforées]] + modèles de correction de longueur (Atalla Ingard, etc.) + Définition des plages paramétriques de validité des modèles
	- Application aux matériaux structurés (multi-pancakes)
	- [[Utilisation de la TMM pour les trous noirs acoustiques]] (limites de l'approche, domaine d'application, dimensions, etc...) 
	- Adaptation des modèles multi-plaques de la littérature aux solutions développée (MTMM pour une solution avec perforations disposées sur un motif carré avec approximation de l'admittance de cavité par approche volumique)
	- [[Structure du code analytique, blocs en série et en parallèle]]
	- Validation du code analytique (littérature + validation numérique si besoin)
	- Optimisation (par d'exemple nécessairement)
	- [[Etude de la solution retenue en régime linéaire]] 

5. **Prise en compte des conditions d'excitation réalistes** (20 p.)

	1. Forts niveaux
		- Approche phénoménologique (empirique) + mise en physique du problème de fort niveau (traduction en terme des grandeurs d'intérêt du problème) avec la [[Modèle de plaque avec forts niveaux]]. 
		- [[Intégration du modèle fort niveau de Laly avec une approche multi-plaques]]  application à une ou toute les plaques, approche itérative, possibilité d'utiliser les matrices de transfert ou non, un niveau de pression totale, etc.)
	2. Ecoulement (rasant)
		- [[Revue empirique des phénomènes liés à l'écoulement (doppler, sifflements au niveau des perforations, etc.)]] 
		- [[Equation d'Helmholtz convectée pour une reformulation de l'impédance de surface]] 
		- Difficulté d'[[utiliser une impédance de surface pour la prédiction de la réduction de bruit]] 
		- [[Description du modèle approché utilisé à partir du nombre de Mach moyen]]
	3. Incidence (normale, oblique rasante)
		- [[Prise en compte de l'impédance de surface d'un traitement en incidence rasante]]
		- [[Distinction entre un comportement dépendant de l'angle d'incidence (MPP cavités non séparés) et réduction de l'énergie incident normalement à cause de l'angle]] 
		- Cas rasant, forçage acoustique, cas particulier d'un traitement latéral en guide d'onde acoustique type silencieux (faible rayon)
		- Retour sur l'idée de réaction localisée, correction de la masse ajoutée du modèle liée à l'incidence, interaction entre incidence et forts niveaux
		- [[Effets des termes de sources]] 

4. Application de la méthodologie : 
- Contexte du projet 
- Revue exhaustive des paramètres clés qui pilotent le [[comportement des plaques micro-perforées]] (5 p.)
- Présélection d'une solution à partir des objectifs dans le cadre d'une application réelle
- Correction des modèles à partir des résultats expérimentaux
- Etude de la solutions grâce aux modèles + validation, définition des contraintes industrielles
- Optimisation contrainte
- Validation numérique et expérimentale

4. **Etude et optimisation des solutions** (15 p.)

	- [[Etude de l'effet trou-noir acoustique|Mise en évidence de l’effet trou noir acoustique]] sur la solution développée
		- Approche statistique (comparaison des performances de combinaisons aléatoires en fonction du niveau d'ordre des configurations)
		- Comparaison entre le modèle avec et sans prise en compte des admittances volumiques (impact de l'épaisseur des cavités sur la validité du modèle)
	-  Discussion autour de l'existence d'un "[[Effet diaphragme]]"
		- Etude d'après les formulations analytiques (dépendance des modèles à une potentielle porosité non-homogène)
		- Approche empirique : revue des mesures expérimentales qui valident l'existence possible 
- [[Etat de l'art des méthodologies d'optimisation]]  
- Approche multi-objectifs utilisée, algorithme génétique, convergence, minimum locaux etc.

8. **Application au projet REAR** (20 p.)

	- Présentation du projet 
		- [[Description qualitative du champ acoustique dans le rotor]] (sources, niveau sonore, directivité, …) **dès l'état de l'art?** pas besoin d'être publié nécessairement
	- [[Présentation du cahier des charges acoustique]] 
	- [[Présentation du cahier des charges techniques et compromis entre fabrication et performances acoustiques]] 
	- Présentation de la cartouche finale avec méthode d'intégration de la solution de l'ETS
	- Optimisation de plusieurs solutions avec prise en compte en parallèle des solutions développées par les autres équipes

	- Validation expérimentale (en tube et en cabine)
	- Campagne de mesure et quantification de l'impact sur le bruit résultant

9. **Annexe : Développement des outils de modélisation et de validation** (10 p.)

	- Code et application
		- Présentation de la structure du code
		- Présentation de l'application avec interface graphique
		- Possibilité d'ajouter son propre coefficient de Forchheimer si connu
		- Estimation manuel des facteurs de corrections (Cd, Forchheimer)

	-  Adaptation des bancs
		- Assemblages et pièces, 
		- Techniques d'usinage

10. **Bibliographie** 

Nombre de pages totale : 130 p. + 10 p. d'annexes + bibliographie