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
  module M = Netstring_pcre

  let search rex w =
    try Some (M.search_forward rex w 0) with
      | Not_found -> None

  let regex_case_insensitive =
    M.regexp_case_fold
}}

{server{
  let build_pattern w =
    let w = M.quote w in
    regex_case_insensitive  (("^" ^ w) ^ "|\\s" ^ w)

  let search_case_insensitive w0 w1 =
    if w0 = "" || w0 = w1
    then None
    else
      let pattern = (build_pattern w0) in
      match search pattern w1 with
        | None -> None
        | Some (i,r) -> if i = 0 then Some (i,r) else Some (i+1, r)
}}

{server{
  (* arguments are utf8 caml string *)
  let search_case_accents_i w0 w1 =
    let w0 = Ew_accents.without w0 in
    let w1 = Ew_accents.without w1 in
    search_case_insensitive w0 w1
}}

{server{
  let searchopt_to_bool w0 w1 =
    match search_case_accents_i w0 w1 with
      | None -> false
      | Some _ -> true
}}

{server{
  (* w1 is a completion of w0. ex: is_completed_by "e" "eddy" = yes *)
  (* both arg are utf8 caml string *)
  let is_completed_by w0 w1 =
    if w0 = "" || w1 = ""
    then false
    else searchopt_to_bool w0 w1
}}


{client{
  module M = Ojw_completion_f.Make(struct
        type 'a elt = 'a elt'
        type element = element'

        let to_dom_elt = To_dom.of_element
        let of_dom_elt = Of_dom.of_element
      end)
      (Ojw_dropdown_f.Make(struct
          type element = element'
          type 'a elt = 'a elt'

          let to_dom_elt = To_dom.of_element
          let of_dom_elt = Of_dom.of_element
        end)(Ew_button)(Ew_traversable))
}}

{shared{
  let li ?a ~value ~value_to_match = Ew_traversable.li ?a ?href:None ~anchor:false ~value ~value_to_match
}}
  (*
{client{
  let completion : ?refresh:completion_fun -> unit -> unit -> (int * int) =
    (fun ?(refresh) _ _ ->
    Eliom_lib.debug "completion mec";
    (0,0))

}}
   *)

{server{
  let completion
      ~(refresh : refresh_fun client_value)
      ?(limit : int option)
      ?(accents : bool option)
      ?( sensitive : bool option)
      ?(adaptive : bool option)
      ?(auto_match : bool option)
      ?(clear_input_on_confirm : bool option)
      ?(move_with_tab : bool option)
      ?(on_confirm : on_confirm_fun client_value option)
      (elt : element' elt')
      (elt_traversable : Ew_traversable.element' elt') =
    ignore {unit{
        Eliom_client.onload (fun () ->
          let (_,_) = M.completion__
              ~refresh:%refresh
              ?limit:%limit
              ?accents:%accents
              ?sensitive:%sensitive
              ?adaptive:%adaptive
              ?auto_match:%auto_match
              ?clear_input_on_confirm:%clear_input_on_confirm
              ?move_with_tab:%move_with_tab
              ?on_confirm:%on_confirm
              %elt
              %elt_traversable
          in ()
      )
    }};
    (elt, elt_traversable)
}}
