(** Uses a [valid] bit to indicate the validity of a [value].  Conceptually similar to an
    [Option.t]. *)

open Base

type ('a, 'b) t2 = ('a, 'b) Comb.with_valid2 =
  { valid : 'a
  ; value : 'b
  }
[@@deriving sexp, bin_io]

type 'a t = ('a, 'a) t2 [@@deriving sexp, bin_io]

val map : 'a t -> f:('a -> 'b) -> 'b t
val map2 : 'a t -> 'b t -> f:('a -> 'b -> 'c) -> 'c t
val iter : 'a t -> f:('a -> unit) -> unit
val iter2 : 'a t -> 'b t -> f:('a -> 'b -> unit) -> unit
val to_list : 'a t -> 'a list

(** Create a new hardcaml interface with type ['a With_valid.t X.t] *)
module Fields : sig
  module Make (X : Interface.Pre) : Interface.S with type 'a t = 'a t X.t

  module M (X : T1) : sig
    type nonrec 'a t = 'a t X.t
  end
end

(** Create a new hardcaml interface with type [('a, 'a X.t) With_valid.t2]. *)
module Wrap : sig
  module Make (X : Interface.Pre) : Interface.S with type 'a t = ('a, 'a X.t) t2

  module M (X : T1) : sig
    type nonrec 'a t = ('a, 'a X.t) t2
  end
end
