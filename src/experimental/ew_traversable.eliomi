{shared{
  open Eliom_content.Html5.D
  open Html5_types
  open Eliom_content.Html5
}}

{shared{
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
      with type 'a D.elt = 'a elt'
       and type D.element = element'
       and type 'a Content.elt = 'a elt'
       and type Content.element = item_element'
  end

    include Ojw_traversable_sigs.T
      with type 'a D.elt = 'a elt'
       and type D.element = element'
       and type 'a Content.elt = 'a elt'
       and type Content.element = item_element'
}}

{server{
  module Style : sig
    val traversable_cls : string
    val traversable_elt_cls : string
    val selected_cls : string
  end
}}

{shared{
  val li :
    ?a:[< Html5_types.li_attrib > `Class `User_data ]
      Eliom_content.Html5.D.attrib list
  -> ?anchor:bool
  -> ?href:string
  -> ?value:Html5_types.text
  -> ?value_to_match:Html5_types.text
  -> Html5_types.flow5_without_interactive Eliom_content.Html5.D.Raw.elt list
  -> [> Html5_types.li ] Eliom_content.Html5.D.elt
}}

{server{
  val traversable : element' elt' -> element' elt'
}}
