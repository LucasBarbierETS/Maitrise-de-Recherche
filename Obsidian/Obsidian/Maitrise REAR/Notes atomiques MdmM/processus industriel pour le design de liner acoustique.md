
utilisation d'une approche numérique (par élément finis)

[[winklerHighFidelityModeling2021]]

« The liner design approach at Collins Aerospace, which is considered representative for the aerospace industry, consists of a three-step process, starting with impedance optimization, then followed by the assessment of the liner attenuation in the far field, and finally the evaluation of system level noise targets » (Winkler et al., 2021, p. 532)

« An Actran model generally requires the creation of a computational mesh, a realistic CFD flow database, and the assembly of a finite element input file to specify the noise excitation and boundary conditions. » (Winkler et al., 2021, p. 533)

1. **Définition de l'impédance cible**

« The target attenuation spectrum is defined, prior to the optimization, in concurrence with the engine manufacturer’s system level noise targets.» (Winkler et al., 2021, p. 532)

question : qui défini les objectifs? Le motoriste? Le constructeur d'avion? Les normes gouvernementales? Comment sont formulés les objectifs?

2. **Mise en oeuvre de l'optimisation de la configuration du liner**

![[image-3-x90-y255.png]]

A partir de l'impédance cible, on retrouve les paramètres du liner (typiquement SDOF) qui match au mieux avec l'objectif par une optimisation multi-variables. Le [[modèle de Goodrich]] est utilisé.

« A representative reduced order model (ROM) for predicting the liner impedance is the Goodrich impedance model that is currently used by the Collins Aerospace nacelle business to perform liner optimizations along with pre-test and pre-certification noise predictions » (Winkler et al., 2021, p. 533)

« based on pre-defined attenuation targets » (Winkler et al., 2021, p. 532) **cela veut-il dire que l'optimisation est "entrainée" sur des cibles d'entrainement au préalable?** 

D'après le graphe, l'impédance permet de prédire une "atténuation", visiblement en champ proche puisque le champ lointain est mentionné plus loin.

Ca n'est pas préciser dans le texte mais la prédiction semble être réutilisée pour redéfinir le spectre d'atténuation cible (cela ressemblerait à une méthode hybride?)

3. **Calcul de l'atténuation acoustique en champ lointain**

D'après le graphe : ![[image-3-x120-y169.png]]
Le spectre de source est défini est utilisé en plus de l'évaluation de l'impédance du liner optimal.

« The input source for the predictions utilizes equal energy modal distribution. » (Winkler et al., 2021, p. 534)

4. **Evaluation des niveaux sonores perçus**
![[image-3-x115-y79.png]]
