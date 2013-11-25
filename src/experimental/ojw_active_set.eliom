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

type t = {
  at_least_one : bool Js.t;
  mutable active : item Js.t Js.opt;
}

let set ?(at_least_one = false) () = {
    at_least_one = Js.bool at_least_one;
    active = Js.null;
  }

let enable ~set it =
  Js.Opt.iter set.active
    (fun active -> active##disable());
  it##enable();
  set.active <- Js.some (Js.Unsafe.coerce it :> item Js.t)

let disable ~set it =
  if Js.to_bool set.at_least_one
  then ()
  else
    (it##disable ();
     set.active <- Js.null)

let ctor
    ~(enable : (#item Js.t -> unit -> unit))
    ~(disable : (#item Js.t -> unit -> unit))
    (elt : #item' Js.t) =
  let elt' = (Js.Unsafe.coerce elt :> item' Js.t) in
  let meth = Js.wrap_meth_callback in
  elt'##_enable <- meth enable;
  elt'##_disable <- meth disable;
  (elt' :> item Js.t)
}}
