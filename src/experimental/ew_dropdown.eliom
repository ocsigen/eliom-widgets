{shared{
  open Eliom_content.Html5
  open Eliom_content.Html5.F
  open Html5_types
}}

{server{
  type dropdown_fun = Ew_alert.t' -> Ew_traversable.element' Ew_traversable.elt'
}}

{shared{
  type 'a elt' = 'a Ew_button.elt'
  type element' = Ew_button.element'
}}

{client{
  include Ojw_dropdown_f.Make(struct
    type element = element'
    type 'a elt = 'a elt'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)
  (Ew_button)
  (Ew_traversable)
}}

{shared{
  let li = Ew_traversable.li
}}

{server{
  let dropdown ?hover ?hover_timeout elt elt_traversable =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          dropdown
            ?hover:%hover
            ?hover_timeout:%hover_timeout
            %elt %elt_traversable
        )
      )
    }};
    [elt; elt_traversable];
}}
