###### Exemple d'une procédure

banc aéroacoustic B2A
M = 0.2
SPL = 150 dB
liner de 15 cm * 5 cm
goal : maximise the attenuation 
frequency :  200-3000 Hz
step : 10 Hz
pondération : surpondération à 500 Hz pour assurer une bonne atténuation
définition du besoin : il est possible de fournir un spectre de pondération

procédure : 
1. discrétisation (réalisée par pyDG) du LEE par la méthode 2D DG sur un maillage 2D GMSH 
2. L'utilisateur fournit le profil de vitesse de l'écoulement
3. Le problème linéaire est crée en deux partie, l'une statique et l'autre dynamique (partie optimisée).
4. Optimisation :
	1. à chaque fréquence : 
		- projection du problème sur une base orthogonale (Nz = 19) (accélération de l'ordre de 100)
		- calcul du coefficient de réflexion à chaque point de la base. Tracé dans le plan complexe.
		- Calcul du transmission loss (input défini par l'utilisateur, sortie fixe) pour n'importe quelle impédance
		- Pour chaque fréquence on obtient une impédance idéale.
		- pour une fréquence : 40 x10^3 TL calculés en 2 min
		- Pour un liner/une impédance donné on calcule le TL à toutes les fréquences. on utlise un algo du plus proche voisin  pour récupérer le TL depuis la carte de Tl pré-calculé
Une fois que la carte de TL est sauvegardée : 
- 
- Optimiser le coefficient de réflexion pour atteindre le coefficient optimal 
	- inconvénient : on ne considère par le TL donc risque trouver une solution sous optimale
	- [[idée - cartographiquer le TL autour de l'impédance optimale pour estimer la robustesse d'une approche indirecte]]
	- 
Fonction coût hybride : 

$f=\sum_i \epsilon_i\left|\beta_{s, \text { optim }}\left(\omega_i\right)-\beta_s\left(\omega_i\right)\right|^2+\alpha_{500} \min \left(\mathrm{TL}(500 \mathrm{~Hz}), \mathrm{TL}_{\text {threshold }}\right)$ 

- une pondération $\epsilon_i$ est effectuée au niveau des fréquences. Si le gradient du TL en fonction est de l'impédance est grand le poids est plus grand pour encourager la convergence la ou des écarts à l'optimal serait dommageable.
- 