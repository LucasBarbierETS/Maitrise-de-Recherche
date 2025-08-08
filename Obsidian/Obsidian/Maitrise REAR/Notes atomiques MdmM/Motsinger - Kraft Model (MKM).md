
Ce modèle est développé par [[note de lecture - motsinger1991|Motsinger et Kraft]] pour décrire l'[[impédance de surface]] d'un [[liner acoustique à 1 degré de liberté]] sous la forme : 

$$\frac{Z}{\rho c}=\frac{R}{\rho c}+i\left(\frac{X_m}{\rho c}+\frac{X_c}{\rho c}\right)$$
###### *légende*
$$\begin{array}{ll}R / \rho c & \text { face-sheet resistance } \\ X_m / \rho c & \text { face-sheet mass reactance } \\ X_c / \rho c & \text { cavity reactance, equal to }-\cot (k h) \\ h & \text { cavity depth, cm } \\ k & \text { wave number, equal to } \omega / c, \mathrm{~cm}^{-1}\end{array}$$
###### Résistance acoustique $\frac{R}{\rho c}$  

Pour définir la [[résistance acoustique normalisée d'une plaque perforée|résistance acoustique de la plaque perforée]], une relation est faite entre cette grandeur et la [[résistance au passage de l'air d'une plaque perforée|résistance au passage de l'air de cette plaque]]. 
 $$\frac{R}{\rho c}=\frac{32\mu t}{ \rho_0 c_0\left(\phi C_D\right) d^2}+\frac{1}{2 c_0\left(\phi C_D\right)} u_{\mathrm{rms}}$$
###### *légende*

$\mu$ la [[viscosité dynamique]] de l'air, $C_D$ le [[coefficient de décharge]] de l'orifice, $\phi$ la porosité de la plaque, $u_{\mathrm{rms}}$ la vitesse acoustique quadratique moyenne. 

###### Réactance acousique $\frac{X_m}{\rho c}$ 

La [[réactance acoustique d'une plaque perforée| réactance acosutique de la plaque perforée]] est associée à des effets de masse ajoutée. 

$$\frac{X_m}{\rho c} = \frac{k(t + \epsilon d)}{\phi} \quad \text{avec} \quad \epsilon = 0.85(1 - 0.7 \sqrt{\phi})$$
###### *légende*

$k$ le nombre d'onde, $\epsilon d$ le terme de correction de longueur de l'épaisseur avec $\epsilon$ un [[facteur de correction de longueur pour une plaque perforée]] adimenssionel.

Cette formulation est reprise de [[note de lecture - ingardTheoryDesignAcoustic1953|Ingard]].
###### Utilisation

Ce modèle est utlisé pour développer un [[modèle réaliste de l'impédance de surface d'un liner]] qui [[sujet - prise en compte de l'écoulement|tienne compte de l'écoulement]]. 