
### Contexte

- BLUECOPTER DEMONSTRATOR
	- *Objectif* : Prouver la faisabilité de plusieurs concepts d'ingénierie pour développer des hélicoptères plus "éco-efficient" ([page. 1](zotero://open-pdf/library/items/FLQ5BCT3?page=1&annotation=QEQA9TNK))
	- *Objectif acoustique* : Réduire le niveau sonore perçu en bas de 10 EPNdB en dessous de la règlementation en vigueur  ([page. 1](zotero://open-pdf/library/items/FLQ5BCT3?page=1&annotation=PA7AQRWL))
	- Plusieurs innovations : nouvelle forme de pâle pour le rotor principal (Blue Edge), rotor arrière caréné, développement d'un traitement acoustique pour le rotor caréné arrière, …

### Concept acoustique
 
 Liner acoustique :
- Special Acoustic Absorber (SAA) (2+1DOF)

Modèle analytique à constantes localisées pour le résonateur de Helmholtz + propagation 1D dans le cône

> [!quote|yellow]+ Image ([page. 2](zotero://open-pdf/library/items/D55ZY93L?page=2&annotation=8YKJ2658))
> ![[Zotero/redmannAeroacousticLinerApplications2013/Images/redmannAeroacousticLinerApplications2013-2-x70-y537.png]]

> [!quote|green]+ Highlight ([page. 2](zotero://open-pdf/library/items/D55ZY93L?page=2&annotation=5DF3KVA8))
> Several assumptions had to be done on the acoustic properties as dimension of the coupling orifice and impedance of this orifice and permeable sheet. However, due to its simplicity such a validated model is suitable within an optimization process for the geometric dimensions 

> [!quote|green]+ Highlight ([page. 3](zotero://open-pdf/library/items/D55ZY93L?page=3&annotation=6TS233LE))
> From the specifications for the frequency ranges, which define the main spectral ranges with maximum absorption, its geometric dimension had been calculated. Based on this pre-design samples for impedance tube tests as well as for flow channel tests has been manufactured 

 Liner aérodynamique : 
 - *Objectif* : réduire la vorticité de l'écoulement de dégagement en bout de pâle, source importante de bruit large bande. **Le liner n'a pas pour but d'absorber l'énergie acoustique! L'impédance de surface souhaitée est celle de l'air** ($\rho0 c0$) ([page. 7](zotero://open-pdf/library/items/UDCIT46P?page=7&annotation=QSA9Z5YJ))
 - *Principe de fonctionnement du liner* : Offrir une surface perméable à l'écoulement (radial, tourbillonnaire) au niveau du passage des pâles.
 - *Configuration choisie* : Cavité annulaire ("*U-shape*") entourant le plan du rotor, recouverte par un tissage résistif en acier ("*wire-mesh*") **faiblement résistif**
### Design et dimensionnement

- Cahier de charge acoustique : Broadband, > 500 Hz ([page. 4](zotero://open-pdf/library/items/UDCIT46P?page=4&annotation=MVSL996R))
-
-
### Remarques sur la conception

> [!quote|green]+ Highlight ([page. 7](zotero://open-pdf/library/items/UDCIT46P?page=7&annotation=Z5V89KBV))
> The modelling of the noise reduction physics is not reliable possible with the tools available because both, the turbulent tip clearance flow as well as the turbulent flow through the wire mesh surface must be modelled in full 3D at very fine temporal and spatial resolutions in order to allow the extraction of the acoustic relevant pressure fluctuations. The necessary CFD amount was beyond the scope of the project. 

> [!quote|green]+ Highlight ([page. 9](zotero://open-pdf/library/items/UDCIT46P?page=9&annotation=8EI38UNF))
> As the acoustic liner is located in flow direction behind the fan plane a remarkable effect on suction side cannot be observed and could also not be expected 

> [!quote|green]+ Highlight ([page. 5](zotero://open-pdf/library/items/UDCIT46P?page=5&annotation=D3B58R3S))
> The maximum volume depth of the absorber elements located just behind the rotor is 51 mm, the minimum depth of the absorber elements near the diffusor exit is 36 mm 
##### Exploitation de la surface accessible du carénage

Le liner intégré pour les mesures n'exploitait que 40 % de la surface disponible.

> [!quote|yellow]+ Image ([page. 5](zotero://open-pdf/library/items/UDCIT46P?page=5&annotation=ITLB3P3G))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-5-x62-y627.png]]

Une nouveau design (non exploité à priori) a été proposé entre temps, permettant d'atteindre un taux d'exploitation de la surface disponible de 90 %.

> [!quote|yellow]+ Image ([page. 5](zotero://open-pdf/library/items/UDCIT46P?page=5&annotation=H95W3RXS))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-5-x312-y499.png]]


### Procédure de validation

- Pour un échantillon droit : 
	- validation numérique 3D (Insertion Loss)

> [!quote|yellow]+ Image ([page. 6](zotero://open-pdf/library/items/UDCIT46P?page=6&annotation=NZP2DKM6))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-6-x46-y392.png]]


- Sur la traitement intégré dans le carénage : 
	- Mesure de l'impédance avec Impédance-mètre portatif (29 mm)

> [!quote|yellow]+ Image ([page. 6](zotero://open-pdf/library/items/UDCIT46P?page=6&annotation=9YYUEKRR))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-6-x310-y341.png]]


#### Modélisation CFD réaliste 


> [!quote|yellow]+ Image ([page. 8](zotero://open-pdf/library/items/UDCIT46P?page=8&annotation=QL4HCX2Z))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-8-x285-y594.png]]

- [[Actran]] 
- Modélisation avec et sans traitement
- Traitement intégralement modélisé en 3D pour tenir compte de la réactance réaliste
- Définition de la résistance acoustique à la surface du traitement en fonction des valeurs mesurées sur le "mesh-grid"
- **Pas d'écoulement!**

- Sources : 
	- 10 monopoles dans le plan du rotor, à 70 % du rayon
	- Excitation tonal en $1/3$ d'octave 
	- **Niveau sonore non indiqué** 

##### Résultats  

###### Observations qualitatives : 
- A basses fréquences (630 Hz), les émissions sont concentrées dans le l'axe du rotor
- A hautes fréquences (2500 Hz), des patterns modaux apparaissent


> [!quote|yellow]+ Image ([page. 9](zotero://open-pdf/library/items/UDCIT46P?page=9&annotation=WVANKUPC))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-9-x65-y601.png]]

###### Impact du liner : 
- Le champ de pression est observé dans un plan contenant l'axe du rotor (vue de profil) et dans un plan tangent à cet axe, au niveau du stator ("pressure-side", "lined-side").
- A 630 Hz, on observe le développement d'un mode circonférentiel et une atténuation de plusieurs dB lorsque le liner est utilisé.

> [!quote|yellow]+ Image ([page. 9](zotero://open-pdf/library/items/UDCIT46P?page=9&annotation=7BBPQ6LY))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-9-x60-y219.png]]

- A 2500 Hz, l'efficacité du traitement est moindre et le champ obtenu dépend fortement de la géométrie de la source

> [!quote|yellow]+ Image ([page. 9](zotero://open-pdf/library/items/UDCIT46P?page=9&annotation=FL6EH4LU))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-9-x306-y496.png]]

Intégration du niveau de pression sur la surface de l'hémisphère droit du fenestron ("pressure side") 

> [!quote|yellow]+ Image ([page. 10](zotero://open-pdf/library/items/UDCIT46P?page=10&annotation=FV75NNUL))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-10-x64-y593.png]]

#### Mesures en chambre anéchoïque

Montage d'un carénage réel sur un banc d'essai à échelle 0.7:1
Mesure sur deux arcs semi-circulaires de rayon 4 m, amovibles sur l'hémisphère supérieur d'émission. Scan complet de l'hémisphère par pivot continu autour d'un axe vertical.


> [!quote|yellow]+ Image ([page. 3](zotero://open-pdf/library/items/UDCIT46P?page=3&annotation=IE5KH5CS))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-3-x300-y565.png]]

4 configurations testées : 
- Hard wall (Aluminium tape)
- Liner acoustique
- Liner aérodynamique
- Liner acoustique + liner aérodynamique

Séparation du bruit large bande (aéroacoustique), du spectre d'émission tonal (BPF) par traitement du signal temporel (code ROSI) 

##### Résultats

Mesure des niveaux moyens sur les deux demi-hémisphères pour les différentes configurations de liner testées et pour le spectre complet ou décomposés (composantes tonales et large-bande)


> [!quote|yellow]+ Image ([page. 13](zotero://open-pdf/library/items/UDCIT46P?page=13&annotation=2ESS8QAU))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-13-x307-y470.png]]

> [!quote|yellow]+ Image ([page. 13](zotero://open-pdf/library/items/UDCIT46P?page=13&annotation=KKTEEI3J))
> ![[Zotero/pongratzACOUSTICLINERDESIGN/Images/pongratzACOUSTICLINERDESIGN-13-x306-y78.png]]

#### Remarques

- Optimisation en fonction de l'impédance/ absorption désirée, pour une configuration droite
- Le changement de forme lié à la mise en place circulaire n'est pas prise en compte
- Il n'est pas clairement indiqué si l'
- La modélisation tient compte de la géométrie réelle et pas seulement de l'impédance de surface
- Les fréquences où l'on constate le plus de perte par transmission en tube correspondent aux fréquences ou ces réductions sont observées sur la géométrie réelle (environ 600 Hz). Elle correspondent aussi aux fréquences ou l'on obtient une réactance acoustique nulle (résonnance) sur le spectre d'impédance mesurée. **On a donc une corrélation entre l'impédance normale (conditions de laboratoire), le Transmission Loss (incidence rasante, écoulement) et la modélisation réaliste (sans écoulement)**.
-  Pas de prédiction analytique des performances de réduction de bruit 