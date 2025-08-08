
1. **Grandeurs acoustiques, grandeurs $RMS$**

La moyenne du produit scalaire des signaux temporels est égale au produit des valeurs *RMS*
![[Acoustics of Ducts and Mufflers#^6fbcdd]]

Dans le cas d'un signale sinusoïdal $p = Pe^{j\omega t}$, $p_{rms} = P/\sqrt{2}$
Le niveau sonore mesuré par un microphone à une fréquence donnée prend la forme : 
$$L_p\left(f\right)=20 \log _{10}\left(\frac{p_{R M S}\left(f\right)}{p_{r e f}}\right)$$avec 
$$p_{R M S}(f)=\frac{1}{\Delta{f}}\sqrt{\int_{f-\Delta f / 2}^{f+\Delta f / 2} |\tilde{p}(f)|^{2 }df}$$L'échantillonnage temporel du signal impose une résolution fréquentielle minimale pour la transformée de Fourrier de celui-ci. Ainsi : 
$$p_{R M S}(f)=|\tilde{p}(f)|$$
et de même : 
$$v_{R M S}(f)=|\tilde{v}(f)|$$
On peut alors faire le lien entre l'impédance de surface : 
$$Z_{s}(f) = \frac{\tilde{p}(f)}{\tilde{v}(f)}$$ et les valeurs $RMS$ de ces mêmes grandeurs exprimées sur l'échelle logarithmique.

On a en effet
$$v_{R M S}(f) = \frac{p_{ref}*10^{L_{p}(f)/20}}{|Z_{s}(f)|}$$

**Il est alors possible de définir la vitesse moyenne quadratique $v_{RMS}$ impliquée dans la formulation des effets non-linéaires à partir du niveau sonore à la surface du traitement et de l'impédance de surface**.

2. **Matrices de transfert**

Comme
$$
\begin{pmatrix} \tilde{p_{1}}(f) \\ \tilde{v_{1}}(f) \\ \end{pmatrix} = 
\begin{pmatrix} T_{1, 1}&T_{1, 2}  \\ T_{2, 1}&T_{2, 2} \\ \end{pmatrix} 
\begin{pmatrix} \tilde{p_{2}}(f) \\ \tilde{v_{2}}(f) \\ \end{pmatrix}
$$
on a 
$$ \begin{cases} 
|\tilde{p_{1}}(f)| = |T_{1, 1}*\tilde{p_{2}}(f) + T_{1, 2}*\tilde{v_{2}}(f)|\\
|\tilde{p_{2}}(f)| = |T_{2, 1}*\tilde{p_{2}}(f) + T_{2, 2}*\tilde{v_{2}}(f)| 
\end{cases}
$$
Comme dans le cas général (notre situation n'étant pas une exception)
$$|a+b| \neq |a| + |b|$$**Il n'est pas possible d'utiliser les matrices de transfert pour retrouver les valeurs *RMS* au niveau des différentes interfaces**.

Pour remédier à ce problème il faut reconstruire la transformée d'une pression acoustique incidence virtuelle ayant les mêmes propriétés énergétiques que le signal mesuré. 






