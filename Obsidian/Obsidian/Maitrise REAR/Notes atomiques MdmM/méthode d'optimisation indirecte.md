La méthode est présentée dans [[nark2021]].

Le diagramme suivant illustre le fonctionnement de ces deux méthodes d'optimisation. 

![[image-6-x87-y521.png]] 

La particularité de la méthode indirecte réside dans la séparation du processus en deux partie indépendantes successives :

- <span style="color:rgb(255, 0, 0)">Phase 1</span> : [[prédiction de l'impédance de surface optimale]]
	- on calcule quelle serait l idéale permettant d'atteindre une réduction du niveau sonore maximale.
- <span style="color:rgb(0, 176, 240)">Phase 2</span>, on optimise les paramètres du liner pour s'approcher au plus près de l'impédance idéale. Ici la fonction coût mesure la [[somme des écarts au carré]] entre l'impédance à la i-ème itération et l'impédance idéale.
![[image-5-x153-y121.png]]
## Principales différences avec la méthode directe

- Avec cette méthode le calcul du champ n'est pas à refaire à chaque itération. Une fois l'impédance idéale obtenue **l'optimisation sur le modèle semi-analytique est rapide est peu couteuse**.

- **Etre proche de l'impédance idéale ne veut pas dire être proche de l'atténuation idéale**. Ainsi l'algorithme risque de converger vers un maximum locale qui ne produira par l'atténuation maximale.


## Questions

- [[question - Comment est déterminée l'impédance idéale dans le code de propagation]]? réponse : [[méthode pour déterminer l'impédance acoustique d'un liner basée sur l'équation de Helmholtz convectée (CHE)]] 

