let () =
  let open Hx.Libhx.Text in
  let buf = Lexing.from_channel stdin in
  Sys.catch_break true;
  Printf.printf "Welcome to HX. Press Enter+CTRL-D to finish input. Press CTRL-C to exit.\n%!";
  (try
    let rec loop () =
      (try
         Printf.printf "> %!";
         Parser.hx_file (Lexer.make ()) buf;
         Printf.printf "OK!\n%!"
       with
       | Lexer.Error s ->
          Printf.fprintf stderr "lexer error: %s\n%!" s
       | Parser.Error ->
          Printf.fprintf stderr "error: parse error\n%!");
      loop ()
    in
    loop ()
  with Sys.Break -> ());
  Printf.fprintf stdout "Bye!\n%!"
