Le Software OPAL (Optimization of Acoustic Liners) a été développé par l'équipe du laboratoire ONERA dans [[simon2021]] et [[roncen2021]].

Le but est de permettre l'assemblage et l'optimisation de solutions acoustiques le long d'une conduite


![[image-4-x111-y503.png]]


Le processus d'optimisation est décrit par le diagramme suivant : 


![[image-3-x86-y66.png]]


###### Simulation 1D

La première formulation du problème proposée suppose que : 
- le tube est de longueur infinie ce qui permet d'exprimer les modes de tube sous la forme : $$p(x, r, \theta)=P_{m, n}(r) e^{-i k_{m, n} x} e^{-i m \theta}$$![[image-6-x135-y531.png]]
- le tube est uniformement traité sur toute sa longueur. Ainsi on considère qu'il n'y a pas de discontinuité de la condition limite d'impédance au niveau des parois.


La présence du liner entraine une atténuation des modes qui se propagent dans le conduit.

Le profil de vitesse dans le conduit est donné en entrée du problème.

Les équations d'Euler sont résolues sur un maillage dans le plan transverse au conduit par *« méthode de collocation spectrale » (Simon et al., 2021, p. 5)*

Le transmission loss par mètre est alors donné par :$$T L_{m, n} /m=20 \log _{10}\left(\frac{p(x=1)}{p(x=0)}\right)=-20 \log _{10}(e) \operatorname{Im}\left(k_{m, n}\right) \approx-8.6859 \operatorname{Im}\left(k_{m, n}\right)$$
###### Simulation 2D

Pour tenir compte des discontinuités de l'impédance de surface, pour des géométries plus complexes ou lorsque l'hypothèse de tube infini n'est plus valable on utilise un *« solveur discontinu 2D de type Galerkin » (Roncen et al., 2020, p. 6)*.

Les [[équations d'Euler harmonique]] sont résolues.


![[optimisation dans OPAL]] 


[[processus complet d'optimisation avec OPAL]].
language : python
fait par : ONERA

###### Ce que OPAL ne fait pas


