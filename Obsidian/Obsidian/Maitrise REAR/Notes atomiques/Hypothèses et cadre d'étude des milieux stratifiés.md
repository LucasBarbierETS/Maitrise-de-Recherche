
#### Conservation du débit

Pour définir le cadre de notre modèle, partons d’une situation simple où le champ acoustique se développe au sein d’un matériau stratifié de section finie.  
On suppose que le champ est normal à la surface pour chacune des couches du matériau. On considère que les propriétés acoustiques (impédance caractéristique, célérité, nombre d'onde etc.) sont **homogènes par morceau** (pas d’effets de bords ni de frottement aux parois). Le champ acoustique qui se développe dans le matériau est donc unidimensionnel.

Dans cette situation : 

- À chaque interface, il y a continuité de la **pression** et du **débit acoustique**, du fait de la conservation du flux massique. Si les sections amont et aval diffèrent, la continuité de la vitesse n’est pas garantie. Il est alors judicieux d’exprimer le champ acoustique selon la **convention Pression – Débit** avec $u = v S$ où $v$ est la vitesse acoustique totale et $S$ la section.



- Au sein d'une couche, la composante du champ acoustique issu de la superposition des ondes aller et retour à une fréquence donnée peut être défini par une forme explicite unique dépendant de la position suivant la direction normale à la couche. Il est alors possible d'établir une relation entre les grandeurs acoustiques considérées au niveau des deux interfaces de la couche ($p_i, u_i, p_i', u_i'$) . Cette relation peut s'exprimer à l'aide d'une **matrice de transfert** :
$$
\begin{bmatrix} \ p_{i} \\ u_{i} \end{bmatrix} 
= TM_i\begin{bmatrix} \ p_{i}' \\ u_{i}' \end{bmatrix} 
= \begin{bmatrix} \cos(k_{i}d) & j*Z_{{c}_{i}}\sin(k_{i}d) \\ j*\frac{\sin(k_{i}d)}{Z_{{c}_{i}}} & \cos(k_{i}d) \\ \end{bmatrix}
\begin{bmatrix} \ p_{i}' \\ u_{i}' \end{bmatrix} 
$$
Avec $d$ l'épaisseur de la couche. Cette matrice existe pour chaque composante monochromatique du champ. Chacun de ses termes dépend donc de la fréquence considérée. 

Pour un matériau $M$ composé de plusieurs couches superposées, il est alors possible d'établir une matrice de transfert globale reliant les grandeurs acoustiques à l'entrée et à la sortie de celui-ci. Pour cela il suffit de réaliser le produit des matrices de transfert élémentaires successives : 
$$
\begin{bmatrix} \ p_{M} \\ u_{M} \end{bmatrix} 
= TM_{M}\begin{bmatrix} \ p_{M}' \\ u_{M}' \end{bmatrix} 
= \prod T M_i\begin{bmatrix} \ p_{M}' \\ u_{M}' \end{bmatrix} 
$$
#### Caractérisation des matériaux et grandeurs d'expression des performances

Une fois que l'on sait comment décrire les relations du champ en amont et en aval d'un matériau stratifié, il faut maintenant remonter aux relations ces grandeurs entre elle au niveau de la surface libre du matériau. On considère que le matériau dispose d'un fond rigide ce qui permet de poser $u_{M}= 0$. Il est alors possible d'établir que :
$$\frac{p_M}{u_{M}}= \frac{TM_{1,1}}{TM_{2,1}}$$
On définit **l'impédance de surface $Z_s$**  du matériau en remontant à la formulation suivant la **convention Pression - Vitesse** en multipliant le rapport précédent par sa surface libre : 

$$Z_{s}= S_{M}* \frac{TM_{1,1}}{TM_{2,1}}$$
L'impédance de surface est la condition limite en surface imposée par le comportement acoustique global du matériau. Les performances attendues du matériau sont évaluer par son **coefficient d'absorption**, grandeur dérivée de $Z_s$ :

$$\alpha = 1 - \left|\frac{Zs - Z_0)}{Zs + Z_0)} \right|^2$$
avec $Z_0$ l'impédance caractéristique de l'air.
#### Relations entre grandeurs virtuelles et aspects énergétiques 

On définit par ailleurs le coefficient de réflexion $R$ : 
$$ R = \left|\frac{Zs - Z_0)}{Zs + Z_0)} \right|$$
On peut montrer que ce coefficient exprime le rapport entre les amplitudes des ondes retour et aller du champ acoustique à la surface du matériau. En incidence normale, ces amplitudes sont reliées directement au contenu énergétique du champ. Le coefficient d'absorption correspond alors directement au rapport entre les flux d'énergie évalués au niveau de la surface dans les deux directions. Si le matériau est fermé, le flux sortant correspond à l'énergie réfléchie par le matériau.

On voit que l'on peut alors réexprimer le coefficient d'absorption suivant la formulation
![[Propagation of Sound in Porous Media#^4a19f2]]

Ce coefficient quantifie donc directement l'aptitude du matériau à dissiper d'énergie qui atteint sa surface. Plus il est grand, moins le matériau restitue à l'environnement extérieur l'énergie qu'il reçoit.

#### Généralisation et hypothèses géométriques

Le modèle développé permet, à partir de la description des relations locales du champ acoustique de traduire le comportement global d'un matériau par une relation entre les grandeurs acoustiques à sa en surface. Il est alors possible d'évaluer ses performances en termes d’absorption énergétique.

On a fait l’hypothèse que les ondes se développent en **ondes planes** dans le matériau, que le champ est uniforme suivant la direction transverse à la normale, et qu’il peut donc être décrit entièrement par la donnée **ponctuelle** de la pression et du débit (ou vitesse) pour chaque section.

Le cas de figure où le problème peut-être décrit par des variables localisées correspond à un comportement dit à **réaction localisée**
L'hypothèse de ce comportement est valide tant que la fréquence considérée ne dépasse pas la fréquence de coupure du matériau pour laquelle la demi-longueur d'onde devient inférieur à la dimension transversale du matériau. 

Dans les matériaux conventionnels utilisés en aéronautique, l'introduction d'une structure compartimentée (NIDA) permet de garantir que les cavités sont plus longues que larges et ainsi que cette hypothèse est vérifiée.

Si la propagation normale à la surface est garantie dans le matériau alors la formulation de la condition limite en surface garde son interprétabilité énergétique même lorsque le champ incident n'est plus à incidence normale. En effet le flux énergétique incident correspond à la projection normale de l'intensité acoustique. La même proportion d'énergie est absorbé, le champ réfléchi respecte alors loi de réflexion de Snell-Descartes pour l'acoustique géométrique.

