{shared{
  open Eliom_content
  open Html5_types
  open Dom_html
  open Dom
}}

{shared{
  type 'a elt' = 'a Eliom_content.Html5.elt
  type element' = [ body_content ]
}}

{shared{
  type button_dyn_alert_fun' =
      element' elt'
      -> Ew_alert.element' Ew_alert.elt'
      -> Ew_alert.content' Ew_alert.elt' list Lwt.t
}}

{client{
  include Ojw_button_sigs.T
    with type 'a Alert.D.elt = 'a Ew_alert.D.elt
    with type Alert.D.element = Ew_alert.D.element
    with type 'a D.elt = 'a Eliom_content.Html5.elt
     and type D.element = [ body_content ]
}}

{server{
  val closeable_by_click :
     element' elt'
  -> element' elt'

  val button :
    ?set:Ew_active_set.t' client_value
  -> ?pressed:bool
  -> ?predicate:(unit -> bool Lwt.t)
  -> element' elt'
  -> element' elt'

  open Ew_alert

  val button_alert :
    ?set:Ew_active_set.t' client_value
  -> ?pressed:bool
  -> ?predicate:(unit -> bool Lwt.t)
  -> ?allow_outer_clicks:bool
  -> ?closeable_by_button:bool
  -> ?before:(element' elt' -> Ew_alert.element' Ew_alert.elt' -> unit)
  -> ?after:(element' elt' -> Ew_alert.element' Ew_alert.elt'-> unit)
  -> element' elt'
  -> Ew_alert.element' Ew_alert.elt'
  -> (element' elt' * Ew_alert.element' Ew_alert.elt')

  val button_dyn_alert :
    ?set:Ew_active_set.t' client_value
  -> ?pressed:bool
  -> ?predicate:(unit -> bool Lwt.t)
  -> ?allow_outer_clicks:bool
  -> ?closeable_by_button:bool
  -> ?before:(element' elt' -> Ew_alert.element' Ew_alert.elt' -> unit Lwt.t)
  -> ?after:(element' elt' -> Ew_alert.element' Ew_alert.elt'-> unit Lwt.t)
  -> element' elt'
  -> Ew_alert.element' Ew_alert.elt'
  -> button_dyn_alert_fun' client_value
  -> (element' elt' * Ew_alert.element' Ew_alert.elt')
}}
