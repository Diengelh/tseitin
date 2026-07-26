open Formule
open Tseitin
open DPLL
open RandomFormule
open FCC


(** Mesure du temps d'exécution d'une formule fonc sur un paramètre arg
    renvoyant le couple (résultat, temps de calcul). *)
let mesure fonc arg =
  let debut = Sys.time () in
  let res = fonc arg in
  let fin = Sys.time () in
  (res, fin -. debut)

let bench_dpll (f : formule) : unit = 
  let (f', t) = (try (mesure tseitin f) with 
             Non_equivalence -> 
               failwith "la formule ne doit pas contenir une opération d'équivalence"
            )
  in let res = "F = "^(string_of_formule f)^"\nT(F) = "^(string_of_formule f')^"\n"
in let res = res^"transformation = "^(string_of_float t)^"s\n"
in let fcc, t = mesure formule_to_fcc f
in let nb_clause, nb_lit = nb_clause_lit fcc
in let res = res^ "fcc (F) : "^(string_of_float t)^"s ("^(string_of_int nb_clause)^
   " clauses, "^(string_of_int nb_lit)^" littéraux)\n"
in let fcc', t = mesure formule_to_fcc f'
in let nb_clause, nb_lit = nb_clause_lit fcc'
in let res = res^ "fcc' (T(F)) : "^(string_of_float t)^"s ("^(string_of_int nb_clause)^
   " clauses, "^(string_of_int nb_lit)^" littéraux)\n"
in let b1, t = mesure dpll_sat_unit_prop fcc
in let res = res^ "dpll (F) : "^(string_of_bool b1)^" ("^(string_of_float t)^"s)\n"
in let b2, t = mesure dpll_sat_unit_prop fcc'
in let res = res^ "dpll (T(F)) : "^(string_of_bool b2)^" ("^(string_of_float t)^"s)\n"
in print_string res


let bench_dpll' (l : string list) (i : int) : unit =
  bench_dpll (random_form l i)
  
