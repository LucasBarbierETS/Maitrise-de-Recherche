Article de référence : THE DEVELOPMENT OF THE DUCTED FAN NOISE PROPAGATION AND RADIATION CODE CDUCT-LARC



> [!quote|green]+ Highlight ([page. 3](zotero://open-pdf/library/items/R73R9NG2?page=3&annotation=Y2AYJ4RC))
> This code calculates the propagation of a given acoustic source ahead of the fan face or aft of the exhaust guide vanes in the inlet or exhaust ducts, respectively 
![[Pasted image 20250715095151.png]]
**Objectif** : Modéliser le champ acoustique en amont et en aval d'une source dans un conduit. Il est aussi possible de prédire le rayonnement du système et donc le champ acoustique hors du conduit

**Modules** :  
- Spécification des entrées/ sorties
- Calcul de dynamique des fluides (CFD)
- Génération d'une grille (grid) acoustique
- Calcul de l'écoulement arrière
- Radiation acoustique du conduit

**Fonctionnement** : 

#### Module de propagation des ondes

##### Equation de propagation des ondes

> [!quote|green]+ Highlight ([page. 2](zotero://open-pdf/library/items/Z37C5XV8?page=2&annotation=WE7FQYTQ))
> The CDUCT code is based on a parabolic approximation to the convected Helmholtz equation in an orthogonal curvilinear coordinate system 

##### Prise en compte de l'impédance de surface

> [!quote|green]+ Highlight ([page. 5](zotero://open-pdf/library/items/Z37C5XV8?page=5&annotation=BQ576NN4))
> The transverse boundary conditions of the duct are assumed to be locally reacting impedance surfaces which are out of the flow

Les conditions limites sont définis **hors de l'écoulement** : on fait l'hypothèse du couche d'épaisseur infinitésimale sous laquelle le champ de vitesse est nul. On définit alors des conditions de continuité entre les valeurs de part et d'autre de la couche


> [!quote|yellow]+ Image ([page. 552](zotero://open-pdf/library/items/UI4DKWLD?page=552&annotation=E92NWFUZ))
> ![[Zotero/doughertyWavesplittingTechniqueNacelle1997/Images/doughertyWavesplittingTechniqueNacelle1997-3-x270-y536.png]]

##### Impédance optimale

- Source spécifiée sous la forme d'un potentiel acoustique ([page. 28](zotero://open-pdf/library/items/Z37C5XV8?page=28&annotation=M33KIWTV))
- Nombre de Mach : 0.4 ([page. 27](zotero://open-pdf/library/items/Z37C5XV8?page=27&annotation=GUVQGX7A))
- Géométrie de la source : section plane ([page. 27](zotero://open-pdf/library/items/Z37C5XV8?page=27&annotation=28D5UMWS))
- Algorithme DownHill Simplex  ([page. 27](zotero://open-pdf/library/items/Z37C5XV8?page=27&annotation=8W9PIXK4))

>[!quote|green]+ Highlight ([page. 30](zotero://open-pdf/library/items/Z37C5XV8?page=30&annotation=KGMIH2FH))
> the optimized impedances are not obtainable by current passive lining designs for the entire important frequency range 
### Evolution CH3DPA

> [!quote|green]+ Highlight ([page. 12](zotero://open-pdf/library/items/GZIJQ9YE?page=12&annotation=K4EJMV3U))
> CH3DPA uses as input the acoustic pressure distribution in the hard wall duct upstream of the liner test section and the description of the liner treatment. The sound pressure is described in terms of the amplitude and phase of each of the cut-on modes in the upstream section and is based on the data measured in the CDTR. The liner description is input in terms of the spectrum of wall impedance. 

> [!quote|green]+ Highlight ([page. 12](zotero://open-pdf/library/items/GZIJQ9YE?page=12&annotation=IMKGDXI5))
> The impedance model used by CH3DPA is the Two Parameter Impedance Prediction model 
