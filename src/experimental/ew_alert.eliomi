{shared{
  open Eliom_content.Html5
  open Html5_types
}}

{shared{
  (** The type of the content element (dynamic alert only). *)
  type content' =
      [
        | body_content
      ]

  (** The type of the alert element. *)
  type element' =
      [
        | body_content
      ]

  (** The type of an html element. *)
  type 'a elt' = 'a Eliom_content.Html5.elt
}}

{shared{
  type dyn_alert_fun' =
      element' elt'
      -> content' elt' list Lwt.t
}}

{client{
  module type T = sig
    include Ojw_alert_sigs.T
      with type 'a D.elt = 'a elt'
       and type D.element = element'
       and type 'a Content.elt = 'a Eliom_content.Html5.elt
       and type Content.element = content'
  end

  include Ojw_alert_sigs.T
    with type 'a D.elt = 'a elt'
     and type D.element = element'
     and type 'a Content.elt = 'a Eliom_content.Html5.elt
     and type Content.element = content'
}}

{server{
  val closeable_by_click :
     element' elt'
  -> element' elt'

  val alert :
     ?allow_outer_clicks:bool
  -> ?before:(element' elt' -> unit Lwt.t)
  -> ?after:(element' elt' -> unit Lwt.t)
  -> element' elt'
  -> element' elt'

  val dyn_alert :
     ?allow_outer_clicks:bool
  -> ?before:(element' elt' -> unit Lwt.t)
  -> ?after:(element' elt' -> unit Lwt.t)
  -> element' elt'
  -> dyn_alert_fun' client_value
  -> element' elt'

}}
