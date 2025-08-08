

Cette méthode est présentée dans [[jones2020]] En fonction des condition d'utilisation elle peut servir à :
- **prédir l'impédance acoustique d'un liner testé dans [[tube d'impédance à écoulement rasant]]** si le champ de pression et la vitesse d'écoulement sont connus
- **déterminer le champ de pression dans un tube d'impédance à écoulement rasant** si l'impédance du liner est connue
- **optimiser l'impédance de surface d'un liner pour atteindre un champ de pression souhaité** si la vitesse de l'écoulement est connue

Pour exploiter cette méthode, un modèle numérique du tube d'impédance est développé pour y mener des calculs par éléments finis.

![[image-40-x146-y159.png]]

###### Hypothèse du modèles

- Le champ de pression est uniforme dans le plan est est mesuré au niveau de la surface inférieure, en face du liner $(p (x,y,z) = p(x,y) = p(x,0))$ 
- L'écoulement est uniforme (épaisseur de couche limite infiniement fine) et constant

###### Contenu du modèle

Le modèle se base sur l'[[équation de Helmholtz convectée en 2D]] qui relie le champ de pression acoustique, les conditions limites aux parois et la vitesse de l'écoulement : $$\left(1-M^2\right) \frac{\partial^2 p(x, y)}{\partial x^2}+\frac{\partial^2 p(x, y)}{\partial y^2}-2 i k M \frac{\partial p(x, y)}{\partial x}+k^2 p(x, y)=0$$ 
###### Conditons limites 

- Au niveau des parois rigides la vitesse acoustique normale à la surface est supposée nulle $$\frac{\partial p(x, 0)}{\partial y}=0$$
- On utilise la [[condition limite de Myers]] formulée en pression pour définir le comportement acoustique du liner : $$-\frac{\partial p(x, H)}{\partial y}=i k\left(\frac{p(x, H)}{\zeta}\right)+2 M \frac{\partial}{\partial x}\left(\frac{p(x, H)}{\zeta}\right)+\frac{M^2}{i k} \frac{\partial^2}{\partial x^2}\left(\frac{p(x, H)}{\zeta}\right)$$
Dans ce modèle l'impédance de surface normalisée $\zeta$ est infini entre 0 et $x1$ et $x2$ et L. Elle est constante entre $x1$ et $x2$ et décrit le comportement acoustique du liner.

###### Optimisation de l'impédance de surface

L'optimisation est utilisée pour :
- 1. **déterminer l'impédance de surface d'un liner suite à des mesures expérimentales menées en tube d'impédance** 
- 2. **déterminer l'impédance idéale associée à une [[définition d'un besoin|condition donnée du champ de pression en entrée et en sortie du liner]]

Pour cette opération l'[[algorithme Stewart-Davidon-Fletcher-Powell]] est utilisé. A partir de plusieurs impédance de surface initiale, l'impédance est obtenue à l'aide d'une fonction coût sur la pression acoustique au niveau des microphones situées sur la surface inférieure.  
![[image-40-x205-y388.png]]

Dans le cas 1. , $p_{\mathrm{num}}$  est le résultat donné par la simulation par éléments finiset $p_{\mathrm{meas}}$ les données expérimentales.
Dans le cas 2. ...

###### Initialisation 

On réalise le processus d'optimisation en partant de 4 impédance de surface initiales : $0.5 + 0.5i,\ 0.5 − 0.5i,\ 2.0 + 0.5i,\ et\ 2.0 − 0.5i$ (Jones et al., 2020, p. 37)[[A Review of Acoustic Liner Experimental Characterization at NASA Langley]].

###### Utilisation



Cette méthode est utilisée dans : 
- la [[méthode d'optimisation indirecte]] pour calculer l'impédance idéale d'un liner.
[[Optimisation d'un liner à profondeurs variables]] 

La cartographie du TL en fonction de l'impédance est très couteuse
###### Questions 

[[question - Comment sont définies les p(xj)_meas dans le cas 2.]]? 
[[question - Ou est le lien entre la méthode d'optimisation indirecte et la méthode CHE]]?

Quelle méthode numérique pour mapper le problème sur les noeuds du maillage
Est ce qu'on cherche une impédance qui dépende la fréquence? Est ce qu'on cherche un impédance idéale pour chaque fréquence?
Comment est définie la source acoustique?