{shared{
  open Eliom_content.Html5
  open Html5_types
}}

{client{
  open Dom_html
}}

{shared{
  type content' =
      [
        | body_content
      ]

  type element' =
      [
        | body_content
      ]

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
      with type 'a D.elt = 'a Eliom_content.Html5.elt
       and type D.element = element'
       and type 'a Content.elt = 'a Eliom_content.Html5.elt
       and type Content.element = content'
  end

  let nothing r = r
  include Ojw_alert_f.Make(struct
    type element = element'
    type 'a elt = 'a elt'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)(struct
    type element = content'
    type 'a elt = 'a elt'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)
}}

{server{
  let closeable_by_click (elt : element' elt') =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (closeable_by_click %elt)
      )
    }};
    elt

  let alert
      ?(allow_outer_clicks : bool option)
      ?(before : (element' elt' -> unit) option)
      ?(after : (element' elt' -> unit) option)
      (elt : element' elt') =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          alert
            ?allow_outer_clicks:%allow_outer_clicks
            ?before:%before
            ?after:%after
            %elt
        ))
    }};
    elt

  let dyn_alert
      ?(allow_outer_clicks : bool option)
      ?(before : (element' elt' -> unit Lwt.t) option)
      ?(after : (element' elt' -> unit Lwt.t) option)
      (elt : element' elt')
      (f : dyn_alert_fun' client_value) =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          dyn_alert
            ?allow_outer_clicks:%allow_outer_clicks
            ?before:%before
            ?after:%after
            %elt
            %f
        ))
    }};
    elt
}}
