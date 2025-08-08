On étudie la solution MPPSBH constituée d'une succession de plaques perforées et de cavité. 

On considère les paramètres constants suivants : 
- Le rayon des perforations $r$ 
- Le nombre de perforations en profondeur $N_{d}$
- La largeur $W$ et la profondeur $D$ des cavités (et des plaques) 
- La distance inter-perforations $d_{int}$

Pour chaque plaque plusieurs paramètres varient suivant la largeur :
- Le nombre de perforations $N_{w}$
- La largeur de la fente couverte par les perforations $d_{s}$
Ces trois paramètres sont bien sur couplées car $d_{s} = d_{int} * (N_{w} - 1) + 2r$.

![[Pasted image 20250523080312.png]]

Ces variations se retrouvent exprimées dans plusieurs grandeurs d'intérêt : 
- Le taux de perforations de la fente 
- $$\phi_{s} =  S_{s} / S_{perf} = \frac{d_{s} D}{N_{d} N_{w} \pi r^2}$$  
- Le taux de perforation réel de la plaque $$\phi_{p} = S_{p} / S_{perf} = \frac{W D}{N_{d} N_{width} \pi r^2}$$ 
On appelle effet trou-noir acoustique l'observation de propriétés acoustiques particulières sur le spectre d'absorption d'une solution acoustique lorsque celle-ci présente un pore principale à profil décroissant (linéaire ou quadratique). En réécrivant les équations des ondes, cette décroissance continue de la largeur se traduit par une diminution progressive de la célérité des ondes dans le matériau. 
Si l'espacement des perforations reste le même, alors la diminution de la largeur de la zone perforée s'accompagne d'une diminution de la porosité réelle. Ainsi il n'est pas évident d'attribuer les différentes propriétés acoustiques observées à telle ou tel facteur géométrique isolément. 

**Principe de l'étude**

Le but de l'étude et de créer plusieurs configurations de la solution en tirant aléatoirement le nombre de perforations en largeur sur chaque plaque. A partir de chaque configuration aléatoire on produit plusieurs configurations permutées pour lesquelles la liste des nombres de perforations est une permutation aléatoire de la liste initiale. Ainsi on obtient un jeu de configuration pour lesquels certaines configurations diffèrent par la distribution des perforations et l'ordre des plaques tandis que d'autre ne diffèrent que par l'ordre.

**Métriques sur les configurations**

On cherche à identifier si l'ordre des plaques a une importance. Plus précisément on identifie plusieurs propriétés du profil :
- **La monotonie**, l'ordre des plaques
- **La régularité** (smoothness) du profil, l'importante des écarts entre plaques voisines
- **La distribution (statistique)** des nombres de perforations

Pour quantifier ces propriétés on propose plusieurs métriques : 
- **La moyenne** du nombre de perforations (identique pour les permutations)
- **La variance** du nombre de perforations (identique pour les permutations)
- La **position du barycentre**, qui évalue si les plaques fortement perforées sont plutôt en haut (1), au milieu (0) ou en bas (-1)
- Le **désordre spatial**, la somme des carrés des écarts entre les positions dans la liste courante et dans la liste ordonnée

**Métriques sur les performances acoustiques

Ici on s'intéresse aux performances :
- à basses fréquences
- larges bandes
On définit donc comme critères d'évaluation des configurations les coefficients d'absorption sur trois bandes : 150-400 Hz, 400-600 Hz, et 600-1500Hz ainsi que sur les bandes élargies 150-600 Hz, 400-1500 Hz et enfin 150-1500 Hz

