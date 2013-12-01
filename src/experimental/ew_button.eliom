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

{client{
  include Ojw_button_f.Make(struct
    type 'a elt = 'a elt'
    type element = element'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)(Ew_alert)
}}

{server{
  let button ?(set : Ew_active_set.t' client_value option) ?pressed elt =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          let alert = match %set with
            | None -> button ?set:None
            | Some set -> button ~set:(Ew_active_set.of_server_set set)
          in
          alert
            ?pressed:%pressed
            %elt
        ))
    }};
    elt

  let button_alert
        ?(set : Ew_active_set.t' client_value option)
        ?pressed
            (*
        ?before
        ?after
        ?parent
             *)
        elt
            (*
        (f : (Ew_alert.t' -> Ew_alert.element' Ew_alert.elt') client_value) =
             *)
        elt_alert =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          let alert = match %set with
            | None -> button_alert ?set:None
            | Some set -> button_alert ~set:((Ew_active_set.of_server_set set) :> Ojw_active_set.t)
          in
          alert
            ?pressed:%pressed
            (*
            ?before:%before
            ?after:%after
            ?parent:%parent
             *)
            %elt
            (*
            %f
             *)
            %elt_alert
        ))
    }};
    elt
}}
