open Base

type ('a, 'b) t2 = ('a, 'b) Comb.with_valid2 =
  { valid : 'a
  ; value : 'b
  }
[@@deriving sexp, bin_io]

type 'a t = ('a, 'a) t2 [@@deriving sexp, bin_io]

let map x ~f = { valid = f x.valid; value = f x.value }
let map2 x y ~f = { valid = f x.valid y.valid; value = f x.value y.value }

let iter x ~f =
  f x.valid;
  f x.value
;;

let iter2 x y ~f =
  f x.valid y.valid;
  f x.value y.value
;;

let to_list { valid; value } = [ valid; value ]

module Fields = struct
  module Make (M : Interface.Pre) = struct
    module Pre = struct
      type nonrec 'a t = 'a t M.t [@@deriving sexp_of]

      let map t ~f = M.map ~f:(map ~f) t
      let iter (t : 'a t) ~(f : 'a -> unit) = M.iter ~f:(iter ~f) t
      let map2 a b ~f = M.map2 a b ~f:(map2 ~f)
      let iter2 a b ~f = M.iter2 a b ~f:(iter2 ~f)

      let t =
        M.map M.t ~f:(fun (n, w) -> { value = n ^ "$value", w; valid = n ^ "$valid", 1 })
      ;;

      let to_list t = M.map t ~f:to_list |> M.to_list |> List.concat
    end

    include Pre
    include Interface.Make (Pre)
  end

  module M (X : T1) = struct
    type nonrec 'a t = 'a t X.t
  end
end

module Wrap = struct
  module Make (M : Interface.Pre) = struct
    module Pre = struct
      type nonrec 'a t = ('a, 'a M.t) t2 [@@deriving sexp_of]

      let map t ~f = { valid = f t.valid; value = M.map ~f t.value }

      let iter (t : 'a t) ~(f : 'a -> unit) =
        f t.valid;
        M.iter ~f t.value
      ;;

      let map2 a b ~f = { valid = f a.valid b.valid; value = M.map2 ~f a.value b.value }

      let iter2 a b ~f =
        f a.valid b.valid;
        M.iter2 ~f a.value b.value
      ;;

      let t = { valid = "valid", 1; value = M.map M.t ~f:(fun (n, w) -> "value$" ^ n, w) }
      let to_list t = t.valid :: M.to_list t.value
    end

    include Pre
    include Interface.Make (Pre)
  end

  module M (X : T1) = struct
    type nonrec 'a t = ('a, 'a X.t) t2
  end
end
