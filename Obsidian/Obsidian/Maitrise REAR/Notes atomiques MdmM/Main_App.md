###### Description

###### Propriétés 

- <mark style="background: #ADCCFFA6;">SubelementsDatas</mark> : il s'agit d'une structure qui contient les informations sur tous les sous-élements (SE) d'une configuration. **Les sous-élements sont numérotés suivant leur ordre de création**, indifférement de leur position dans la structure. Les propriétés de chaque SE sont stockées dans une sous-structure (SS) : <mark style="background: #ADCCFFA6;">app.SubelementDatas.Subelement_i</mark>
  Chaque SS contient : 
	- <mark style="background: #D2B3FFA6;">Subelement_i.Name</mark> : (chaine de caractère) le type de SE
		- "None" pour les sous-élements désactivés et indéfinis
		- "Undefined" pour les sous-élements activés et indéfinis
	- <mark style="background: #D2B3FFA6;">Subelement_i.Marker</mark> : (chaine de caractère)
		- "o" pour les sousélements activés et définis
		- "s" pour les sous-élements activés et indéfinis
		- "+" pour les sous-élements désactivés et indéfinis
	- <mark style="background: #D2B3FFA6;">Subelement_i.Position</mark>
	- <mark style="background: #D2B3FFA6;">Subelement_i.Color</mark>
	- <mark style="background: #D2B3FFA6;">Subelement_i.Object</mark>
	- <mark style="background: #D2B3FFA6;">Subelement_i.ParamList</mark>
	- <mark style="background: #D2B3FFA6;">Subelement_i.ConfigName</mark>
- <mark style="background: #ADCCFFA6;">UIComponents</mark> : il s'agit d'une structure qui contient une structure d'affichage pour chaque type de composant