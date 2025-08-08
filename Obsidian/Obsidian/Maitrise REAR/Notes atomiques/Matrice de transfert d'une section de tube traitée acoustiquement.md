[[Laly]] présente dans sa thèse une méthode pour **déterminer la matrice de transfert d'une section de tube à partir de l'impédance de surface normale de ses parois**. Dans l'ensemble il reprend la théorie développée par [[Munjal]] et augmente l'ordre d'approximation des séries de Taylor utilisée pour résoudre les équations.

Laly part de l'équation transcendantale de la forme $k_{x}^{+}= f_1(Z,M,k_0,L_x,k_z^{+})$ 

> [!eq1]+
> ![[Zotero/TheseLaly/Images/TheseLaly-254-x143-y462.png]]

qui prétend relier les nombres d'ondes dans les deux directions d'une paroi traitée à l'impédance de surface (normale?) de son traitement. Visiblement une approche équivalente permet de faire de même avec $k_x^{-}$ à partir de $k_z^{-}$ .

Une autre équation de dispersion de la forme $k_{z}^{+}= f_2(M,k0,k_x^{+})$  

>[!eq2]+
> ![[Zotero/TheseLaly/Images/TheseLaly-254-x100-y252.png]]


 permet de supprimer la dépendance en $k_z$ 

On obtient ainsi une fonction de $k_x^{+}$ dont on cherche les racines. On utilise alors les développement limités pour obtenir un polynôme en $k_x^{+}$, avec $Z, M$ et $k_0$ supposés connus, qu'on résout à l'aide de méthodes numériques

On a donc plusieurs $k_x^{+}$  et $k_x^{-}$ qui sont solutions des équations précédentes. Soit les solutions sont couplées deux a deux soit la relation entre les deux nombres d'ondes n'est pas aussi simple. Quoi qu'il en soit, pour tout couple de $k_x^{+}$  et $k_x^{-}$, on récupère les $k_z^{+}$  et $k_z^{-}$ correspondants. On calcule alors la matrice de transfert de la section traitée à partir d'une équation de la forme $T = f_3(Z_0,k_0,M,k_z^{+},k_z^{-})$  

>[!eq3]+
>![[Zotero/TheseLaly/Images/TheseLaly-255-x74-y283.png]]

*Remarque : Visiblement il n'est pas question ici de réaliser la caractérisation inverse c'est à dire de déterminer l'impédance de surface à partir de la matrice de transfert mesurée expérimentalement. Cela signifie que le problème n'est pas réversible ou alors qu'il existe trop de solutions possibles sans possibilité de discriminer entre les solutions

*Remarque : ici le problème est posé en terme de nombre ce qui correspond à une approche modale. On ne sait pas alors précisément comment sont reliés les nombres d'ondes entre eux, si ils sont imposés ou si seulement certains sont autorisés d'après les équations posés

