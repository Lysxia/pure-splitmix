(* SplitMix: a splittable PRNG.

   http://gee.cs.oswego.edu/dl/papers/oopsla14.pdf

   This implementation closely follows the OpenJDK8 implementation
   of SplittableRandom.
   http://hg.openjdk.java.net/jdk8/jdk8/jdk/rev/b90dcd1a71bf

   In particular, in contrast with the paper, it swaps the uses of mix64 and
   mix64variant13, presumably because the latter is more robust to low entropy
   inputs, that initialization is more vulnerable to.
*)

module Bits = struct
  let (^) = Int64.logxor
  let (>>>) = Int64.shift_right_logical
  let (<<<) = Int64.shift_left
  let (|.) = Int64.logor
  let (&.) = Int64.logand
  let ( * ) = Int64.mul
  let (+) = Int64.add
  let (-) = Int64.sub
end

type t = {
  seed:  int64;
  gamma: int64;
}

let golden_gamma = 0x9e3779b97f4a7c15L

(* MurmurHash3 finalization mix.
   https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp#L81-L90
*)
let mix64 z =
  let open Bits in
  let z = (z ^ (z >>> 33)) * 0xff51afd7ed558ccdL in
  let z = (z ^ (z >>> 33)) * 0xc4ceb9fe1a85ec53L in
  z ^ (z >>> 33)

(* Stafford's variant 13 of mix64.
   https://zimbry.blogspot.fi/2011/09/better-bit-mixing-improving-on.html
*)
let mix64variant13 z =
  let open Bits in
  let z = (z ^ (z >>> 30)) * 0xbf58476d1ce4e5b9L in
  let z = (z ^ (z >>> 27)) * 0x94d049bb133111ebL in
  z ^ (z >>> 31)

(* Number of 1 bits in an int64. *)
let popcount z =
  let open Bits in
  let z = z - ((z >>> 1) &. 0x5555_5555_5555_5555L) in
  let z = (z &. 0x3333_3333_3333_3333L) + ((z >>> 2) &. 0x3333_3333_3333_3333L) in
  let z = (z + (z >>> 4)) &. 0x0f0f_0f0f_0f0f_0f0fL in
  Int64.to_int ((z * 0x01010101_01010101L) >>> 56)

(* New gamma for split. *)
(* Note: there is a bug in the SplitMix paper. However, the text is correct as
   a reference, and it should be < 24 indeed.
   http://www.pcg-random.org/posts/bugs-in-splitmix.html
*)
let mix_gamma z =
  let open Bits in
  let z = mix64 z |. 1L in
  if popcount Bits.(z ^ (z >>> 1)) < 24 then
    z ^ 0xaaaa_aaaa_aaaa_aaaaL
  else
    z

let of_seed s = { seed = s; gamma = golden_gamma }

let of_string s =
  let s = Digest.string s in
  let rec loop i acc =
    if i < 0 then
      acc
    else
      loop (i-1) Bits.((acc <<< 8) |. Int64.of_int (Char.code (String.get s i)))
  in
  of_seed (loop 8 0L)

let auto_seed () =
  Random.self_init ();
  let open Bits in
  let half = 0x100000000L in
  let s = ((Random.int64 half <<< 32) |. Random.int64 half) + golden_gamma in
  { seed = mix64variant13 s; gamma = mix_gamma (s + golden_gamma) }

let mk_split seed1 seed2 = {
  seed = mix64variant13 seed1;
  gamma = mix_gamma seed2;
}

let split { seed = seed0; gamma } =
  let seed1 = Bits.(seed0 + gamma) in
  let seed2 = Bits.(seed1 + gamma) in
  let rng1 = mk_split seed1 seed2 in
  let rng2 = { (* The original generator, stepped twice. *)
    seed = seed2;
    gamma = gamma;
  } in
  (rng1, rng2)

let vary n { seed = seed0; gamma } =
  if n < 0 then invalid_arg "PureSplitMix.vary";
  let n = 2 * n + 1 in
  let seed1 = Bits.(seed0 + Int64.of_int n * gamma) in
  let seed2 = Bits.(seed1 + gamma) in
  mk_split seed1 seed2

let next_int64 { seed; gamma } =
  let seed' = Bits.(seed + gamma) in
  (mix64variant13 seed', { seed = seed'; gamma })

let to_int64 rng = fst (next_int64 rng)

(* bound must be positive. *)
let rec int64' rng bound =
  let (bits, rng) = next_int64 rng in
  let r = Bits.(bits >>> 1) in (* Make it nonnegative at the cost of one bit. *)
  let v = Int64.rem r bound in
  if Bits.(bits - v > Int64.min_int - bound) then
    int64' rng bound
  else
    v

let int rng bound =
  if bound <= 0 then
    invalid_arg "PureSplitMix.int"
  else
    Int64.to_int (int64' rng (Int64.of_int bound))

(* Test sign bit. *)
let bool rng = to_int64 rng < 0L
