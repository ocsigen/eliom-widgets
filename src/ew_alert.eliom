{shared{
  open Eliom_content.Html5
  open Html5_types
}}
{client{
  open Dom_html
}}

{shared{
  type parent =
      [
        | body_content
      ] D.elt

  type container =
      [
        | div
      ] D.elt

  type container_content =
      [
        | div_content
      ] D.elt
}}

{client{
  let nothing r = r
  include Ojw_alert_f.Make(struct
    type parent' = parent
    type container' = container
    type container_content' = container_content

    let to_container = To_dom.of_element
    let to_parent = To_dom.of_element

    let of_container = Of_dom.of_element

    let default_parent () = Of_dom.of_element (document##body)
    let default_container cnt = D.div cnt
  end)
}}

{server{
  type t
}}
