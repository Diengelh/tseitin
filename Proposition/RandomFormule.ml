open Formule
open Random

(** random_form atoms k renvoie une formule pseudo-aléatoire
   avec k opérateurs et des atomes de la liste atoms, liste
   supposée non vide. Les opérateurs sont Top, Bot, Non, Et
   Ou et Imp. La formule générée ne doit pas contenir
   d'opérateurs d'équivalence. *)
let rec random_form (l : string list) (n : int) : formule =
  Random.self_init ();
  let atome () = List.nth l (Random.int (List.length l)) in
  match n with
  | 0 -> Atome (atome ())
  | 1 -> (
      match int 5 with
      | 0 -> if int 2 = 0 then Bot else Top
      | 1 -> Non (Atome (atome ()))
      | 2 -> Ou (Atome (atome ()), Atome (atome ()))
      | 3 -> Et (Atome (atome ()), Atome (atome ()))
      | _ -> Imp (Atome (atome ()), Atome (atome ())))
  | _ -> (
      let f = random_form l in
      match int 2 with
      | 0 -> Non (f (n - 1))
      | _ -> (
          let k = int n in
          match int 3 with
          | 0 -> Ou (f k, f (n - k - 1))
          | 1 -> Et (f k, f (n - k - 1))
          | __ -> Imp (f k, f (n - k - 1))))

