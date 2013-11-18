{shared{
  open Eliom_content.Html5
  open Html5_types
}}

{shared{
  (** The type of the parent element. *)
  type parent =
      [
        | body_content
      ] D.elt

  (** The type of the container element. *)
  type container =
      [
        | div
      ] D.elt

  (** The type of the container content elements. *)
  type container_content =
      [
        | div_content
      ] D.elt
}}

{client{
  exception Close_during_initialization

  (** The type which reprensents an alert. *)
  type t

  (** [close a] closes an alert. Be aware that using this function during
    * the initialization of the alert box will raise
    * [Close_during_initialization].
    *)
  val close : t -> unit

  (** [closed a] returns [true] if the alert box is closed. *)
  val closed : t -> bool

  (** [alert ?parent ?wrap ?before ?after f] creates an alert box. The
    * content is defined using the function [f] which returns a list of
    * html elements.
    *
    * You can change the [parent] to which the alert box will be inserted.
    * By default, it is set to [document##body]. You can also use a specific
    * container for the alert box, using [wrap] function (default: div element).
    *
    * If you want to do some operations before inserting the alert box into the dom
    * (such as positioning your box), you can use [before] callback. There is also
    * a callback [after] which is called after insertion.
    *
    * The initialization is finished once the content of the alert box is
    * returned.
    *)
  val alert :
     ?parent:parent
  -> ?wrap:(container_content list -> container)
  -> ?before:(container -> unit)
  -> ?after:(container -> unit)
  -> (t -> container_content list)
  -> t
}}

{server{
  type t
}}
