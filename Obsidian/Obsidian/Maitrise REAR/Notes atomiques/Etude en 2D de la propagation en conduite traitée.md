#### Cas 1 : Conduite traitée en x = b, sans écoulement

$$ p_1(x, z>0, t) = (C_{1} e^{-j k_z z}+C_2 e^{j k_z z})(e^{-j k_x x}+C_3 e^{j k_x x})e^{{j\omega t}}$$ 
Avec pour condition limite suivant $x$, $Z_{x} = \frac{p(b,z,t)}{u_{x}(b,z,t)}$  et $u_{x}(0, z, t) = 0$  
 Par ailleurs on sait que ![[Acoustics of Ducts and Mufflers#^182ae7]]
 soit $$ u_x(x, z, t) = -\frac{k_x}{\omega \rho_0}(C_{1} e^{-j k_z z}+C_2 e^{j k_z z})(C_3 e^{j k_x x}-e^{-j k_x x})e^{{j\omega t}}$$ 
 On obtient alors $C_{3}= 1$. On peut alors réécrire 
$$ p_1(x, z, t) = \sum_{n=0}^{+\infty} 2*cos(k_{1, x, n}x)(C_{1, 1, n} e^{-j k_{1,z,n} z}+C_{1, 2, n} e^{j k_{1, z, n} z})e^{{j\omega t}}$$
 avec  $$Z_{x}= -\frac{j\omega \rho0}{k_{1,x,n}}tan(k_{1,x, n}b)$$
L'équation précédente est **transcendante**, on ne connait pas de forme explicite pour la fonction inverse de $\tan(x)/x$. On retrouver les racines de cette fonction à l'aide de méthode numérique.

Le nombre d'onde axial $k_{z,n}$ associé au mode transversal $n$ est donné par la relation

![[Acoustics of Ducts and Mufflers#^7408b6]]

Cette relation, valable pour tout mode à une fréquence donnée, traduit un lien entre la norme du vecteur d'onde $\vec{k_0}$, constante pour une fréquence donnée car **reliée aux propriétés locales intrinsèques** du milieu et ses coordonnées possibles **dépendantes de la géométrie globale du système et de ses conditions limites**.

Cette relation de dispersion complexe nous indique qu'il n'y a qu'un nombre fini de modes propagatif.

Si $Z_x$ n'est pas infini, alors les $k_{1, x}$ sont non nuls **il n'y a donc aucun mode plan qui peux se développer dans la conduite traitée**

Dans la section de conduite traité (supposée infinie), à une pulsation $\omega$ donnée, le champ peut donc seulement prendre la forme d'une telle somme.

#### Cas 2 : Couplage avec une conduite non traitée en z = 0
$$p_2(x, z<0, t)=\sum_{m=0}^{+\infty} \cos \left(\frac{m \pi x}{b}\right)\left[C_{2, 1, m} e^{-j k_{2, x, m}x} + C_{2, 2, m} e^{-j k_{2, x, m}x}\right]e^{{j(\omega t + \phi)}}. 
$$avec
$$k_{2, z, m}=\sqrt{k_0-\left(\frac{m \pi}{b}\right)^2}$$ 
Si on impose un source plane en $z_s < 0$ alors on impose une propagation d'énergie suivant un mode plan dans la conduite non traitée. A l'interface l'énergie se conserve. Or on sait qu'aucun mode plan n'existe dans la conduite traitée. Intuitivement l'énergie sous forme plane va exciter et se transférer sur les modes symétriques admissibles de la conduite traitée. Plus le degré du mode est élevé moins l'énergie incidence peut agir comme un piston sur ce mode et ainsi peut d'énergie lui sera transféré. Chaque mode et associé à un angle pour le transport de l'énergie. Ainsi : 
- Le nombre de mode propagatif est fini
- L'énergie incidente se réparti principalement entre les modes symétriques
- L'énergie incidente se transfert en majorité sur les modes de faibles degrés
Comme le nombre de mode est fini, la projection n'est pas complète, une partie de l'énergie ne se propage pas. Il faut néanmoins garantir la continuité de la pression en tout point de la section. Pour combler ces vides on va introduire : 
- Des modes propagatif retour (plan ou non) dans la conduite non traitée
- Des modes non propagatif (évanescents), ou propagatif atténués (nombre d'onde complexe)
La condition à la source impose qu'au niveau de la source, les modes d'ordre supérieurs potentiels sont dissipés. Cependant une partie de l'énergie du mode plan peut être réfléchie et stockée dans un mode stationnaire. La décomposition en mode n'est qu'une écriture comptable qui garanti l'équilibrage des formes modales au niveau des interfaces.