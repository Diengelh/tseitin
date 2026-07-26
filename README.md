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

### Transformation de Tseitin
- Transformation d'une formule en sa forme equisatisfaisable
- Gestion des operateurs logiques : negation, conjonction, disjonction, implication
- Introduction de nouveaux atomes (prefixe `new_`) pour les sous-formules
- Conservation des atomes originaux (prefixe `old_`)

### Conversions d'interpretations
- `restrict_inter` : Convertit une interpretation satisfaisant T(F) en interpretation satisfaisant F
- `extension_inter` : Convertit une interpretation satisfaisant F en interpretation satisfaisant T(F)

### Generation aleatoire de formules
- Generation de formules avec un nombre specifie d'operateurs
- Utilisation du module Random d'OCaml
- Support de differents alphabets

### Tests de correction
- `test_equisat_quine` : Teste l'equisatisfaisabilite avec l'algorithme de Quine
- `test_equisat_dpl1` : Teste l'equisatisfaisabilite avec DPLL (tous les temoins)
- `test_equisat_quine'` : Test sur formule aleatoire avec Quine
- `test_equisat_dpl1'` : Test sur formule aleatoire avec DPLL

### Benchmark
- `bench_dpl1` : Mesure les performances de la transformation
- `bench_dpl1'` : Benchmark sur formule aleatoire
- Mesure du temps de transformation et de resolution

## Architecture du projet

Le projet est structure avec Dune et organise en plusieurs modules :
