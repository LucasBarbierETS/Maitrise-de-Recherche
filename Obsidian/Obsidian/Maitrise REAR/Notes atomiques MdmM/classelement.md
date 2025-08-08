*classelement* est un objet de type classe qui possède les propriétés suivantes : 
- ListOfSubelements : un *cell array* contenant une liste d'objet de type classe. Chacun de ces objets doit posséder un méthode *transfermatrix*.
- EndStatus : un indicateur qui précise si l'élement possède ou non une terminaison en fond rigide ("opened par defaut, ou "closed")

Le constructeur de la classe prend comme variable d'entrée : 
- list_of_subelements
- end_status