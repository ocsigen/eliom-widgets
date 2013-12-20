{shared{
  open Eliom_content.Html5
  open Dom_html
  open Dom
  open Html5_types
}}

{shared{
  type 'a elt' = 'a Eliom_content.Html5.elt
  type element' = [ body_content ]
}}

{shared{
  type button_dyn_alert_fun' =
      element' elt'
      -> Ew_alert.element' Ew_alert.elt'
      -> Ew_alert.content' Ew_alert.elt' list Lwt.t
}}

{client{
  include Ojw_button_f.Make(struct
    type 'a elt = 'a elt'
    type element = element'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)(Ew_alert)
}}

{server{
  let closeable_by_click = Ew_alert.closeable_by_click

  let button
      ?(set : Ew_active_set.t' client_value option)
      ?pressed
      ?predicate
      elt =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          let button = match %set with
            | None -> button ?set:None
            | Some set -> button ~set:(Ew_active_set.of_server_set set)
          in
          button
            ?pressed:%pressed
            ?predicate:%predicate
            %elt
        ))
    }};
    elt

  let button_alert
        ?(set : Ew_active_set.t' client_value option)
        ?pressed
        ?predicate
        ?allow_outer_clicks
        ?before
        ?after
        elt
        elt_alert =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          let button_alert = match %set with
            | None -> button_alert ?set:None
            | Some set -> button_alert ~set:((Ew_active_set.of_server_set set) :> Ojw_active_set.t)
          in
          button_alert
            ?pressed:%pressed
            ?predicate:%predicate
            ?allow_outer_clicks:%allow_outer_clicks
            ?before:%before
            ?after:%after
            %elt
            %elt_alert
        ))
    }};
    (elt, elt_alert)

  let button_dyn_alert
        ?(set : Ew_active_set.t' client_value option)
        ?pressed
        ?predicate
        ?allow_outer_clicks
        ?before
        ?after
        elt elt_alert f =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          let alert = match %set with
            | None -> button_dyn_alert ?set:None
            | Some set ->
                button_dyn_alert ~set:((Ew_active_set.of_server_set set) :> Ojw_active_set.t)
          in
          button_dyn_alert
            ?pressed:%pressed
            ?predicate:%predicate
            ?allow_outer_clicks:%allow_outer_clicks
            ?before:%before
            ?after:%after
            %elt
            %elt_alert
            %f
        ))
    }};
    (elt, elt_alert)
}}
