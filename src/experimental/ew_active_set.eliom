{shared{
  type t' = int
}}

{client{
  module HT = Hashtbl

  let htable =
    HT.create 10

  type t = Ojw_active_set.t

  let set ?at_least_one () =
    let set = Ojw_active_set.set ?at_least_one () in
    HT.add htable (HT.hash set) set;
    set

  let of_server_set set =
    HT.find htable set

  let to_server_set set =
    HT.hash set
}}
