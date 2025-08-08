## 1. Matrice de transfert d'un bloc

La matrice de transfert $T$ d'un bloc acoustique est définie par :

$$\begin{bmatrix} p_1 \\ v_1 \end{bmatrix} = \begin{bmatrix} T_{11} & T_{12} \\ T_{21} & T_{22} \end{bmatrix} \begin{bmatrix} p_2 \\ v_2 \end{bmatrix}$$

L'impédance de surface du bloc est obtenue par la relation entre la pression et la vitesse :

$$Z_s = \frac{p_1}{v_1} = \frac{T_{11} \cdot p_2 + T_{12} \cdot v_2}{T_{21} \cdot p_2 + T_{22} \cdot v_2}$$

## 2. Impédance de surface du bloc du dessous

L'impédance de surface du bloc inférieur est donnée par :

$$Z_{s,\text{dessous}} = \frac{T_{11,\text{dessous}}}{T_{21,\text{dessous}}}$$

## 3. Composition des matrices de transfert

Lorsque deux blocs sont superposés, la matrice de transfert totale est le produit des matrices de chaque bloc :

$$T_{\text{tot}} = T \cdot T_{\text{dessous}}$$

Avec :

$$T_{\text{tot}} = \begin{bmatrix} T_{11} & T_{12} \\ T_{21} & T_{22} \end{bmatrix} \begin{bmatrix} T_{11,\text{dessous}} & T_{12,\text{dessous}} \\ T_{21,\text{dessous}} & T_{22,\text{dessous}} \end{bmatrix}$$

## 4. Expression de l'impédance de surface totale

L'impédance de surface totale est définie par :

$$Z_{s,\text{tot}} = \frac{T_{\text{tot},11}}{T_{\text{tot},21}}$$

En développant les termes :

$$\begin{cases}
T_{\text{tot},11} = T_{11} \cdot Z_{s,\text{dessous}} + T_{12} \\ T_{\text{tot},21} = T_{21} \cdot Z_{s,\text{dessous}} + T_{22} \\
\end{cases}$$


Finalement, l'impédance de surface totale s'exprime sous la forme :

$$Z_{s,\text{tot}} = \frac{T_{11} \cdot Z_{s,\text{dessous}} + T_{12}}{T_{21} \cdot Z_{s,\text{dessous}} + T_{22}}$$
## Conclusion

Cette expression montre que l'impédance de surface totale est une fonction rationnelle des éléments des matrices de transfert du bloc de transfert et de l'impédance du bloc inférieur.