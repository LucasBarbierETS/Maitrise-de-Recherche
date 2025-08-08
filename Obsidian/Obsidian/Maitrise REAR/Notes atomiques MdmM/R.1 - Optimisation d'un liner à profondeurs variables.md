
Le but est de :
- tester le processus d'optimisation et les modèles présentés dans [[galles2024]] 
- développer un algorithme d'optimisation de géométrie
- tester l'influence de l'homogénéité de l'impédance
- Optimiser une structure plus complexe
- Mettre en place un processus de travail en commun

Ce qui n'est pas fait dans [[galles2024]] : 
- optimiser les MPP
- optimiser la géométrie
- utilisation de LEE [[comparaison entre la méthode CHE et la méthode LEE|au lieu de CHE]] pour l'extraction de l'impédance : écoulement non-uniforme
- méthode directe en utilisant l'approche de Tomko
###### Phase 1 : (Juillet)

- **revue de littérature** : 
	- cavités repliées (?)
	- méthodes d'extraction de l'impédance
* **modélisation analytique** :
	*  création du code analytique pour décrire la configuration MDOF (modèle SIM)
- **modélisation numérique** : 
	- création des fichiers de paramètres géométriques à partir des configurations analytiques (macros excel) 
	- création de modèles solidworks à géométrie variable

###### Phase 2 (Juillet - Août)

- **revue de littérature** : 
	- écoulements, revue complète
	- forts niveaux, couplages des effects d'écoulement et de forts niveaux 
- **modélisation analytique** : 
	- intégration de l'optimisation dans l'application
	- implémentation des modèles non linéaires complets
- **modélisation numérique** : 
	- créer une géométrie adaptée au liner à incidence rasante
	- 
- créer un liner FEM à incidence normale qui tient compte du fort niveau,  adapté à la géométrie
- créer un code d'optimisation de la géométrie (comme Packing3D) 

###### Phase 3 (Août - Septembre)

- revue de littérature : *méthodes de modélisations numériques*
- créer un liner FEM à incidence rasante adapté à la géométrie
- faire les calculs à incidence normale
- tester l'inhomogénéité de l'impédance (ordre des cavités)
 
###### Etape 4  (Septembre - Octobre)

- test de l'optimisation hybride
- créer un liner (normal/rasant) FEM qui tient compte des écoulements et des forts niveaux
- fabriquer les échantillons + plaques en 3D et tester en incidence rasante + fort niveau


###### Livrables : 

- configuration optimisée
- impédance idéale, sensibilité du TL
- solution imprimée, usinée, testée