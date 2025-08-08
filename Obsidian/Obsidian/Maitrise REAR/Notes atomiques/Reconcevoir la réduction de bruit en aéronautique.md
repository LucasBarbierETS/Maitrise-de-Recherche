Dans cet article, l'objectif est de :

> [!quote|blue]+ Highlight ([page. 1](zotero://open-pdf/library/items/PVLYAIGW?page=1&annotation=CC9FSYYN))
> étudier la pertinence d’un revêtement acoustique à réaction localisée afin de réduire la diffraction acoustique, voire augmenter la furtivité, de la poutre de queue d’un hélicoptère soumis au bruit du fenestron 

###### Feasibility of an acoustic liner applied to a Fenestron

> [!ABSTRACT]- ABSTRACT
>  
> A helicopter anti-torque system significantly contributes to radiated noise. The Fenestron™ anti-torque system used on Airbus helicopters, reduces this noise through masking effects and blade distribution modulation. This paper explores integrating acoustic treatments into the Fenestron™, similar to those used in aircraft engine nacelles, to further decrease the anti-torque system noise. Numerical simulations are performed to identify the optimal acoustic impedance for these liners, followed by proposing and assessing several liner designs on small-scale experimental benches. Finally, a larger-scale, more representative measurement campaign on a Fenestron™ mock-up with integrated liners demonstrates that a likely significant noise reduction can be attained.
> 

Metadata
> [!meta]- Metadata – [PDF](zotero://open-pdf/library/items/DQEVJAMJ)
> **Title**:: Feasibility of an acoustic liner applied to a Fenestron  
> **Authors**:: Victor Lafont, Delphine Sebbane, Frank Simon, Elia Pautard, Julien Caillet, Jean-Paul Pinacho,
> **Year**:: Error: `format` can only be applied to dates. Tried for format object 
>**ItemType**:: journalArticle
>**Journal**:: ** 
>
> 
>
> **Related**:: [[Faisabilité d'un revêtement acoustique furtif basé sur l'impédance: application aéronautique]], 

#### Reflexion

https://chatgpt.com/share/686e9101-71c4-800f-98dc-944e6a17dddc

**Idées importantes** :  
- On se fait une fausse idée du rapport entre la source le milieu et ce qu'introduit un traitement acoustique. Cette fausse idée vient d'une compréhension préscientifique du réel
- En repensant la situation on voit que l'initiative de réduction de bruit à un impact sur deux aspects conceptuellement distincts du problème : **dissiper plus** et **produire moins** 
- En agissant sur le système la contribution d'un traitement acoustique sur ces "champs de bataille" est **indistinguable** en tant que l'évaluation de la performance repose sur l'état du champ de pression qui dépend lui de ces deux choses prises ensemble

**NOTE** : Dans ce cas pourquoi séparer ces deux aspects? Parce que l'un n'explique pas l'autre ou que rien n'explique les deux en même temps. La condition d'impédance de surface est elle une formulation de ces deux aspects séparément ou de l'un des deux? L'un étant purement situationnel, **elle n'est alors plus une propriété intrinsèque**

### L'erreur de raisonnement, à l'origine de la méprise

La réduction du bruit est classiquement pensée comme une "lutte contre l'énergie acoustique" : on veut soit **absorber** cette énergie, soit **réduire** celle transmise par les sources *au sens de l'aménagement de l'environnement matériel de la source*. Cette perspective repose sur une vision apparemment causale : la **source** produit un champ acoustique, et c’est ce champ qu’on cherche à atténuer. Ce raisonnement serait le bon si il s'agissait d'une source d'eau (voir [[Perspective préscientifique d'un problème d'acoustique]])

Pourtant, cette vision ne résiste pas à une lecture plus fine des phénomènes acoustiques en régime établi.

Dans cette optique, la source **n’émet** pas seulement une onde ; elle **entretient** un champ acoustique autour d’elle. Ce champ, une fois établi, contient de l’énergie qui est à la fois **stockée localement**, **dissipée**, ou **rayonnée**. Ce n’est que parce que la source continue à fournir de l’énergie que ce champ persiste. Si la dissipation augmente, le champ rétrécit ; s’il diminue, le champ peut s’étendre.

Ainsi, le **champ acoustique s’ajuste dynamiquement**. Il tend à s’étendre autant que possible, mais est contraint par la capacité du milieu à le dissiper. Plus le champ s'étend, plus il est coûteux en énergie pour la source de le maintenir. L’équilibre s’établit là où l’énergie **fournie par la source** est **exactement compensée** par l’énergie **perdue dans le système** (absorption, rayonnement, fuites).

#### Une nouvelle "narration"

- On garde la conception énergétique
- La source travaille à créer un champ acoustique
- Le champ qu'elle cultive est au niveau de ses moyens : si elle est forte elle pourra l'agrandir mais il faut aussi pour cela qu'elle ait un pouvoir s'action sur l'environnement (métaphore du cycliste qui pédale à vide et qui ne travaille pas même si il est puissant)
- Le champ est le fruit du travail il n'est pas le travail, il est état d'un système qui a subit ce travail. Le champ n'est pas l'énergie. (**Est-il de l'énergie?**)
- Partout le champ subit l'inertie de la nature qui l'empêche de s'accroitre, il tend alors a disparaitre car la source "travaille" aussi a maintenir l'existant quand l'environnement s'y oppose
- Un champ intense demande plus de travail a être entretenu : pour optimiser son extension il y a forcement des endroits ou il doit réduire l'intensité pour avoir moins de travail a faire.
- L l'extension et l'intensité du champ s'équilibre précisément lorsque le travaill que la source peut fournir est la même que celle qu'il faut pour entretenir le champ
- Pour réduire le champ on peut mettre des bâtons dans les roues de la source, Elle a alors besoin de travailler plus localement pour entretenir son champ. A fortiori le champ diminue en amplitude a cet endroit mais la est le problème il s'agit d'une reconfiguration du travail réaliser par la source! Ainsi la source peut tout a fait diminuer le champ localement pour avoir moins de travail a faire et s'adapter à la nouvelle contrainte. Néanmoins par principe le résultat final sera une diminution de champ.
- La s'introduit les facteurs géométriques et s'arrête la métaphore : l'introduction de la solution fait qu'a certains endroits, le champ augmente en intensité, la source à alors plus de travail a réalisé pur le maintenir ainsi.
- Mais en plus le réarrangement géométrique fait qu'il est plus difficile à la source de travailler sur son environnement, elle n'arrive plus a donner autant d'énergie à tout son environnement, **quelle part d'énergie en moins est due à la géométrie et l'autre a la la dissipation?**

https://chatgpt.com/share/686e9101-71c4-800f-98dc-944e6a17dddc

Dans ce cadre, **deux stratégies** s’offrent pour réduire le bruit :

1. **Augmenter les pertes** (rendre le champ plus dissipatif).
    
2. **Empêcher la source de travailler efficacement** (la “couper” du champ qu’elle tente d’entretenir).

Toute modification du système agit en réalité sur **ces deux fronts simultanément**. Et paradoxalement, **l’amélioration d’un aspect** peut parfois **détériorer l’autre** : par exemple, en rendant le champ si résonant qu’il limite l’action de la source, mais stocke plus d’énergie ; ou inversement, en dissipant trop tôt l’onde, ce qui oblige la source à travailler plus fort en amont.

Autrement dit, il **n’y a pas de moyen de séparer proprement** l’effet de chaque traitement acoustique selon ces deux mécanismes. Le résultat ne peut être évalué qu’à travers **le champ résultant**, et non par l’attribution causale à l’une ou l’autre stratégie. Ces effets sont **inséparables au sens variationnel** : une variation du système induit une **réorganisation globale** des interactions entre la source, le champ et le milieu.

### Cas réel ? Ces deux combats sont-ils aussi important l'un que l'autre?

En champ libre : pas de reconfiguration spécifique du champ du fait de l'absorption : principalement absorbant
En tube : Les deux égaux voir la géométrie plus importantes
Hybride : quel est la limite pour l'approche modale? On considère alors purement l'absorption? 
### Relation fonctionnel de tout ça

#### Cas simple tube avec condition terminal rigide

1 tube fond rigide
2 tube side-branch quart d'onde (sans perte)
3 tube normal avec matériau
4 matériau rasant

On suppose ici que dans les deux situations la longueur sans matériau est la même pour pouvoir comparer deux situations comparables, bien qu'en vérité elles ne le soit pas, dans l'espace des géométrie avec et sans matériaux il n'y en a pas deux qui soit particulièrement proches et comparables au sens du champ qui s'y développe (ou alors je me trompe)
- Cas sans matériau
	- En régime établie, pour tout fréquence, indépendamment des résonnances propres du tube, le champ non dissipatif se stationarise (il le fait toujours en vérité au sens de l'action). Ici il se stationarise au sens ou le champ réflechi n'a pas perdu en amplitude, l'intensité acoustique s'annule partout, partout la pression et la vitesse sont en quadrature de phase. L'énergie ne se propage plus, ou alors de manière équivalente la source ne travaille plus sur le champ. L'impédance d'entrée vue par la source dépend de la relation entre la pression et la vitesse à l'entrée et dépend donc de la géométrie mais quoi qu'il en soit puisque la pression et la vitesse sont parfaitement en quadrature l'impédance est purement imaginaire (pas de pertes)
	- En introduisant une couche de matériau, on a plusieurs changement  : 
		- il n'est probablement même pas envisageable de considérer le nouveau champ dans le même espace de phase (mécanique hamiltonienne) a moins que le contour rigide du problème rester inchangés et que les degrés de libertés formulés soient identiques 
		- On introduit des pertes, ces pertes sont liés à la nouvelle géométrie et aux propriétés dissipatives du matériau, on ne peut pas connaitre ce qui appartient à l'un et à l'autre
		- Le champ ne peut plus se stationnariser sans que la source fournisse de l'énergie, conséquence la pression et la vitesse ne sont plus parfaitement en quadrature de phase, la puissance n'est plus nulle, la partie réelle de l'impédance d'entrée n'est plus.
		- **La puissance injectée par la source peut etre entièrement assignée aux pertes induites** dans le matériau, pour autant **on ne peut pas dire qu'on a ainsi caractérisé le matériau**. En effet les pertes dépendent de l'emplacement de ou il se trouvait (**cette propriété intrinsèque n'existe en fait pas au sens au rien de mesurable n'est l'image entièrement indépendante d'une mesure des pertes dans le matériau indépendant de la géométrie**)
	- A ce stade qu'est ce qu'on a appris/ mis en évidence : 
		- Les pertes créees sont contextuelles, toujours, bien qu'évidemment les propriétés du matériaux ne jouent pas aucun rôle
		- Comme les pertes sont diffuses et géométriques, la seule manière expérimentale comptable permettant d'évaluer les pertes et de mesurer l'impédance d'entrée de la source et de, à partir de sa partie réelle, définir la puissance induite. Problème : il est fort probable que l'écart de puissance entre la situation avec et sans traitement soit très faible car l'environnement entier dissipe toujours plus qu'un matériau localement aussi efficace soit il, cette mesure n'est donc pas vraiment praticable dans le cas général (peut etre en conduite à la limite, surtout en champ clos)
		- Pour l'instant on voit qu'il y a quand meme des choses à tirer :  
			- en tube on est capable de définir l'impédance de surface du matériau qui semble etre une grandeur reproductible et intrinsèque dans une certaines mesure : on est capable de la redéfinir pour n'importe quelle longueur **a condition de connaitre la longueur du dit tube!** en fait on la reconstitue suivant certaines hypothèses plus qu'on ne la connait au sens littérale. On sait alors que peut importe la longueur du prochain tube on sera capable de retrouve la même mesure, de plus la partie réelle de cette impédance peut probablement être associé à la partie réelle de l'impédance d'entrée associée aux pertes ( je n'ai pas de preuve de ca) encore que ca ne soit vraiment pas sur (est ce le cas en général? meme si l'échantillon est placé en incidence rasante)
			- On est capable de mesurer l'impédance d'entrée de la source (en théorie) et ainsi définir la dissipation du champ : **c'est à la fois ce qu'on cherche et pas vraiment!** Déjà en champ clos l'ajout d'un matériau reconfigure le champ et sa stationnarité. On sait qu'alors la plupart de l'énergie est stationnaire et qu'une très faible partie de celle ci se redirige vers les parties ou elle est dissipée. mais il n'en demeure pas moins que le champ existe toujours en amont du traitement, la reconfiguration de la géométrie à pu changer les fréquence propres, les résonnances et bien qu'en tout point on puisse définir une enveloppe stationnaire et de petite vague qui se propage, c'est notamment la partie enveloppe qui est perçue par l'oreille, alors **la reconfiguration du champ n'a a priori aucune raison de suivre parfaitement la réduction liée à la dissipation**.
	
	- *Idée : les modes sont les états stationnaires (non propagatif) supports qui permettent de transporter l'énergie : est ce que chaque mode propage sa propres énergie? Quelle différence entre les énergie propagée par les différents modes?
	- *Idée : Peut on séparer l'action de champ stationnaire et celle du champ propagatif?

On a alors à peu près tous les blocs pour redéfinir notre problème avec en plus la condition de champ non clos qui fait que la majorité de l'énergie est dissipée par l'environnement bien qu'il soit très peut dissipatif ainsi l'impédance d'entrée à bien une partie réelle non nulle ($\rho c$ j'imagine peut etre que je whippin) et le surplus associé aux pertes du matériau seront peanuts

Réponse : 
https://chatgpt.com/s/t_686fd3838ba48191be5383dc2e8e30ce

Vers un nouveau formalisme pour la réduction de bruit
https://chatgpt.com/share/686fbc04-f410-800f-b228-815aaac73575