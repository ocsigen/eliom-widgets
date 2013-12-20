{shared{
  type t'
}}

{client{
  type t = Ojw_active_set.t

  val set : ?at_least_one:bool -> unit -> t
  val of_server_set : t' -> t
  val to_server_set : t -> t'
}}
