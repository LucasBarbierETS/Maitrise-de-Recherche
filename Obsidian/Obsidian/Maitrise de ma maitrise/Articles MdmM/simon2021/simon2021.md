---
year:
  "{ date | format (\"YYYY\") }": 
authors:
  "{ authors }":
---

Titre : Design and optimization of acoustic liners with a shear grazing flow: OPAL software platform description
Lien Zotero : [Simon et al. - 2021 - Design and optimization of acoustic liners with a .pdf](zotero://select/library/items/9GDCIRDH)


 
- OPAL objectifs        
	-  The first goal of OPAL is to allow the user to assemble a large panel of parallel/serial elementary acoustic layers along a given duct. (page [3](ann.desktopURI))                                                                           
- OPAL architecture                  
	-   (page [4](ann.desktopURI))![[image-4-x111-y503.png]]                                                              
- OPAL fonctionnement            
	-  the physical properties of this liner can be optimized for a given flow and frequency range, relatively to weighted objectives: impedance target, maximum absorption coefficient or transmission loss with a total sample size and weight... (page [3](ann.desktopURI))     
	-   (page [3](ann.desktopURI))![[image-3-x86-y66.png]]                                                                 
- OPAL solutions                      
	-   (page [4](ann.desktopURI))![[image-4-x49-y320.png]]  
	-  we state the modelling type of high sound pressure level (SPL) nonlinearities with Melling’s model [12] (page [4](ann.desktopURI))                                                           
- méthode de résolution 1D pour OPAL                          
	-  Two very distinct simulation capabilities are available. The first one assumes a liner of infinite length, and solves a simplified 1D problem of wave attenuation within an infinite duct. The second problem tackles the more challenging 2D case, where impedance discontinuities as well as complex geometries can be taken into account. In both situations, both plane and axisymmetric cases can be considered. (page [5](ann.desktopURI))     
	-  An eigenproblem is assembled, and solved for each frequency of interest from the linearized Euler equations (LEE) discretized with a spectral collocation method (Tchebychev polynomials) [18]. (page [5](ann.desktopURI))   
	-   (page [6](ann.desktopURI))![[image-6-x135-y531.png]]  
	-  The shear flow velocity profile and its spatial derivative are an input to the problem (page [6](ann.desktopURI))                                       
	- acoustique modale - écoulement Theoretical investigation of hydrodynamic surface mode in a lined duct with sheared flow and comparison with experiment (page [12](ann.desktopURI))   
	- description de la prise en compte de l'écoulement dans le modèle 1D Wavenumber-based Impedance Eduction with a Shear Grazing Flow (page [12](ann.desktopURI))         
- OPAL modèle 2D                                      
	-  a 2D Discontinuous-Galerkin (DG) solver for the harmonic linearized Euler equations can be used (page [7](ann.desktopURI))   
	-  The generalized eigen problem is solved with an Arnoldi’s method [21]. (page [8](ann.desktopURI))                                     
	- description de la méthode d'arnoldi pour le problème aux valeurs propres Wavenumber-based Impedance Eduction with a Shear Grazing Flow (page [12](ann.desktopURI))      
- OPAL optimisation                                            
	-   (page [8](ann.desktopURI))![[image-8-x233-y530.png]]  
	-  x is the vector of optimization variables (page [8](ann.desktopURI))   
	-  f is the objective function (page [8](ann.desktopURI))   
	-  A the matrix of linear constraints (page [8](ann.desktopURI))   
	-  [xmin, xmax] the bounds. (page [8](ann.desktopURI))   
	-  internal constraints (page [8](ann.desktopURI))   
	-  global constraints (page [8](ann.desktopURI))   
	-   (page [8](ann.desktopURI))![[image-8-x222-y127.png]]  
	-   (page [8](ann.desktopURI))![[image-8-x210-y88.png]]  
	-   (page [9](ann.desktopURI))![[image-9-x176-y631.png]]  
	-   (page [9](ann.desktopURI))![[image-9-x170-y565.png]]  
	-  The total order indices inform on how the transmission loss is affected by uncertainties on the liner parameters (page [9](ann.desktopURI))   
	- Analyse de sensibilité pour un liner LEONAR à deux couches, réalisée avec un algorithme de Monte Carlo sur un modèle Gaussien  (page [10](ann.desktopURI))![[image-10-x175-y619.png]]                           