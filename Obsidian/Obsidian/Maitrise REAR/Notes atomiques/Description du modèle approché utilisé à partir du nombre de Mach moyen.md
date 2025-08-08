
##### Modèle de Goodrich

> [!quote|green]+ Highlight ([page. 533](zotero://open-pdf/library/items/KT3X6N29?page=533&annotation=7Z32Y4WY))
> The Goodrich model is based on a modified Crandall’s solution and empirically adjusted to more accurately quantify the discharge coefficients of realistic perforate hole profiles, such as tapering effects, obtained with different manufacturing methods 

> [!quote|yellow]+ Image ([page. 549](zotero://open-pdf/library/items/KT3X6N29?page=549&annotation=3542WWZJ))
> ![[Zotero/winklerHighFidelityModeling2021/Images/winklerHighFidelityModeling2021-20-x42-y365.png]]


> [!quote|green]+ Highlight ([page. 533](zotero://open-pdf/library/items/KT3X6N29?page=533&annotation=5RAT6NJJ))
> the successful implementation of this model depends on experimentally acquired values for effective percent open area (POA) and hole diameter obtained from DC flow resistance data. #porosité-effective

**suivant cette approche, comment est prise en compte la condition d'impédance dans le couplage avec le tube?**

#### Approche de Laly

Laly ne tient pas compte de l'écoulement directement dans l'impédance de surface **mais dans la formulation de la matrice de transfert de la section traitée**.


> [!quote|yellow]+ Image ([page. 254](zotero://open-pdf/library/items/CMZQ7B9B?page=254&annotation=FMRPKA46))
> ![[Zotero/TheseLaly/Images/TheseLaly-254-x112-y597.png]]


*Munjal* ([page. 336](zotero://open-pdf/library/items/CMZQ7B9B?page=336&annotation=B9KFQC7F)) donne l'équation transcendantale des modes complexes propagatif dans une conduite $$\frac{Z k_x^{+}}{\rho_0 \omega}=j \operatorname{cotg}\left(L_x k_x^{+}\right)\left(1-\frac{M k_z^{+}}{k_0}\right)^2$$
avec $k_{x}^+$ le nombre d'onde dans la direction $x$ (que vaut-il?) et $k_z^{+}=\frac{-M k_0+\sqrt{k_0^2-\left(1-M^2\right)\left(k_x^{+}\right)^2}}{1-M^2}$ le nombre d'onde associé la pression incidente dans la direction $z$.

En remplaçant  $k_z^+$ par cette formule dans l'équation transcendantale, est en remplaçant la fonction tangente par son développement en série de Taylor, on peut retrouver $k_{x}^+$ par recherche numérique des racines d'un polynôme. Une approche similaire permet d'obtenir $k_{x}^-$.

Ainsi que la matrice de transfert adaptée à une condition d'écoulement ([page. 255](zotero://open-pdf/library/items/CMZQ7B9B?page=255&annotation=PUSQZPS8))

$$T=\frac{e^{j\left(k_z^{+}-k_z^{-}\right) L_z}}{Y^{+}+Y^{-}}\left[\begin{array}{cc}
Y^{-} e^{-j L_z k_z^{+}}+Y^{+} e^{+j L_z k_z^{-}} & Y^{+} Y^{-}\left(e^{+j L_z k_z^{-}}-e^{-j L_z k_z^{+}}\right) \\
e^{+j L_z k_z^{-}}-e^{-j L_z k_z^{+}} & Y^{+} e^{-j L_z k_z^{+}}+Y^{-} e^{+j L_z k_z^{-}}
\end{array}\right]$$

avec $Y^{+}=Z_0\left(k_0-M k_z^{+}\right) / k_z^{+}$ et $Y^{-}=Z_0\left(k_0+M k_z^{-}\right) / k_z^{-}$.

Laly montre qu'un développement d'ordre 6 permet de prédire le transmission Loss avec bien plus de précision que le développement d'ordre 4 précédemment utilisé.