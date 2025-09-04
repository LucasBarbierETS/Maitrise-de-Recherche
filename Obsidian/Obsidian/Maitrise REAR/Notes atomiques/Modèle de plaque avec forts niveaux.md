#### Modèle de Laly ([page. 73](zotero://open-pdf/library/items/CMZQ7B9B?page=73&annotation=HHWB2KEC))

##### Redéfinition des paramètres du modèle JCAL

Laly redéfinie la tortuosité et la résistivité au passage de l'air de la plaque en tenant compte de la vitesse acoustique RMS à l'entrée de celle-ci ([page. 76](zotero://open-pdf/library/items/CMZQ7B9B?page=76&annotation=6UFNB66G)). La formulation basée sur le coefficient de décharge de la plaque vient de Zinn ([page. 70](zotero://open-pdf/library/items/CMZQ7B9B?page=70&annotation=4BWUU625))

$$\sigma_t=\frac{8 \eta}{\phi r^2}+ \frac{4}{3}\frac{\rho_0\left(1-\phi^2\right)}{\pi h \phi C_D^2} V_a$$
et $$\alpha_{\infty n l}=1+\frac{2 \varepsilon_{e n l}}{h}$$
$$\varepsilon_{\text {enl }}=\frac{4}{3\left(1+V_a /\left(\phi c_0\right)\right)} 0.48 \sqrt{\pi r^2}\left[\sum_{n=0}^8 a_n(\sqrt{\phi})^n\right]$$
avec $$\begin{aligned}
& a_0=1.0, a_1=-1.4092, a_2=0.0, a_2=0.33818, a_4=0.0 \\
& a_5=0.06793, a_6=-0.02287, a_7=0.003015, a_8=-0.01614
\end{aligned}$$
^10b67e
#### Expression de la vitesse RMS dans les perforations

Pour exprimer la vitesse RMS, deux approches sont possibles : 
- Une première approche, reprise de Soon-Hong Park, **formule explicitement la relation entre la pression incidente RMS et la vitesse acoustique RMS**  ([page. 78](zotero://open-pdf/library/items/CMZQ7B9B?page=78&annotation=DIR75TT3)) $${V_{a_{RMS}}}=\frac{c_0}{\sqrt{2}} \frac{\phi}{\left(1-\phi^2\right)}\left[-\frac{1}{2}+\sqrt{\frac{1}{4}+\frac{2 \sqrt{2} {P}_{i_{RMS}} }{\rho_0 c_0^2} \frac{\left(1-\phi^2\right)}{\phi^2}}\right]$$ Cette approche nécessite cependant de connaitre la pression incidence (différente de la pression totale) ce qui n'est pas toujours le cas en pratique.

- Une seconde approche, suggérée mais non utilisée par Laly, consiste à exploiter la relation $$|{Z_s}| = \frac{|{P_{t_{RMS}}}|}{|V_{a_{RMS}}|}$$ pour **retrouver itérativement** la valeur de la vitesse telle que $$|{Z_s(V_{iter})}| - \frac{|{P_{t_{RMS}}}|}{|V_{iter}|} < \epsilon$$avec $P_{r e f} 10^{L_p / 20}$ , $L_p$ le niveau de pression totale à l'entrée, $P_{r e f} = 20 \mu \mathrm{~Pa}$ la pression acoustique de référence.

#### Un modèle semi-empirique

Ce modèle demeure un modèle semi-empirique car il tient compte de certains effets géométriques de la plaque obtenus empiriquement au moyen du [[coefficient de décharge]] de la plaque $C_{d}= 0.76$. Cette valeur est admise en général mais varie en réalité en fonction des paramètres géométriques (On considère pour les cas d'applications les plus courants que le coefficient varie entre 0.6 et 0.8 ([page. 70](zotero://open-pdf/library/items/CMZQ7B9B?page=70&annotation=KYTJMKWM)) . [Kraft](zotero://open-pdf/library/items/9IDH9DCW?page=563&annotation=7NJH4ACN) propose une formule empirique pour ce coefficient en fonction des différents paramètres géométriques de la plaque dans le cas où le rapport $t/d$ entre l'épaisseur et le diamètre des perforations est inférieur à 1 (plaques fines).
$$C_D=0.80695 \sqrt{\sigma^{0.1} / e^{-0.5072(t / d)}}$$
