{shared{
  open Eliom_content.Html5.D
  open Html5_types
  open Eliom_content.Html5
}}

{shared{
  type 'a opt' = 'a option

  type 'a elt' = 'a Eliom_content.Html5.elt

  type element' = [
    | ul
  ]

  type item_element' = [
    | li
  ]
}}

{client{
  include Ojw_traversable_f.Make(struct
    type 'a opt = 'a opt'

    type 'a elt = 'a elt'
    type element = element'
    type item_element = item_element'

    let to_opt a =
      Js.Opt.case (a)
        (fun () -> None)
        (fun a -> Some a)

    let of_opt = function
      | None -> Js.null
      | Some a -> Js.some a

    let opt_none = None
    let opt_some a = Some a

    let opt_iter opt f = match opt with
      | None -> ()
      | Some a -> f a

    let opt_case opt f f' = match opt with
      | None -> f ()
      | Some a -> f' a

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element

    let to_dom_item_elt = To_dom.of_element
    let of_dom_item_elt = Of_dom.of_element
  end)
}}

{shared{
  let li ?(a = []) ?(href = "#") ~value elts =
    let a =
      (a_class ["ew_dropdown_element"])
      ::(a_user_data "value" value)
      ::a
    in
    D.li ~a [
      D.Raw.a ~a:[a_tabindex (-1); a_href (uri_of_string (fun () -> href))] elts
    ]
}}

{server{
  let traversable elt =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (traversable %elt)
      )
    }};
    elt
}}
