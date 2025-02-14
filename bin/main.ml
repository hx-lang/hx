let () =
  let open Hx.Libhx.Text in
  let buf = Lexing.from_channel stdin in
  Sys.catch_break true;
  Printf.printf "Welcome to HX. Press Enter+CTRL-D to finish input. Press CTRL-C to exit.\n%!";
  (try
     let rec loop () =
       let (lexer, get_trace) = Lexer.make_tracing () in
       (try
          Printf.printf "> %!";
          Parser.hx_file lexer buf;
          Printf.printf "OK!\n%!"
        with
        | Lexer.Error s ->
           Printf.fprintf stderr "lexer error: %s\n%!" s
        | Parser.Error ->
           Printf.fprintf stderr "error: parse error\n%!");
       Printf.printf "Token stream: %s\n%!" (String.concat " " (List.map Lexer.string_of_token (get_trace ())));
       loop ()
    in
    loop ()
  with Sys.Break -> ());
  Printf.fprintf stdout "Bye!\n%!"
