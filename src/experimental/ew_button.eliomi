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

{client{
  include Ojw_button_sigs.T
    with type Alert.t = Ew_alert.t
    with type 'a Alert.D.elt = 'a Ew_alert.D.elt
    with type Alert.D.element = Ew_alert.D.element
    with type 'a D.elt = 'a Eliom_content.Html5.elt
     and type D.element = [ body_content ]
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
