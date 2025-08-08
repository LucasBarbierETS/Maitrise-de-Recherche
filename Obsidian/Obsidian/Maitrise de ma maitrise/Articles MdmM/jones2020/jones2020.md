---
year:
  "{ date | format (\"YYYY\") }": 
authors:
  "{ authors }":
---

Titre : A Review of Acoustic Liner Experimental Characterization at NASA Langley
Lien Zotero : [Jones et al. - A Review of Acoustic Liner Experimental Characteri.pdf](zotero://select/library/items/EWULH8SU)


 
- méthode pour déterminer l'impédance acoustique d'un liner basée l'équation de Helmholtz convectée    
	- hypothèses It assumes the flow is uniform and the sound fields upstream (0 ≤ x ≤ x1) and downstream (x2 ≤ x ≤ L) of the liner (see Fig. 32) contain no higher-order modes. (page [39](ann.desktopURI))   
	- équation de Helmholtz convectée  (page [39](ann.desktopURI))![[image-39-x144-y122.png]]  
	- condition limite pour une surface à réaction localisée développée par Myers  (page [40](ann.desktopURI))![[image-40-x128-y676.png]]  
	- données du modèle 1/ζ, is taken as zero along the rigid wall portion of the upper wall and H is the duct height (page [40](ann.desktopURI))   
	- la vitesse normale à la surface est nulle dans le cas d'une condition limite rigide  (page [40](ann.desktopURI))![[image-40-x266-y568.png]]  
	- la pression est mesurée au niveau du mur rigide en face du traitement. L'hypotèse de pression constante sur le plan est faite.  (page [40](ann.desktopURI))![[image-40-x206-y508.png]]  
	-  The CHE method employs an optimizer to search for an impedance where the acoustic pressures predicted via this finite element method match the corresponding acoustic pressures measured with the microphones along the lower wall of the GFIT to within an acceptable tolerance. (page [40](ann.desktopURI))   
	-   (page [40](ann.desktopURI))![[image-40-x205-y388.png]]  
	-   (page [40](ann.desktopURI))![[image-40-x146-y159.png]]  
	-  Stewart’s adaptation of the Davidon-Fletcher-Powell (SDFP) optimization 3 (page [40](ann.desktopURI))   
	-  algorithm [55, 56] was employed to minimize the cost function, F (ζ). (page [41](ann.desktopURI))   
	-  0.5 + 0.5i, 0.5 − 0.5i, 2.0 + 0.5i, and 2.0 − 0.5i (page [41](ann.desktopURI))   
	-  it is also possible to use contour maps of the cost function to determine the liner impedance (page [41](ann.desktopURI))   
	-  More recent implementations of the CHE method (sometimes labeled as Python CHE or PyCHE) support the use of a variety of optimizers contained within the SciPy optimization toolkit [58 (page [41](ann.desktopURI))     
	- description de la condition limite pour une surface à réaction localisée On the Acoustic Boundary Condition in the Presence of Flow (page [55](ann.desktopURI))   
	-  A Modification of Davidon’s Minimization Method to Accept Difference Approximations of Derivatives (page [55](ann.desktopURI))   
	- description de l'algorythme Stewart-Davidon-Fletcher-Powell A Comparative Study of Four Impedance Eduction Methodologies Using Several Test Liners (page [55](ann.desktopURI))   
	- description des algorithmes utilisés pour PyCHE SciPy : Open source scientific tools for Python (page [55](ann.desktopURI))   
	- comparaison de différents algorithmes d'optimisation pour la méthode CHE Impedance Eduction for Multisegment Liners (page [55](ann.desktopURI))                       