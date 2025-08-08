##### Tags : #modèle #prise_en_compte_de_l_écoulement

Ce modèle est développé par *Rice E. J.* dans *A Model for the Acoustic Impedance of a Perforated Plate Liner With Multiple Frequency Excitation*

Il est reprit dans [[note de lecture - jonesBroadbandLowFrequencyAcoustic2022]] dans le [[modèle réaliste de l'impédance de surface d'un liner]] d'un [[liner acoustique à 1 degré de liberté]].

Ce modèle décrit la relation entre la [[résistance acoustique normalisée d'une plaque perforée]] de la surface perforée d'un liner située dans une conduite et l'[[écoulement fluide dans un tube|écoulement d'air à l'intérieur de cette conduite]]. 

Le modèle [[modèle réaliste de l'impédance de surface d'un liner|SIM]] est de la forme :
$$\zeta_s=\theta+\mathrm{i} \chi=\theta_{\mathrm{fs}}+\theta_{\mathrm{gf}}+\mathrm{i}\left\{\chi_{\mathrm{fs}}-\cot (k h)\right\}$$
###### Résistance acoustique associée à l'écoulement

La résistance acoustique associée à l'écoulement est donnée par :
$$\theta_{\mathrm{gf}} = \frac{M_{\mathrm{C} / \mathrm{L}}}{\phi\left\{2+1.256\left(\delta_1 / d\right)\right\}}$$

avec $M_{\mathrm{C} / \mathrm{L}}$ le [[nombre de Mach en ligne centrale]], $\delta_1$ l'épaisseur de la [[couche limite de déplacement]], $d$ le diamètre des perforations, $\phi$ la porosité de la plaque.

Lorsque $\left(\delta_1 / d\right) \approx 1$ (écoulement fort) on a :
$$\theta_{\mathrm{gf}} = \frac{M_{\mathrm{C} / \mathrm{L}}}{3\Omega}$$
###### Réactance acoustique associée à l'écoulement

Les effects de [[Motsinger - Kraft Model (MKM)|réactance acoutique associée à la plaque perforée]] sont des [[effets de masse ajoutée]]. 

La longueur de correction $\epsilon d$ ajoutée à l'épaisseur de la plaque dans le [[Motsinger - Kraft Model (MKM)|calcul de la réactance]] est reprend celle fournit par [[facteur de correction de longueur pour une plaque perforée#Facteur de correction de Ingard|Ingard]] pour tenir compte de l'écoulement : 
$$\epsilon=\frac{0.85(1-0.7 \sqrt{\phi})}{1+305 M_{C / L}^3}$$
###### Questions 

[[question - Est-ce qu'on peut définir un nombre de mach en ligne centrale pour un rotor caréné d'hélicoptère]]?