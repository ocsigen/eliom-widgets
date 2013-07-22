(* Copyright Université Paris Diderot*)

(**
   @author Gabriel Radanne
   Editable field with size-variable input and edition icons.
 **)

(* FIXME For mysterious (and probably not very clean) reasons, the type is not the right one.
   edit, confirm and cancel should all have the same kind of type and edit should have a subtype.
 *)
{shared{
val editable_name :
  ?a:[< Html5_types.span_attrib ] Eliom_content.Html5.D.attrib list ->
  ?edit:Html5_types.phrasing_without_interactive Eliom_content.Html5.F.elt ->
  ?confirm:([< Html5_types.phrasing_without_interactive > `PCDATA ]
                     as 'a) Eliom_content.Html5.F.elt ->
  ?cancel:'a Eliom_content.Html5.F.elt ->
  ?default_name:string ->
  content:[< Html5_types.span_content_fun > `A ] Eliom_content.Html5.D.elt ->
  callback:(string -> unit Lwt.t) Eliom_lib.client_value ->
  [> Html5_types.span ] Eliom_content.Html5.D.elt
(** [ editable_name ~default_name content callback ] turns the given [content] into and editable content. 
  It adds an edit button which replace the [content] by an editable field with the [default_name].
  If the confirm button is pressed, [callback] is called with the new name.
  [~edit], [~confirm] and [~cancel] can be used to customize the various buttons.
 **)

}}
