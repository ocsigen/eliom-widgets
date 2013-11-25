{client{
open Dom
open Dom_html

let nothing r = r
include Ojw_alert_f.Make(struct
  type 'a elt = Dom_html.element Js.t

  type parent = Dom_html.element
  type element = Dom_html.element

  let to_dom_elt = nothing
  let to_dom_parent = nothing

  let default_parent () = document##body
end)
}}
