{shared{
  open Eliom_content.Html5.F
  open Eliom_content.Html5
}}

(* Some features could be implemented with this dropdown implementation
 * like:
 * - nested dropdown
 * - ...
 * *)

(* TODO: move it to ojwidgets and make functors to do coercions from
 * tyxml elements to js elements in eliom-widgets.
 *
 * TODO: documentations WIP
 * *)

{client{
  class type dropdown_t = object
    inherit Ojw_button.alert_t
    method get_active : Dom_html.element Js.t option

    method get_index : int
    method internal_on_keyup : Dom_html.keyboardEvent Js.t -> unit Lwt.t
    method internal_on_keydown : Dom_html.keyboardEvent Js.t -> unit Lwt.t
    method opened : bool

    method show : unit Lwt.t
    method hide : unit Lwt.t

    method on_reset : unit Lwt.t
    method on_confirm : unit Lwt.t

    method on_keydown : Dom_html.keyboardEvent Js.t -> unit Lwt.t

    method on_show : unit Lwt.t
    method on_hide : unit Lwt.t

    method on_focus : unit Lwt.t
    method on_outclick : unit Lwt.t

    method update_position : unit
  end
}}

{server{
  class type dropdown_t = object
    inherit Ew_button.alert_t
    method get_active : Html5_types.li Eliom_content.Html5.elt option

    method get_index : int
    method internal_on_keyup : Dom_html.keyboardEvent Js.t -> unit Lwt.t
    method internal_on_keydown : Dom_html.keyboardEvent Js.t -> unit Lwt.t
    method opened : bool

    method show : unit Lwt.t
    method hide : unit Lwt.t

    method on_reset : unit Lwt.t
    method on_confirm : unit Lwt.t

    method on_keydown : Dom_html.keyboardEvent Js.t -> unit Lwt.t

    method on_show : unit Lwt.t
    method on_hide : unit Lwt.t

    method on_focus : unit Lwt.t
    method on_outclick : unit Lwt.t

    method update_position : unit
  end
}}

{client{

  class type focusable_t = object
    inherit Dom_html.element
    method focus : unit Js.meth
  end

  type orientation_t =
    | Bottom
    | Left
    | Right

  let gbl_set = Ew_button.new_radio_set ()
  let gbl_active_widget = ref None

  (** widget low-level which represents a dropdown *)
  class dropdown
    ~(attach_to : 'a Eliom_content.Html5.D.elt)
    ?(orientation = Bottom)
    ?(circular = true)
    ?(closeable_by_button = true)
    ?(li_id = "") ?(li_class = [])
    ?(ul_id = "") ?(ul_class = [])
    (lelt: (([< Html5_types.li_content_fun ] Eliom_content.Html5.D.elt) list) list)
    =

  let li_attrs = [a_id li_id; a_class ("ew_dropdown_element"::li_class)] in

  let ul_content =
    List.map
      (fun elt -> D.li ~a:li_attrs elt)
      (lelt)
  in
  let ul_attrs = [a_id ul_id; a_class ul_class] in
  let ul_html = D.ul ~a:(ul_attrs) ul_content in

  let is_child_of child parent =
    (parent##compareDocumentPosition(child) land 16) = 16
  in
  let contains elt cl =
    elt##classList##contains(Js.string cl) = (Js.bool true)
  in
  object(self)

    val mutable ul' = To_dom.of_ul ul_html
    val mutable li' = None
    val mutable att' = To_dom.of_element attach_to

    inherit Ojw_button.alert
          ~allow_outer_click:false
          ~closeable_by_button
          ~closeable_by_method:true
          ~button:(To_dom.of_element attach_to)
          ~set:gbl_set
          ()
    as super

    method on_post_unpress =
      Ojw_log.log "post_unpress";
      Lwt.return ()

    method get_node = Lwt.return [ul']

    method private get_li_attrs = li_attrs
    method private get_ul_attrs = ul_attrs

    method private reset =
      li' <- None;
      List.iter
        (fun li ->
           Js.Opt.case (Dom_html.CoerceTo.element li)
             (fun () -> ())
             (fun li -> li##classList##remove(Js.string "ew_active")))
        (Dom.list_of_nodeList (ul'##childNodes));
      self#on_reset

    method private unset_active =
      match li' with
        | None -> ()
        | Some active_li ->
            active_li##classList##remove(Js.string "ew_active");
            li' <- None

    method private set_active li =
      let set_active_li li =
        li' <- Some li;
        li##classList##add(Js.string "ew_active")
      in
      match li' with
        | None -> set_active_li li
        | Some active_li ->
            active_li##classList##remove(Js.string "ew_active");
            set_active_li li

    method get_active = li'

    method get_index =
      let index = ref 0 in
      let ret =
        List.exists
          (fun li ->
             let ret = ref false in
               Js.Opt.case (Dom_html.CoerceTo.element li)
                 (fun _ -> ())
                 (fun li ->
                    index := !index + 1;
                    ret := contains li "ew_active");
               !ret)
          (Dom.list_of_nodeList (ul'##childNodes));
      in
      (if ret then (!index-1) else -1) (* ternaire i miss you :( *)

    method internal_on_keyup (e : Dom_html.keyboardEvent Js.t) : unit Lwt.t =
      lwt () =
        match e##keyCode with
          | 27 -> self#hide
          | _ -> Lwt.return ()
      in
      Lwt.return ()

    method internal_on_keydown (e : Dom_html.keyboardEvent Js.t) : unit Lwt.t =
      let move default updater =
        match li' with
          | None ->
              Js.Opt.case (default)
                (fun _ -> ())
                (fun li ->
                   Js.Opt.case (Dom_html.CoerceTo.element li)
                     (fun _ -> ())
                     (fun li -> self#set_active li))
          | Some li ->
              Js.Opt.case (updater li)
                (fun _ -> ())
                (fun li ->
                   Js.Opt.case (Dom_html.CoerceTo.element li)
                     (fun _ -> ())
                     (fun li ->
                        match li' with
                          | None -> ()
                          | Some pli -> self#set_active li))
      in
      lwt () =
        match e##keyCode with
          | 13 -> (* enter *)
              self#on_confirm
          | 38 -> (* up *)
              Lwt.return (move (ul'##lastChild) (fun li -> li##previousSibling))
          | 40 -> (* down *)
              Lwt.return (move (ul'##firstChild) (fun li -> li##nextSibling))
          | 9  -> (* tab *)
              self#unpress
          | _ ->
              Lwt.return ()
      in
      lwt () = self#on_keydown e in
      Lwt.return ()

    method opened =
      self#pressed

    method show =
      self#press

    method press =
      gbl_active_widget := Some (self#internal_on_keydown, self#internal_on_keyup);
      lwt () = self#reset in
      lwt () = super#press in
      (Js.Unsafe.coerce att')##focus();
      let () = self#update_position in
      lwt () = self#on_show in
      Lwt.return ()

    method hide =
      self#unpress

    method unpress =
      if self#opened then
        gbl_active_widget := None;
      lwt () = super#unpress in
      lwt () = self#on_hide in
      Lwt.return ()

    method on_reset = Lwt.return ()
    method on_confirm = Lwt.return ()

    method on_keydown ke = Lwt.return ()

    method on_show = Lwt.return ()
    method on_hide = Lwt.return ()

    method on_focus = Lwt.return ()
    method on_outclick = Lwt.return ()

    method update_position =
      (* The following code attempt to move the dropdown under the element
       * to which the dropdown is attached *)
      let computed_att = Ojw_fun.getComputedStyle att' in
      let aw = Ojw_misc.get_full_width computed_att in
      let ah = Ojw_misc.get_full_height computed_att in
      let hshift, vshift =
        (* TODO: Display the dropdown on another place if the current
         * orientation put the dropdown outside of the screen *)
        match orientation with
          | Bottom ->
              (Dom_html.document##body##scrollLeft),
              (ah + Dom_html.document##body##scrollTop)
          | Right ->
              (Dom_html.document##body##scrollLeft + aw),
              (Dom_html.document##body##scrollTop)
          | Left ->
              (Dom_html.document##body##scrollLeft - aw),
              (Dom_html.document##body##scrollTop)
      in
      let rectopt = att'##getClientRects()##item(0) in
      let (container_top, container_left) =
        Js.Opt.case rectopt
          (fun rect -> (Js.string "0px", Js.string "0px"))
          (fun rect ->
             let to_css shift x =
               let integer = (int_of_float (Js.to_float x)) + shift in
                 Ojw_unit.pxstring_of_int integer
             in
               (to_css vshift rect##top, to_css hshift rect##left))
      in
      ul'##style##top <- container_top;
      ul'##style##left <- container_left;
      let computed_ul = Ojw_fun.getComputedStyle ul' in
      let ulw = Ojw_misc.get_full_width computed_ul in
      (* We want to remove the extra width of the element to get exactly
       * the same width of the attached element if his size is bigger
       * than the ul's one *)
      let extra_inner = Ojw_misc.get_full_width ~with_width:false computed_ul in
      if aw > ulw then
         ul'##style##width <- Ojw_unit.pxstring_of_int (aw - extra_inner)
      else ()

    initializer
    (* We had the default class "ew_dropdown" which provides basic
     * css to remove bullets from li elements *)
    ul'##classList##add(Js.string "ew_dropdown");
    ignore (lwt () = self#hide in Lwt.return ());
    Lwt.async
      (fun () ->
         Lwt_js_events.clicks ul'
           (fun e _ ->
              if not self#opened
              then Lwt.return ()
              else
                (lwt () = self#on_confirm in
                 Dom.preventDefault e;
                 Dom_html.stopPropagation e;
                 Lwt.return ())));
    Lwt.async
      (fun () ->
         Lwt_js_events.mouseouts ul'
           (fun e _ ->
              self#unset_active;
              Lwt.return ()));
    Lwt.async
      (fun () ->
         Lwt_js_events.mouseovers ul'
           (fun e _ ->
              (Js.Optdef.iter (e##toElement)
                 (fun elt ->
                    Js.Opt.iter elt
                      (fun elt ->
                         let rec aux it =
                           Js.Opt.iter (Dom_html.CoerceTo.element it)
                             (fun elt ->
                                if not (contains elt "ew_dropdown")
                                then
                                  (if (contains elt "ew_dropdown_element")
                                   then (self#set_active elt)
                                   else (Js.Opt.iter (elt##parentNode)
                                           (fun p -> aux p))))
                         in
                         if is_child_of (elt :> Dom.node Js.t) ul'
                         then aux (elt :> Dom.node Js.t))));
              Lwt.return ()))
  end

  let _ =
    Lwt.async
      (fun () ->
         Lwt_js_events.keydowns Dom_html.document
           (fun e _ ->
              match !gbl_active_widget with
                | None -> Lwt.return ()
                | Some (kdown,_) -> kdown e));
    Lwt.async
      (fun () ->
         Lwt_js_events.keyups Dom_html.document
           (fun e _ ->
              match !gbl_active_widget with
                | None -> Lwt.return ()
                | Some (_,kup) -> kup e));

}}
