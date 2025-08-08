##### Tags :  #modèle

Ce modèle est présenté dans [[jones2022]]

Il permet de déterminer l'[[impédance de surface normalisée d'une plaque perforée]] d'un liner [[liner acoustique à 1 degré de liberté|SDOF]].

##### Hypothèses du modèle

- Le modèle est à [[modèle à constante localisée|constante localisée]]. 

- Les non-linéarités associées aux [[forts niveaux]] et à l'[[écoulement rasant]] sont prises en compte

##### Construction du modèle

Ce modèle est de la forme : 
$$\zeta_s=\theta+\mathrm{i} \chi=\theta_{\mathrm{fs}}+\theta_{\mathrm{gf}}+\mathrm{i}\left\{\chi_{\mathrm{fs}}-\cot (k h)\right\}$$

Ce modèle est une recomposition de plusieurs modèles précédents. Il se base sur le [[Zwikker - Kosten Transmission Line (ZKTL)|modèle à transmission de ligne de Zwikker et Kasten]] qui traduit la propagation des ondes dans le liner et du [[Motsinger - Kraft Model (MKM)|modèle de Motsinger et Kraft]] qui prend en compte en compte les forts niveaux. La prise en compte de l'écoulement vient du [[Rice - Heidelberg model|modèle de Rice et Heidelberg]]. 

L'impédance de surface est donnée avec ce modèle par :

$$\zeta=\frac{32 \mu t}{\rho_0 c_0\left(\phi C_D\right) d^2}+\frac{1}{2 c\left(\phi C_D\right)^2} u_{\mathrm{rms}}+\frac{M_{\mathrm{C} / \mathrm{L}}}{\phi\left\{2+1.256\left(\delta_1 / d\right)\right\}}+\mathrm{i}\left\{\frac{k(t+\epsilon d)}{\phi}-\cot (k h)\right\}$$
###### *légende*

$\mu$ la [[viscosité dynamique]] de l'air, $C_D$ le [[coefficient de décharge]] de l'orifice, $\phi$ la porosité de la plaque, $u_{\mathrm{rms}}$ la vitesse acoustique quadratique moyenne


###### Description détaillée du modèle

Pour la partie réelle : 
- Le [[Motsinger - Kraft Model (MKM)#Résistance acoustique $ frac{R}{ rho c}$|premier terme]] est associé à la résistance de la plaque perforée
- Le [[Motsinger - Kraft Model (MKM)#Résistance acoustique $ frac{R}{ rho c}$|deuxième terme]] est associé à la résitance acoustique due aux forts niveaux 
- Le [[Rice - Heidelberg model|troisième terme]] est associé à la résitance acoustique due à l'écoulement rasant

Pour la partie imaginaire : 
- Le [[Motsinger - Kraft Model (MKM)|premier terme]] est associé à la correction de l'épaisseur de la plaque. Dans ce terme, $\epsilon$ [[Rice - Heidelberg model|tient compte de l'écoulement]] 
- Le [[Zwikker - Kosten Transmission Line (ZKTL)|dernier terme]] est associé à la propagation dans la cavité derrière la plaque