(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{shared{
  type radio_set_t = (unit -> unit Lwt.t) ref

  class type button_t = object
    method on_pre_press : unit Lwt.t
    method on_post_press : unit Lwt.t
    method on_pre_unpress : unit Lwt.t
    method on_post_unpress : unit Lwt.t
    method on_press : unit Lwt.t
    method on_unpress : unit Lwt.t
    method pressed : bool
    method press : unit Lwt.t
    method unpress : unit Lwt.t
    method switch : unit Lwt.t
  end
}}

{client{
  open Eliom_content.Html5

  module In_button_m = struct
    type button_t = [Html5_types.div_content] Eliom_content.Html5.elt

    let to_button button = To_dom.of_element button
  end

  include Ojw_button.F.Button_f.Make(In_button_m)
}}
