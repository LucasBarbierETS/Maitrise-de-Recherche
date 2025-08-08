---
year:
  "{ date | format (\"YYYY\") }": 
authors:
  "{ authors }":
---

Titre : {{title}}
[Lien vers Zotero]({{desktopURI}}) 


{% for annotation in annotations %}{% if annotation.type == 'note' %}{% set color = annotation.color %} 
- {{ annotation.comment }} {% for ann in annotations %} {% if ann.color == color %}{% if ann.annotatedText %}
	- {%if ann.annotatedText%}{{ann.annotatedText}}{% endif %} (page [{{ann.page}}](ann.desktopURI)) {% endif %}{% if ann.imageRelativePath %}
	- {%if ann.annotatedText%}{{ann.annotatedText}}{% endif %}  (page [{{ann.page}}](ann.desktopURI))![[{{ann.imageRelativePath}}]]{% endif %}{% endif %} {% endfor %}{% endif %} {% endfor %}