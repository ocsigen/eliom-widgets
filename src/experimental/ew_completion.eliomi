{shared{
  open Eliom_content.Html5
  open Dom_html
  open Dom
  open Html5_types
}}

{shared{
  type element' = Ew_button.element'
  type 'a elt' = 'a Ew_button.elt'

  type refresh_fun = int -> string -> Ew_traversable.item_element' Ew_traversable.elt' list Lwt.t
  type on_confirm_fun = string -> unit Lwt.t
}}

{server{
  (* w1 is a completion of w0. ex: is_completed_by "e" "eddy" = yes *)
  (* both arg are utf8 caml string *)
  val is_completed_by : string -> string -> bool
}}


  (*
{client{
  (*include Ojw_completion_sigs.T
    with type D.element = element'
    with type 'a D.elt = 'a elt'
     and type Dropdown.Traversable.D.element = Ew_traversable.element'
     and type 'a Dropdown.Traversable.D.elt = 'a Ew_traversable.elt'
   *)
  val completion : ?refresh:completion_fun -> unit -> unit -> (int * int)
}}
   *)
{shared{
  val li :
    ?a:[< Html5_types.li_attrib > `Class `User_data ]
      Eliom_content.Html5.D.attrib list
  -> value:Html5_types.text
  -> Html5_types.flow5_without_interactive Eliom_content.Html5.D.Raw.elt list
  -> [> Html5_types.li ] Eliom_content.Html5.D.elt
}}

{server{
  val completion :
     refresh:refresh_fun client_value
  -> ?limit:int
  -> ?accents:bool
  -> ?sensitive:bool
  -> ?adaptive:bool
  -> ?auto_match:bool
  -> ?clear_input_on_confirm:bool
  -> ?move_with_tab:bool
  -> ?on_confirm:on_confirm_fun client_value
  -> element' elt'
  -> Ew_traversable.element' elt'
  -> (element' elt' * Ew_traversable.element' elt')
}}
