https://perso.univ-lemans.fr/~odazel/vrac/

Le modèle JCAL et un modèle permettant de retrouver les paramètres acoustiques effectifs de la couche de fluide équivalent homogène d'un matériau poreux à partir de 5 paramètres de cette couche : la porosité $\phi$, la tortuosité $\alpha_{\infty}$, la résistivité au passage de l'air $\sigma$ ainsi que les longueurs caractéristiques visqueuse et thermique. Il se base sur l'étude de la forme explicite des pertes qui adviennent dans un pore.
#### Histoire du modèle

##### Premier modèle empirique

En 1970, Delany et Bazley propose un modèle empirique pour l'impédance caractéristique équivalente et pour le nombre d'onde équivalent en fonction de la fréquence et de la [[résistivité au passage de l'air]]. L'approche consiste alors à ajuster par optimisation les coefficients d'un polynôme complexe en $\frac{\rho_0f}{\sigma}$ (adimensionnel) sur divers résultats expérimentaux, en imposant la conformité au principe de **causalité physique**. (la partie réelle de l'impédance et, à plus forte raison, le coefficient d'absorption doivent rester positifs sur tout le spectre).
$$Z_{e q}=\rho_0 c_0\left[1+0.0785 (\frac{\rho_0f}{\sigma})^{-0.632}-j 0.120 (\frac{\rho_0f}{\sigma})^{-0.632}\right]$$
$$k_{e q}=\frac{\omega}{c_o}\left[1+0.0978 (\frac{\rho_0f}{\sigma})^{-0.700}-j 0.189 (\frac{\rho_0f}{\sigma})^{-0.595}\right]$$
*Remarque : Cette dernière formulation est équivalente à la formulation d'une célérité équivalente des ondes dépendant de la fréquence $c_{eq} = \frac{\omega}{k_{eq}}$
##### Etude d'un matériau à pore cylindrique

La difficulté qu'on rencontre lorsqu'on cherche à modéliser un matériau poreux vient du fait que dans le cas général on ne sait pas comment formuler et donc quantifier les phénomènes dissipatifs. Par ailleurs il n'est pas possible de décrire exactement le champ de pression en tenant compte de la géométrie réelle de la matrice poreuse. On étudie alors une situation de difficulté intermédiaire dans laquelle les pores sont droits, cylindriques à base circulaire. Dans cette situation il est possible de reformuler les équations de propagation des ondes.

Le but est ici de **faire apparaitre des formes générales explicites permettant de décrire les effets de dissipation visco-thermiques** pour une forme spécifique de poreux, et de les adapter par la suite à tous les autres.

Il est possible de modéliser les phénomènes dissipatifs dans un pore cylindrique en tenant compte séparément des pertes visqueuses et thermiques (Zwikker & Kosten, 1949). 

- Pertes visqueuses
	En particulier on peut reformuler l'équation de conservation de la masse :
	
	![[Propagation of Sound in Porous Media#^bc2dd6]]
	La résolution de cette équation en coordonnées cylindriques nous permet d'obtenir le profil de la vitesse axiale tenant compte des frottements visqueux aux parois. Par volonté d'homogénéisation, on décide ramener les équations sous leur forme linéaire conservative. On réécrit l'équation d'Euler généralisée équivalente, reliant la pression $p$ (uniforme sur la section du pore) et la vitesse axiale moyenne $\bar{v}$ au moyen d'une densité équivalente :
	![[Propagation of Sound in Porous Media#^25888e]]	
	*Remarque : La densité traduit les effets de masse inertielle, exprimé dans le principe fondamental de la dynamique. Ici **on intègre les effets visqueux aux effets inertiels en écrivant la densité sous forme complexe**.
	
	Dans cette situation on définie la **tortuosité** : $\alpha(\omega)= \frac{\rho_{eq}(\omega)}{\rho_0}$ 
	
	Dans un pore cylindrique la tortuosité prend la forme :
	![[Propagation of Sound in Porous Media#^02015b]] 
	avec $s = R\sqrt{\frac{-j\omega}{\nu}} = \frac{\sqrt{-2j}R}{\Lambda}$   et $\Lambda = \sqrt{\frac{2\nu}{\omega}}$ la **longueur caractéristique visqueuse** 
	

- Pertes thermiques
	Par ailleurs on peut écrire la **diffusion de la température acoustique** : 
	![[Propagation of Sound in Porous Media#^61d457]] 
	En résolvant cette équation en coordonnées cylindrique dans le plan de la section on obtient la répartition de la température acoustique. 

	On formule alors le	[[module d'élasticité isostatique (bulk modulus)]] en fonction de la température acoustique moyenne sur la section
	![[Propagation of Sound in Porous Media#^0bf535]]
	*Remarque : Comme pour la densité, le module d'élasticité relie des grandeurs réelles qui se trouve être en phase (pression, densité, température). **L'introduction d'un terme complexe permet de formuler des effets dissipatifs tout en maintenant le formalisme conservatif**
	
	Finalement on obtient un module l'élasticité equivalent qui tient compte des effet de diffusion thermique
	![[Propagation of Sound in Porous Media#^652293]]
	avec $s' = R\sqrt{\frac{-j\omega Pr}{\nu}} = \frac{\sqrt{-2j}R}{\Lambda'}$ et $\Lambda' = \sqrt{\frac{2\nu}{\omega Pr}}$ la **longueur caractéristique thermique**

	*Remarque : La dépendance de la tortuosité (resp. du modèle d'élasticité) à la fréquence est contenue dans sa dépendance à $\Lambda$ (resp. $\Lambda'$). On voit que le milieu ($\nu$) et la géométrie ($R$) ont une influence conjointe sur l'apparition de pertes visqueuses et thermiques.

	*Remarque : Pour résumer l'approche, **on tient compte de deux phénomènes de diffusion distincts qui donnent lieux à des pertes énergétiques**. Ces deux phénomènes sont pris en compte indépendant en introduisant une partie imaginaire dans la formulation de certaines variables qui servent à expliciter les relations entre les variables d'état du système. Ainsi, au lieu de complexifier le formalisme, on le corrige en utilisant des **variables effectives**.
#### **Modèle de Johnson**  

Le modèle de Johnson donne la densité effective du matériau poreux équivalent en fonction



 