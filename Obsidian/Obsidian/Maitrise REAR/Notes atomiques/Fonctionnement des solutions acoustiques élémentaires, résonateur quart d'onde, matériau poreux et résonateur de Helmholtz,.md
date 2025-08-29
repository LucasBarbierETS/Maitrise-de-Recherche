
Les deux solutions acoustiques les plus élémentaires sont le résonateur quart d'onde et le résonateur de Helmholtz. Ces deux dispositifs permettent d'introduire les principes de fonctionnement de base des autres solutions acoustiques plus complexes ainsi que les relations entre effets dissipatifs et réactifs. La compréhension de ces effets est importante pour penser la conception et le dimensionnement de traitements acoustiques adaptés à des applications spécifiques.
#### Le résonateur quart d'onde 

Le résonateur quart d'onde est constitué d'une cavité droite ou d'une cavité repliée de largeur inférieure à la longueur d'onde considérée de telle sorte qu'on puisse garantir une propagation acoustique normale à la section dans la cavité. Dans cette cavité, on considère des pertes visqueuses au niveau des parois ainsi qu'une condition de réflexion totale au fond de la cavité (terminaison rigide) ce qui permet de garantir une vitesse acoustique nulle. Lorsque une onde acoustique dont la longueur d'onde est le quadruple de la longueur de la cavité attend le résonateur à incidence normale, l'interférence entre l'onde incidente et l'onde réfléchie produit une onde résultante donc l'amplitude en vitesse est maximale à la surface. Les fréquences qui vérifient cette condition sont les fréquence dites "propres" du résonateur. Comme en régime linéaire les pertes sont proportionnelles à la vitesse, on obtient donc à la fréquence dite "quart d 'onde" une valeur maximale des pertes pariétales cumulées (intégrées) suivant la profondeur du résonateur et ainsi un premier pic d'absorption. À mesure que la fréquence augmente, le profil de vitesse se modifie : la vitesse en entrée décroît et les pertes cumulées diminuent, ce qui réduit l’absorption. On observe cependant de nouveaux pics lorsque la cavité mesure $3\lambda/4, 5\lambda/4, ...$  soit aux **résonances impaires multiples** de la fréquence quart d’onde.


> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/BPTKL425?page=3&annotation=NGR524WY))
> ![[Zotero/jonesEvaluationVariableDepthLiner2015/Images/jonesEvaluationVariableDepthLiner2015-4-x69-y294.png]]

> [!quote|yellow]+ Image ([page. 23](zotero://open-pdf/library/items/WGDWB5NW?page=23&annotation=HKERTVTR))
> ![[Zotero/jones2022/Images/jones2022-24-x166-y229.png]]


Pour le résonateur quart d'onde on a des effets dissipatifs diffus tout au long de la cavité et un effet réactif qui n'est pas vraiment lié à la forme du résonateur (on pourrait avoir des parois ondulées, repliées ou courbes, par exemple) mais seulement à sa longueur. Les effets réactifs sont alors pilotés par la géométrie globale. 

##### Cas spécifique d'une cavité quart d'onde poreuse

Un matériau poreux est constitué d’une matrice à pores ouverts, où l’air s’écoule de manière tortueuse à travers un réseau de cavités microscopiques. La surface de contact entre le fluide et matrice est alors considérablement accru, et les pertes visco-thermiques qui se concentraient principalement au niveau des parois sont maintenant diffuse dans l'ensemble du matériau.
De plus l'ordre de grandeurs des pores impliquent que les pertes thermiques ne peuvent plus être négligées. Lorsque on souhaite réduire le niveau bruit et donc dissiper de l'énergie acoustique on peut utiliser des couches de matériaux poreux au dessus d'une paroi rigide (avec ou sans lame d'air entre les deux) si l'application s'y prête. L'introduction de pertes diffuses dans la matrice poreuse va empêcher la formation d'une onde résultante nette composée de deux ondes (incidente et réfléchie) uniques. Cela a pour conséquences d'altérer les effets réactifs initialement associées à la cavité remplie du fluide (air) seul.

#### Le résonateur de Helmholtz

Le cas du résonateur de Helmholtz diffère sensiblement de celui du résonateur quart d’onde. Sa configuration classique associe un col étroit et allongé à une cavité de volume quelconque. Cette géométrie en deux parties permet d’introduire des hypothèses distinctes : dans la cavité, une variation de pression entraîne une forte variation de volume, traduisant une compressibilité marquée. À l’inverse, dans le col, la pression est supposée uniforme entre l’entrée et la sortie, de sorte que l’air y est considéré comme faiblement compressible. On parle alors de **compliance** pour la cavité et d’**inertance** pour le col.

> [!quote|yellow]+ Image ([page. 49](zotero://open-pdf/library/items/CMZQ7B9B?page=49&annotation=NIHVXQTQ))
> ![[Zotero/TheseLaly/Images/TheseLaly-49-x126-y502.png]]

Soumis à une excitation harmonique, l’air contenu dans le col se comporte comme une masse reliée à un ressort, la cavité jouant le rôle de ce dernier. L’analogie mécanique du système masse –ressort permet ainsi de décrire la vitesse acoustique dans le col. Dans cette configuration, les pertes acoustiques proviennent principalement du col, et très peu du volume. Il ne s’agit donc plus d’intégrer les pertes le long de la cavité, mais bien de maximiser la vitesse acoustique dans le col. La cavité arrière n’assume plus de rôle dissipatif, mais uniquement un rôle réactif, gouverné par son **admittance volumique**. L’élément déterminant n’est donc plus la longueur de la cavité, mais son volume. Si toutefois la cavité est de forme droite, le volume se trouve lié à sa longueur, et le comportement tend à se rapprocher de celui d’un résonateur quart d’onde. La résolution différentielle du système masse-ressort équivalent nous donne la première fréquence de résonance appelée **fréquence de Helmholtz** : 

$$f_H=\frac{c}{2 \pi} \sqrt{\frac{S}{V L_{\mathrm{eff}}}}$$

Le col concentre à la fois des effets résistifs et réactifs : il conditionne le niveau de pertes dissipatives, mais aussi les effets inertiels liés au rayonnement. De cette façon, un résonateur de Helmholtz peut offrir soit des performances en bande plus large lorsque son facteur de qualité est faible (col à section large)
$$Q \propto \sqrt{\frac{L_{\mathrm{eff}}}{S V}}$$
soit un fonctionnement à des fréquences plus basses que celles d’un quart d’onde équivalent (col long et étroit) Dans cette configuration, les pertes acoustiques surviennent principalement dans le col du résonateur et très peu à l'intérieur du volume. Il n'est plus question d'intégrer les pertes le long du résonateur mais seulement de maximiser la vitesse acoustique dans le col. La cavité arrière n'a plus de rôle dissipatif mais seulement un rôle réactif qu'elle contrôle via son admittance volumique. Ici ce n'est donc plus la longueur qui est importante mais le volume. Si toutefois la cavité reste droite alors le volume sera relié à sa longueur on alors on a un comportement s'approchant de celui du résonateur quart d'onde. Le col, de son côté, cumule des effets résistifs et réactifs, il contrôle le niveau des pertes mais aussi les effets inertiels dû au rayonnement.  De cette façon il est possible d'obtenir des performances plus large bande si on a un facteur de qualité faible ou bien plus bas en fréquence que le quart d'onde équivalent si on a des des perforations étroites (bcp d'inertie).


Cette fois-ci on a des effets dissipatifs localisés et des effets réactifs séparés. On peut piloter les performances souhaitées à partir du volume et des dimensions du col. On a cependant toujours une limitations physique qui nous empêche de descendre en fréquence, cette fois directement reliée au volume.  

Avec ces deux exemples simplifier on voit que : 

-  La **dissipation en acoustique** est liée à différents mécanismes, sur les surfaces comme dans le volume, qui convertissent l’énergie mécanique en énergie thermique (effets visqueux et thermiques). Cette énergie dissipée est ensuite évacuée par des transferts de chaleur vers les parois.
- La **dissipation totale** de l’énergie dans un matériau correspond à la somme (ou à l’intégrale) de toutes les dissipations locales qui surviennent en son sein.
- Les **effets réactifs** sont le résultat du couplage entre les différentes parties inhomogènes qui composent un matériau acoustique, et non la simple addition d’effets réactifs séparés. Ce sont eux qui déterminent principalement les **fréquences de résonance** où la dissipation est maximisée.
- L’**efficacité d’un traitement acoustique** pour remplir une fonction donnée dépend de l’association judicieuse de ses propriétés dissipatives et réactives.
- Aucune partie d’une solution acoustique ne peut être introduite sans **altérer les propriétés réactives** de l’ensemble. En particulier les modifications des propriétés dissipatives d'un matériau à géométrie constante ont également un impact sur le comportement réactifs globale. Il faut toutefois rappelé qu'il est possible qu’une partie d’un dispositif acoustique n’apporte que peu ou pas d’effet résistif. Une approche intéressante consiste alors à **ajuster ces éléments réactifs** de manière à obtenir la configuration la plus pertinente, adaptée à l’état des pertes du système, sans les dégrader davantage.
