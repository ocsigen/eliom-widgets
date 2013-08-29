{shared{
  open Eliom_content.Html5.F
  open Eliom_content.Html5
}}

{shared{
  class type completion_t = object
    inherit Dropdown_mutable.dropdown_mutable_t

    method clear_input : unit
    method update : unit Lwt.t
  end
}}

{server{
  module M = Netstring_pcre

  let search rex w =
    try Some (M.search_forward rex w 0) with
      | Not_found -> None

  let regex_case_insensitive =
    M.regexp_case_fold
}}

{client{
  module M = Regexp

  let search rex w =
    M.search rex w 0

  let regex_case_insensitive w =
    M.regexp_with_flag w  "i"
}}

{shared{
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

{client{
  let search_case_accents_i w0 w1 =
    let w0 = Js.to_string (Ojw_fun.removeDiacritics w0) in
    let w1 = Js.to_string (Ojw_fun.removeDiacritics w1) in
    search_case_insensitive w0 w1 (*both arg are caml utf8 string *)
}}

{shared{
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
  (* w1 is a completion of w0. ex: is_completed_by "e" "eddy" = yes *)
  (* both arg are utf16 JS string *)
  let is_completed_by w0 w1 =
    if w0 = (Js.string "") || w1 = (Js.string "")
    then false
    else searchopt_to_bool w0 w1
}}

{client{

  (** A completion widgets which works with an 'a type.
    *
    * You have to define some needed functions by the widget:
    * [to_string]: take your 'a type as parameter and returns it as a string
    * [on_confirm]: ..
    * [on_refresh]: called when the widget need to refresh his internal list
    *               of choices
    * [on_show]: this function must return the html equivalent of you 'a type
    *
    * ...
    *
    * WIP
    * *)

  class ['a] completion
    ~(input : [< `Input ] Eliom_content.Html5.D.elt)
    ?(max = 5)
    ?(clear_input_on_outclick = true)
    ~(to_string : 'a -> string)
    ?(on_confirm : ('a -> unit Lwt.t) = (fun a -> Lwt.return (ignore a)))
    ~(on_refresh : string -> 'a list Lwt.t)
    ~(on_show : 'a -> [< Html5_types.li_content_fun ] Eliom_content.Html5.D.elt list)
    ()
    =

  object(self)

    val input' = (To_dom.of_input input)
    val mutable need_update' = false
    val mutable choices' : 'a list = []

    inherit Dropdown_mutable.dropdown_mutable
          ~closeable_by_button:false
          ~attach_to:input
          []
    as inherited_dd

    method clear_input =
      input'##value <- Js.string ""

    method on_outclick =
      if clear_input_on_outclick then self#clear_input;
      Lwt.return ()

    (* because key handler have been set first, we know that
     * this handler will be called in first (cf. need_update') *)
    method on_keydown e =
      let index = inherited_dd#get_index in
      match e##keyCode with
        | 8 ->
            need_update' <- true;
            Lwt.return ()
        | 38 | 40 ->
            input'##value <- Js.string (to_string (List.nth choices' index));
            Dom.preventDefault e;
            Dom_html.stopPropagation e;
            Lwt.return ()
        | _ -> Lwt.return ()

    method on_confirm =
      let index = inherited_dd#get_index in
      input'##value <- Js.string (to_string (List.nth choices' index));
      lwt () = self#hide in
      lwt () = on_confirm (List.nth choices' index) in
      Lwt.return ()

    method private remove_unmatched =
      let n_iter = ref 0 in
      let input = input'##value in
      choices'
        <- List.filter
             (fun a ->
                if !n_iter >= max then false
                else
                  (if not (is_completed_by (input) (Js.string (to_string a)))
                   then false
                   else (n_iter := !n_iter + 1; true)))
             (choices')

    method update =
      inherited_dd#clear;
      self#remove_unmatched;
      List.iter (fun a -> inherited_dd#append (on_show a)) (choices');
      need_update' <- false;
      inherited_dd#show

    initializer
      (** listen to event on the widget input *)
      Lwt.async
        (fun () ->
           Lwt_js_events.inputs (To_dom.of_input input)
             (fun e _ ->
                if (List.length choices') = 0 || need_update'
                then
                  (lwt l = on_refresh (Js.to_string ((To_dom.of_input input)##value)) in
                   choices' <- l;
                   self#update)
                else
                  (lwt () = self#update in
                   Lwt.return ())))
  end

}}
