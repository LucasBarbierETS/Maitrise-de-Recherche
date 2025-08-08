---
year:
  "{ date | format (\"YYYY\") }": 
authors:
  "{ authors }":
---

Titre : Design and optimization of acoustic liners with a shear grazing flow: OPAL software applications
Lien Zotero : [Roncen et al. - Design and optimization of acoustic liners with a .pdf](zotero://select/library/items/6ZRBH57Q)


 
- pyDG module                                                                
	- J. Primus, E. Piot, and F. Simon. An adjoint-based method for liner impedance eduction: Validation and numerical investigation. J. Sound Vib., 332(1):58–75, January 2013. [18] R Roncen, F Méry, E Piot, and F Simon. Statistical inference method for liner impedance eduction with a shear grazing flow. AIAA Journal, pages 1–11, 2018. (page [13](ann.desktopURI))     
	- Nodal discontinuous Galerkin methods: algorithms, analysis, and applications (page [13](ann.desktopURI))   
	- Influence of source propagation direction and shear flow profile in impedance eduction of acoustic liners (page [13](ann.desktopURI))            
- procédure d'optimisation du liner avec le software OPAL    
	- projection of the discretized LEE onto a reduced order basis [21], based on proper orthogonal decomposition (POD) (page [5](ann.desktopURI))   
	- The method is coined snapshot-POD (page [6](ann.desktopURI))   
	- Details on the method and its application on statistical inference for impedance eduction can be found in Ref. [18]. (page [6](ann.desktopURI))       
	- duct of 5cm by 5cm square cross section (page [6](ann.desktopURI))   
	- grazing flow up to Mach 0.4 (page [6](ann.desktopURI))   
	- SPL up to 150dB (page [6](ann.desktopURI))   
	- A 15cm long liner can be placed within the duct (page [6](ann.desktopURI))   
	- the present goal is to maximize the attenuation performed by the liner (page [6](ann.desktopURI))   
	- The incident acoustic waves propagates in the same direction as the flow (page [6](ann.desktopURI))   
	-   (page [6](ann.desktopURI))![[image-6-x41-y407.png]]  
	-   (page [6](ann.desktopURI))![[image-6-x411-y408.png]]  
	- The frequency range of interest is [200Hz-3000Hz] with a step of 10Hz (page [6](ann.desktopURI))   
	- important weight at 500Hz (page [6](ann.desktopURI))   
	- The first step is for OPAL to assemble the 2D DG problem, given a mesh geometry and a cell order (page [6](ann.desktopURI))   
	-   (page [6](ann.desktopURI))![[image-6-x99-y151.png]]  
	- At each frequency of interest, a snapshot-POD surrogate basis is created iteratively (see Sec. 1, or Ref. [18] for more details) (page [7](ann.desktopURI))   
	- Instead of selecting the impedance value, which is unbounded, we rather select the reflection coefficient value βs (page [7](ann.desktopURI))   
	-   (page [7](ann.desktopURI))![[image-7-x258-y625.png]]  
	- he transmission loss (TL) can be evaluated cheaply, at any impedance (page [7](ann.desktopURI))   
	- An optimal impedance, i.e., that yields the highest TL, can thus be evaluated at each frequency. (page [7](ann.desktopURI))   
	- Another strategy would be to only optimize the impedance value (or in this case, the reflection coefficient), to get as close to the optimal value βopt as possible, (page [7](ann.desktopURI))   
	-   (page [8](ann.desktopURI))![[image-8-x68-y576.png]]  
	- f1(x) = min ∑ω |β(x, ω) − βopt(ω)|. (page [8](ann.desktopURI))   
	- As both objectives f0 and f1 are meaningful, one could consider them both within a multi-objective optimization to be solved with dedicated methods such as those available in pyMOO [3] (page [8](ann.desktopURI))   
	- A first weighting is performed on frequencies, giving more weight when the optimal TL is steep, which indicates that an error on the reflection coefficient would be more damaging to the overall absorption of the liner (page [8](ann.desktopURI))   
	-   (page [8](ann.desktopURI))![[image-8-x129-y204.png]]  
	- the purpose of the min function next to α500 is to stop the optimization from trying to increase the TL at the specified frequency above a given user defined threshold TLthreshold, which would be done at the detriment of the other frequencies. (page [8](ann.desktopURI))       
	- Statistical inference method for liner impedance eduction with a shear grazing flow (page [13](ann.desktopURI))       
	- Model reduction via proper orthogonal decomposition (page [13](ann.desktopURI))   
	- A 3-d finite element mesh generator with built-in pre-and post-processing facilities. (page [13](ann.desktopURI))                                  