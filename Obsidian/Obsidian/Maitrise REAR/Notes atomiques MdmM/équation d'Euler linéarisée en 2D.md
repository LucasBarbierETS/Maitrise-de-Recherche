Si il n'y a pas d'écoulement l'équation d'Euler linéarisée peut être remplacée par une équation d'onde convectée.

L'utilisation de LEE permet de considérer des écoulement non uniformes, incluant des effects de réfraction associée à la [[couche limite de cisaillement]].

###### Cas général

$$

\begin{cases} 
\frac{\partial u}{\partial t} + u_0\frac{\partial u}{\partial x} + v_0\frac{\partial u}{\partial y} + \frac{\partial u_0}{\partial x} u + \frac{\partial u_0}{\partial y} v + \frac{\partial p}  {\partial x}= 0\\ \\ \\

\frac{\partial v}{\partial t} + u_0\frac{\partial v}{\partial x} + v_0\frac{\partial v}{\partial y}  + \frac{\partial v_0}{\partial x} u + \frac{\partial u_0}{\partial x} v + \frac{\partial p}{\partial x}= 0\\ \\ \\

\frac{\partial p}{\partial t} + \frac{\partial u}{\partial x} + \frac{\partial v}{\partial y} + u_0\frac{\partial p}{\partial x} + v_0\frac{\partial p}{\partial y} = 0\\ 
\end{cases}
$$
###### Ecoulement constant suivant $x$ (tube infini)

A écoulement constant suivant $x$ ($\frac{\partial u_0}{\partial x} = \frac{\partial v_0}{\partial x} = 0$) on obtient : 

$$

\begin{cases} 
\frac{\partial u}{\partial t} + u_0\frac{\partial u}{\partial x} + v_0\frac{\partial u}{\partial y} + \frac{\partial p}  {\partial x}= 0\\ \\ \\

\frac{\partial v}{\partial t} + u_0\frac{\partial v}{\partial x} + v_0\frac{\partial v}{\partial y} + \frac{\partial p}{\partial x}= 0\\ \\ \\

\frac{\partial p}{\partial t} + \frac{\partial u}{\partial x} + \frac{\partial v}{\partial y} + u_0\frac{\partial p}{\partial x} + v_0\frac{\partial p}{\partial y} = 0\\ 
\end{cases}
$$
###### Ecoulement et propagation unidirectionnels 

Avec une propagation acoustique unidimensionelle ($v_{0}= v = \frac{\partial v}{\partial x} = \frac{\partial v}{\partial y} = \frac{\partial p}{\partial y} = 0$) on obtient 

$$

\begin{cases} 
\frac{\partial u}{\partial t} + u_0\frac{\partial u}{\partial x} + \frac{\partial p}  {\partial x}= 0\\ \\ \\

\frac{\partial v}{\partial t} + \frac{\partial p}{\partial x}= 0\\ \\ \\

\frac{\partial p}{\partial t} + \frac{\partial u}{\partial x} + u_0\frac{\partial p}{\partial x} = 0\\ 
\end{cases}
$$

problème d'homogénéité!

vient de : An adjoint-based method for liner impedance eduction: Validation and numerical investigation

question   : quel lien avec les équations en 1D?