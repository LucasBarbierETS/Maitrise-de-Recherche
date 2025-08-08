#### Pore central constant (multi-pancakes)  

En plus de l'intérêt d'utiliser plusieurs plaques successives [Dupont](zotero://open-pdf/library/items/EI6UVSF8) développe un métamatériau constitué de plaques circulaires superposées, perforées en leur centre. Le matériau obtenu est composé d'un pore central entouré d'une succession de cavité annulaires fines dites "pancakes".

Dans ce matériau, des pertes visqueuses sont observées dans les perforations. 
Le modèle est construit à partir d'une cellule périodisée représentant deux demi-pores principaux (avec perte), deux demi-pore communs (sans pertes) et une cavité annulaire, définie en utilisant les matrices de transfert en série. 

> [!quote|yellow]+ Image ([page. 89](zotero://open-pdf/library/items/EI6UVSF8?page=89&annotation=NXU7WQ32))
> ![[Zotero/dupont2018/Images/dupont2018-4-x302-y311.png]]

> [!quote|yellow]+ Image ([page. 89](zotero://open-pdf/library/items/EI6UVSF8?page=89&annotation=ZVPM6DDV))
> ![[Zotero/dupont2018/Images/dupont2018-4-x302-y270.png]]

Les cavités annulaires sont prises en compte en définissant une impédance de surface au niveau des parois virtuelles du pore central entouré par chaque cavité, et intégré au modèle dans une [[Matrice de transfert de jonction]]. On utilise alors l'[[impédance de surface latérale exprimée à partir des fonctions de  Hankel]] qui considère une propagation des ondes suivant la direction radiale. 

L'introduction de cavités latérales va diminuer la partie réelle de la [[célérité effective]] du matériau. Par la relation $\lambda= \frac{c}{f}$, on voit que cela va produire **une diminution des longueurs d'ondes effectives** dans le matériau qui pourra ainsi être efficace à plus basse fréquence.

Sur la figure suivante, on voit que l'introduction de l'[[effet diaphragme]]  permet de baisser la fréquence du premier pic en comparaison avec celui du résonateur de Helmholtz. Dans les deux cas précédents on atteint des fréquences largement plus basses que la fréquence de résonance du résonateur quart d'onde de même épaisseur. **Cela confirme l'importance des effets réactifs obtenus avec l'introduction des plaques résistives.** 

> [!quote|yellow]+ Image ([page. 92](zotero://open-pdf/library/items/EI6UVSF8?page=92&annotation=ZPRKYVQV))
> ![[Zotero/dupont2018/Images/dupont2018-7-x296-y453.png]]


#### Décroissance du rayon du pore central

[Bezancon](zotero://open-pdf/library/items/ZC36VJYU) s'intéresse ensuite à la réduction progressive du rayon du pore central dans le matériau. Il observe une augmentation du nombre de résonance et un élargissement de la bande d'absorption. Il est possible d'identifier ce nouveau comportement à une effet trou-noir acoustique.

> [!quote|yellow]+ Image ([page. 6](zotero://open-pdf/library/items/ZC36VJYU?page=6&annotation=PNHU7JKX))
> ![[Zotero/bezanconThinMetamaterialUsing2024/Images/bezanconThinMetamaterialUsing2024-6-x295-y404.png]]

#### Solution multi-plaques perforées avec profil décroissant (MPPSBH)

 [Chen](zotero://open-pdf/library/items/AH7QFLYS) propose une solution à base de multi-plaque perforées à profil décroissant. les plaques sont fines et l'impédance est formulée d'après l'impédance des plaque de Maa, puis intégrée dans une [[matrice de transfert de plaque perforée]].

L'admittance des cavités latérales est définies à partir d'une approximation volumique.
 
> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/AH7QFLYS?page=3&annotation=A3FY7857))
> ![[Zotero/chenBroadbandLowfrequencySound2024/Images/chenBroadbandLowfrequencySound2024-3-x88-y294.png]]