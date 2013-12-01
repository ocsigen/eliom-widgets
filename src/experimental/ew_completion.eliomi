{shared{
  open Eliom_content.Html5
  open Dom_html
  open Dom
  open Html5_types
}}

{shared{
  type element' = Ew_button.element'
  type 'a elt' = 'a Ew_button.elt'

  type completion_fun = string -> Ew_traversable.item_element' Ew_traversable.elt' list
}}

{server{
  (* w1 is a completion of w0. ex: is_completed_by "e" "eddy" = yes *)
  (* both arg are utf8 caml string *)
  val is_completed_by : string -> string -> bool
}}


{client{
  include Ojw_completion_sigs.T
    with type D.element = element'
    with type 'a D.elt = 'a elt'
     and type Dropdown.Traversable.D.element = Ew_traversable.element'
     and type 'a Dropdown.Traversable.D.elt = 'a Ew_traversable.elt'
}}

{server{
  val completion :
     refresh:completion_fun client_value
  -> 'a elt'
  -> 'a elt'
  -> 'a elt' list
}}
