 *Article de référence : Modification of the transfer matrix method for the sonic black hole and broadening effective absorption band*

Cet article propose de modifier la formulation analytique de la cavité conique, habituelle formulée comme une cavité cylindrique dans les différents modèles de trous noirs acoustiques utilisant un modèle à base de matrice de transfert. 

![[Zotero/chen2024a/Images/chen2024a-3-x55-y49.png]]

D'après l'article, l'approximation cylindrique n'est plus fiable lorsque le nombre de cavités diminue car la différence entre les rayons du pore centrale en amont et en aval de la cavité deviendrait trop grande.

L'article reprend l'**équation de Webster** pour décrire la propagation des ondes dans une cavité à parois coniques rigides : 

![[Zotero/chen2024a/Images/chen2024a-4-x43-y342.png]]
En appliquant cette équation à une section circulaire dans le rayon dépend de l'abscisse, on obtient une nouvelle équation des ondes et ainsi une nouvelle formulation pour la matrice de transfert de la portion de cavité.

La cavité toroïdale est prise en compte dans un second temps, à l'aide d'une matrice de transfert qui exploite son admittance de surface vue depuis l'intérieur du pore principale. La propagation dans la cavité est supposée purement radiale, le champ s'exprime alors à partir des fonctions de Hankel en fonction de $x$, $r(x)$ et $t$. 

Finalement l'admittance de surface est formulée à partir de l'impédance de surface suivant la direction radiale, formulée en [[convention p-v]], évaluée au niveau de la plaque en amont de la cavité. L'admittance est réutilisée dans la matrice de transfert formulée en [[convention Pression - Débit]] en appliquant l'impédance à la surface de connexion entre la cavité conique et la cavité toroïdale.

Dans notre cas, l'utilisation de cette méthode nécessite de prendre plusieurs précautions : 
- Il faut **s'assurer que la forme de l'équation des ondes reste la même dans le cas ou la section est une fente au lieu d'un cercle**. Cela pourrait avoir un impact sur la formulation de la matrice de transfert de la cavité conique.
- Comment notre cavité n'est pas à base circulaire, la propagation radiale ne s'applique pas. Il faut alors passer par une autre formulation de l'impédance de surface, on bien par [[Formulation de l'admittance d'une cavité à partir de son volume|une formulation de l'admittance à partir du volume de la cavité]].  



