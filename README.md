# Pochimon Donjon Myst-re (socle technique)

Prototype Godot 4 en GDScript pour un dungeon crawler 2D au tour par tour.

## Lancer
1. Ouvrir le dossier avec Godot 4.
2. Lancer la scène principale (`scenes/Main.tscn`).

## Contenu
- Écran titre (nouvelle partie / chargement).
- Hub (état équipe, inventaire, repos, sauvegarde).
- Donjon procédural sur grille.
- Déplacement case par case (flèches).
- Combat tour par tour (équipe de 3 + ennemis IA simple).
- Compétences, objets, victoire/défaite.
- Sauvegarde JSON simple (`user://savegame.json`).

## Données
Les données sont séparées dans `data/*.json` pour faciliter l'enrichissement.
