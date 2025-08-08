La méthode PTMM utilisée a été développée par Verdière. Elle consiste à formuler la matrice de transfert d'un ensemble de matériau **de même épaisseur**, débouchants ou non, disposés en parallèle les uns des autres.
#### Approche par sommes des admittances

Cette méthode a pour objectif la plus classique loi de mélange on l'on se contente de réaliser **la somme des admittances** pondérées par la surface (ASM).


> [!quote|yellow]+ Image ([page. 94](zotero://open-pdf/library/items/N34GRCUI?page=94&annotation=VW3QQ4I3))
> ![[Zotero/verdiereComparisonParallelTransfer2014/Images/verdiereComparisonParallelTransfer2014-6-x117-y431.png]]

Comme on peut le voir sur cette figure, l'approche ASM perd en fiabilité dans certaines situations car **elle ne tient pas correctement compte des conditions limites**. C'est le cas lorsque les blocs parallèles débouchent sur une même section (unsealed) ou lorsque certains blocs sont reliés à une cavité inférieure (cavity back condition).

#### Nouvelles conditions limites

En adoptant une approche par matrice de transfert, l'enjeu est de reliée les grandeurs (pression et débit) à l'entrée et à la sortie du matériau. 

> [!quote|yellow]+ Image ([page. 2](zotero://open-pdf/library/items/L2E2D4CA?page=2&annotation=5E9GMNMQ))
> ![[Zotero/verdiereTransferMatrixMethod2013/Images/verdiereTransferMatrixMethod2013-3-x317-y508.png]]
> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/L2E2D4CA?page=3&annotation=IE3MKUMT))
> ![[Zotero/verdiereTransferMatrixMethod2013/Images/verdiereTransferMatrixMethod2013-4-x61-y344.png]]


Comme dit précédemment certains blocs pouvant être ouverts (j) ou fermés (k), la condition limite doit tenir compte de ces deux états possibles de chaque bloc.

On définit alors une condition pour le débit, valable en amont et en aval : 

> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/L2E2D4CA?page=3&annotation=JTM3IM5H))
> ![[Zotero/verdiereTransferMatrixMethod2013/Images/verdiereTransferMatrixMethod2013-4-x60-y635.png]]

Notons que le débit en aval est nul pour les cavités fermées.

Pour la pression on définit la continuité en amont pour tous les blocs et en aval pour les blocs ouverts seulement, les autres ayant une condition définie à partir de leur propre matrice de transfert


> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/L2E2D4CA?page=3&annotation=6G2UHAIQ))
> ![[Zotero/verdiereTransferMatrixMethod2013/Images/verdiereTransferMatrixMethod2013-4-x325-y444.png]]

> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/L2E2D4CA?page=3&annotation=PMVJZ5ZM))
> ![[Zotero/verdiereTransferMatrixMethod2013/Images/verdiereTransferMatrixMethod2013-4-x324-y365.png]]

A la suite d'une série de réécriture on obtient la forme générale de la matrice de transfert du bloc : 

> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/L2E2D4CA?page=3&annotation=UPUZPSFL))
> ![[Zotero/verdiereTransferMatrixMethod2013/Images/verdiereTransferMatrixMethod2013-4-x54-y216.png]]

