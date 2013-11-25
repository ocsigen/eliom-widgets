{client{
  let nothing r = r
  include Ojw_completion_f.Make(struct
      type 'a elt = Dom_html.element Js.t
      type element = Dom_html.element

      let to_dom_elt = nothing
      let of_dom_elt = nothing

      module Dropdown = Ojw_dropdown
    end)
}}
