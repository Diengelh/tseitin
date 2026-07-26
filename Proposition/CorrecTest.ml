open Formule
open Tseitin
open Quine
open RandomFormule
open DPLL
open FCC

let test_equisat_quine (f: formule) : unit =
  let tf = (try (tseitin f) with 
             Non_equivalence -> 
               failwith "la formule ne doit pas contenir une opération d'équivalence"
          )
  in let res = "F = "^(string_of_formule f)^"\nT(F) = "^(string_of_formule tf)^"\n"
  in let f_quine_sat = quine_sat f and  tf_quine_sat = quine_sat tf
  in let equisat = (f_quine_sat = tf_quine_sat)
  in let res = res^"quine_sat(F) : "^(string_of_bool f_quine_sat)^"\n"
  in let res = res^"quine_sat(T(F)) : "^(string_of_bool tf_quine_sat)^"\n"
  in let res = res^"Equisat(T(F)) : "^(string_of_bool equisat)^"\n"
  in print_string res


let test_equisat_quine' (l : string list) (i : int) : unit =
  let f = random_form l i
  in test_equisat_quine f
    
let test_equisat_dpll (f : formule) : unit =
  let f' = (try (tseitin f) with 
             Non_equivalence -> 
               failwith "la formule ne doit pas contenir une opération d'équivalence"
            )
  in let res = "F = "^(string_of_formule f)^"\nT(F) = "^(string_of_formule f')^"\n"
  in let ts = dpll_all_sat (formule_to_fcc f) and  ts' = dpll_all_sat (formule_to_fcc f')
  in let is = List.map (function x -> interpretation_of_list (all_atome_true x)) ts 
    and is' = List.map (function x -> interpretation_of_list (all_atome_true x)) ts'
  in let is_ext = List.map (function x -> extension_inter x f) is
    and is_res' = List.map (function x -> restrict_inter x) is'
  in let b = is_all_eval_true f' is_ext 
     and b' = is_all_eval_true f is_res'
  in let s = "is_ext sat T(F) ? "^string_of_bool b ^"\n"
            ^"is'_rest sat F ? "^string_of_bool b'^"\n"
  in print_string (res^s);;

let test_equisat_dpll' (l : string list) (i : int) : unit =
  let f = random_form l i
  in test_equisat_dpll f
  
(*
   prend en paramètre un entien n et renvoie la liste contenant les "x0", "x1", ...., "xn-1"
   chaines de caractères
*)
let list_xi n =
  let rec aux acc  i =
  if i = n then acc else aux (("x"^(string_of_int i))::acc) (i + 1)
in aux [] 0

  