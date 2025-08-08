[[zhang2023]]

###### Datasets

Plusieurs datastets sont utilisés pour l'entrainement et l'apprentissage. 

- D est le datatset utilisé pour la phase d'apprentissage. Il est composé de 20000 paires de données chacune formée par **une configuration paramétriques de 10 valeurs** et **un spectre d'absorption associé à celle-ci de 109 valeurs**. Le spectre est obtenu par simulation numérique de la configuration paramétrées sur COMSOL. Les configurations paramétriques sont définies (aléatoirement?) dans une limite

###### Questions pour l'auteur

- Comment sont obtenus les spectres dans le cas du datasets D2? Y-a t'il toujours une configuration réelle derrière chaque spectre ou celle-ci sont obtenus aléatoirement? Dans la figure 7 la cible ressemble à une courbe réaliste issue d'une configuration préatablie. Si c'est le cas quelle est cette configuration? Est-elle dans range1 ou dans range2? 
- Comment est calculé le cout lors de la caractéristation inverse? 
- Comment fonctionne le test du modèle inverse puisque aucune cible ne sera jamais totalement atteinte? Peut-on fournir un seuil de tolérance d'erreur?
