{shared{
  open Eliom_content.Html5
  open Eliom_content.Html5.F
  open Html5_types
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
  let li ?a ~href = Ew_traversable.li ?a ?value:None ~anchor:true ~href ?value_to_match:None
}}

{server{
  let dropdown
      ?(hover:bool option)
      ?(hover_timeout:float option)
      (elt : element' elt')
      (elt_traversable : Ew_traversable.element' elt') =
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
    (elt, elt_traversable);
}}
