(* Stateful wrapper imitating OpenJDK's semantics. *)
module SplitMix = struct
  open PureSplitMix

  let init n = ref (of_seed n)

  let split g =
    let g1, g0 = split !g in
    g := g0;
    ref g1

  let next_long g =
    let n, g0 = next_int64 !g in
    g := g0;
    n
end

open SplitMix

let print n = print_endline (Int64.to_string n)

let _ =
  let g0 = init 33L in
  print (next_long g0);
  print (next_long g0);
  let g1 = split g0 in
  print (next_long g1);
  let g2 = split g1 in
  print (next_long g1);
  let g3 = split g2 in
  print (next_long g2);
  print (next_long g2);
  print (next_long g3);
  print (next_long g3);
  print (next_long g3)
