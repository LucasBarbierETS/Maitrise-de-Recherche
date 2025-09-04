Une fois que les composantes élémentaires du code sont définies. Le but est de les assembler et au besoin de les adapter pour valider les approches à partir de résultats de la littérature
##### Solutions multi-pancakes, cavités annulaires et correction de le longueur modifiées

Rédaction original dans [[Réduction du pore central#^e51361]]

[Dupont](zotero://open-pdf/library/items/EI6UVSF8) développe un métamatériau constitué de plaques circulaires superposées, chacune percée en leur centre. Le matériau obtenu présente un pore central entouré d’une succession de cavités annulaires très fines, dites _pancakes_.

Dans ce dispositif, des pertes visqueuses apparaissent dans les perforations. La superposition de plaques percées uniquement au centre engendre de nombreux changements de section, qui se traduisent par des discontinuités marquées des paramètres acoustiques d’une couche à l’autre. En outre, la concentration du flux acoustique au centre des plaques produit un **effet de forme** : le champ acoustique n’est plus purement normal à la surface, mais comporte une composante radiale. Ces deux phénomènes — **rupture d’impédance** liée au changement de section et **effet de forme** lié à la focalisation du flux — sont regroupés sous l’appellation **effet diaphragme**.

L’**effet diaphragme** ne se limite pas à modifier la partie réactive de l’impédance. Le rétrécissement de la section impose une accélération du flux acoustique dans les pores ; cette accélération accroît la vitesse locale et donc les pertes visqueuses, ce qui augmente la résistivité effective de la couche.

Pour modéliser le comportement de ces diaphragmes successifs, on considère une cellule périodisée constituée d’un tronçon d’épaisseur nulle au centre, relié latéralement à une cavité annulaire dans laquelle la propagation est supposée purement radiale. L’effet de cette cavité est représenté par l’[[impédance de surface latérale exprimée à partir des fonctions de Hankel]], hypothèse justifiée par la faible épaisseur des cavités comparée à leur rayon. La cellule périodique est ainsi composée de deux demi-pores principaux (avec pertes), deux demi-pores communs (sans pertes) et une cavité annulaire, reliés en série à l’aide de matrices de transfert.

> [!quote|yellow]+ Image ([page. 89](zotero://open-pdf/library/items/EI6UVSF8?page=89&annotation=NXU7WQ32))
> ![[Zotero/dupont2018/Images/dupont2018-4-x302-y311.png]]

> [!quote|yellow]+ Image ([page. 89](zotero://open-pdf/library/items/EI6UVSF8?page=89&annotation=ZVPM6DDV))
> ![[Zotero/dupont2018/Images/dupont2018-4-x302-y270.png]]

Comme les plaques sont proches, les effets inertiels associés au rayonnement du pore principale à la sortie et à l'entrée on été négligés (tortuosité = 1). En revanche on considère des effets de rayonnement de part et d'autre du matériau pour les plaques extrêmes.

> [!quote|yellow]+ Image ([page. 89](zotero://open-pdf/library/items/EI6UVSF8?page=89&annotation=32BFG7DG))
> ![[Zotero/dupont2018/Images/dupont2018-4-x189-y71.png]]


Ici cette surface latérale est cylindrique et débouche sur une surface annulaire.  l'[[impédance de surface latérale exprimée à partir des fonctions de  Hankel]] qui considère une propagation des ondes dans une direction purement radiale. Cette hypothèse est justifiée par la faible épaisseur des cavités en comparaison avec le rayon de celles-ci.

L'introduction de cavités latérales va diminuer la partie réelle de la [[célérité effective]] du matériau. Par la relation $\lambda= \frac{c}{f}$, on voit que cela va produire **une diminution des longueurs d'ondes effectives** dans le matériau qui pourra ainsi être efficace à plus basse fréquence. 

Sur la figure suivante, on voit que l'introduction de l'[[effet diaphragme]]  permet de baisser la fréquence du premier pic en comparaison avec celui du résonateur de Helmholtz. Dans les deux cas précédents on atteint des fréquences largement plus basses que la fréquence de résonance du résonateur quart d'onde de même épaisseur. **Cela confirme l'importance des effets réactifs obtenus avec l'introduction des plaques résistives.** 

> [!quote|yellow]+ Image ([page. 92](zotero://open-pdf/library/items/EI6UVSF8?page=92&annotation=ZPRKYVQV))
> ![[Zotero/dupont2018/Images/dupont2018-7-x296-y453.png]]


###### Rétrécissement du pore central, Matériau de Gauthier et correction de longueurs modifiées
###### MPPSBH, cavités coniques, Plaques et correction de longueur