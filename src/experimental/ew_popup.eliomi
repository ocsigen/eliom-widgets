{shared{
  open Eliom_content.Html5
  open Eliom_content.Html5.F
  open Html5_types
}}

{shared{
  type 'a elt' = 'a Ew_alert.elt'
  type element' = Ew_alert.element'
}}

{shared{
  type dyn_popup_fun' = Ew_alert.dyn_alert_fun'
}}

{client{
  include Ojw_popup_sigs.T
    with type 'a Alert.D.elt = 'a Ew_alert.D.elt
    with type Alert.D.element = Ew_alert.D.element
    with type 'a D.elt = 'a Eliom_content.Html5.elt
     and type D.element = [ body_content ]
}}

{server{
  val closeable_by_click :
     element' elt'
  -> element' elt'

  val popup :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?with_background:bool
  -> element' elt'
  -> element' elt'

  val dyn_popup :
     ?show:bool
  -> ?allow_outer_clicks:bool
  -> ?with_background:bool
  -> element' elt'
  -> dyn_popup_fun' client_value
  -> element' elt'
}}
