Dans la pratique, l'acoustique moderne consiste en **l'étude des fluctuations de certaines grandeurs qui caractérisent l'état thermodynamique de la matière fluide** (l'air ou l'eau le plus souvent) **dans l'espace et le temps**. En particulier **l'acoustique linéaire s'intéressent à des fluctuations faibles de ces grandeurs autour de leur valeur statique**. On considère également que les cycles de transformation de la matière peuvent être considérés comme réversible, adiabatique. 

Les grandeurs d'intérêts de l'acoustique sont **la pression $p$ et la vitesse $v$**. L'étude de ces relations impliquent d'autres grandeurs qui caractérisent l'état de la matière dans l'espace et le temps: la **densité** $\rho$ et la **température acoustique** $\tau$. Chacune de ces grandeurs ($\Theta$) se présente sous la forme de la somme d'**une composante statique constante** ($\Theta_0$) et d'**une composante dynamique variable** 
($\Theta'$) de moyenne temporelle nulle.  

On définit plusieurs propriétés du milieu qui décrivent les relations entre ces grandeurs : 
l'**impédance caractéristique $Z_{c}$**, la **célérité $c$**, la **densité $\rho$** et la **compressibilité $K$**. 
On a en effet : $$Z_{c} = \frac{p}{v}$$
Avec $p$ et $v$ la pression et la vitesse d'une onde purement progressive, monochromatique.

Ces variables sont redondantes, on privilégie les unes ou les autres en fonction de ce que l'on cherche à formuler. 

En particulier : ![[Propagation of Sound in Porous Media#^035d50]]et $$c = \sqrt{\frac{K}{\rho}}$$
En **acoustique linéaire**, plusieurs principes physiques sont à la base de la formulation des relations entre la vitesse et la pression acoustique. Ces principes, valables en tout point de l'espace sont : 

- le principe de **conservation de la masse** : pour un volume donné, la perte de la masse qu'il renferme à un instant $t$ est égal au flux massique qui traverse sa surface. Une formulation locale de ce principe s'écrit : 
$$\frac{\partial \rho}{\partial t} = - \rho_{0} \space \nabla \cdot \vec{v}$$
- le principe de conservation **de la quantité de mouvement**. en particulier l'équation d'Euler linéarisée est une reformulation locale de la $2^{nd}$ loi de Newton dans le cas ou l'on considère seulement les forces de pression parmi l'ensemble des forces conservatives en jeu : 
$$\nabla p = - \rho_{0} \space \frac{\partial \vec{v}}{\partial t}$$
- la **loi d'état thermodynamique** pour une transformations adiabatique.
$$p = c^{2}\space \rho$$
### Propagation des ondes de pression et de vitesse

A partir des relations précédentes on obtient l'[[Equation d'Helmholtz]] : ($\theta = p, v$) 

![[Equation d'Helmholtz#^a22dee]]

dont l'onde monochromatique est la solution non triviale la plus simple : 
$$p(\vec{x}, \omega, t) = A(\vec{x})e^{i(\omega t-k\vec{x})}+B(\vec{x})e^{i(\omega t+k\vec{x})}$$
$$v(\vec{x}, \omega, t) = \frac{A(\vec{x})}{Z_c}e^{i(\omega t-k\vec{x})}-\frac{B(\vec{x})}{Z_c}e^{i(\omega t+k\vec{x})}$$
Cette solution correspond à la superposition de deux ondes de même fréquence $\frac{\omega}{2*\pi}$, de même direction et de sens opposé.

*Remarque : On étudie les solutions complexes de l'équation bien que la pression et la vitesse acoustique mesurables soit des grandeurs (respectivement) scalaire et vectorielle réelles. On considère alors que les grandeurs mesurables correspondent aux parties réelles des grandeurs complexes étudiées. 

Il existe autant de solutions à cette équation que de $A, B$ et $\omega$ différents avec $k = \frac{\omega}{c}$ . Comme l'équation est linéaire, toutes les combinaisons linéaires d'ondes monochromatiques respectent aussi les principes physiques énoncés.
### Energie, conservation et propagation

A partir des relations de conservations précédentes on peut déduire un corollaire qui traduit un **principe de conservation de l'énergie acoustique** :
$$\frac{\partial w}{\partial t} + \nabla \cdot I = 0$$
avec $w = \frac{1}{2}\rho_{0}v^{2}+\frac{1}{2}\frac{p^2}{\rho_0c^2}$ la somme de l'**énergie cinétique** et de l'**énergie potentielle acoustique** et $I = pv$ l'**intensité acoustique** ou **flux d'énergie acoustique**

Remarque :  En définissant une source acoustique en un point de l'espace, on impose un pression et un vitesse acoustique donnée mais de **le travail fourni par la source n'est pas constant dans le temps, il dépend de l'état transitoire ou établi du champ ainsi que de la dissipation qui à lieu dans le milieu de propagation**. En particulier dans le cas d'un régime acoustique établi sans perte, on observe des variations et des reconfigurations locales de l'énergie acoustique mais **le flux d'énergie moyen reste nul**.
