
La densité spectrale de puissance est la [[Transformée de Fourrier]] de la fonction d'autocorrélation d'un processus (Wiener–Khinchin) 
$$S_{p p}(f)=\int_{-\infty}^{\infty} R_{p p}(\tau) e^{-j 2 \pi f \tau} \mathrm{~d} \tau, \quad R_{p p}(\tau)=\mathbb{E}[x(t) x(t+\tau)]$$

Que donne l'autocorrélation d'un signal temporel?

$$\mathcal{F}\left\{R_{x x}\right\}(f)=|X(f)|^2$$$$S_{x x}(f)=\mathcal{F}\left\{R_{x x}(\tau)\right\} \quad\left(\mathrm{PSD}, \mathrm{~Pa}^2 / \mathrm{Hz}\right)$$

#### Différence entre DSP et DSE

Pour un signal à énergie finie, non nul entre $0$ et $T$, la **densité spectrale d'énergie** est définie par :
$$\Phi_x(f)=\left|X_T(f)\right|^2, \quad X_T(f)=\int_0^T x(t) e^{-j 2 \pi f t} d t$$
En intégrant la DSE sur tout le domaine fréquentiel, on retrouve l'énergie totale du signal :
$$\int_{-\infty}^{\infty} \Phi_x(f) d f=\int_0^T x^2(t) d t=E \quad\left[\mathrm{~Pa}^2 \cdot \mathrm{~s}\right]$$
La densité spectrale de puissance peut être calculée pour tout signal d'énergie infinie à puissance finie (stationnaire). En l'intégrant on retrouve la puissance moyenne (RMS) du signal, equivalent à sa variance.
$$\int_{-\infty}^{\infty} S_{x x}(f) d f=R_{x x}(0)=\mathbb{E}\left\{x^2(t)\right\}=p_{\mathrm{rms}}^2 \quad\left[\mathrm{~Pa}^2\right]$$
#### A retenir

- Pour **comparer visuellement** : compare les **PSD (Pa²/Hz)** → invariantes au pas, tant que la bande fréquentielle et la normalisation (monocôté, fenêtre/énergie, calibration) sont cohérentes.
    
- Pour **intégrer** (OASPL, niveaux de bandes) :
    
    - **Depuis PSD** → multiplier par Δf\Delta fΔf.
        
    - **Depuis narrow-band** → **somme des $p_{\mathrm{rms}}^2$​** (sans $\Delta f$).
        
- Les deux voies donnent la **même puissance totale** si tout est bien aligné.