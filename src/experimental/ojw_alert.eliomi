{client{
open Dom_html

include Ojw_alert_f.T
  with type 'a elt = Dom_html.element Js.t
   and type parent = Dom_html.element
   and type element = Dom_html.element
}}
