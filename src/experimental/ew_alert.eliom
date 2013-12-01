{shared{
  open Eliom_content.Html5
  open Html5_types
}}

{client{
  open Dom_html
}}

{shared{
  type parent' =
      [
        | body_content
      ]

  type element' =
      [
        | body_content
      ]

  type 'a elt' = 'a Eliom_content.Html5.elt
}}

{client{
  module type T = sig
    include Ojw_alert_sigs.T
      with type 'a D.elt = 'a Eliom_content.Html5.elt
       and type D.parent = parent'
       and type D.element = element'
  end

  let nothing r = r
  include Ojw_alert_f.Make(struct
    type 'a elt = 'a Eliom_content.Html5.elt

    type parent = parent'
    type element = element'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element

    let to_dom_parent = To_dom.of_element
    let of_dom_parent = Of_dom.of_element

    let default_parent () = Of_dom.of_element (document##body)
  end)
}}

{client{
  type t' = t
}}

{server{
  type t'
}}

{shared{
  (** The type of the function used to generate the alert content. *)
  type alert_fun = t' -> element' elt'
}}
