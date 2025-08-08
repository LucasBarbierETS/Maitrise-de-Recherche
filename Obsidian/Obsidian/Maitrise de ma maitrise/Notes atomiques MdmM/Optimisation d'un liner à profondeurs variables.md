
### Optimization of Variable Depth Acoustic Liners with Grazing Flow
[Galles et al. - 2024 - Optimization of Variable Depth Acoustic Liners wit.pdf](zotero://select/library/items/DQLLS959)

[[galles2024]] 
#### Contexte et objectif 

Cet article se place de contexte de la [[réduction de bruit en aéronautique]]. Il s'intéresse à l'optimisation d'un [[liner acoustique pour le carénage d'un rotor]] dans le cadre du projet de taxi-volant [[Revolutionary Vertical Lift Technolgy (RVLT)]] développé par la NASA.

Les objectifs de cet article sont :

- **présenter et illustrer la [[méthode d'optimisation directe]]**  
- **introduire la [[prise en compte de l'écoulement]] dans le design de liner acoustique**


![[image-3-x65-y581.png]]

#### Contenu scientifique 

L'article décrit le principe de fonctionnement de la [[méthode d'optimisation directe]]. Cette méthode est utilisée pour l'optimisation d'un [[liner à profondeur variable]] composé de plusieurs résonateurs quart d'onde en parallèle. Les résultats sont comparés avec ceux d'une étude précédente (voir plus bas) portant sur la [[méthode d'optimisation indirecte]].

Les configurations optimisées sont modélisées avec un [[modèle réaliste de l'impédance de surface d'un liner]] des configurations tenant compte des forts niveaux. L'impédance de surface est alors utilisée pour résoudre l'[[équation de Helmholtz convectée en 2D]] dans un code de propagation par élements finis.

Finalement les configurations sont imprimées en 3D par [[stéréolithographie]] est testée dans un [[tube d'impédance à écoulement rasant]]. Leur impédence est calculée par la [[méthode de Prony]] et comparée avec les résultats anayltiques.

#### Protocole d'optimisation

##### Fréquences cibles

Les [[fréquences cibles pour l'optimition]] sont la [[fréquence de passage des pâles]]  ($f_b \approx 200 Hz$) et ses [[harmoniques]] qui contribuent fortement un niveau d'émission sonore globale du véhicule.

La [[fréquence de coupure de tube d'impédance]] est de $2700 Hz$, ainsi les fréquences situées au dessus de cette limite sont négligées.

L'article s'intéresse au [[niveau de pression dBA]]. L'utilisation d'un [[filtre de pondération de type A]] diminue fortement les niveaux sonore en dessous de $1000 Hz$ relativement aux niveaux entre $1000 Hz$ et $3000 Hz$ ainsi l'hypothèse est faite qu'en dessous de 1000 Hz les émission n'impactent plus le niveau dBA.

Finalement l'article porte son intérêt sur les harmoniques situées entre $1000 Hz$ et $2700 Hz$.

##### Estimation de la vitesse d'écoulement

Il a été choisi d'estimer la [[vitesse de l'écoulement dans le rotor]] en [[condition de vol statique (hover)]]. Le [[nombre de Mach]] estimé dans l'article est de $0.112$. Pour les calculs numériques et expérimentaux, le [[nombre de Mach en ligne centrale]] est de $0.1$ avec un nombre de Mach moyen à $0.083$.

##### Paramètres d'optimisation

L'optimisation porte sur 5 longueurs associées aux profondeurs des cavités. Le liner est la répétition d'une cellule périodique, elle même consitutée d'un assemblage de résonateurs quarts d'onde en parallèle.

**4 Configurations sont testées : 
- 2 configurations testées par méthode d'optimisation
- Pour chaque méthode d'optimisation deux pondérations sont utilisées pour définir la [[fonction coût]] : **une pondération uniforme** et **une pondération passe-bas** 

Aucune optimisation n'a été réalisé pour les plaques. Toutes les plaques utilisées dans l'article sont identiques.

#### Idées clés de l'article

- **L'[[fonction coût#Pondération fréquentielle|utilisation d'une pondération fréquentielle lors de la définition de la fonction coût]] semble avoir plus d'impact pour la méthode directe que la méthode indirecte.**

- **En essayant de maximiser l'atténuation à toutes les fréquences par optimisation directe on obtient des bandes de coupures dans l'atténuation** et donc des performances larges bandes amoindries. **Pour y remédier il serait intéressant d'ajouter une [[fonction coût#Pénalité additionelle|pénalité additionelle]] pour les grands écarts dans la fonction coût.**

- L'impédance optimale obtenue par méthode indirecte permet de calculer une atténation réaliste. Pour tenir compte de ce résultat interédiaire dans la méthode directe on peut : 
	- 1. **[[spectre d'atténuation réaliste|Redéfinir un spectre d'atténation réaliste]]** 
	- 2.  **Modifier la pondération de la fonction coût**

- [[algorithme Basin - Hopping|L'algorithme d'optimisation basé sur le gradient]] utilisé dans cet article pourrait entrainer la convergence vers un extremum local.

- La définition de la fonction coût sur l'impédance pour la méthode indirecte n'est pas judicieuse puisque les plaques perforées qui pilotent la résitance acoustique ne font pas partie de l'optimisation. **[[fonction coût#Evaluation sur la réactance acoustique|Une évaluation basée sur la réactance acoustique aurait été plus adaptée]]**.

#### Travaux assossiés


- Dans *An Acoustic Liner Design Methodology Based on a Statistical Source Model,* Nark, D. M. fait une description détaillée de la [[méthode d'optimisation indirecte]].

- Dans *Global Optimization by Basin-Hopping and the Lowest Energy Structures of Lennard-Jones Clusters Containing up to 110 Atoms, Wales, D. J* applique la méthode indirecte pour l'optimisation d'un [[liner à profondeur variable]].

- Dans *A Review of Acoustic Liner Experimental Characterization at NASA Langley* Jones, M. G décrit en détail de code de propagation en tube utilisé pour appliquée la méthode directe.

- Dans *Broadband and Low-Frequency Acoustic Liner Investigations at NASA and ONERA*, Jones, M. G. présente le [[modèle réaliste de l'impédance de surface d'un liner]] utilisé dans cet article.


## Questions



## Evaluation de la note
