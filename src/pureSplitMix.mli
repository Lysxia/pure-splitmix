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

(** Generate an [int] uniformly in a range [\[0, max)]. *)
val int : t -> int -> int

(** Generate a [bool]. *)
val bool : t -> bool

val mix64 : int64 -> int64
val mix64variant13 : int64 -> int64
val mix_gamma : int64 -> int64
