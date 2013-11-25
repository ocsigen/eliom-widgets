{client{
open Eliom_content.Html5

module type TParam = sig
  module Traversable : Ojw_traversable_f.T
  module Button : Ojw_button_f.T

  type element
  type 'a elt

  val of_dom_elt : element elt -> Dom_html.element Js.t
  val of_dom_elt : Dom_html.element Js.t -> element elt
end

module type T = sig
  include TParam

  class type dropdown = object
    inherit Button.button

    method traversable : Traversable.traversable Js.t Js.readonly_prop
  end

  val dropdown :
     ?v : Ojw_position.v_orientation
  -> ?h : Ojw_position.h_orientation
  -> ?focus : bool
  -> ?hover : bool
  -> ?hover_timeout : float
  -> Button.element Button.elt
  -> Traversable.element Traversable.elt
  -> element elt list
end

module Make(M : TParam)
  : T
    with type element = M.element
    with type Traversable.element = M.Traversable.element
    with type Traversable.item_element = M.Traversable.item_element
    with type Button.element = M.Button.element
    with type 'a elt = 'a M.elt
    with type 'a Traversable.elt = 'a M.Traversable.elt
    with type 'a Button.elt = 'a M.Button.elt
= struct

  include M

  type dropdown_fun = M.Button.Alert.t -> M.Traversable.element M.Traversable.elt

  class type dropdown = object
    inherit M.Button.button

    method traversable : M.Traversable.traversable Js.t Js.readonly_prop
  end

  class type dropdown' = object
    inherit dropdown

    method _timeout : unit Lwt.t Js.opt Js.prop
    method _traversable : M.Traversable.traversable Js.t Js.prop
  end

  let dropdown
        ?(v = `bottom)
        ?(h = `center)
        ?(focus = true)
        ?(hover = false)
        ?(hover_timeout = 1.0)
        elt (elt_traversable : M.Traversable.element M.Traversable.elt) =
    let elt' = (Js.Unsafe.coerce (M.Button.to_button elt) :> dropdown' Js.t) in

    (* Don't use the 'this' argument because it correspond to dropdown content
     * and not the button used by the dropdown.
     *
     * FIXME: Should we check if 'pressed' method is not undefined ? It should
     * never happen.. *)
    let is_traversable _ = Js.to_bool (elt'##pressed) in

    let on_mouseovers, on_mouseouts =
      (fun f ->
         Js.Opt.iter (elt'##_timeout)
           (fun th -> Lwt.cancel th);
         f ()),
      (fun () ->
         let th = Lwt_js.sleep hover_timeout in
         elt'##_timeout <- Js.some th;
         try_lwt
           lwt () = th in
           if (Js.to_bool elt'##pressed) then
             elt'##unpress();
           Lwt.return ()
         with Lwt.Canceled -> Lwt.return ())
    in

    let elt_traversable' = M.Traversable.to_dom_elt elt_traversable in

    ignore (Ojw_button.button_alert ~pressed:false (elt' :> Dom_html.element Js.t) elt_traversable');

    Ojw_position.relative_move ~v ~h
      ~relative:(M.Button.to_dom_elt elt)
      elt_traversable';

    elt'##_traversable <-
      M.Traversable.to_traversable
        (M.Traversable.traversable ~focus ~is_traversable elt_traversable);

    if hover then begin
      Lwt.async (fun () ->
          Lwt_js_events.mouseovers elt_traversable'
            (fun _ _ ->
               on_mouseovers (fun () -> ());
               Lwt.return ()));

      Lwt.async (fun () ->
          Lwt_js_events.mouseouts elt_traversable'
            (fun _ _ ->
               lwt () = on_mouseouts () in
               Lwt.return ()));
    end;

    elt'##_timeout <- Js.null;

    if hover then begin
      Lwt.async (fun () ->
        Lwt_js_events.mouseovers elt'
          (fun _ _ ->
             on_mouseovers (fun () ->
               if not (Js.to_bool elt'##pressed) then
                 elt'##press()
             );
             Lwt.return ()));

      Lwt.async (fun () ->
        Lwt_js_events.mouseouts elt'
          (fun _ _ ->
             lwt () = on_mouseouts () in
             Lwt.return ()));
    end;

    [
      M.of_dom_elt (M.Button.to_dom_elt elt);
      M.of_dom_elt (M.Traversable.to_dom_elt elt_traversable);
    ]
end
}}
