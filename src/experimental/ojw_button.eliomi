{client{
  include Ojw_button_f.T
    with module Alert = Ojw_alert
     and type 'a elt = Dom_html.element Js.t
     and type element = Dom_html.element
}}
