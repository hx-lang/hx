(* Read-Eval-Print loop *)

let ps1 = "hx> "

let evaluate ctxt _code = ctxt

let execute_directive _ctxt _d _payload = ()

type cmd = Directive of string * string
         | Code of string
         | Noop

let parse_input ic : cmd =
  Noop

let rec frepl oc ic ctxt : unit =
  Printf.fprintf oc "%s%!" ps1;
  match parse_input ic with
  | Noop -> frepl oc ic ctxt
  | Directive ("quit", _) | Directive ("q", _) -> ()
  | Directive (d, payload) ->
     frepl oc ic (execute_directive ctxt d payload)
  | Code code ->
     frepl oc ic (evaluate ctxt code)

let repl ctxt : unit
  = frepl stdout stdin ctxt
