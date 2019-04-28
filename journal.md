# Le journal, SophiaQuest !

 - 12/04/2019
	 - Prise en main de PICO-8
	 - Découvertes des sprites, l'éditeur de map, de musique
	 - Familiarisation avec la syntaxe Lua
	 
 - 20/04/2019
	 - Création d'un jeu de test comprenant une grande arène avec un personnage et des ennemis
	 - Les personnages/acteurs sont sur 8x8 pixels, la map est très basique avec des bordures simples pour délimiter la zone explorable

 - 21/04/2019
	- Les ennemis et le héros ont des armes et des points de vies. Le héros peut changer d'armes, le jeu se termine quand tous les ennemis ont été vaincus.
	- Ajout d'un HUD pour les PVs et le "cooldown" des attaques.
	- Les ennemis se déplace vers le joueur sans se soucier des obstacles.
	- Ajout des potions de vie
	
- 24/04/2019
	- Ajout d'un effet de foudre et de jet d'eau pour les attaques à distances
	- Amélioration du HUD et des "hitbox" pour ne pas traverser les obstacles

- 25/04/2019
	- Design et ajout du protagoniste "Sofia" en sprites 8x16 pixels
	- Ajout d'autres NPC masculin et féminin
	- Animation des personnages sur un modèle 8x16 pixels (héros et NPC)
	- Ajustement de la position des armes

- 26/04/2019
	- Début de la map du vrai jeu 
	- Ajout des bâtiments Est Polytech, du parking et des intersections de routes 
	- Ajout des sprites de champions d'arènes pour les arènes de Biot, Valbonne et Antibes
	- Suppression de l'ancienne carte qui servait de banc de test
	- Des problèmes de transparences résolues en choisissant la couleur ROSE comme couleur transparente pour les acteurs dans le code (potion, personnages, armes, etc ...)
	- Amélioration de plusieurs sprites dans la map
	- Ajustement des collisions pour 8x16 pixels (la partie inférieure du personnage sert de repère)
	- Clean du code qui commence à être un peu désordonné

- 27/04/2019
	- Ajout de la map BIOT, VALBONNE et ANTIBES
	- Changement du design des buildings et de la clôture du bâtiment à polytech
	- Ajustement de la "hitbox" des projectiles et de la caméra
	- Optimisation de la mémoire utilisée par les sprites et la map
	- Ajout des dialogues et séparation entre les personnages narratifs et les personnages aggressifs
	- Le dialogue est arrêté quand le joueur quitte
	- Limiter la portée de la caméra pour ne pas afficher les éléments parasites de la vue actuelle (ville et intérieur des bâtiments)

- 28/04/2019
	- Ajout de l'arène Thelas et CapGemo
	- Mis à jour de quelques sprites
	- Debug et optimisation des  performances CPU et mémoire
