
#### Conservation du débit

Pour définir le cadre de notre modèle nous allons partir d'une situation simple ou le champ acoustique se développe au sein d'un matériau stratifié de section finie. On suppose que le champ est normal à la surface pour chacune des couches du matériau.  On considère pour chaque couche que les propriétés acoustiques (impédance caractéristique, célérité, etc.) sont uniformes (pas d'effets de bords, de frottement à la paroi, etc.) alors le champ acoustique qui se développe dans le matériau est unidimensionnel.

Dans cette situation : 

- à chaque interface il est à continuité de la vitesse et de la pression du fait de la conservation du débit. Si les sections sont différentes en amont et en aval de l'interface, la continuité des vitesses n'est pas respectée. Il est alors judicieux d'exprimer le champ acoustique suivant une **convention Pression -  Débit**  avec $u = v * S$.
- Au sein d'une couche, la composante du champ acoustique issu de la superposition des ondes aller et retour à une fréquence donnée peut être défini par une forme explicite unique dépendant de la position suivant la direction normale à la couche. Il est alors possible d'établir une relation entre les grandeurs acoustiques considérées au niveau des deux interfaces de la couche ($p_i, u_i, p_i', u_i'$) . Cette relation peut s'exprimer à l'aide d'une **matrice de transfert** :
$$
\begin{bmatrix} \ p_{i}' \\ u_{i}' \end{bmatrix} 
= TM_i\begin{bmatrix} \ p_{i} \\ u_{i} \end{bmatrix} 
= \begin{bmatrix} \cos(k_{i}d) & j*Z_{{c}_{i}}\sin(k_{i}d) \\ j*\frac{\sin(k_{i}d)}{Z_{{c}_{i}}} & \cos(k_{i}d) \\ \end{bmatrix}
\begin{bmatrix} \ p_{i} \\ u_{i} \end{bmatrix} 
$$ Cette matrice existe pour chaque composante monochromatique du champ. Chacun de ses termes dépend donc de la fréquence considérée. 

Pour un matériau $M$ composé de plusieurs couches superposées, il est alors possible d'établir une matrice de transfert globale reliant les grandeurs acoustiques à l'entrée et à la sortie de celui-ci. Pour cela il suffit de réaliser le produit des matrices de transfert élémentaires successives : 

$$
\begin{bmatrix} \ p_{M}' \\ u_{M}' \end{bmatrix} 
= TM_{M}\begin{bmatrix} \ p_{M} \\ u_{M} \end{bmatrix} 
= \prod T M_i\begin{bmatrix} \ p_{M} \\ u_{M} \end{bmatrix} 
$$
#### Caractérisation des matériaux et grandeurs d'expression des performances

Une fois que l'on sait comment décrire les relations du champ en amont et en aval d'un matériau stratifié, il faut maintenant remonter aux relations ces grandeurs entre elle au niveau de la surface libre du matériau. On considère que le matériau dispose d'un fond rigide ce qui permet de poser $u_{M}= 0$. Il est alors possible d'établir que 
