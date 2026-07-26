(** Le module Formule contient les types et définitions de base
    permettant la manipulation des formules de la logique propositionnelle. *)

(** Type des formules de la logique propositionnelle, avec des string comme atomes. *)
type formule =
  | Bot
  | Top
  | Atome of string
  | Imp of (formule * formule)
  | Ou of (formule * formule)
  | Et of (formule * formule)
  | Non of formule
  | Equiv of (formule * formule)

(** Conversion d'une formule en chaîne de caractères. *)
let rec string_of_formule (x : formule) : string =
  match x with
  | Bot -> "⊥"
  | Top -> "T"
  | Atome s -> s
  | Imp (a, b) -> "(" ^ string_of_formule a ^ " -> " ^ string_of_formule b ^ ")"
  | Ou (a, b) -> "(" ^ string_of_formule a ^ " + " ^ string_of_formule b ^ ")"
  | Et (a, b) -> "(" ^ string_of_formule a ^ " * " ^ string_of_formule b ^ ")"
  | Non a -> "~ " ^ string_of_formule a
  | Equiv (a, b) ->
      "(" ^ string_of_formule a ^ " <-> " ^ string_of_formule b ^ ")"

(** Type des interprétations. *)
type interpretation = string -> bool

(** Évalue une formule en fonction d'une interprétation. *)
let eval (i : interpretation) (f : formule) : bool =
  let rec aux = function
    | Top -> true
    | Bot -> false
    | Atome s -> i s
    | Ou (a, b) -> aux a || aux b
    | Et (a, b) -> aux a && aux b
    | Imp (a, b) -> (not (aux a)) || aux b
    | Non a -> not (aux a)
    | Equiv (a, b) -> (aux (Imp(a, b))) && (aux (Imp(b, a)))
  in
  aux f


(** Transforme une liste de couples string en une interprétation. *)
  let interpretation_of_list (l : string list) : interpretation =
    fun s -> List.mem s l

    let ( ++ ) f g =
    match (f, g) with
    | Bot, _ -> g
    | _, Bot -> f
    | Top, _ | _, Top -> Top
    | _ -> Ou (f, g)
  
  (** Opérateur de conjonction, associatif à gauche. *)
  let ( ** ) (f : formule) (g : formule) : formule =
    match (f, g) with
    | Bot, _ | _, Bot -> Bot
    | Top, g -> g
    | f, Top -> f
    | _, _ -> Et (f, g)
  
  (** Opérateur d'implication, associatif à droite. *)
  let ( ^-> ) (f1 : formule) (f2 : formule) : formule =
    match (f1, f2) with
    | Bot, _ | _, Top -> Top
    | f1, Bot -> f1
    | Top, f2 -> f2
    | _, _ -> Imp (f1, f2)
  
  (** Opérateur de négation. *)
  let ( ~~ ) (f : formule) : formule =
    match f with Top -> Bot | Bot -> Top | _ -> Non f
  
  (** Simplification d'une formule. *)
  let rec simplifier (f : formule) : formule =
    match f with
    | Et (f1, f2) -> simplifier f1 ** simplifier f2
    | Ou (f1, f2) -> simplifier f1 ++ simplifier f2
    | Imp (f1, f2) -> simplifier f1 ^-> simplifier f2
    | Non f -> ( ~~ ) (simplifier f)
    | Equiv (f1, f2) -> simplifier (Imp (f1, f2)) ** simplifier (Imp (f2, f1))
    | _ -> f
   
(** Calcule la liste (triée et sans doublon) des atomes d'une formule.*)
  let atomes (f : formule) : string list =
    let rec aux acc = function
      | Bot | Top -> acc
      | Atome s -> if List.mem s acc then(acc) else (s::acc)
      | Et (a, b) | Ou (a, b) | Imp (a, b) | Equiv (a, b) -> let l = (aux acc a) in (aux l b)
      | Non a -> aux acc a
    in
    aux [] f


