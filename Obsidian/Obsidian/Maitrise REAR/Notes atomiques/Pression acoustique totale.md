La pression acoustique totale est une grandeur scalaire de l'espace. 
- Dans le cas 1-D on l'écrit $p = p(x, t)$.
- Pour décomposer cette pression dans le domaine fréquentielle on réalise la **[[Transformée de Fourrier]]** de la pression acoustique totale qui nous donne son **spectre fréquentiel** $$\tilde{p}(x, \omega) = \int_{-\infty}^{\infty} p(x, t) e^{-j \omega t} dt$$
- Dans le cas général on retrouve le signale de pression à partir de son spectre $$p(x,t)=Re \{ \int_{0}^{\infty} ​\tilde{p}(x, \omega)e^{j \omega t} dω\}$$
- Dans le cas ou le signal est **monochromatique** $\tilde{p}​(x,\omega)=P(x)\cdot\delta(\omega−\omega_0​)$ on a en particulier $$p(x,t)=Re \{P(x)e^{j\omega_{0}t} \}$$
Il devient particulièrement intéressant d'identifier la pression acoustique totale au contenu de l'accolade car toutes les propriétés analytiques qui s'appliquent à la pression réelle sont simplifiées en notation complexe $$p(x,t)=P(x)e^{j\omega_{0}t}$$ 
##### Relation avec la [[Pression acoustique incidente]]

La solution générale à l'équation des ondes à une pulsation $\omega_0 = k_0c$ donnée est 
$p(x,t) = P(x)e^{j\omega_{0}t} = (P_ie^{{-jkx}} +P_re^{{jkx}})e^{j\omega_{0}t}$

p_{i}(x,t) + p_{r}(x,t) = P_i(x)e^{j\omega_{0}t} +P_r(x)e^{j\omega_{0}t} = P_ie^{{-jkx}} +P_re^{{jkx}}$
$$P_t = P_{i} \space (1 + R)$$
