
Une fois que la [[méthode de prise de note dans Zotero]] est terminée, on importe les annotations brutes dans une note de revue à l'aide du plugin *Zotero Integration*.

Ces annotations serviront par la suite à la rédaction d'une note de lecture ainsi que différentes notes de notion associées.

###### Commande d'importation

A l'aide de la commande :

```button
name Zotero Integration: Import # 1
type command
action Zotero Integration: Import #1
```

on peut importer les annotations d'un article (description, commentaires, etc.) de manière standardisée à partir d'un [[template Import 1]].

###### Template actuel

Le template actuel importe les annotations en suivant la [[méthode de prise de note dans Zotero]] :  

- Les <mark style="background: #FFB86CA6;">annotations surlignées en orange</mark> servent à naviguer dans le document. Elle ne sont pas importée.

- Les <mark style="background: #D2B3FFA6;">annotations sont triées par couleur</mark>. Chaque couleur correspond à une notion qui doit être intégrées à une note. Lors de la création d'une note de revue, **les annotations sont hiérarchisées dans une check-list à menu déroulant**. Chaque note post-it constitue une rubrique dans laquelle sont placées toutes les notes qui ont la même couleur dans l'ordre de leur apparition dans l'article. **Un même passage peut être surligner et encadrer dans plusieurs couleurs différentes** si il est pertient dans plusieurs notes

###### Modification du template d'importation

Pour modifer le template on peut accéder à la [[nomenclature des annotations d'un article extraites depuis Zotero]] en lancant la commande :

```button
name Zotero Integation: Data Explorer
type command
action Zotero Integration: Data explorer
```

###### Astuce pour l'Utilisation de Balises Liquid dans Obsidian

Lors de l'utilisation de balises Liquid dans Obsidian pour formater des notes importées depuis Zotero :

- Assurez-vous de ne pas laisser d'espaces ou de lignes vides avant les balises Liquid. Cela pourrait entraîner l'interprétation du contenu comme un bloc de code plutôt que comme du texte formaté.
- Utilisez une indentation correcte avec des espaces plutôt que des tabulations pour assurer la clarté et un rendu correct dans Obsidian.
