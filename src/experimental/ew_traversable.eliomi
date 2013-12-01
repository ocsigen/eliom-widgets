{shared{
  open Eliom_content.Html5.D
  open Html5_types
  open Eliom_content.Html5
}}

{shared{
  type 'a opt' = 'a option

  type 'a elt' = 'a Eliom_content.Html5.elt

  type element' = [
    | ul
  ]

  type item_element' = [
    | li
  ]
}}

{client{
  module type T = sig
    include Ojw_traversable_sigs.T
      with type 'a D.elt = 'a Eliom_content.Html5.elt
       and type D.element = element'
       and type D.item_element = item_element'
       and type 'a D.opt = 'a option
  end

  include Ojw_traversable_sigs.T
    with type 'a D.elt = 'a Eliom_content.Html5.elt
     and type D.element = element'
     and type D.item_element = item_element'
     and type 'a D.opt = 'a option
}}

{shared{
  val li :
    ?a:[< Html5_types.li_attrib > `Class `User_data ]
      Eliom_content.Html5.D.attrib list
  -> ?href:string
  -> value:Html5_types.text
  -> Html5_types.flow5_without_interactive Eliom_content.Html5.D.Raw.elt list
  -> [> Html5_types.li ] Eliom_content.Html5.D.elt
}}

{server{
  val traversable : element' elt' -> element' elt'
}}
