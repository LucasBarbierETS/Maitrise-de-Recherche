[[stephens2008]] 

La méthode développée par Stephens & Morris permet d'obtenir la fonction transfert d'un rotor caréné à partir de mesures acoustiques en champ lointain.

Le rotor est supposé non étendu dans l'espace (ensemble de dipôles acoustiques axiaux)


[[fischer2022]]

- « The transfer function relates near-field in-duct and far-field out-duct information. The fan was considered a compact region of axial dipole sources. » (Fischer et al., 2022, p. 3)

- « An iterative algorithm was developed in Matlab to extract the acoustic transfer function spectrum from a series of microphone measurements obtained at several rotor tip speeds but at a single position. » (Fischer et al., 2022, p. 3)

L'algorithme est basé sur la séparation entre le champ de pression rayonné, le terme de source acoustique (force) et la fonction transfert : 
$$\log P_o(f)=\log F(S t)+\log T(H e)$$
(équivalent à $P_o(f)=F(S t)\cdot T(H e)$) 

avec $S_t$ le [[nombre de Strouhal]] et $H_e$ le [[nombre d'Helmholtz]].

- « It must be noted that in Eq. 1 the source strength $F$ depends only on *$S_t$* and the transfer function $T$ depends only on $H_e$. This is because the acoustic sources are explicitly dependent on a frequency related to the fluid velocity, while the transfer function is related only to the geometry of the surrounding surfaces and the sound speed in the medium. » (Fischer et al., 2022, p. 4)

Stephens montre que :
$$\log T=\log k^2+\log \left|G_f\right|^2+\log |\chi|^2+\log \cos ^2 \theta_d$$
(équivalent à $T= k^{2}\cdot \left|G_f\right|^{2}\cdot |\chi|^{2} \cdot \cos ^2 \theta_d$) 

avec $k$ le nombre d'onde, $G_f$ la fonction de Green pour un point de la source en champ libre, $\chi$ le facteur d'amplification de la fonction transfert dû au carénage, $\theta_d$ l'angle entre l'axe du dipôle acoustique et la ligne entre la source et l'obsevateur.

On fait l'hypothèse que la fonction de source acoustique est reliée à la vitesse linéaire de boût de pâle $M_{tip}$ par une loi exponentielle : 

$$F(S t, M_{\text {tip}})=F_{0}\cdot M_{\text {tip }}^{n \cdot S_t}$$

(équivalent à  $\log F\left(S t, M_{\text {tip }}\right)=\log F_{0}(S_t)+ n \cdot S t \cdot \log M_{\text {tip}}$ )

- « That particular scaling for the tip speed has been well documented in the literature, and many different values for 푛 have been found [14–16]. » (Fischer et al., 2022, p. 4)

Les inconnues $F_0$ et $n$ sont obtenues à partir d'une régression des moindre carrés pour $F(S_t)$ pour différentes valeurs de $M_{tip}$.

On normalise la fonction source avec le nombre de Strouhal : $$F\left(S t, M_{\text {tip }}\right)=\left(V_{\text {tip }} B / \pi D_r\right) F\left(f, M_{\text {tip }}\right)$$Finalement le problème initial se réecrit :
$$\log P_o\left(f, M_{\text {tip }}\right)=\log F_0(S t)+n(S t) \log M_{\text {tip }}+\log k^2+\log \left|G_f\right|^2+\log |\chi(H e)|^2+\log \cos ^2 \theta_d$$

Comme l'équation est surdéterminée, on utilise une approche itérative pour converger vers le résultat : 

![[image-9-x70-y319.png]]


- « It must be noted that the method presented in this section to obtain the source strength 퐹 is only valid for a rotating dipole. In the current work, two types of sources are investigated: a speaker (monopole) and a propeller (rotating dipole). The source estimate using Stephens model is only applicable for the propeller case. For the speaker, an arbitrary value of 퐹 = 1 is used as an input in the model. » (Fischer et al., 2022, p. 5)






