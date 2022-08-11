let _ = (* Repl.repl () *)
  let open Hx.Text in
  let ic = open_in "/dev/stdin" in
  let buf = Lexing.from_channel ic in
  (try
     Parser.file Lexer.read buf
   with
   | Lexer.Error s ->
      Printf.fprintf stderr "error: %s\n" s
   | Parser.Error ->
      Printf.fprintf stderr "error: parse error\n");
  close_in ic;
  Printf.fprintf stdout "Bye!\n%!"
