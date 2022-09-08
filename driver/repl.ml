(* Read-Eval-Print loop *)

let ps1 = "hx> "

let evaluate ctxt _code = ctxt

let execute_directive _oc _ctxt _d _payload = ()

module Directive = struct
  type t = Directive of string * string
         | UnknownDirective of string
         | Code of string
         | Noop


  let directives =
    [  ("?", (fun _bs -> Directive ("help", "")))
     ; ("q", (fun _bs -> Directive ("quit", "")))
     ; ("quit", (fun _bs -> Directive ("quit", ""))) ]

  open Hx.Common.IO

  let parse_directive bs =
    let len =
      let rec loop bs i =
        if In.Buffer.length bs > i
        then match In.Buffer.nth bs i with
             | ' ' | '\n' | '\t' -> (i-1)
             | _ -> loop bs (i + 1)
        else i
      in loop bs 1
    in
    let directive = In.Buffer.sub_string bs 1 len in
    try
      let f = List.assoc directive directives in
      f bs
    with Not_found -> UnknownDirective directive

  let parse ic =
    let bs = In.read_all_bytes ic in
    if In.Buffer.length bs > 0
    then (match In.Buffer.nth bs 0 with
          | ':' -> parse_directive bs
          | _   -> Code (In.Buffer.to_string bs))
    else Noop
end

let parse_input ic : Directive.t =
  Noop

let rec frepl oc ic ctxt : unit =
  Printf.fprintf oc "\n%s%!" ps1;
  match Directive.parse ic with
  | Noop ->
     frepl oc ic ctxt
  | UnknownDirective d ->
     Printf.fprintf oc "error: unknown directive '%s'\n%!" d;
     frepl oc ic ctxt
  | Directive ("quit", _) -> ()
  | Directive (d, payload) ->
     frepl oc ic (execute_directive oc ctxt d payload)
  | Code code ->
     frepl oc ic (evaluate ctxt code)

let interact ctxt : unit
  = frepl stdout stdin ctxt
