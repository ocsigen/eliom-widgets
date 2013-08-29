{shared{
  open Eliom_content.Html5.F
  open Eliom_content.Html5
}}

{shared{
  class type dropdown_mutable_t = object
    inherit Dropdown.dropdown_t

    method clear : unit
    method append : Html5_types.li_content_fun Eliom_content.Html5.D.elt list -> unit
    method remove : int -> bool
    method nth : int -> Dom.node Js.t
    method length : int
  end
}}

{client{

  class dropdown_mutable
    ~attach_to
    ?orientation
    ?circular
    ?closeable_by_button
    ?li_id ?li_class
    ?ul_id ?ul_class
    (lelt: (([< Html5_types.li_content_fun ] Eliom_content.Html5.D.elt) list) list)
    =

  let list_of_nl ul =
    Dom.list_of_nodeList (ul##childNodes)
  in

  object(self)

    inherit Dropdown.dropdown
          ~attach_to
          ?orientation ?circular
          ?closeable_by_button
          ?li_id ?li_class
          ?ul_id ?ul_class
          lelt

    method clear =
      List.iter
        (fun c -> Dom.removeChild ul' c)
        (Dom.list_of_nodeList ul'##childNodes)

    method append (elt : (Html5_types.li_content_fun Eliom_content.Html5.D.elt list)) =
      let li = D.li ~a:(self#get_li_attrs) elt in
      Dom.appendChild ul' (To_dom.of_li li)

    method remove n =
      let lli = list_of_nl ul' in
      if n > List.length (lli)
      then false
      else
        let rec aux i = function
          | [] -> false
          | hd::tl ->
              if not (i = n)
              then (aux (i+1) tl)
              else (Dom.removeChild ul' (List.nth lli n); true)
        in aux 0 lli

    method nth n =
      List.nth (list_of_nl ul') n

    method length =
      List.length (list_of_nl ul')

  end

}}
