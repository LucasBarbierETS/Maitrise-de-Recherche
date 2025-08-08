

La méthode d'optimisation directe est un processus d'optimisation décrit par [[Optimisation d'un liner à profondeurs variables]] par comparaison à la [[méthode d'optimisation indirecte]] dans le cadre de l'optimisation d'un [[liner à profondeur variable]] pour atténuer le niveau de bruit dans un conduit avec écoulement.

Le diagramme suivant illustre le fonctionnement de ces deux méthodes d'optimisation. 

![[image-6-x87-y521.png]] 

Avec la méthode directe il n'y a qu'**un seul cycle d'optimisation**. A chaque itération, les paramètres de la i-ème configuration sont utilisées pour calculer l'impédance de surface puis le niveau sonore à la sortie du conduit pour les $N_f$ fréquences considérées dans la fonction coût.

*La fonction coût est basée sur la norme $L_p$ des écarts au niveau idéal.*
  ![[image-6-x217-y188.png]]
 ![[image-7-x114-y518.png]]

## Principales différences avec la méthode indirecte

- La réactualisation des paramètres de la configuration nécessite de calculer le champ acoustique dans le domaine de calcul à chaque itération : **+ de ressources de calcul sont nécessaires**

- Avec cette méthode l'objectif porte directement sur le besoin du problème qui est la réduction de bruit. **Si il converge, l'algorythme direct à plus de chance d'atteindre le maximum global**.