(* Read-Eval-Print loop *)

let ps1 = "hx> "

let evaluate ctxt _code = ctxt

let execute_directive _oc _ctxt _d _payload = ()

module Directive = struct
  type t = Directive of string * string
         | Code of string
         | Noop

  let parse ic = ()
    (* let rec parse ic =
     *   match input_char ic with
     *   | ':' -> parse_directive ic 1 1 (Buffer.create 128) *)
end

let parse_input ic : Directive.t =
  Noop

let rec frepl oc ic ctxt : unit =
  Printf.fprintf oc "\n%s%!" ps1;
  match parse_input ic with
  | Noop ->
     frepl oc ic ctxt
  | Directive ("quit", _) | Directive ("q", _) -> ()
  | Directive (d, payload) ->
     frepl oc ic (execute_directive oc ctxt d payload)
  | Code code ->
     frepl oc ic (evaluate ctxt code)

let repl ctxt : unit
  = frepl stdout stdin ctxt
