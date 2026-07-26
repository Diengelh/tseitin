open Formule

(* Compléter ce fichier avec les éléments du fichier FCC.ml du TP 3 nécessaires pour le projet,
   en plus des définitions ci-dessous. *)

(** Signe d'un littéral. *)
type signe = Plus | Moins

(** Type d'un littéral : produit d'un signe et d'un atome (string). *)
type litteral = signe * string

(** Inversion d'un signe.*)
let neg_sign (s : signe) : signe = match s with Moins -> Plus | _ -> Moins

(** Inversion du signe d'un littéral.*)
let neg_lit (x : litteral) : litteral =
  let s, str = x in
  (neg_sign s, str)

(** Le module Clause permet de manipuler les ensembles
    de littéraux. Il est généré via le foncteur Set.Make. *)
module Clause = Set.Make (struct
  type t = litteral

  let compare = Stdlib.compare
end)

(** Type synonyme : une clause est un ensemble de littéraux. *)
type clause = Clause.t

(** Le module FormeClausale permet de manipuler les ensembles
      de clauses. Il est généré via le foncteur Set.Make. *)
module FormeClausale = Set.Make (struct
  type t = clause

  let compare x y =
    let c = Stdlib.compare (Clause.cardinal x) (Clause.cardinal y) in
    if c <> 0 then c else Clause.compare x y
end)

(** Type synonyme : une forme clausale est un ensemble de clauses. *)
type forme_clausale = FormeClausale.t

(** Renvoie la liste des littéraux d'une clause. *)
let clause_to_list (c : clause) : litteral list = Clause.elements c

(** Renvoie la liste des listes de littéraux des clauses d'une forme clausale. *)
let fcc_to_list (fc : forme_clausale) : litteral list list =
  FormeClausale.fold (fun x acc -> clause_to_list x :: acc) fc []

(** Transforme un littéral en string. *)
let string_of_lit ((s, str) : litteral) : string =
  match s with Moins -> "-" ^ str | _ -> str

(** Transforme une clause en string. *)
let string_of_clause (c : clause) : string =
  "{"
  ^ Clause.fold
      (fun x acc ->
        let sep = if acc = "" then "" else ", " in
        acc ^ sep ^ string_of_lit x)
      c ""
  ^ "}"

(** Transforme une forme clausale en string. *)
let string_of_fcc (fc : forme_clausale) : string =
  "{"
  ^ FormeClausale.fold
      (fun x acc ->
        let sep = if acc = "" then "" else "; " in
        acc ^ sep ^ string_of_clause x)
      fc ""
  ^ "}"

(**
  signe * string list -> string list : renvoie la liste des atomes
  de signe positif
*)
let all_atome_true (l:(string * bool) list) : string list= 
List.fold_left
     (fun acc (atome, b) -> 
          if b then atome::acc
          else acc)
    []
    l

(**
  forme_clause -> int * int
  renvoie respectivement le nombre de clause et le nombre de littéraux
  contenu d'une forme clausale donnée
  *)
let nb_clause_lit fcc :(int * int) =
  (FormeClausale.cardinal fcc, 
   FormeClausale.fold
    (fun c acc -> acc + Clause.cardinal c)
     fcc
     0
     )

(**
  formule -> interpretation list : renvoie vrai si toutes les interprétations de la liste
donnée en paramètre évaluent f comme vrai sinon renvoie faux
*)
let rec is_all_eval_true (f : formule) (ilist: interpretation list) : bool =
  match ilist with
  |[] -> true
  | i::q -> (eval i f) && (is_all_eval_true f q )


(** Mise en FCC, étape 1 : Transforme une formule en une formule équivalente avec des opérateurs 
    de conjonction, de disjonction, de négation, Bot et Top uniquement. *)
let rec retrait_operateurs (f : formule) : formule =
    match f with
    | Bot -> Bot
    | Top -> Top
    | Atome s -> Atome s
    | Imp (h, g) -> Ou (Non (retrait_operateurs h), retrait_operateurs g)
    | Et (h, g) -> Et (retrait_operateurs h, retrait_operateurs g)
    | Ou (h, g) -> Ou (retrait_operateurs h, retrait_operateurs g)
    | Non h -> Non (retrait_operateurs h)
    | Equiv (h, g) -> retrait_operateurs (Et (Imp (h, g), Imp (g, h)));;


(** Mise en FCC, étape 2 : Descend les négations dans une formule au plus profond de l'arbre syntaxique,
    en préservant les évaluations. *)
let rec descente_non (f : formule) : formule =
  match f with
  | Bot |Top | Atome _ -> f
  | Et (h, g) -> Et (descente_non h, descente_non g)
  | Ou (h, g) -> Ou (descente_non h, descente_non g)
  | Non (Et (h, g)) -> (
      match (h, g) with
      | Non t, Non t' -> Ou (descente_non t, descente_non t')
      | Non t, g' -> Ou (descente_non t, descente_non (Non g'))
      | t, Non g' -> Ou ((descente_non (Non t)), descente_non g')
      | _, _ -> Ou (descente_non (Non h), descente_non (Non g)))
  | Non (Ou (h, g)) -> (
      match (h, g) with
      | Non t, Non t' -> Et (descente_non t, descente_non t')
      | Non t, g' -> Et (descente_non t, descente_non (Non g'))
      | t, Non g' -> Et ((descente_non (Non t)), descente_non g')
      | _, _ -> Et (descente_non (Non h), descente_non (Non g)))
  | Non h -> (
      match h with Non h' -> descente_non h' | _ -> Non (descente_non (h)))
  | Imp _ | Equiv _ -> failwith "l'opérateurs Imp et Equiv ne doivent pas être présents dans
                                 la formule lors de la descente des négations"


(** Calcule la conjonction de deux formes clausales. *)
let fcc_conj (f : forme_clausale) (f' : forme_clausale) : forme_clausale =
  FormeClausale.union f f'

(** Calcule la disjonction de deux formes clausales. *)
let fcc_disj (f : forme_clausale) (f' : forme_clausale) : forme_clausale =
  FormeClausale.fold
    (fun c fcc ->
      FormeClausale.union fcc
        (FormeClausale.map (function x -> Clause.union c x) f'))
    f FormeClausale.empty


(** Mise en FCC, étape 3 : calcule la forme clausale associée à une formule. *)
let forme_ensembliste (f : formule) : forme_clausale =
  let f = descente_non (retrait_operateurs (simplifier f)) in
  let rec aux = function
    | Bot -> FormeClausale.add (Clause.empty) FormeClausale.empty
    | Top -> FormeClausale.empty
    | Atome s -> FormeClausale.of_list [ Clause.of_list [ (Plus, s) ] ]
    | Non (Atome s) -> FormeClausale.of_list [ Clause.of_list [ (Moins, s) ] ] 
    | Et (h, g) ->
          let h' = aux h and g' = aux g in
          fcc_conj h' g'
    | Ou (h, g) ->
          let h' = aux h and g' = aux g in
          fcc_disj h' g'
    | _ -> failwith "les opérateurs Imp et Equiv ne doivent pas être dans la
                      formule lors de la mise en forme ensembliste"
  in aux f


(** Convertit une formule en une forme clausale conjonctive équivalente.*)
let formule_to_fcc (f : formule) : forme_clausale =
  forme_ensembliste (descente_non (retrait_operateurs f))
