{shared{
  open Eliom_content.Html5
  open Eliom_content.Html5.F
  open Html5_types
}}

{shared{
  type 'a elt' = 'a Ew_button.elt'
  type element' = Ew_button.element'
}}

{shared{
  type dyn_popup_fun' = Ew_alert.dyn_alert_fun'
}}

{client{
  include Ojw_popup_f.Make(struct
    type element = element'
    type 'a elt = 'a elt'

    let to_dom_elt = To_dom.of_element
    let of_dom_elt = Of_dom.of_element
  end)
  (Ew_alert)
}}

{server{
  let closeable_by_click = Ew_alert.closeable_by_click

  let popup ?show ?allow_outer_clicks ?with_background elt =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          popup
            ?show:%show
            ?allow_outer_clicks:%allow_outer_clicks
            ?with_background:%with_background
            %elt
        )
      )
    }};
    elt

  let dyn_popup ?show ?allow_outer_clicks ?with_background elt f =
    ignore {unit{
      Eliom_client.onload (fun () ->
        ignore (
          dyn_popup
            ?show:%show
            ?allow_outer_clicks:%allow_outer_clicks
            ?with_background:%with_background
            %elt
            %f
        )
      )
    }};
    elt
}}
