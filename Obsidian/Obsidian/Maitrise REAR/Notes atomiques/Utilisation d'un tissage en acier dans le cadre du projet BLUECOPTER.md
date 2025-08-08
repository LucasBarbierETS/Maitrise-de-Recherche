
*Article de référence : ACOUSTIC LINER DESIGN FOR FENESTRON® NOISE REDUCTION*

L’utilisation d’un tissage à la surface d'un traitement acoustique permet :

- **D’éviter de générer des turbulences aérodynamiques à la surface du traitement acoustiques** (cavités, perforations macro, etc…)
- De créer une couche uniforme résistive qui peut, selon le cas, **améliorer ou détériorer** les performances acoustiques
- **Restreindre les phénomènes de turbulences acoustiques non linéaires** (vortex) et donc maintenir la solution dans son régime de fonctionnement linéaire.

Dans le cadre du projet  BLUECOPTER, Airbus à utiliser un maillage fin au-dessus de son carénage pour couvrir son concept acoustique appelé *Special Acoustic Absorber*
![[Pasted image 20250502144849.png]]

**Pour le liner acoustique :**

- Le but est **d’adapter la résistance de surface** $Re(Z_{s_{screen}})$ pour **maximiser l’absorption acoustique** ($Re(Z_{s_{total}}) \approx \rho0 * c0$)
- Le dimensionnement est **obtenu en prenant en compte la résistivité au passage de l’air du tissage dans le code de calcul analytique**
- Une feuille résistive constituée d’un tissage _« twilled weave »_ composite à deux couches en acier inoxydable de type *TM2KT10* (référence non retrouvée) a été utilisée de sorte à obtenir $Re(Z_{s_{total}}) = 1.4 *\rho0 * c0$ ![[Pasted image 20250502144511.png]] 
- Ce choix correspond à un compromis sur la plage 500 – 2000 Hz
- Pour des fréquences plus basses, il faut privilégier des résistances plus faibles
- **Le maillage est appliqué directement sur les solutions qui sont séparées les unes des autres en dessous** (solutions en parallèles, étanchéité entre les solutions à partir de la surface extérieure)

**Pour le liner aérodynamique :**

- Le but est différent : il s’agit ici **de créer un écran aérodynamique, transparent acoustiquement** ($Re(Z_{s_{total}}) << \rho0*c0$)
- Une feuille résistive constituée d’un tissage _« square mesh cloth »_ composite à deux
couches en acier inoxydable de type *TM2BM50* (référence non retrouvée) a été utilisée de sorte à obtenir $Re(Z_{s_{total}}) = 0.09 *\rho0*c0$. 

![[Pasted image 20250502150121.png]]

La résistance acoustique ajoutée lors de la pose d'un écran résistif à la surface d'un traitement est additive du fait de l'épaisseur quasi nulle de cet écran 
($Re(Z_{s_{total}}) = Re(Z_{s_{solution}}) +  Re(Z_{s_{screen}})$). En théorie, le maillage n'induit pas d'effet réactif additionnel $Im(Z_{s_{screen}} = 0$).

**On peut relier la résistance acoustique de l'écran à sa résistance au passage de l'air**.
A vitesse (acoustique) d'écoulement constante, on a une relation affine entre la résistance acoustique et **le nombre d'Euler** de l'écoulement qui exprime **le rapport des forces de pression et les forces d'inertie**, lui même relié à la résistivité au passage de l'air par la [[loi de Darcy]] et dans le cas non-linéaire, au [[modèle de Forchheimer]].

![[Pasted image 20250502150516.png]]