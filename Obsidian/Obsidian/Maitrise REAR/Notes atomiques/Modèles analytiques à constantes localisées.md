Référence : *Acoustics, An introduction to its Physical Principles and Applications, Allan D. Pierce, p. 319

Les modèles analytiques à constantes localisées permettent de remplacer les champs scalaires et vectoriels (dépendance en temps et en espace) par des variables (scalaire, dépendance en temps uniquement) lorsque les conditions le permettent et que ces variables peuvent être interprétées physiquement. Cette formulation est possible pour les [[systèmes acoustiques à deux pores]], en particulier lorsqu'ils sont à réaction localisée.

En acoustique les variables préférentielles pour le passage à une formulation à constante localisée sont **le [[Débit volumique]]** et **la [[Pression moyenne pondérée]]**.

$$U_{S} = \iint_{S} \vec{v} \cdot \vec{n} \, dS$$
$$\bar{p}_{S} =\frac{\iint_{S} p \space\vec{v} \cdot \vec{n}\, dS}{U_{S}}$$
Avec cette formulation, on a la puissance acoustique transmise à travers la surface $S$ donnée par : $$P_{S} = \bar{p}_{S} \space U_{S}$$
Cette formulation permet de conserver le sens initial donné à l'impédance de surface d'après son intuition d'après l'étude empirique du résonateur de Helmholtz sans la dévoyer lorsque elle perd son interprétation physique. Pour aider à la compréhension, lorsque la pression en un point travaille et entraine le champ de vitesse en direction de la surface alors elle est comptabilisé mais elle ne l'est pas (ou partiellement) si la vitesse n'est pas colinéaire à sa normale. **C'est donc une comptabilité énergétique de la pression travaillante.** 

A partir de ces deux grandeurs on définit sur $S$ la **mobilité acoustique normalisée** $\underline{Y_{S}} = \frac{U_{S}}{\bar{p}_{S}}$ (admittance de surface) et la **rigidité acoustique normalisée** $\underline{Z_{S}} = \frac{\bar{p}_{S}}{U_{S}}$ (impédance de surface) qui traduisent la disposition de la surface à se mettre en mouvement lorsque elle est soumise à un potentiel d'action acoustique.


##### Cas particulier (général)

Dans le cas où :
- notre système à deux pores est un cylindre (conduit à section uniforme) d'axe $\vec{e_x}$
- ses sections d'entrées et de sorties sont planes et de normales colinéaires à $\vec{e_x}$
- la pression acoustique $p = p(x)$ est uniforme sur les sections d'entrée et de sortie
- la vitesse acoustique $\vec{v}= v(x) \space \vec{e_x}$ est uniforme et normale
Alors on a que

$$U_{s} = \pm \space v(x)$$
et $$\bar{p}_{S} = \pm \space p$$
suivant l'orientation de la normale des sections.
On retrouve les grandeurs usuelles de l'acoustique que sont la [[Pression acoustique totale]] et la [[Vitesse acoustique]].

