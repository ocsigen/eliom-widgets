{client{
class type widget = object
  inherit Dom_html.element
  method t : Js.js_string Js.t Js.readonly_prop
end

class type widget' = object
  inherit widget
  method _t : Js.js_string Js.t Js.prop
end

val ctor : #widget' Js.t -> string -> widget Js.t
}}
