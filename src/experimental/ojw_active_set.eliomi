{client{
module type T = sig
  class type item = object
    inherit Dom_html.element

    method enable : unit Js.meth
    method disable : unit Js.meth
  end

  class type item' = object
    inherit item

    method _enable : (#item Js.t, unit -> unit) Js.meth_callback Js.prop
    method _disable : (#item Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  type t

  val set : ?at_least_one : bool -> unit -> t

  val enable : set:t -> #item Js.t -> unit
  val disable : set:t -> #item Js.t -> unit

  val ctor :
       enable : (#item Js.t -> unit -> unit)
    -> disable : (#item Js.t -> unit -> unit)
    -> #item' Js.t
    -> item Js.t
end

include T
}}
