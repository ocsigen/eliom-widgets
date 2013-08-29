(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{shared{
  class type show_hide_t = object
    inherit Button_.button_t
  end
}}

{client{
  open Eliom_content.Html5

  module In_button_show_hide_m = struct
    include Button_.In_button_m

    type showed_elt_t = [Html5_types.body_content] Eliom_content.Html5.F.elt

    let to_showed_elt elt = To_dom.of_element elt
  end

  include Ojw_button.F.Button_show_hide_f.Make(In_button_show_hide_m)
}}
