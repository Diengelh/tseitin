# Transformation de Tseitin

![OCaml](https://img.shields.io/badge/OCaml-4.14-orange.svg)
![Dune](https://img.shields.io/badge/dune-3.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-completed-brightgreen.svg)
![GitHub repo size](https://img.shields.io/github/repo-size/Diengelh/Transformation-de-Tseitin)

## Description

Ce projet implemente en OCaml la transformation de Tseitin, une methode permettant de transformer une formule logique en une forme clausale conjonctive (FNC) sans explosion combinatoire. Cette technique, due au mathematicien Grigori Tseitin, est essentielle en resolution automatique de problemes SAT (Satisfiability).

Le projet a ete realise dans le cadre du cours "Outils de Raisonnement" de la Licence 2 Informatique.

La transformation de Tseitin repose sur l'idee suivante : au lieu de distribuer les conjonctions et disjonctions (ce qui peut provoquer une explosion exponentielle), on introduit de nouveaux atomes representant les sous-formules non atomiques. On ajoute ensuite des equivalences definissant ces nouveaux atomes. La formule resultante est equisatisfaisable avec la formule originale.

## Fonctionnalites

- Transformation de Tseitin d'une formule
- Conversions d'interpretations (restriction et extension)
- Generation aleatoire de formules
- Tests de correction avec Quine et DPLL
- Benchmark des performances

## Architecture du projet

Le projet est structure avec Dune et organise en plusieurs modules situes dans le dossier Proposition.

Le fichier Formule.ml definit la structure des formules logiques et les differents operateurs disponibles (negation, conjonction, disjonction, implication, equivalence). Ce module sert de base a tous les autres.

Le fichier Quine.ml implemente l'algorithme de Quine pour determiner la satisfaisabilite d'une formule. Cette methode recursive par cas utilise les tables de verite et permet de tester des formules de petite taille.

Le fichier FCC.ml contient les fonctions de mise en forme clausale conjonctive. Il transforme une formule en une conjonction de clauses, chaque clause etant une disjonction de litteraux.

Le fichier DPLL.ml implemente l'algorithme DPLL (Davis-Putnam-Logemann-Loveland) pour la resolution SAT. Il utilise la propagation unitaire et le choix de litteraux pour determiner efficacement la satisfaisabilite de formules en FNC.

Le fichier RandomFormule.ml contient la fonction de generation aleatoire de formules. Elle permet de generer des formules avec un nombre specifie d'operateurs en utilisant le module Random d'OCaml.

Le fichier Tseitin.ml est le coeur du projet. Il implemente la transformation de Tseitin avec la fonction tseitin, ainsi que les conversions d'interpretations restrict_inter et extension_inter qui permettent de passer d'une interpretation satisfaisant la transformee a une interpretation satisfaisant la formule originale, et inversement.

Le fichier CorrecTest.ml contient les fonctions de test de correction. test_equisat_quine et test_equisat_dpl1 verifient l'equisatisfaisabilite sur une formule donnee, tandis que test_equisat_quine' et test_equisat_dpl1' effectuent les memes tests sur des formules generees aleatoirement.

Le fichier Benchmark.ml contient les fonctions de mesure des performances. bench_dpl1 mesure le temps de transformation et de resolution sur une formule, et bench_dpl1' effectue ces mesures sur une formule aleatoire.

Le fichier dune est le fichier de configuration du systeme de build Dune qui gere la compilation du projet.

## Modules et fonctions principales

### Module Tseitin

| Fonction | Description |
|----------|-------------|
| tseitin | Calcule la transformee de Tseitin d'une formule |
| restrict_inter | Convertit une interpretation de T(F) en interpretation de F |
| extension_inter | Convertit une interpretation de F en interpretation de T(F) |

### Module RandomFormule

| Fonction | Description |
|----------|-------------|
| random_form | Genere une formule aleatoire avec n operateurs |

### Module CorrecTest

| Fonction | Description |
|----------|-------------|
| test_equisat_quine | Teste l'equisatisfaisabilite avec Quine |
| test_equisat_dpl1 | Teste l'equisatisfaisabilite avec DPLL (tous les temoins) |
| test_equisat_quine' | Test sur formule aleatoire avec Quine |
| test_equisat_dpl1' | Test sur formule aleatoire avec DPLL |

### Module Benchmark

| Fonction | Description |
|----------|-------------|
| bench_dpl1 | Mesure les performances de la transformation |
| bench_dpl1' | Benchmark sur formule aleatoire |

## Utilisation

## Exemples de resultats

### Test avec Quine

F = a ∨ b
T(F) = new_0 ∧ (new_0 ↔ (old_a ∨ old_b))
quine_sat(F) : true
quine_sat(T(F)) : true
Equisat ? true

### Test avec DPLL

F = a ∧ (b ∨ c)
T(F) = new_0 ∧ (new_0 ↔ (old_a ∧ new_1)) ∧ (new_1 ↔ (old_b ∨ old_c))
is_ext sat T(F) ? true
is'_rest sat F ? true

### Benchmark

F = ((a ∨ b) ∧ (c ∨ d)) ∨ e
Transformation : 0.000010s
fcc (F) : 0.000051s (2 clauses, 4 litteraux)
fcc (T(F)) : 0.000036s (12 clauses, 26 litteraux)
Dpl1 (F) : true (0.000003s)
Dpl1 (T(F)) : true (0.000044s)

## Algorithme de Tseitin

### Principe

1. Parcourir l'arbre de la formule
2. Pour chaque sous-formule non atomique, lui associer un nouvel atome
3. Ajouter une equivalence entre le nouvel atome et la sous-formule
4. La formule resultante est la conjonction de tous les nouveaux atomes et de leurs definitions

### Exemple

Formule originale : F = ¬a ∨ a

Transformee de Tseitin :
T(F) = new_0
∧ (new_0 ↔ (new_1 ∨ old_a))
∧ (new_1 ↔ ¬old_a)

### Proprietes

- La transformee est equisatisfaisable avec la formule originale
- La taille de la transformee est lineaire en fonction de la taille de la formule originale
- Evite l'explosion combinatoire de la mise en forme clausale

## Difficultes rencontrees et solutions

| Probleme | Solution |
|----------|----------|
| Gestion des nouveaux atomes | Utilisation d'un compteur global pour generer des noms uniques |
| Construction recursive de la transformee | Fonction recursive avec accumulation des equivalences |
| Conversion des interpretations | Parcours des equivalences pour deduire les valeurs manquantes |
| Generation aleatoire equilibree | Repartition des operateurs entre les sous-formules |

## Auteurs

- Elhadji Loum Dieng
  
Projet realise dans le cadre de la Licence Informatique 2eme annee
Universite de Rouen Normandie - 2024

## Remerciements

- Enseignants du module Outils de Raisonnement
- Universite de Rouen Normandie

## Licence

Ce projet est sous licence MIT.
