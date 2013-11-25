{client{
open Dom
open Dom_html

module type T = sig
  exception Close_during_initialization

  type 'a elt

  type parent
  type element

  val to_dom_elt : element elt -> Dom_html.element Js.t

  (** The type which reprensents an alert. *)
  type t

                                    (*

  (** [close a] closes an alert. Be aware that using this function during
    * the initialization of the alert box will raise
    * [Close_during_initialization].
    *)
  val close : t -> unit

  (** [alert ?parent ?wrap ?before ?after f] creates an alert box. The
    * content is defined using the function [f] which returns a list of
    * javascript elements.
    *
    * You can change the [parent] to which the alert box will be inserted.
    * By default, it is set to [document##body]. You can also use a specific
    * container for the alert box, using [wrap] function (default: div element).
    *
    * If you want to do some operations before inserting the alert box into the dom
    * (such as positioning your box), you can use [before] callback. There is also
    * a callback [after] which is called after insertion.
    *
    * The initialization is finished once the content of the alert box is
    * returned.
    *)
  val alert :
     ?parent:parent elt
  -> ?before:(element elt -> unit)
  -> ?after:(element elt -> unit)
  -> (t -> element elt)
  -> t


                                     *)
  class type alert_event = object
    inherit Dom_html.event
  end

  module Event : sig
    type event = alert_event Js.t Dom.Event.typ

    module S : sig
      val show : string
      val hide : string
      val close : string
    end

    val show : event
    val hide : event
    val close : event
  end

  val show : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val hide : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t
  val close : ?use_capture:bool -> #Dom_html.eventTarget Js.t -> alert_event Js.t Lwt.t

  val shows :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> element elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val hides :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> element elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  val closes :
    ?cancel_handler:bool
    -> ?use_capture:bool
    -> element elt
    -> (alert_event Js.t -> unit Lwt.t -> unit Lwt.t)
    -> unit Lwt.t

  class type alert = object
    inherit Ojw_base_widget.widget

    method visible : unit -> bool Js.t Js.meth
    method show : unit Js.meth
    method hide : unit Js.meth
  end

  val alert :
     ?show:bool
  -> element elt
  -> element elt

  val to_alert :
     element elt
  -> alert Js.t

end

module Make(M : sig
  type 'a elt

  type parent
  type element

  val to_dom_elt : element elt -> Dom_html.element Js.t
  val to_dom_parent : parent elt -> Dom_html.element Js.t

  val default_parent : unit -> parent elt

end) = struct
  exception Close_during_initialization

  include M

  type t_ = {
    parent : Dom_html.element Js.t;
    mutable container : Dom_html.element Js.t option;
  }

  type t = t_ option ref

  class type alert_event = object
    inherit Dom_html.event
  end

  module Event = struct
    type event = alert_event Js.t Dom.Event.typ

    module S = struct
      let show = "show"
      let hide = "hide"
      let close = "close"
    end

    let show : event = Dom.Event.make S.show
    let hide : event = Dom.Event.make S.hide
    let close : event = Dom.Event.make S.close
  end

  let show ?use_capture target =
    Lwt_js_events.make_event Event.show ?use_capture target
  let hide ?use_capture target =
    Lwt_js_events.make_event Event.hide ?use_capture target
  let close ?use_capture target =
    Lwt_js_events.make_event Event.close ?use_capture target


  let shows ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop show ?cancel_handler ?use_capture (M.to_dom_elt t)
  let hides ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop hide ?cancel_handler ?use_capture (M.to_dom_elt t)
  let closes ?cancel_handler ?use_capture t =
    Lwt_js_events.seq_loop close ?cancel_handler ?use_capture (M.to_dom_elt t)

  class type alert = object
    inherit Ojw_base_widget.widget

    method visible : unit -> bool Js.t Js.meth
    method show : unit Js.meth
    method hide : unit Js.meth
  end

  class type alert' = object
    inherit alert

    method _visible : (#alert Js.t, unit -> bool Js.t) Js.meth_callback Js.prop
    method _show : (#alert Js.t, unit -> unit) Js.meth_callback Js.prop
    method _hide : (#alert Js.t, unit -> unit) Js.meth_callback Js.prop
  end

  class type dyn_alert = object
    inherit alert

    method update : unit Js.meth
  end

  let alert ?(show = false) elt =
    let elt' = (Js.Unsafe.coerce (M.to_dom_elt elt) :> alert' Js.t) in
    let meth = Js.wrap_meth_callback in

    (* FIXME:
     * Should we get the display value each time we hide the alert instead ?
     * *)
    let display = Js.string (match (Js.to_string elt'##style##display) with
        | "none" -> "block" (* should we force ? *)
        | display -> display
      );
    in

    elt'##_show <-
    meth (fun this () ->
      this##style##display <- display
    );

    elt'##_hide <-
    meth (fun this () ->
      this##style##display <- Js.string "none"
    );

    elt'##_visible <-
    meth (fun this () ->
      Js.bool (not (this##style##display = (Js.string "none")))
    );

    if not show then
      elt'##hide();

    elt

      (*

  let dyn_alert ?parent ?before ?after f =
    let p = match parent with
      | None -> (fun () -> M.to_dom_parent (M.default_parent ()))
      | Some p -> (fun () -> M.to_dom_parent p)
    in
    let alrt = ref None in
    let p = p () in
    let c = f alrt in
    let c' = M.to_dom_elt c in
    alrt := Some {
      parent = p;
      container = Some c';
    };
    (match before with
       | None -> ()
       | Some f -> Ojw_tools.as_dom_elt c' (fun c' -> f c));
    appendChild p c';
    (match after with
       | None -> ()
       | Some f -> f c);
    alrt

       *)

  let to_alert elt = (Js.Unsafe.coerce (M.to_dom_elt elt) :> alert Js.t)
end
}}
