{shared{
  open Eliom_content
  open Html5_types
  open Dom_html
  open Dom
}}

{client{
  include Ojw_button_f.T
    with type Alert.t = Ew_alert.t
    with type 'a Alert.elt = 'a Ew_alert.elt
    with type Alert.element = Ew_alert.element
    with type 'a elt = 'a Eliom_content.Html5.elt
     and type element = [ body_content ]
}}

{server{
  val button :
    ?set:Ew_active_set.t' client_value -> ?pressed:bool
  -> 'a Html5.elt
  -> 'a Html5.elt

  open Ew_alert

  val button_alert :
    ?set:Ew_active_set.t' client_value
  -> ?pressed:bool
  (*
  -> ?before:(element' elt' -> unit) client_value
  -> ?after:(element' elt' -> unit) client_value
  -> ?parent:parent' elt' client_value
   *)
  -> 'a Html5.elt
       (*
  -> (Ew_alert.t' -> element' elt') client_value
        *)
  -> 'a Html5.elt
  -> 'a Html5.elt
}}
