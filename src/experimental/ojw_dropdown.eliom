{client{
  let nothing r = r
  include Ojw_dropdown_f.Make(struct
    module Button = Ojw_button
    module Traversable = Ojw_traversable

    type element = Dom_html.element
    type 'a elt = Dom_html.element Js.t

    let to_dom_elt = nothing
    let of_dom_elt = nothing
  end)
}}
