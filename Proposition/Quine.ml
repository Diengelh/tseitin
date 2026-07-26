open Formule

(** subst g s f : substitue une formule g à un atome s dans une formule f. *)
let subst (f : formule) (s : string) (g : formule) =
  let rec aux = function
    | Top -> Top
    | Bot -> Bot
    | Atome a -> if a = s then g else Atome a
    | Non q -> Non (aux q)
    | Et (f1, f2) -> Et (aux f1, aux f2)
    | Ou (f1, f2) -> Ou (aux f1, aux f2)
    | Imp (f1, f2) -> Imp (aux f1, aux f2)
    | Equiv (f1, f2) -> Equiv (aux f1, aux f2)
  in
  aux f

(** Choisit un atome d'une formule, renvoyant None si aucun n'est présent.*)
let rec choix_atome (f : formule) : string option =
  match f with
  | Top | Bot -> None
  | Atome s -> Some s
  | Et (h, g) | Ou (h, g) | Imp (h, g) | Equiv (h, g)->
      let res_h = choix_atome h in
      if res_h = None then choix_atome g else res_h
  | Non h -> choix_atome h;;

(** Simplifie une formule d'une manière paresseuse. *)
let rec simplif_quine : formule -> formule = function
  | Bot -> Bot
  | Top -> Top
  | Atome s -> Atome s
  | Ou (f, g) -> (
      match simplif_quine f with
      | Bot -> simplif_quine g
      | Top -> Top
      | f' -> (
          match simplif_quine g with Bot -> f' | Top -> Top | g' -> Ou (f', g'))
      )
  | Et (f, g) -> (
      match simplif_quine f with
      | Bot -> Bot
      | Top -> simplif_quine g
      | f' -> (
          match simplif_quine g with Bot -> Bot | Top -> f' | g' -> Et (f', g'))
      )
  | Imp (f, g) -> (
      match simplif_quine f with
      | Bot -> Top
      | Top -> simplif_quine g
      | f' -> (
          match simplif_quine g with
          | Top -> Top
          | Bot -> Non f'
          | g' -> Imp (f', g')))
  | Non f -> (
      match simplif_quine f with
      | Top -> Bot
      | Bot -> Top
      | f' -> Non (simplif_quine f'))
  |Equiv(f, g) -> simplif_quine (Et(Imp(f, g), Imp(g, f)));;

(** Teste si une formule est satisfaisable, selon l'algorithme de Quine. *)
let rec quine_sat (f : formule) : bool =
  match choix_atome f with
  | Some a ->(
              match simplif_quine (subst f a Bot) with
              | Top -> true
              | f' ->if quine_sat f' then true 
                     else quine_sat (simplif_quine (subst f a Top))
             )
  | None -> ( match simplif_quine f with Top -> true | _ -> false)

