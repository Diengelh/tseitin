open FCC
   
   (** Simplifie la forme clausale fcc en considérant que le littéral l est vrai *)
   let simplif_fcc (f : forme_clausale) (l : litteral) : forme_clausale =
     FormeClausale.fold 
       (fun c acc -> 
         if Clause.mem l c 
           then acc
         else if Clause.mem (neg_lit l) c 
           then let c' = Clause.remove (neg_lit l) c in FormeClausale.add c' acc
         else FormeClausale.add c acc
         )
       f
       FormeClausale.empty
      
       
   (** Applique l'algorithme DPLL pour déterminer si une fcc est satisfaisable. *)
   let rec dpll_sat (f : forme_clausale) : bool = 
     match f with
     |f' when FormeClausale.is_empty f' -> true 
     |f' when FormeClausale.mem (Clause.empty) f' -> false
     |_ -> let l = Clause.min_elt (FormeClausale.min_elt f)
           in let f'' = simplif_fcc f l
           in 
             if dpll_sat f'' 
               then true
             else 
               let l' = neg_lit l
                 in dpll_sat (simplif_fcc f l')

   
   (** Applique l'algorithme DPLL pour déterminer si une fcc est satisfaisable, renvoyant None si ce n'est pas le cas
         et Some res sinon, où res est une liste de couples (atome, Booléen)
         suffisants pour que la formule soit vraie. *)
   let dpll_ex_sat (fml : forme_clausale) : (string * bool) list option =
     let rec aux f acc =
       match f with
       |f' when FormeClausale.is_empty f' -> acc 
       |f' when FormeClausale.mem (Clause.empty) f' -> []
       |_ -> let l = Clause.min_elt (FormeClausale.min_elt f)
             in let f'' = simplif_fcc f l
             in 
               let t =  aux f'' ((snd l, if fst l = Plus then true else false)::acc)
               in 
                 if (List.length t) != 0
                   then t
                 else 
                   let l' = neg_lit l
                     in aux (simplif_fcc f l') ((snd l', if fst l' = Plus then false else true)::acc)
     in let res = aux fml [] 
    in if List.length res = 0 then None else Some res   
   
   (** Renvoie la liste des listes de couples (atome, Booléen) suffisants pour que la formule soit vraie,
       selon l'algorithme DPLL. *)
   let dpll_all_sat (fml : forme_clausale) : (string * bool) list list =
     let rec aux f (acc:(string * bool) list) =
       match FormeClausale.min_elt_opt f with
       |None -> [acc]
       |Some c -> (match Clause.min_elt_opt c with
                   |None -> []
                   |Some l -> 
                     let lg =  aux (simplif_fcc f l)
                                     ((snd l, if fst l = Plus then true else false)::acc)
                         in let l' = neg_lit l
                     in let ld = aux (simplif_fcc f l')
                                     ((snd l', if fst l' = Moins then false else true)::acc)
                   in lg@ld
                   )
    in aux fml []
        
   (** Applique l'algorithme DPLL pour déterminer si une fcc est satisfaisable. 
       Utilise la propagation unitaire. *)
   let rec dpll_sat_unit_prop (f : forme_clausale) : bool = 
     match FormeClausale.min_elt_opt f with
     |None -> true
     |Some c -> (match Clause.min_elt_opt c with
                 |None -> false
                 |Some l -> let b = dpll_sat_unit_prop (simplif_fcc f l)
                            in if b || Clause.cardinal c = 0 
                                 then b
                               else 
                                 (dpll_sat_unit_prop (simplif_fcc f (neg_lit l)))
   
                 )
   



