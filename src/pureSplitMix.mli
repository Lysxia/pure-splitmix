(** A purely functional splittable PRNG. *)

(** PRNG state, immutable. *)
type t

(** {2 Initialization} *)

(** Initialize from an integer. *)
val of_seed : int64 -> t

(** Initialize by hashing a string. *)
val of_string : string -> t

(** Initialize impurely in a system-dependent way. *)
val auto_seed : unit -> t

(** {2 Generate values} *)

(** A state should be used only once to ensure the outputs are independent. *)

(** Split the state. *)
val split : t -> t * t

(** Infinitary split. Index must be [>= 0]. *)
val vary : int -> t -> t

(** Generate 64 random bits, and return a new state. *)
val next_int64 : t -> int64 * t

(** Generate 64 random bits. *)
val int64 : t -> int64

(** Generate an [int] uniformly in the range [\[min_int, max_int\]] *)
val int_signed : t -> int

(** Generate an [int] uniformly in the range [\[0, max_int\]] *)
val int_nonneg : t -> int

(** Generate an [int] uniformly in a range [\[0, bound)]. *)
val int : t -> int -> int

(** Generate a [bool]. *)
val bool : t -> bool

(** {3 Internal functions} *)

(** Exported for testing. *)
module Internal : sig
  val popcount : int64 -> int
  val mix64 : int64 -> int64
  val mix64_variant13 : int64 -> int64
  val mix_gamma : int64 -> int64
end
