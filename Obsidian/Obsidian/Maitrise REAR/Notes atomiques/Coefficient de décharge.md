

> [!quote|yellow]+ Image ([page. 543](zotero://open-pdf/library/items/KT3X6N29?page=543&annotation=XUVQ258G))
> ![[Zotero/winklerHighFidelityModeling2021/Images/winklerHighFidelityModeling2021-14-x179-y259.png]]

**Définition** 

> [!quote|green]+ Highlight ([page. 43](zotero://open-pdf/library/items/NMNDZ2RK?page=43&annotation=5UTTZ39B))
> The ratio of the area of the vena contracta to the orifice area is known as the **coefficient of contraction**, $Ca$, for the orifice. Its value, as might be anticipated, is dependent on the static head across the orifice, on the ratio of orifice area to free stream area and on the fluid viscosity. In practice it is also found that the velocity in the vena contracta is less than that which might be anticipated from the assumption of an ideal inviscid fluid. This ratio of the ideal velocity to actual velocity at the vena contracta is known as the **coefficient of velocity**, $Cv$. Whilst the coefficient of velocity is a function of pressure ratio it is generally very nearly equal to unity. In practice, because of the standard uses of orifices for measuring flow rates, a third coefficient is generally exclusively quoted; this is known as the **discharge coefficient**, $Co$, and it is equal to the product of the velocity and contraction coefficients. 

**[[Vena Contracta]]** 

**Utilisation dans les modèles en acoustique

Le coefficient de décharge est utilisé en acoustique pour modéliser l'évolution de la résistance acoustique en fonction de la vitesse acoustique en régime non-linéaire.

Dans sa thèse, Laly utilise la formulation suivante pour modéliser la résistance spécifique non linéaire normalisée : 

> [!quote|yellow]+ Equation de la résistance spécifique non linéaire normalisée selon Zinn ([page. 70](zotero://open-pdf/library/items/CMZQ7B9B?page=70&annotation=7IZK2UDY))
> ![[Zotero/TheseLaly/Images/TheseLaly-70-x137-y212.png]] 

Il indique que $Cd$ peut varier entre 0,6 et 0,8. Un peu plus loin il indique que la valeur usuelle pour ce coefficient est 0,76. L'article duquel il tire cette valeur ne cite pas sa source. Par ailleurs entre les deux extrémités de l'intervalle prises au carré, il y a un rapport du simple au double qui se répercute directement sur la formulation de la résistivité non-linéaire au passage de l'air.

Le coefficient de décharge dépend : 
- du nombre de Reynold $Re$
- du diamètre de la perforation $d$
- de la vitesse de l'écoulement $v$
- la porosité  $\phi$ 

d'après Johansen (article associé au graphe suivant) : 
$$\mathrm{C}_{\mathrm{D}}=f(v d / v, d / \mathrm{D})$$
*Remarque : Il y a une double dépendance au rayon des perforations, dans le rapport des diamètres et dans le [[nombre de Reynolds]]. Dans l'expression de $Re$, $d$ caractérise le rapport entre force d'inertie et forces visqueuses. Dans le rapport $d/D$, $d$ traduit un aspect cinématique lié à la conservation du débit.*

Dans notre cas, il serait intéressant de définir un modèle du coefficient de décharge en fonction du rayon des pores, de la porosité et du niveau sonore (ou de la vitesse acoustique). 
$$\mathrm{C}_{\mathrm{D}}=f(r, v, n_{perf}*\pi*r^2 )$$
En fixant ces deux variables on définit nécessairement un certain nombre de perforations $n_{perf}$ et on supposera que leurs dispositions n'a aucun impact sur la mesure du coefficient de décharge.

L'article de Melling (mentionné précédemment) précise qu'il est important de **comparer les résultats des plaques perforées avec ceux d'une plaque équivalente à un seul pore**

**Mesure du coefficient de décharge**

> [!quote|yellow]+ Image ([page. 14](zotero://open-pdf/library/items/RZX5AHPP?page=14&annotation=DMYYUM77))
> ![[Zotero/FlowPipeOrifices/Images/FlowPipeOrifices-14-x106-y149.png]]

**Attention cette figure a été mesurée avec de l'eau**. Avec de l'air la viscosité est plus faible donc le nombre de Reynolds est plus grand.

Où est on sur ce graphe lorsqu'on atteint les forts niveaux?
Quelles différences entre Cd pour une ou 
plusieurs perforations?
Quel impact a le coefficient de décharge sur la résistance non-linéaire?
Comment peut on faire ces mesures au résistivimètre fort débit?

