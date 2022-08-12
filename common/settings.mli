(* HX compiler settings/options *)

val interacting    : bool ref    (* -i *)
val typecheck_only : bool ref    (* --typecheck-only *)
val compile_only   : bool ref    (* -c *)
val output_name    : string ref  (* -o *)
val no_prelude     : bool ref    (* --no-prelude *)
val optimise_ir    : int ref     (* -O <level:0|1|2|3> *)

type compiler_backend = Native | JavaScript | OCaml
val compiler_backends : compiler_backend list ref (* -b <native|js|ocaml> *)


(* Dump options *)
val dump_ast : bool ref  (* -dast *)
val dump_ir  : bool ref  (* -dir *)
