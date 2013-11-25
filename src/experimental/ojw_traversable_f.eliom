{client{

module type T = sig
  type 'a opt

  type 'a elt
  type element
  type item_element

  val to_opt : 'a Js.opt -> 'a opt
  val of_opt : 'a opt -> 'a Js.opt

  val opt_none : 'a opt
  val opt_some : 'a -> 'a opt

  val opt_iter : 'a opt -> ('a -> unit) -> unit
  val opt_case : 'a opt -> (unit -> 'b) -> ('a -> 'b) -> 'b

  val to_dom_elt : element elt -> Dom_html.element Js.t
  val of_dom_elt : Dom_html.element Js.t -> element elt

  val to_dom_item_elt : item_element elt -> Dom_html.element Js.t
  val of_dom_item_elt : Dom_html.element Js.t -> item_element elt

  class type traversable = object
    inherit Ojw_base_widget.widget

    method getContainer : element elt Js.meth

    method next : unit Js.meth
    method prev : unit Js.meth
    method resetActive : unit Js.meth
    method setActive : element elt -> unit Js.meth
    method getActive : element elt opt Js.meth
    method isTraversable : bool Js.meth
  end

  val traversable :
      ?enable_link : bool
  -> ?focus : bool
  -> ?is_traversable : (#traversable Js.t -> bool)
  -> ?on_keydown : (Dom_html.keyboardEvent Js.t -> bool)
  -> element elt
  -> element elt

  val to_traversable : element elt -> traversable Js.t
end

module Make(M : sig
  type 'a opt

  type 'a elt
  type element
  type item_element

  val to_opt : 'a Js.opt -> 'a opt
  val of_opt : 'a opt -> 'a Js.opt

  val opt_none : 'a opt
  val opt_some : 'a -> 'a opt

  val opt_iter : 'a opt -> ('a -> unit) -> unit
  val opt_case : 'a opt -> (unit -> 'b) -> ('a -> 'b) -> 'b

  val to_dom_elt : element elt -> Dom_html.element Js.t
  val of_dom_elt : Dom_html.element Js.t -> element elt

  val to_dom_item_elt : item_element elt -> Dom_html.element Js.t
  val of_dom_item_elt : Dom_html.element Js.t -> item_element elt
end)
  : T with type element = M.element
    with type 'a elt = 'a M.elt
    with type item_element = M.item_element
= struct

  include M

  class type traversable = object
    inherit Ojw_base_widget.widget

    method getContainer : element elt Js.meth

    method next : unit Js.meth
    method prev : unit Js.meth
    method resetActive : unit Js.meth
    method setActive : element elt -> unit Js.meth
    method getActive : element elt opt Js.meth
    method isTraversable : bool Js.meth
  end

  class type traversable' = object
    inherit traversable
    inherit Ojw_base_widget.widget'

    method _getContainer : (#traversable Js.t, unit -> element elt) Js.meth_callback Js.prop

    method _next : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _prev : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _resetActive : (#traversable Js.t, unit -> unit) Js.meth_callback Js.prop
    method _setActive : (#traversable Js.t, element elt -> unit) Js.meth_callback Js.prop
    method _getActive : (#traversable Js.t, unit -> element elt opt) Js.meth_callback Js.prop
    method _isTraversable : (#traversable Js.t, unit -> bool) Js.meth_callback Js.prop
  end

  let default_is_traversable this =
    let elt =
      this##querySelector
        (Js.string "li[data-value].ew_dropdown_element > a:focus")
    in
    Js.Opt.case (elt)
      (fun () -> false)
      (fun _  -> true)

  let default_on_keydown _ =
    false

  let traversable
        ?(enable_link = true)
        ?(focus = true)
        ?(is_traversable = default_is_traversable)
        ?(on_keydown = default_on_keydown)
        elt =
    let elt' = (Js.Unsafe.coerce (M.to_dom_elt elt) :> traversable' Js.t) in
    let meth = Js.wrap_meth_callback in

    ignore (Ojw_base_widget.ctor elt' "traversable");

    let contains elt cl =
      elt##classList##contains(Js.string cl) = Js._true
    in

    let move ~default ~next this =
      let set item = this##setActive(M.of_dom_elt (Js.Unsafe.coerce item)) in
      M.opt_case (this##getActive())
        (fun () ->
           M.opt_iter (M.to_opt (default ())) (fun item -> set item))
        (fun active ->
           let rec aux item =
             Js.Opt.case (next item)
               (fun () ->
                  Js.Opt.iter (default ()) (fun item -> set item))
               (fun item ->
                  let item = (Js.Unsafe.coerce item :> Dom_html.element Js.t) in
                  if contains item "ew_dropdown_element"
                  then (
                    Js.Opt.iter (item##getAttribute(Js.string "data-value"))
                      (fun attr ->
                         Ojw_log.log (Js.to_string attr));
                    set item
                  )
                  else aux item)
           in aux (M.to_dom_elt active))
    in

    elt'##_getContainer <-
    meth (fun this () ->
      elt
    );

    elt'##_prev <-
    meth (fun this () ->
      Eliom_lib.debug "prev";
      move this
        ~default:(fun () -> elt'##lastChild)
        ~next:(fun elt -> Ojw_log.log "prevSibling"; elt##previousSibling)
    );

    elt'##_next <-
    meth (fun this () ->
      Eliom_lib.debug "next";
      move this
        ~default:(fun () -> elt'##firstChild)
        ~next:(fun elt -> Ojw_log.log "nextSibling"; elt##nextSibling)
    );

    let (!$) q = elt'##querySelector(Js.string q) in

    elt'##_resetActive <-
    meth (fun this () ->
      M.opt_iter (this##getActive())
        (fun item ->
           (M.to_dom_elt item)##classList##remove(Js.string "selected"));
    );

    elt'##_getActive <-
    meth (fun this () ->
      Js.Opt.case (!$ "li[data-value].ew_dropdown_element.selected")
        (fun () -> M.opt_none)
        (fun item -> M.opt_some (M.of_dom_elt item))
    );

    elt'##_setActive <-
    meth (fun this item ->
      Js.Opt.case ((M.to_dom_elt item)##parentNode)
        (* if there is no parent, so item is not a child of
         * the traversable element *)
        (fun () -> ())
        (fun parent ->
           if not (parent = ((M.to_dom_elt elt) :> Dom.node Js.t))
           then ()
           else (
             M.opt_iter (this##getActive())
               (fun item ->
                  (M.to_dom_elt item)##classList##remove(Js.string "selected"));
             (M.to_dom_elt item)##classList##add(Js.string "selected");
             if focus then
               Js.Opt.iter ((M.to_dom_elt item)##firstChild)
                 (fun item -> (Js.Unsafe.coerce item)##focus());
             ()))
    );

    elt'##_isTraversable <-
    meth (fun this () ->
      is_traversable this
    );

    Ojw_log.log "event_listener: keydown";
    Lwt.async (fun () ->
      Lwt_js_events.keydowns Dom_html.document
        (fun e _ ->
           Ojw_log.log "keydown";
           if elt'##isTraversable() then begin
             let prevent = ref false in
             (match e##keyCode with
              | 38 -> (* up *)
                  elt'##prev(); prevent := true;
              | 40 -> (* down *)
                  elt'##next(); prevent := true;
              | _ ->
                  prevent := (on_keydown e));
             if !prevent then Dom.preventDefault e
           end;
           Lwt.return ()
        ));

    let is_child_of child parent =
      (parent##compareDocumentPosition(child) land 16) = 16
    in
    Lwt.async (fun () ->
      Lwt_js_events.clicks elt'
        (fun e _ ->
           (Js.Optdef.iter (e##toElement) (fun elt ->
              Js.Opt.iter elt
                (fun elt ->
                   let rec aux it =
                     Js.Opt.iter (Dom_html.CoerceTo.element it)
                       (fun elt ->
                          if not (contains elt "ew_dropdown") then begin
                            if not (contains elt "ew_dropdown_element")
                            then (Js.Opt.iter (elt##parentNode) (fun p -> aux p))
                            else (
                              elt'##setActive (M.of_dom_elt elt);
                              if not enable_link
                              then Dom.preventDefault e
                              else (Eliom_lib.debug "do no prevent"; ()))
                          end)
                   in
                   if is_child_of (elt :> Dom.node Js.t) elt'
                   then aux (elt :> Dom.node Js.t))));
           Lwt.return ()));

    elt

  let to_traversable elt = (Js.Unsafe.coerce (M.to_dom_elt elt) :> traversable Js.t)
end
}}
