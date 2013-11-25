{shared{
  open Eliom_content.Html5
  open Eliom_content.Html5.F
  open Html5_types
}}

{server{
  type dropdown_fun = Ew_alert.t' -> Ew_traversable.element' Ew_traversable.elt'
}}

{client{
  include Ojw_dropdown_f.Make(struct
    module Button = Ew_button
    module Traversable = Ew_traversable

    type element = [ body_content ]
    type 'a elt = 'a Eliom_content.Html5.elt

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)
}}

{shared{
  let li = Ew_traversable.li
}}

{server{
  let dropdown ?hover ?hover_timeout ?v ?h elt elt_traversable =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          dropdown
            ?v:%v ?h:%h
            ?hover:%hover
            ?hover_timeout:%hover_timeout
            %elt %elt_traversable
        )
      )
    }};
    [elt; elt_traversable];
}}
