Le modèle décrit permet de modéliser le comportement d'un matériau composé d'un assemblage de composantes élémentaires (plaques perforées, couche de matériau poreux, cavités, jonction). Pour les besoins de la méthodologie développée, ce modèle analytique de l'impédance de surface est intégré à un code plus large incluant différentes fonctionnalités supplémentaires

- [[Structure du code analytique, blocs en série et en parallèle]]

Dans le code il est possible de considérer plusieurs matériaux en parallèle est de définir la condition limite globale associé à l'ensemble des éléments juxtaposés. L'impédance de surface de plusieurs éléments en parallèle peut-être obtenue en réalisant la somme des admittances de chacun des éléments. Cette somme est pondérés par le rapport de surface de l'élément seul avec celle de l'ensemble. 
Cette approche est valide tant que l'hypothèse d'une impédance homogène de l'assemblage est vérifiée, ce qui est le cas en dessous d'une certaine fréquence de coupure dépendant des dimensions de l'assemblage ainsi constitué. Elle ne permet pas cependant de formuler la matrice de transfert de cet assemblage de manière fiable. Dans l'optique de rendre l'outil de conception plus flexible, une autre approche plus complète à été intégrer permettant ainsi d'assembler librement des blocs élémentaires en série et en parallèle.

#### Fonctionnalités supplémentaire (TL, mise en jonction, mise en jonction multiple)

Le méthodologie de conception a pour objectif d'être compatible avec un large panel d'application industrielle. On a vu que le modèle présenté était interprétable pour des incidences de champ normales ou obliques, pour lesquelles on pouvait explicitement définir un flux d'énergie acoustique pénétrant dans le matériau. Ceci n'est plus directement vrai lorsque le traitement est utilisé en conduite pour réduire le bruit en transmission car alors le comportement du matériau est fortement couplé avec le comportement propre de la conduite. L'incidence des ondes guidées par la conduite est rasante, il n'est plus possible d'estimer directement un flux d'énergie incident en projetant suivant la normale. On ne peut alors plus évaluer la performance d'un traitement à partir du coefficient d'absorption seulement, la formulation des pertes par transmission est alors nécessaire. 

Les pertes par transmission le long d'une conduite sont directement reliée à paramètres acoustiques effectifs de celle-ci. Si l'on se place en dessous de la fréquence de coupure de la conduite, celle-ci se comporte comme un guide d'onde à une dimension et le relations entre les grandeurs acoustiques pour différentes section de la conduite peuvent être décrites par des matrices de transfert tant que la conduite peut-être considérée comme acoustique homogène par morceau. La matrice de transfert d'un tronçon homogène de la conduite prend la même forme que celle de la couche de fluide équivalent élémentaire présentée précédemment. On formule les pertes par transmission à partir de la matrice de transfert globale suivant l'expression

> [!quote|yellow]+ Image ([page. 27](zotero://open-pdf/library/items/GNXTFEBQ?page=27&annotation=L929ZIHP))
> ![[Zotero/nicolasDeveloppementDunCode/Images/nicolasDeveloppementDunCode-32-x134-y388.png]]


On peut intégrer la prise en compte d'un traitement acoustique à la surface d'une conduite en repartant du principe de la conservation du débit 


> [!quote|yellow]+ Image ([page. 9](zotero://open-pdf/library/items/GNXTFEBQ?page=9&annotation=GDK2P74H))
> ![[Zotero/nicolasDeveloppementDunCode/Images/nicolasDeveloppementDunCode-14-x148-y466.png]]


On partir des relations  de continuité, on établit que :

> [!quote|yellow]+ Image ([page. 9](zotero://open-pdf/library/items/GNXTFEBQ?page=9&annotation=EWD8933D))
> ![[Zotero/nicolasDeveloppementDunCode/Images/nicolasDeveloppementDunCode-14-x152-y239.png]]

(Prendre garde aux convention pression débit. La division par $S_1$ n'est pas nécessaire qui la matrice est  exprimée en P-D
On peut alors voir un jonction comme une couche de fluide-équivalent d'épaisseur nulle dont l'impédance caractéristique serait l'impédance de surface du traitement considéré sur la surface de jonction apparente.
#### Modifications des paramètres semi-empiriques

Comme on l'a vu pour les modèle de plaque, certains paramètres sont obtenus de manière semi-empirique et ont une plage de validité limitée (coefficient de décharge, longueur de correction de l'épaisseur). De plus certains paramètres considérés dans leur plage de validitié peuvent ne plus être valide si le reste du matériau influence directement sur les caractéristiques du champ dans la couche considérée. C'est le cas par exemple si on considère une superposition de plusieurs plaques rapprochées auquel cas le rayonnement de chaque plaque sera contraints par la plaque suivantes et la longueur corrigées de l'épaisseur serait surestimées. 

Dans l'optique de pouvoir présélectionner des configurations adaptées à certains applications et leur contraintes, puis de les faire varier dans une plage paramétrique limités, il est est intéressant de pouvoir de pouvoir adapter manuellement les termes correctifs. Ainsi si on optimise parmi plusieurs configurations pour lesquelles un même terme correctif reste valide alors on peut raffiner spécifiquement le modèle a partir des résultats d'une validation numérique ou expérimentale.

#### Ecriture du code (programmation orientée objet, intégration dans une application)

L'intégration de ces éléments de modèle analytiques à été réalisée avec MATLAB. Des classes d'objets ont étés définis pour chaque blocs élémentaires intégrant leur paramètres et méthodes propres. Des méthodes communes on été réunies dans des classes parentes. Enfin des classes associées aux assemblages série et parallèles on était développée avec leur méthode d'intégration propre permettant toutes sortes d'assemblages imbriqués.

