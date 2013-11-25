{shared{
  open Eliom_content.Html5
  open Dom_html
  open Dom
  open Html5_types
}}

{shared{
  type element' = [ input ]
  type 'a elt' = 'a Eliom_content.Html5.elt

  type completion_fun = unit -> Ew_traversable.item_element' Ew_traversable.elt' list
}}

{client{
  include Ojw_completion_f.Make(struct
      type 'a elt = 'a Eliom_content.Html5.elt
      type element = [ input ]

      let to_dom_elt = To_dom.of_element
      let of_dom_elt = Of_dom.of_element

      module Dropdown = Ew_dropdown
    end)
}}

{server{
  let completion
        ~(refresh : completion_fun client_value)
        elt elt_traversable =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          completion
            ~refresh:%refresh
            %elt
            %elt_traversable
        )
      )
    }};
    [elt; elt_traversable]
}}
