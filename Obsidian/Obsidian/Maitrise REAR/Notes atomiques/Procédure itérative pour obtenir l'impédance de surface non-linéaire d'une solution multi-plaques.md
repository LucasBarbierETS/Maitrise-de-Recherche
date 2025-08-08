*Article de référence : Acoustical modeling of micro-perforated panel at high sound pressure levels using equivalent fluid approach*

On cherche ici à étendre et adapter l'approche itérative présentée dans l'article de référence, permettant de retrouver l'impédance de surface d'une structure plaque + cavité par une approche itérative.
Dans cet article, l'approche consiste à exprimer **[[Comportement additif de l'impédance de surface pour les structures plaques + cavités|la composante additive de l'impédance de surface]]** associée à la plaque perforée en cherchant à faire converger un modèle de prédiction de la vitesse acoustique à l'entrée de la solution.
$$Z_{total}= Z_{MPP} + Z_{background} $$

Ici on cherche donc une forme pour l'impédance de surface "propre" de la plaque qui s'exprime suivant l'**approche par matériau poreux équivalent** à partir de la **densité effective**, de la **porosité** et de l'**épaisseur du matériau** (ici la plaque) :

$$Z_{M P P}=j \frac{\omega h}{\rho_0 c_0 \phi} \tilde{\rho}_{e n}$$

La densité effective est, quant à elle, exprimée suivant le modèle JCA à partir de la **tortuosité** et de la **résistivité au passage de l'air** ainsi que les 3 autres paramètres qui constitue ce modèle.

$$\tilde{\rho}_{e n}(\omega)=\rho_0 \alpha_{\infty n l}\left(1+\frac{\sigma_t \phi}{j \omega \rho_0 \alpha_{\infty n l}} \sqrt{1+\frac{4 j \rho_0 \omega \eta \alpha_{\infty n l}^2}{\phi^2 \sigma_t^2 \Lambda^2}}\right)$$

C'est ici que l'on fait apparaitre les effets non-linéaires.  En effet on sait que **ces deux paramètres sont particulièrement sensibles à la vitesse acoustique dans le matériau** : 

On a d'abord
$$\alpha_{\infty n l}=1+\frac{2 \varepsilon_{e n l}}{h}$$
avec
$$\varepsilon_{\text {enl }}=\frac{\Psi}{\left(1+V_a /\left(\phi c_0\right)\right)} 0.48 \sqrt{\pi r^2}\left[\sum_{n=0}^8 a_n(\sqrt{\phi})^n\right]$$
Puis
$$\sigma_t=\frac{8 \eta}{\phi r^2}+\beta \frac{\rho_0\left(1-\phi^2\right)}{\pi h \phi C_D^2} V_a$$

Ainsi pour avoir $Z_{MPP}$ on a besoin de $Z_{background}$  et de $Va$. Par ailleurs pour connaitre $Va$ nous avons besoin de $Z_{total}$ donc de $Z_{MPP}$ et de $Z_{background}$. 

**Extension**

Dans notre code analytique, **la surface d'impédance est obtenue à partir des matrices de transfert** des différentes parties de la solution, aussi complexe soit-elle, et ainsi l'approche additive ne s'applique pas. Il faut alors : 
- imposer un modèle à vitesse nulle à l'entrée de la solution. On est donc dans le cas du modèle linéaire et on prédit l'impédance globale par produit successif de matrice. 
- A partir de cette impédance initiale, on calcule la vitesse RMS (voir [[Relations entre impédance de surface, grandeurs acoustiques et grandeurs RMS]])
- .
- Comme on a la pression RMS et la vitesse RMS on remonte couche par couche aux valeurs successives de vitesse et pression RMS. Pour cela on a besoin de la **matrice de transfert inverse** (voir [[Discussion sur l'application des matrices de transfert inverses au valeurs RMS]])
- On calcule alors à nouveau les nouveaux paramètres JCA des couches et ainsi l'impédance de de surface totale qui nous permet de définir une nouvelle vitesse RMS. Et ainsi de suite…
- On finit par définir un critère de convergence (max des écarts entre des itérations des vitesses RMS).

Pour cela il faut :
- une méthode de matrice de transfert inverse pour remonter les parties dans le sens inverse
- une méthode de définition flottante des paramètres JCA des plaques avec un paramètres Va définit à 0 par défaut (cas linéaire et qui augmente avec le niveau sonore)

**Algorithme**

- Pas de méthode itérative à l'intérieur de la classe, la procédure itérative est lancé depuis l'élément globale (**surface_impedance_iter(env)**)
- env continent le vecteur p_rms sur le support fréquentiel
- Initialisation

