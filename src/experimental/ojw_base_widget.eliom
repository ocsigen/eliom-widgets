{client{
class type widget = object
  inherit Dom_html.element
  method t : Js.js_string Js.t Js.readonly_prop
end

class type widget' = object
  inherit widget
  method _t : Js.js_string Js.t Js.prop
end

let ctor elt t =
  elt##_t <- Js.string t;
  (elt :> widget Js.t)
}}
