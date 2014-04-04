{shared{
  open Html5_types
  open Eliom_content.Html5
  open Eliom_content.Html5.F
}}

{shared{
  type 'a elt' = 'a Eliom_content.Html5.elt

  type element' = [
    | ul
  ]

  type item_element' = [
    | li
  ]
}}

{client{
  module type T = sig
    include Ojw_traversable_sigs.T
      with type 'a D.elt = 'a elt'
       and type D.element = element'
       and type 'a Content.elt = 'a elt'
       and type Content.element = item_element'
  end

  include Ojw_traversable_f.Make(struct
    type 'a elt = 'a elt'
    type element = element'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)(struct
    type 'a elt = 'a elt'
    type element = item_element'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)
}}

{server{
  module Style = struct
    let traversable_cls = "ojw_traversable"
    let traversable_elt_cls = "ojw_traversable_elt"
    let selected_cls = "selected"
  end
}}

{shared{
  let li ?(a = []) ?(anchor = true) ?(href = "#") ?value elts =
    let a =
      (a_class [Style.traversable_elt_cls])
      ::(match value with
          | None -> []
          | Some value -> [a_user_data "value" value]
      ) @ a
    in
    if anchor then
      Eliom_content.Html5.D.li ~a [
        Eliom_content.Html5.D.Raw.a
          ~a:[a_tabindex (-1); a_href (uri_of_string (fun () -> href))] elts
      ]
    else Eliom_content.Html5.D.li ~a elts
}}

{server{
  let traversable (elt : element' elt') =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (traversable %elt)
      )
    }};
    elt
}}
