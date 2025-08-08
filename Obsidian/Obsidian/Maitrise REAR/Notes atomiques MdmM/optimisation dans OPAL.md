[[simon2021]] 

L'optimisation formulée ainsi : 
$$\begin{array}{rl}\min _{x \in R^n} & f(x) \\ \text { s.t. } \quad x & \in\left[x_{\min }, x_{\max }\right] \\ A x & \leq b\end{array}$$
vise à minisier la valeur de la fonction coût définie sur un vecteur de paramètres. Les valeurs de ces paramètres sont contraintes par des bornes et par une matrice de contrainte $A$.
###### Contraintes

- Deux groupes de contraintes : 
	- les **contraintes internes** entre différents paramètres d'une même solution (ex. pour un résonateur LEONAR, la longueur du tube doit être inférieure à l'épaisseur totale de la cavité)
	- les **contraintes globales** qui tiennent compte des variables des différentes sous parties (ex. l'épaisseur maximale définie par l'utilisateur est la limite pour la somme des épaisseurs des différents composants en série)

###### Fonction coût

**L'utilisateur à la main sur la définition de la fonction coût.** Il est possible de :
- **maximiser le TL** : 
	- par la moyenne du TL pondéré $$f_{T L 1}(x)=-\sum_{\omega \in W} \beta(\omega) T L(x, \omega)$$par la valeur minimale du TL pondéré $$f_{T L 2}(x)=\max _{\omega \in W}-\beta(\omega) T L(x, \omega)$$ plus difficile à atteindre
- **matcher avec une impedance de réference** :
	- par la moyenne quadratique des écarts absolus  à l'impédance pondérée $$f_{Z 1}(x)=\sum_{\omega \epsilon W}\left|\beta(\omega)\left(Z(x, \omega)-Z_{r e f}(\omega)\right)\right|^2$$par l'écart absolu maximale à l'impédance pondérée $$f_{Z 2}(x)=\max _{\omega \varepsilon W}\left|\beta(\omega)\left(Z(x, \omega)-Z_{r e f}(\omega)\right)\right|$$
###### Algorythmes

- algorithme évolutifs
- Pour simulation couteuses : Optimization Bayesian
- optimisation robuste
- Mean - Variance optimization : pour trouver des solutions qui sont un compromis entre performance attendu et variablilité (utilisation d'une optimisation Bayesian avec des polynomes chaotiques???)

###### Etude de sensibilité

Analyse de sensibilité pour un liner LEONAR à deux couches, réalisée avec un algorithme de Monte Carlo sur un modèle Gaussien
![[image-10-x175-y619.png]]

###### Remarques

- Pour réaliser des liners réalistes, **il est nécessaire de tenir compte des incertitudes de modélisation et de fabrication afin d'évaluer la rubustesse du TL obtenu**.

- Pour quantifier l'incertitude sur le TL, il faut déterminer les paramètres importants à partir des indices de Sbol fournis par étude de sensibilité puis appliqué une calibration Bayesienne sur ces paramètres.