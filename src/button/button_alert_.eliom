(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{shared{
  open Eliom_content.Html5
}}

{shared{
  class type alert_t = object
    inherit Button_.button_t

    method set_parent_node : [`Body | Html5_types.body_content] elt -> unit
    method get_alert_box : [Html5_types.div_content] elt option
    method get_node : [Html5_types.div_content] elt list Lwt.t
  end
}}

{client{
  module In_button_alert_m = struct
    include Button_.In_button_m

    type node_t = [Html5_types.div_content] elt
    type parent_t = [`Body | Html5_types.body_content] elt

    let of_node node = ((Of_dom.of_div node) :> node_t)
    let to_node node = To_dom.of_element node
    let to_parent parent = To_dom.of_element parent

    let default_parent () = (Of_dom.of_element Dom_html.document##body)
  end

  include Ojw_button.F.Button_alert_f.Make(In_button_alert_m)
}}
