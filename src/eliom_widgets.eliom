(* Copyright Université Paris Diderot. *)

{shared{
  module Editable = Editable
}}

{client{
  module Button = struct
    include Ojw_button
    include Ojw_button_alert
    include Ojw_button_show_hide
    include Ojw_button_show_hide_focus
  end

}}
