
#### Pression acoustique et transformée de Fourrier

La pression acoustique mesurée dans un fluide est une fonction **réelle** du temps et de l’espace :
$$p(\mathbf{x},t)∈\mathbb{R}$$ Pour un signal à énergie finie : $$\int_{-\infty}^{\infty}|p(\mathbf{x}, t)|^2 d t<\infty$$
La [[Transformée de Fourrier]] est une bijection sur $L^2(\mathbb{R})$. 

![[Transformée de Fourrier#^085c88]]

On peut ainsi passer d'un signal temporel à sa transformée sans aucun risque ni perte d'information : 
$$p(\mathbf{x}, t)=\frac{1}{2 \pi} \int_{-\infty}^{\infty} \tilde{p}(\mathbf{x}, \omega) e^{i \omega t} d \omega$$
#### Pression acoustique réelle et complexe

$\tilde{p}(x, \omega)$ est la projection au sens du [[Produit scalaire généralisé]] de $p(x, t)$ sur $\phi_{\omega}$ appartenant à la [[Base généralisée]] de $L^2(\mathbb{R})$. 

A quelle condition $p(x, t) = \tilde{p}(x, \omega)e^{i \omega t}$ 

