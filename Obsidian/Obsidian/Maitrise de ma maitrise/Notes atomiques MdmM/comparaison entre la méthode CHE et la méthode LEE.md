
[[watson2006]] 

Cet article compare une [[méthode pour déterminer l'impédance acoustique d'un liner basée sur l'équation de Helmholtz convectée (CHE)]] avec une [[méthode pour déterminer l'impédance acoustique d'un liner basée sur l'équation d'Euler linéarisée (LEE)]].


![[Tableau récapitulatif des méthodes d'extraction de l'impédance.univer]]

##### Mise en oeuvre numérique

L'espace d'étude est réduit à 2 dimensions, les perturbations sont considérées 
dans le plan de coupe médian du tube.

On se restreint à la bande de fréquence allant de $500 Hz$ à $3000 Hz$ pour conserver l'hypothèse d'onde plane.

###### CHE
- basis funcitons : cubic Hermite polynomial 
- boundaries conditions : weak formulation
- direct sparse solver
- source acoustique : la pression et la vitesse transerse sont données     (suivant $z$), $p=p_s(x), \quad v=v_s(x)$ 
- [[question - pourquoi la vitesse transverse est supposée indépendante de la distance à la paroi]]?
###### LEE
- basic functions : linear polynomials
- boundaries conditions : strong formulation
- LAPACK band solver
- source acoustique : la pression est donnée

###### Sources

Dans les deux cas, la condition de source est implémentée sur les noeuds du maillage appartenant au plan de la source. 

Ressources numériques : Lomax platform (250 GB RAM, 512 CPUs, CPU speed : 600 Mhz, processor chip : R14000)

La résolution se fait en comparant les champ de pression mesurés et estimés sur la surface inférieure (en face du liner) ($y = 0$)

$$F(\zeta)=\sum_{I=1}^{n \text { wall }}\left[\left.p\left(z_I, 0\right)\right|_{\mathrm{FEM}}-\left.p\left(z_I, 0\right)\right|_{\mathrm{Meas}}\right]\left[\left.\left.p^*\left(z_I, 0\right)\right|_{\mathrm{FEM}} p^*\left(z_I, 0\right)\right|_{\mathrm{Meas}}\right]$$


**Remarque** : cette formulation est générale ainsi elle fonctionne même dans le cas ou l'impédance réelle n'est pas homogène ou si l'écoulement induit une couche limite visqueuse à la surface du liner.

##### Techniques d'optimisation


L'impédance théorique est supposée constante et on considère une source harmonique : **l'optimisation ne porte que sur deux paramètres, $\chi$ et $\theta$.**
(pas de dépendance fréquentielle de la solution).

![[Approches numériques pour la résolution d'un problème d'extraction de l'impédance]]


##### Résultats

- Pour une même méthode, les trois approches d'optimisation converge vers la même impédance de surface
- Les deux méthodes donnent des résultats similaires. Quelques divergences en basse fréquence ($500 Hz$) et à écoulement rapide. Il est possible que ces différences soient dues à la prise en compte ou non de la couche limite visqueuse.

Conclusion : La méthode basée sur les équations d'Euler est plus adaptée en cas d'écoulement plus complexe (visqueux)



