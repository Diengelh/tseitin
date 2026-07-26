open Formule

exception Non_equivalence;;

(**
 apply_op: prend une chaine de caractère s et deux formules a, b et renvoie
 une formule composée de celle de a et b en fonction de la chaine s.
*)
let apply_op (s: string) (a: formule) (b: formule) : formule =
  match s with
  | "et" -> Et(a, b)
  | "ou" -> Ou(a, b)
  | "imp" -> Imp(a, b)
  |_ -> raise Non_equivalence

(** Calcule la transformée de Tseitin d'une formule donnée,
    en supposant que la formule ne contienne pas d'opérateur d'équivalence. *)
    let tseitin (f : formule) : formule =
      let neww var = "new_" ^ string_of_int var
      in let old var = "old_" ^ var 
      in let rec aux k g =
        match g with
        | Atome s -> (k, Equiv (Atome (neww k), Atome (old s)))
        | Top | Bot -> (k, Equiv (Atome (neww k), g))
        | Non a -> (
                    match a with
                      | Atome s -> (k + 1), Equiv (Atome (neww k), Non(Atome (old s)))
                      |Top |Bot -> (k + 1), Equiv (Atome (neww k), Non(a))
                      | _ ->
                          let i, h = aux (k + 1) a in
                          (i, Et (Equiv (Atome (neww k), Non (Atome (neww (k + 1)))), h))
                    )
        | Et (a, b) | Ou (a, b) |Imp(a, b) -> let op = (match g with
                                                          |Ou _ -> "ou"
                                                          |Et _ -> "et"
                                                          |Imp _ -> "imp"
                                                          |_ -> raise Non_equivalence
                                                         )
              in (
                    match a with
                  | Atome s1 -> 
                                ( match b with
                                  |Atome s2 -> (k + 1, Equiv (Atome (neww k), apply_op op (Atome (old s1)) (Atome (old s2))))
                                  |Top |Bot -> (k + 1, Equiv (Atome (neww k), apply_op op (Atome (old s1)) b))
                                  |_ -> let i, h = aux (k + 1) b in
                                          ( i,Et
                                                (Equiv (Atome (neww k), apply_op op (Atome (old s1)) (Atome (neww (k + 1)))),
                                                    h))
                                )
                  |Top |Bot -> 
                                ( match b with
                                  |Atome s2 -> (k + 1, Equiv (Atome (neww k), apply_op op a (Atome (old s2))))
                                  |Top |Bot -> (k + 1, Equiv (Atome (neww k), apply_op op  a b))
                                  |_ -> let i, h = aux (k + 1) b in
                                          ( i, Et
                                                (Equiv (Atome (neww k), apply_op op a (Atome (neww (k + 1)))),
                                                    h))
                                )
                  | _ ->
                      let i, h = aux (k + 1) a in
                                ( match b with
                                  |Atome s -> (i, Et (Equiv (Atome (neww k), apply_op op (Atome (neww (k + 1))) (Atome (old s))), h))
                                  |Top |Bot -> (i, Et (Equiv (Atome (neww k), apply_op op (Atome (neww (k + 1))) b), h))
                                  |_ ->  let i2, h2 = aux i b in
                                    ( i2, 
                                    Et( 
                                      Et
                                        (Equiv (Atome (neww k), apply_op op (Atome (neww (k + 1))) (Atome (neww i))),
                                          h), h2 ))
                                )
                  )
        | _ -> raise Non_equivalence
      in let _, l = aux 0 f 
    in Et (Atome (neww 0), l)

(** Transforme une interprétation évaluant une transformée de Tseitin T(F) comme vraie
    en une interprétation évaluant la formule de départ F comme vraie. *)
  let restrict_inter (i : interpretation) : interpretation =
    fun s -> i ("old_"^s)

(*fonction auxiliaire qui retourne la liste contenant que les equivalences d'une
   transformé de tseitin d'une formule donnée en paramètre*)
let to_equiv_list (ft: formule) : formule list =
  let rec aux_0 = function
  Equiv h -> [Equiv h]
  |Non h -> aux_0 h
  |Et(h, g) |Ou(h, g) |Imp(h , g)-> (aux_0 g)@(aux_0 h)
  |_ ->failwith "erreur"
  in let ft' = ( match ft with
              |Et(_, g) -> g
              |_ -> failwith "tranformation de tseitin mal faite"
            )
  in  aux_0 ft'

(** Transforme une interprétation évaluant une formule F comme vraie
    en une 
    interprétation évaluant sa transformée de Tseitin T(F) comme vraie. *)
let extension_inter (i : interpretation) (f : formule) : interpretation =
  let tf = tseitin f in
  let atomes_f = atomes f in
  let t = List.fold_left 
            (fun acc s -> if i s then ("old_"^s)::acc else acc) [] atomes_f
  in let list_equiv = to_equiv_list tf
  in let rec aux acc = function
         [] -> acc
         |Equiv(Atome s, f)::q -> let i' = interpretation_of_list acc
                            in let acc = if eval i' f then (s::acc) else acc
                          in aux acc q
         |_ -> failwith "erreur"
  in interpretation_of_list (aux t list_equiv)

   