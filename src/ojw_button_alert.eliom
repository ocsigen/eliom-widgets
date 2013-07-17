(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{client{
  open Eliom_content.Html5

  module In_button_alert_m = struct
    include Ojw_button.In_button_m

    type node_t = Html5_types.div_content elt
    type parent_t = [`Body | Html5_types.body_content] Eliom_content.Html5.F.elt

    let to_node node = To_dom.of_element node
    let to_parent parent = To_dom.of_element parent

    let default_parent () = (Of_dom.of_element Dom_html.document##body)
  end

  include Ojwidgets.F.Button_alert_f.Make(In_button_alert_m)
}}
