
L'acoustique est la discipline qui s'intéresse aux phénomènes sonores. Elle cherche à décrire, formuler, expliquer, la création de la propagation ou de la dissipation des sons.

Dans la pratique, l'acoustique moderne consiste en **l'étude des fluctuations de certaines grandeurs qui caractérisent l'état thermodynamique de la matière fluide** (l'air ou l'eau le plus souvent) **dans l'espace et le temps**. En particulier **l'acoustique linéaire s'intéressent à des fluctuations faibles de ces grandeurs autour de leur valeur statique**. Dans ces conditions les cycles de transformation de la matière peuvent être considérés comme réversible, adiabatique.
### Energie, Intensité, Sources sonores

L'acoustique repose sur une hiérarchie de grandeurs physiques qu'on mesure, déduit ou interprète, chacune ayant un statut expérimental ou théorique distinct. Il est fondamental de distinguer les relations entre pression, vitesse particulaire, intensité, énergie, signal, onde, transmission, et de comprendre les limitations associées à certains cas critiques.

https://chatgpt.com/canvas/shared/686db356060c819199adb6af497c8a5b

Énergie acoustique

- **Symbole :**
    
- Somme d'énergie cinétique et potentielle.
    
- Toujours positive, **peut exister sans transport net** (ex. onde stationnaire).

Intensité

- **Symbole :**
    
- **Produit scalaire moyenné** dans le temps entre pression et vitesse particulaire.
    
- Un vecteur qui indique la **direction du transport d'énergie**.
    
- Peut être nul localement même en présence d'ondes fortes (ex. onde stationnaire).
Le corolaire aux équations de conservation n'apporte rien, par rapport à la formulation de l'état du système, mais permet de définir la puissance d'une source acoustique (Acoustics, Pierce, p.39)


### Principes, variables et grandeurs d'étude
#### Raisonnement préscientifique

La compréhension des phénomènes acoustiques échappe souvent à une représentation unifiée en raison de **la complexité propre de ces phénomènes**, mais aussi en raison de **la structure même de notre imagination causale**.

En effet, notre rapport préscientifique (Gaston Bachelard, La formation de l'esprit scientifique) au monde est façonné par une série d’**intuitions héritées de l’expérience ordinaire** : le son "vient de quelque part", "une cause produit un effet", "l'énergie va d'un point à un autre", "les ondes se propagent comme des objets tangibles", etc.

Ces intuitions sont **efficaces sur le plan symbolique, poétique, ou narratif**, mais elles deviennent des obstacles lorsqu'il s'agit de saisir la **complexité fonctionnelle, dynamique, non-locale et réciproque** des phénomènes acoustiques.

La notion de source, par exemple, **n’est pas un foyer d’émission isolé**, mais un **nœud de couplage entre un système et un champ**. La propagation, loin d’être un simple "déplacement", est **une mise en relation globale de tout le système matériel** par une contrainte d'équilibre dynamique.

Ces éléments prennent un caractère privilégié dans notre entendement parce qu’ils sont associés à des **formes sensibles** (pression : tympan ; propagation : distance ; énergie : effort), mais ce privilège est **culturel, psychologique, et linguistique**, non ontologique.

#### Grandeurs privilégiées

Il est essentiel en acoustique de **ne pas confondre une grandeur mesurable (pression), une grandeur énergétique (intensité), et une grandeur ondulatoire (forme d’onde)**

En acoustique, il n’existe pas de grandeur « naturellement privilégiée ». Pression acoustique, vitesse particulaire, énergie, impédance, intensité : ces notions n’ont de sens qu’au sein d’un système de relations formelles. Elles ne prennent valeur qu’à travers :
 - leur **accessibilité expérimentale ou sensorielle** (par ex., la pression via l’audition),
- leur **nécessité conceptuelle ou théorique** (par ex., l’énergie pour exprimer une conservation),
 - ou leur **fonction structurante dans une loi de comportement** (par ex., l’impédance pour relier champ de pression et de vitesse à une frontière).

C’est uniquement **en fonction de ces besoins** (percevoir, mesurer, formuler) qu’une grandeur devient « utile » ou « naturelle ». Autrement dit, **le formalisme acoustique est intrinsèquement relationnel et contextuel**, et non hiérarchisé ou ontologique.

Par exemple, **la conservation de l'énergie dans les fluide est un corolaire redondant de la conservation de la masse et de la quantité de mouvement**. On peut donc se passer de l'énergie pour décrire un champ acoustique. Ce concept reste cependant utile pour l'interprétation de certains résultats et phénomènes, en particulier elle permet de définir simplement la puissance acoustique d'une source (Pierce, *Acoustics, An Introduction to Its Physical Principles and Applications*)

Il n'y a pas en acoustique de grandeurs privilégiées par rapport à d'autres. Pour ainsi dire, les concepts définis théoriquement (pression, vitesse, intensité acoustique, etc.) et formulés sous forme mathématique n'ont pas d'existence au delà de l'abstraction et qui plus est, toujours en relation les unes par rapport aux autres. Elles ne revêtent un caractère privilégié pour l'imaginaire que si elle sont directement reliés avec un phénomène mesurable, sensoriel ou à certaines loi de comportement du système qui nécessitent un support conceptuel pour etre formulée. Ainsi on utilise la pression que parce qu'elle est directement reliée à la perception auditive, on utilise l'énergie que parce elle est nécessaire à la formulation du principe de sa conservation, on utilise l'intensité que parce qu'elle est directement reliée à l'intuition de propagation de cette énergie.
#### Introduction au formalisme

Les grandeurs d'intérêts de l'acoustique sont **la pression $p$ et la vitesse $v$**. L'étude de ces relations impliquent d'autres grandeurs qui caractérise l'état de la matière dans l'espace et le temps: la **densité** $\rho$ et la **température acoustique** $\tau$. Chacune de ces grandeurs ($\Theta$) se présente sous la forme de la somme d'**une composante statique constante** ($\Theta_0$) et d'**une composante dynamique variable** ($\Theta'$) de moyenne temporelle nulle.  

On définit plusieurs propriétés du milieu qui décrivent les relations entre ces grandeurs : 
l'**impédance caractéristique $Z_{c}$**, la **célérité $c$**, le **nombre d'onde $k$**, la **densité $\rho$** et la **compressibilité $K$**. Ces variables sont redondantes, on privilégie les unes ou les autres en fonction de ce que l'on cherche à formuler. En particulier : ![[Propagation of Sound in Porous Media#^8fee5f]]$$c = \sqrt{\frac{K}{\rho}}$$ 
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
Ainsi formulé, un front d'onde se déplace à la vitesse de la phase $\phi = \omega t-k\vec{x}$ soit $c = \frac{\omega}{k}$.

[[Formulation complexe de la pression acoustique]] 
*Remarque : On étudie les solutions complexes de l'équation bien que la pression et la vitesse acoustique mesurables soit des grandeurs (respectivement) scalaire et vectorielle complexes. On considère alors que les grandeurs mesurables correspondent aux parties réelles des grandeurs complexes étudiées. 

Dans la pratique on associe un signal temporel à la 
### Energie, conservation et propagation

A partir des relations de conservations précédentes on peut déduire un corollaire qui traduit un **principe de conservation de l'énergie acoustique** :
$$\frac{\partial w}{\partial t} + \nabla \cdot I = 0$$
avec $w = \frac{1}{2}\rho_{0}v^{2}+\frac{1}{2}\frac{p^2}{\rho_0c^2}$ la somme de l'**énergie cinétique** et de l'**énergie potentielle acoustique** et $I = pv$ l'**intensité acoustique** ou **flux d'énergie acoustique**

Remarque :  En définissant une source acoustique en un point de l'espace, on impose un pression et un vitesse acoustique donnée mais de **le travail fourni par la source n'est pas constant dans le temps, il dépend de l'état transitoire ou établi du champ ainsi que de la dissipation qui à lieu dans le milieu de propagation**. En particulier dans le cas d'un régime acoustique établi sans perte, on observe des variations et des reconfigurations locales de l'énergie acoustique mais **le flux d'énergie moyen reste nul**.

### Dissipation, pertes visqueuses et thermiques

Dans la matière, la déperdition énergétique prend plusieurs formes : 
- **Le travail de forces non conservatives dans le milieu peut convertir une partie de l'énergie mécanique en énergie thermique**
- Les transformations thermodynamique de la matière n'étant pas parfaitement adiabatique, **une partie de l'énergie mécanique est perdue par création d'entropie** 

Dans un milieu dissipatif il est alors nécessaire de considérer la **viscosité dynamique** $\eta$, la **conductivité thermique** $\kappa$ et **capacité thermique massique** $C_p$ dans les relations de conservations et d'échange.
##### Pertes visqueuses

Au contact d'une paroi les couches de fluide subissent une force de frottement tangentielle qui s'oppose à leur déplacement, dans le sens opposé à celui du champ de vitesse. A proximité de la paroi, les couches sont cisaillées les unes par les autres du fait de la **viscosité dynamique** du milieu. Les couches éloignées entrainent les couches proches freinées par la paroi. Dans cette situation il y a une **diffusion du moment cinétique** dans le milieu en direction de la paroi. Cette diffusion se manifeste par un flux d'énergie dans la même direction. **L'énergie mécanique est ainsi détournée sous la forme d'un travail du milieu exercé sur la paroi**, travail qui se manifeste par l'échauffement de celle-ci, ou dans le cas d'une paroi isotherme par un transfert thermique depuis le fluide vers la paroi.

La diffusion du moment cinétique concerne une zone de l'espace limitée dans laquelle le champ de vitesse est déformée par les frottements visqueux. On définit une **couche limite visqueuse** à la surface de la paroi, dont l'épaisseur est appelée **longueur caractéristique visqueuse**

$$\Lambda = \sqrt{\frac{2\nu}{\omega}}$$

*Remarque : Cette longueur augmente avec la viscosité du fluide soit avec l'aptitude du fluide à s'opposer aux gradients de vitesse. 
##### Pertes thermiques

Des pertes d'énergie apparaissent à chaque cycle thermodynamique de la matière qui est traversée par un champ acoustique. Ces pertes prennent la forme d'une lente accumulation d'énergie thermique dans la matière, lorsque celle-ci n'est pas parfaitement restituée au cours des compression-détentes successives.
L'introduction d'un gradient thermique dans le milieu (contact à un paroi isotherme par exemple) entraine **la diffusion de cette énergie thermique accumulée**.

On définie une région de l'espace dans laquelle on considère que l'introduction d'un gradient thermique entraine un diffusion significative de cette énergie, appelée **couche limite thermique**. Son épaisseur est appelée **longueur caractéristique thermique** : ![[Propagation of Sound in Porous Media#^848f9b]]
*Remarque : Cette longueur augmente avec l'aptitude du milieu à conduire l'énergie et diminue avec son aptitude à la stocker.

*Remarque : Les longueurs caractéristiques thermique et visqueuse diminue toute les deux avec la fréquence. On peut comprendre cela en remarquant que dans les deux cas diffusion est d'autant plus importante que les gradients (de vitesse et de température) se maintiennent dans le temps ce qui est le cas lorsque la période de l'oscillation est plus grande. A haute fréquence, les gradients ne persistent pas assez et la diffusion est limitée.

#### Matériau acoustique, réflexion, transmission, absorption

##### Milieu stratifié, 1D, incidence normale

En appliquant les équations de l'acoustique à un milieu stratifié en 1D (*Propagation of Sound in Porous Media*, *figure 2.3*) on peut définir en amont et en aval du changement de milieu des ondes aller $p$ et retour $p'$ dont les amplitudes et les phases respectent les conditions de continuité de la pression et de la vitesse acoustique en $M$. On peut alors définir le [[coefficient de réflexion]] et le [[coefficient d'absorption]] : 

![[Propagation of Sound in Porous Media#^348f1e]]

![[Propagation of Sound in Porous Media#^4a19f2]]

avec $Z(M)$ l'impédance de surface en $M$ définie dès lors que que les conditions limites en aval sont définies ![[Propagation of Sound in Porous Media#^c50868]]
On voit ici que dans ce contexte on peut interpréter le coefficient d'absorption comme exprimant le rapport entre le flux d'énergie à travers une surface.

![[Propagation of Sound in Porous Media#^e5f578]]

#### Milieu stratifié, 2D, onde plane, incidence oblique 

Si on s'intéresse au développement d'une onde plane oblique dans un plan bistratifié (*[[Propagation of Sound in Porous Media|PSPM]], figure 3.3*) comme l'impédance est définie par rapport à la vitesse normale on a maintenant ![[Propagation of Sound in Porous Media#^5eb7f9]] 
On voit ici que l'angle d'incidence modifie la longueur du trajet réel des ondes dans le matériau 
($kd \space cos(\theta))$ et donc la quantité d'énergie absorbée mais l'expression corrige en même temps la formulation de l'impédance pour tenir compte du fait que **l'énergie n'est plus comptabilisée de la même manière**
- Transmission : rapport des puissances transmises
    
- Absorption : rapport de la puissance dissipée (ou non réfléchie)
    
- Ces grandeurs supposent un **champ incident connu** et **des hypothèses sur les champs de référence** (ex. onde plane).
##### Approche énergétique

Dans un milieu propagatif, le champ acoustique est constitué d'une superposition d'ondes ayant des amplitudes, fréquences, direction, géométries différentes. Lorsque on s'intéresse au traitement acoustique passif d'une surface rigide on souhaite poser un cadre formel permettant de relier les propriétés du matériau avec les 


### Approche modale

Relation contre-intuitive entre source, résonnance et énergie emmagasinée
https://chatgpt.com/share/6875146c-6868-800f-b63a-726cd01a6c66




