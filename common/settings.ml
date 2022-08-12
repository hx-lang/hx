(* HX compiler settings/options *)

let interacting = ref false    (* -i *)
let typecheck_only = ref false (* --typecheck-only *)
let compile_only = ref false   (* -c *)
let output_name = ref "a.out"  (* -o *)
let no_prelude = ref false      (* --no-prelude *)
let optimise_ir = ref 0        (* -O <level:0|1|2|3> *)

type compiler_backend = Native | JavaScript | OCaml
let compiler_backends : compiler_backend list ref = ref [] (* -b <native|js|ocaml> *)


(* Dump options *)
let dump_ast = ref false (* -dast *)
let dump_ir  = ref false (* -dir *)
