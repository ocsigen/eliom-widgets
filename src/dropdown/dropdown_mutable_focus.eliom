{shared{
  open Eliom_content.Html5.F
  open Eliom_content.Html5
}}

{shared{
  class type dropdown_mutable_focus_t = object
    inherit Dropdown_mutable.dropdown_mutable_t
  end
}}

{client{

  class dropdown_mutable_focus
    ~attach_to
    ?orientation
    ?circular
    ?closeable_by_button
    ?li_id ?li_class
    ?ul_id ?ul_class
    (lelt: ([< Html5_types.flow5_without_interactive Html5_types.a ] Eliom_content.Html5.D.elt) list)
    =
  object(self)

    inherit Dropdown_mutable.dropdown_mutable
          ~attach_to
          ?orientation ?circular
          ?closeable_by_button
          ?li_id ?li_class
          ?ul_id ?ul_class
          (List.map (fun a -> [a]) lelt)

    method on_keydown ke =
      (match ke##keyCode with
         | 38 | 40 ->
             (match self#get_active with
               | None -> ()
               | Some active ->
                   Js.Opt.iter (active##firstChild)
                     (fun ch ->
                        ((Js.Unsafe.coerce ch) :> Dropdown_focus.focus_t Js.t)##focus()));
         | _ -> ());
      Lwt.return ()

  end

}}
