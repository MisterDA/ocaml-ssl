module C = Configurator.V1

let default c : C.Pkg_config.package_conf =
  if C.ocaml_config_var_exn c "system" = "macosx" then
    if Sys.is_directory "/usr/local/opt/openssl" then
      { libs = ["-L/usr/local/opt/openssl/lib"]
      ; cflags = ["-I/usr/local/opt/openssl/include"]
      }
    else
      { libs = ["-L/opt/local/lib"]
      ; cflags = ["-I/opt/local/include"]
      }
  else
    { libs   = ["-lssl"; "-lcrypto"]
    ; cflags = []
    }

let () =
  C.main ~name:"ssl" (fun c ->
      let default = default c in
      let conf =
        match C.Pkg_config.get c with
        | None -> default
        | Some pc ->
          begin match (C.Pkg_config.query pc ~package:"openssl") with
            | Some s -> s
            | None -> default
          end
      in
      C.Flags.write_sexp "c_library_flags.sexp" conf.libs;
      C.Flags.write_sexp "c_flags.sexp" conf.cflags)
