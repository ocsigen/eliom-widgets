{shared{
open Eliom_lib
open Eliom_content.Html5
open F
}}

{client{
let onclick_replace container replacement trigger =
  let open Lwt_js_events in
  Lwt.async
    (fun () ->
       clicks trigger (fun _ _ ->
	 Lwt.return (Manip.replaceChildren container replacement)
       ))
  }}

{shared{

(* little alias *)
type 'a my_btn =
  ([< Html5_types.phrasing_without_interactive] as 'a )
    Eliom_content.Html5.F.elt

(* TODO bind the enter key to "send" *)
let editable_name
    ?(a=[])
    ?(edit : 'a my_btn option)
    ?(confirm : 'b my_btn option)
    ?(cancel : 'c my_btn option)
    ?(default_name="New name") ~content ~(callback:(string -> unit Lwt.t) client_value) =
  let fake_input =
    span ~a:[a_contenteditable true]
      [pcdata default_name] in
  let btn_icon title content =
    D.Raw.a ~a:[ a_title title ; a_class ["link"] ]
      [content] in
  let edit = btn_icon "Edit name" (Option.get (fun () -> pcdata "✍") edit) in
  let confirm = btn_icon "Change name" (Option.get (fun () -> pcdata "✔") confirm) in
  let cancel = btn_icon "Cancel" (Option.get (fun () -> pcdata "✘") cancel) in
  let container = D.span ~a:a [ content ; edit ] in
  let _  = {unit{
      let container = %container in
      let original = %content in
      let callback = %callback in
      let edit, confirm, cancel = %edit, %confirm, %cancel in
      let fake_input = %fake_input in
      let replacement = [fake_input; confirm; cancel] in
      let () = onclick_replace container replacement
	  (To_dom.of_element edit) in
      let () = onclick_replace container [original;edit]
	  (To_dom.of_element cancel) in
      Lwt.async (fun () ->
	let open Lwt_js_events in
	click (To_dom.of_element confirm) >>= (fun _ ->
	  (* AFAIK there is no security issue here, since it should be sanitize *)
	  let new_name = Js.to_string (To_dom.of_element fake_input)##innerHTML in
	  callback new_name
	))
    }} in
  container
}}
