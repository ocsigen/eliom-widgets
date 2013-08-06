(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{shared{
  open Eliom_content
  open Eliom_content.Html5

  type dynup_service_t =
      (unit, Eliom_lib.file_info, Eliom_service.nonattached,
       [ `WithoutSuffix ], unit,
       [ `One of Eliom_lib.file_info ] Eliom_parameter.param_name,
       [ `Registrable ], (string list * string) Eliom_parameter.caml)
        Eliom_service.service
}}

{shared{
  let dir_to_path ?(file = "") dir =
    let make_path a b = a^"/"^b in
    make_path (List.fold_left (make_path) "./static" dir) file
}}

{server{
  let mkdir_if_needed dirs =
    try_lwt
      lwt _ =
        Lwt_list.fold_left_s
          (fun prev_dir dir ->
             let path = prev_dir^"/"^dir in
             lwt () =
               if not (Sys.file_exists path)
               then Lwt_unix.mkdir path 0o766
               else Lwt.return ()
             in
             Lwt.return path)
          ("./static")
          (dirs)
      in
      Lwt.return ()
    with
      | Unix.Unix_error (_,f,s) ->
          print_endline (f^":"^s); (* TODO: should be logged in another way *)
          Lwt.return (ignore ({unit{ Ojw_log.log ((%f)^":"^(%s)) }}))

}}

{shared{
  exception Invalid_extension
}}

{server{
  let default_temp_dirname () =
    ["ew"; "tmp"]

  let default_dirname () =
    ["ew"; "uploaded"]

  let default_new_filename () =
    let base64url_of_base64 s =
      for i = 0 to String.length s - 1 do
        if s.[i] = '+' then s.[i] <- '-' ;
        if s.[i] = '/' then s.[i] <- '_' ;
      done
    in
    let fname = Ocsigen_lib.make_cryptographic_safe_string () in
    base64url_of_base64 fname;
    fname

  let service ?name () =
    Eliom_service.post_coservice'
      ?name
      ~post_params:(Eliom_parameter.file "f")
      ()

  let clean_thread_already_started = ref false

  (* This function act like a daemon. It will be called each [timeout]
   * seconds. (maybe, the infinite loop could be more generalized ? We
   * could create and Ew_daemon to do some stuffs on the server easily ?
   * *)
  let clean_temporary_dir dpath timeout =
    let tdir = default_temp_dirname () in
    let tdpath = dir_to_path tdir in
    let rec infinite_loop lasts =
      lwt tdir = Lwt_unix.opendir tdpath in
      let rec iter_on_dir files =
        lwt temp = Lwt_unix.readdir_n tdir 10 in
        let files = Array.append files temp in
        if Array.length temp < 10 (* we have read all files *)
        then Lwt.return (files)
        else iter_on_dir files
      in
      lwt files = iter_on_dir [||] in
      lwt () = Lwt_unix.closedir tdir in
      let lfiles = Array.to_list files in
      let lfiles =
        List.filter (fun s -> not (s = ".") && not (s = "..")) lfiles
      in
      let new_lasts = ref [] in
      let find_and_remove f1 =
        try
          let to_remove = List.find (fun f2 -> f1 = f2) lasts in
          let fpath = dpath^"/"^to_remove in
          let tfpath = tdpath^"/"^to_remove in
          print_endline ("______>>>>> rm "^fpath);
          print_endline ("______>>>>> rm "^tfpath);
          lwt () = Lwt_unix.unlink fpath in
          lwt () = Lwt_unix.unlink tfpath in
          Lwt.return ()
        with
          | Not_found ->
              new_lasts := f1::(!new_lasts);
              Lwt.return ()
      in
      lwt () = Lwt_list.iter_s (find_and_remove) lfiles in
      print_endline ("______>>>>>sleep for "^(string_of_float timeout));
      lwt () = Lwt_unix.sleep timeout in
      infinite_loop !new_lasts
    in
    try_lwt
      infinite_loop []
    with
      | Unix.Unix_error (_,f,s) ->
          print_endline (f^":"^s); (* TODO: should be logged in another way *)
          Lwt.return (ignore ({unit{ Ojw_log.log ((%f)^":"^(%s)) }}))

  let handler
    ?(timeout = 180.)
    ?(remove_on_timeout = false)
    ?(dir = default_dirname ())
    ?(new_filename = default_new_filename)
    ?extensions
    f
    =
    let dpath = dir_to_path dir in
    let tdir = default_temp_dirname () in
    (fun () file ->
       let () =
         match extensions with
           | None -> ()
           | Some exts ->
               let fn = Eliom_request_info.get_original_filename file in
               if not (List.exists (Filename.check_suffix fn) exts)
               then raise Invalid_extension
               else ()
       in
       lwt () =
         (* TODO: launch only one thread by services *)
         if remove_on_timeout && (!clean_thread_already_started = false)
         then begin
            lwt () = mkdir_if_needed tdir in
            (** We call a thread which will scan the temporary directory
              * and delete files on timeout *)
            clean_thread_already_started := true;
            Lwt.return (ignore (clean_temporary_dir dpath timeout));
         end
         else Lwt.return ()
       in
       lwt () = mkdir_if_needed dir in
       let fname = new_filename () in
       let fpath = dpath^"/"^fname in
       lwt () =
         Lwt_unix.link (Eliom_request_info.get_tmp_filename file) fpath
       in
       lwt () =
         if remove_on_timeout
         then
           let tfpath = dir_to_path ~file:fname tdir in
           Lwt_unix.link fpath tfpath
         else Lwt.return ()
       in
       (* on uploaded, call the user's handler *)
       lwt () = f dir fname in
       Lwt.return (dir, fname))

  let register service handler =
    Eliom_registration.Ocaml.register (service :> dynup_service_t) handler

  let mark_as_used fname =
    try_lwt
      let tdpath = dir_to_path ~file:fname (default_temp_dirname ()) in
      lwt () = Lwt_unix.unlink tdpath in
      Lwt.return ()
    with
      | Unix.Unix_error (_,f,s) ->
          print_endline (f^":"^s); (* TODO: should be logged in another way *)
          Lwt.return (ignore ({unit{ Ojw_log.log ((%f)^":"^(%s)) }}))
}}

{client{
  let dyn_upload ~(service : dynup_service_t) ~(file : File.file Js.t) handler =
    lwt (dname, fname) =
      Eliom_client.call_caml_service
        ~service:(service)
        () file
    in
    handler dname fname
}}
