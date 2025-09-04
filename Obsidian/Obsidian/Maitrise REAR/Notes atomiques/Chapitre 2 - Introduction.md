 Dans le cadre du développement d'une méthodologie de conception et de dimensionnement. Il est important de définir un modèle généraliste, capable de fonctionner pour un panel large de solutions. 
 
Objectifs du modèle :
- prédire quantitativement l'impédance de surface de la solution en condition de laboratoire, prédire qualitativement (et non précisément) les performances industrielles, suivre les tendances réelles associées aux effets d'excitation réalistes
- Corriger empiriquement le modèle lorsque il est utilisé dans une gamme de paramètre donnée dans laquelle cette correction reste valide 

Nous nous limiterons à l'étude des solutions stratifiées (ou multicouches) et nous verrons dans le cas général quelles propriétés du champ acoustique on peut définir dans ces types de matériaux. continuité des grandeurs acoustique, continuité du débit)

Nous verrons ensuite quelles grandeurs d'intérêts peuvent être formalisées pour fournir une aperçu des performances acoustiques des matériaux

Après cela, nous verrons, en posant quelques hypothèses simples (incidence normale, onde plane), comment la description des solutions acoustiques peut-être standardisée et rendue modulaire (réaction localisée, matrices de transfert)

A partir de la nous décrirons comment tout matériau peut être représenté par des blocs élémentaires, dont les principe élémentaires sont ceux de la transmission line idéalisée (couche de poreux équivalent, jonction). On va voir comment le modèle JCA peut-être utilisé pour décrire des matériaux équivalent, (cavités avec pertes (quart d'onde), plaque perforées, jonction et admittance volumique)

Ensuite nous verrons comment on peut ramener les cas complexes à des cas simples grâce à des modèles équivalents et des termes correctifs (semi-empiriques)

Ensuite nous présenterons brièvement le reste des fonctionnalités attendus du code, et la structure de l'implémentation de la méthode

La seconde partie de la méthode est constituée de la validation des modèles analytiques en essayant de valider un maximum de modèles présenter dans la littérature 

A partir de la structure de ce code nous verrons dans quel mesure il est possible d'intégrer la prise en compte des conditions réelles d'excitation, de tenir compte des paramètres de l'environnement mais aussi de la géométrie suivant laquelle la solution est intégrée


