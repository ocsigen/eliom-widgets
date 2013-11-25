(*
var event;
  if (document.createEvent) {
    event = document.createEvent("HTMLEvents");
    event.initEvent("dataavailable", true, true);
  } else {
    event = document.createEventObject();
    event.eventType = "dataavailable";
  }

  event.eventName = eventName;
  event.memo = memo || { };

  if (document.createEvent) {
    element.dispatchEvent(event);
  } else {
    element.fireEvent("on" + event.eventType, event);
  }
 *)

{client{
class type ['a] customEventInit = object
  method bubbles : bool Js.t Js.prop
  method cancelable : bool Js.t Js.prop
  method detail : 'a Js.t Js.opt Js.prop
end

class type ['a] customEvent = object
  inherit Dom_html.event
  inherit ['a] customEventInit
end

  type 'a ctor = (Js.js_string Js.t -> 'a customEventInit Js.t -> 'a customEvent Js.t) Js.constr

  let customEvent ?(can_bubble = false) ?(cancelable = false) ?(detail : 'a Js.t option) typ =
    let ctor : 'a ctor =
      Js.Optdef.case (Js.def (Js.Unsafe.variable ("CustomEvent")))
        (fun () -> raise (Failure "CustomEvent is not supported")) (* TODO *)
        (fun ctor -> ctor)
    in
    let init = ((Js.Unsafe.obj [||]) : 'a customEventInit Js.t) in
    init##bubbles <- Js.bool can_bubble;
    init##cancelable <- Js.bool cancelable;
    let detail = match detail with
       | None -> Js.null
       | Some detail -> Js.some detail
    in
    init##detail <- detail;
    jsnew ctor (Js.string typ, init)

  let dispatchEvent (elt : #Dom_html.element Js.t) (ev : #Dom_html.event Js.t) : unit =
    (Js.Unsafe.coerce elt)##dispatchEvent(ev)
}}
