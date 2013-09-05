(* Copyright Université Paris Diderot.

   Author : Charly Chevalier
*)

{shared{
  (* SUGGESTIONS: Use this type as an abstract type for each
   * of the followings functions ? To enforce to use our [service]
   * function ? *)

  (** Type of a dynamic service. *)
  type dynup_service_t =
      (unit, Eliom_lib.file_info, Eliom_service.nonattached,
       [ `WithoutSuffix ], unit,
       [ `One of Eliom_lib.file_info ] Eliom_parameter.param_name,
       [ `Registrable ], (string list * string) Eliom_service.caml_service)
        Eliom_service.service
}}

{shared{
  (** Exception raised in case of invalid extension *)
  exception Invalid_extension
}}

{server{
  (** Create a dynamic service used to upload file dynamically. See
    * also [handler] and [register] *)
  val service : ?name:string -> unit -> dynup_service_t

  (* SUGGESTIONS:
   * - use a value instead of an hard coded string for "static" ? *)

  (** Handler associated to a (dyn_upload) [service]. You have to provide
    * a function which will take [dname] and [fname]. This handler allow
    * you to do some manipulation on the file which will be uploaded
    * dynamically.
    *
    * You can provide some functions to custom the uploaded file. You
    * can set a [timeout], enable the remove of unused file, using
    * [remove_on_timeout]. You can also change the [dir] and
    * provide a function to generate a new filename ([new_filename]).
    *
    * You can also give a list of valid extensions. If a file, does not
    * have a valid extension, and exception of type [Invalid_extension]
    * will be raised.
    * *)
  val handler :
     ?timeout:float
  -> ?remove_on_timeout:bool
  -> ?dir:(string list)
  -> ?new_filename:(unit -> string)
  -> ?extensions:string list
  -> (string list -> string -> unit Lwt.t)
  -> (unit -> Ocsigen_extensions.file_info -> (string list * string) Lwt.t)

  (** Register a dynamic uploader service *)
  val register :
     dynup_service_t
  -> (unit -> Ocsigen_extensions.file_info -> (string list * string) Lwt.t)
  -> unit

  val mark_as_used :
     string
  -> unit Lwt.t
}}

{client{
  (** Retrieve the associated file (on the server)
    * of [file]. It will call your handler with [dname] and [fname]
    * which correspond respectively of the directory of [file] (on the
    * server) and the filename of [file]. *)
  val dyn_upload :
     service:dynup_service_t
  -> file:File.file Js.t
  -> (string list -> string -> unit Lwt.t)
  -> unit Lwt.t
}}
