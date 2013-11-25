{client{
  let nothing r = r
  include Ojw_traversable_f.Make(struct
    type 'a opt = 'a Js.opt

    type 'a elt = Dom_html.element Js.t
    type element = Dom_html.element
    type item_element = Dom_html.element

    let to_opt = nothing
    let of_opt = nothing

    let opt_none = Js.null
    let opt_some = Js.some

    let opt_iter = Js.Opt.iter
    let opt_case = Js.Opt.case

    let to_dom_elt = nothing
    let of_dom_elt = nothing

    let to_dom_item_elt = nothing
    let of_dom_item_elt = nothing
  end)
}}
