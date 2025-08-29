[[Modèle JCA de plaques perforées]] 

Les modèles de plaques étudiés donnent des formulations propres aux plaques pour les variables d'intérêt utilisées pour définir le comportement acoustiques des matériaux homogènes en général en particulier pour les [[Modèle JCA|paramètres JCAL]]. 
#### Matrice de transfert d'une plaque perforée

La matrice de transfert d'une plaque perforée décrit les relations entre les variables d'état du problème en amont et en aval de la plaque (en A' et en B' sur le schéma). En [[convention Pression - Débit]] on ne se préoccupe pas des changement de section car **le débit en A et égal au débit en A'**.
![[Zotero/atallaModelingPerforatedPlates2007/Images/atallaModelingPerforatedPlates2007-4-x311-y591.png]]

Pour décrire le comportement d'une plaque, la section utilisée pour exprimer le débit est la section correspondant aux perforations soit $S_{D} = \phi S_{a}$ avec $S_{a}$ la surface apparente externe considérée.

![[Matrice de transfert d'une couche de fluide équivalente (c.p.d.)#^a271bc]]

**En fonction de la manière de définir $S_{a}$ on doit définir $\phi$ de sorte à conserver $S_{D}$ invariée**. En particulier lorsque la plaque n'est pas uniformément perforée (voir [[Effet diaphragme]]), on peut définir $S_{a}$ comme la surface sur laquelle sont regroupées les perforations. On aura alors $\phi$ définie comme le rapport entre la surface recouverte par les perforations est celle de la "sous-surface" considérée.
##### Formulation du modèle de fluide équivalent

[[Modeling of perforated plates and screens using rigid frame porous models|Noureddine Atalla et Franck Sgard]] donnent une formulation pour la résistivité au passage de l'air et pour la tortuosité d'une plaque perforée.

Pour la [[Résistivité au passage de l'air]], ils reprennent la formulation générale utilisée pour les matériaux poreux à pores cylindriques droits, définie à partir du rayon des perforations et de **la porosité réelle** de la plaque :

![[Propagation of Sound in Porous Media#^0ae31d]] 

Ils proposent de corriger la tortuosité pour tenir compte virtuellement d'un effet de masse ajoutée associé au rayonnement de la plaque. 
$$\alpha_{\infty} = 1 + \frac{2\epsilon_{e}}{d}$$
Ce terme de correction dépend ainsi du rayon et du taux de perforation. Allard et Ingard proposent : 
$$\epsilon_{e} = 0.48\sqrt{\pi r^{2}}(1 - 1.14\sqrt{\phi})$$
avec $\phi < 0.2$ 




