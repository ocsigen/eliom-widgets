(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{client{
  open Eliom_content.Html5

  type focusable_t = Ojwidgets.F.Button_show_hide_focus_f.focusable_t

  module In_button_show_hide_focus_m = struct
    include Ojw_button_show_hide.In_button_show_hide_m

    type focus_t = [`A | `Input] Eliom_content.Html5.F.elt

    let to_focus focus =
      let focus = To_dom.of_element focus in
      ((Js.Unsafe.coerce focus) : focusable_t Js.t :> focusable_t Js.t)
  end

  include Ojwidgets.F.Button_show_hide_focus_f.Make(In_button_show_hide_focus_m)
}}
