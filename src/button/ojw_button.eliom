(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{shared{
  type radio_set_t = (unit -> unit Lwt.t) ref
}}

{client{
  open Eliom_content.Html5

  module In_button_m = struct
    type button_t = [Html5_types.div_content] Eliom_content.Html5.elt

    let to_button button = To_dom.of_element button
  end

  include Ojwidgets.F.Button_f.Make(In_button_m)
}}
