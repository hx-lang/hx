{
open Lexing
open Parser

exception Error of string

let next_line lexbuf =
 let pos = lexbuf.lex_curr_p in
 lexbuf.lex_curr_p <- {
     pos with pos_bol = lexbuf.lex_curr_pos;
              pos_lnum = pos.pos_lnum + 1
   }

(* let column lexbuf =
  let p = lexbuf.lex_curr_p in
  p.pos_cnum - p.pos_bol

let position lexbuf =
  let p = lexbuf.lex_start_p in
  let p' = lexbuf.lex_curr_p in
  let cnum = p.pos_cnum - p.pos_bol in
  let cnum'  = p'.pos_cnum - p'.pos_bol in
  (p.pos_lnum, cnum, cnum' - cnum) *)

let keywords =
  let keywords = [
      "let", LET;
      "sig", SIG;
      "type", TYPE;
    ]
  in
  List.fold_left
    (fun tbl (str, tok) -> Hashtbl.add tbl str tok; tbl)
    (Hashtbl.create 17) keywords
}

(* White space *)
let tab = '\x09'
let space = '\x20'
let linefeed = '\x0a'
let vertab = '\x0b'
let formfeed = '\x0c'
let return = '\x0d'
let newline = linefeed | return linefeed | return | formfeed

(* Comments *)
let comment = "//" [^ '\x0a' '\x0d' '\x0c']*  (newline | eof)
let open_ml_comment = "/*"
let close_ml_comment = "*/"
let sl_comment = "//"

let whitechar = vertab | tab | space
let whitestuff = whitechar | comment
let whitespace = whitestuff+

(* Digits *)
let asc_digit = ['0'-'9']
let digit = asc_digit
let bit = '0' | '1'
let octit = ['0'-'7']
let hexit = digit | ['A'-'F'] | ['a'-'f']

(* Number literals *)
let decimal = digit+
let binary = bit+
let octal = octit+
let hexadecimal = hexit+
let integer = decimal
            | "0b" binary | "0B" binary
            | "0o" octal | "0O" octal
            | "0x" hexadecimal | "0x" hexadecimal
let exponent = ('e' | 'E') ('+' | '-')? decimal
let float = decimal '.' decimal exponent?
          | decimal exponent

(* Character literals *)
let quote = '\x27'
let backslash = '\x5c'
(* TODO: support more escape sequences. *)
let char_esc = 'a' | 'b' | 'f' | 'n' | 'r' | 't' | 'v' | backslash | '"' | quote | '&'
let escape = backslash (char_esc | 'b' binary | 'o' octal | 'x' hexadecimal)
let asc_char = ['A'-'Z' 'a'-'z']
let char = quote (asc_char | space | escape) quote

(* Atoms *)
let asc_symbol = '!' | '#' | '$' | '%' | '&' | '*' | '+' | '.' | '/' | '<' | '=' | '>' | '?' | '@'
	         | backslash | '^' | '|' | '-' | '~' | ':'
let asc_small = ['a'-'z']
let asc_large = ['A'-'Z']
let large = asc_large
let small = asc_small

(* Identifiers *)
let varid = small (small | large | digit | quote)*
let conid = large (small | large | digit | quote)*
let ident = varid | conid

(* Operators *)
let opchar = [ '.' '!' '$' '&' '*' '+' '/' '<' '=' '>' '@' '\\' '^' '-' '|' ]

rule read = parse
| whitespace { read lexbuf }
| newline    { next_line lexbuf; read lexbuf }
| '('        { LPAREN }
| ')'        { RPAREN }
| '{'        { LBRACE }
| '}'        { RBRACE }
| ','        { COMMA }
| ';'        { SEMICOLON }
| "->"       { RARROW }
| "="        { EQUALS }
(* | integer    { INT (lexeme lexbuf) }
| float      { FLOAT (lexeme lexbuf) }
| char       { let raw = lexeme lexbuf in
               let refined = String.sub raw 1 (String.length raw - 2) in
               CHAR refined } *)
| sl_comment  { read_sl_comment lexbuf }
| open_ml_comment   { read_ml_comment 0 lexbuf }
(*| '"'        { read_string (Buffer.create 17) lexbuf }*)
| ident      { let raw = lexeme lexbuf in
               try Hashtbl.find keywords raw
               with Not_found -> IDENT raw }
| eof        { EOF }
| _ { raise (Error (lexeme lexbuf)) }

and read_sl_comment = parse
| eof { EOF }
| newline { next_line lexbuf; read lexbuf }
| _ { read_sl_comment lexbuf }

and read_ml_comment nesting = parse
| eof               { raise (Error ("Unterminated comment")) }
| close_ml_comment  { if nesting = 0 then read lexbuf else read_ml_comment (nesting - 1) lexbuf }
| open_ml_comment   { read_ml_comment (nesting + 1) lexbuf }
| newline           { next_line lexbuf; read_ml_comment nesting lexbuf }
| _                 { read_ml_comment nesting lexbuf }

(*and read_string buf = parse
| eof                 { raise (Error ("Unterminated string")) }
| '"'                 { STRING (Buffer.contents buf) }
| backslash escape    { Buffer.add_string buf (lexeme lexbuf); read_string buf lexbuf }
| backslash           { read_multi_string buf lexbuf; read_string buf lexbuf }
| _                   { Buffer.add_string buf (lexeme lexbuf);
                        read_string buf lexbuf }
and read_multi_string buf = parse
| eof                 { raise (Error ("Unterminated string")) }
| backslash           { () }
| newline             { next_line lexbuf; read_multi_string buf lexbuf }
| whitechar+          { read_multi_string buf lexbuf }
| _                   { raise (Error ("Unexpected character literal")) }*)


{

  let string_of_token = function
    | COMMA -> "COMMA"
    | EQUALS -> "EQUALS"
    | RARROW -> "RARROW"
    | SEMICOLON -> "SEMICOLON"

    | LET -> "LET"
    | SIG -> "SIG"
    | TYPE -> "TYPE"

    | LBRACE -> "LBRACE"
    | RBRACE -> "RBRACE"

    | LPAREN -> "LPAREN"
    | RPAREN -> "RPAREN"

    | IDENT x -> Printf.sprintf "IDENT(%s)" x

    | V_NO_PATTERN -> "V_NO_PATTERN"

    | EOF -> "EOF"

  module StatefulLexer = struct
    type recall_mode = Exp | Pat
    type state =
      | Normal
      | Recall of recall_mode
      | LBrace of int

    type syncat =
      | Pattern
      | Expression
      | Ambiguous

    let syntactic_category = function
      | LET | EQUALS -> Expression
      | _ -> Ambiguous

    let lexer : unit -> lexbuf -> token
      = fun () ->
      let st = ref Normal in
      let buf = ref None in
      let tokq = Queue.create () in
      let rec next lexbuf =
        match !st with
        | Normal ->
           (match read lexbuf with
            | LBRACE ->
               st := LBrace 1;
               LBRACE
            | tok -> tok)
        | Recall mode ->
           (match !buf with
            | Some tok -> (buf := None; tok)
            | None ->
               if Queue.is_empty tokq
               then (st := Normal; next lexbuf)
               else (match (Queue.pop tokq, mode) with
                     | (LBRACE, Exp) -> buf := Some V_NO_PATTERN; LBRACE
                     | (tok, _) -> tok))
        | LBrace n ->
           assert (not (n <= 0));
           let tok = read lexbuf in
           Queue.push tok tokq;
           (match tok with
            | LBRACE ->
               if n = 3 then (st := Recall Exp; V_NO_PATTERN)
               else (st := LBrace (n + 1); next lexbuf)
            | RBRACE ->
               if n = 1 then (st := Recall Exp; V_NO_PATTERN)
               else (st := LBrace (n - 1); next lexbuf)
            | RARROW when n = 1 ->
               st := Recall Pat; next lexbuf
            | _ -> (match syntactic_category tok with
                    | Ambiguous -> next lexbuf
                    | Expression -> st := Recall Exp; V_NO_PATTERN
                    | Pattern -> assert false))
      in
      next
  end

  let make () = StatefulLexer.lexer ()
  let make_logging () =
    let lexer = StatefulLexer.lexer () in
    fun lexbuf ->
    let tok = lexer lexbuf in
    Printf.printf "%s %!" (string_of_token tok); tok
  (* case: {{{f}}} expression
         : {f} -> pattern
         : {{f}} expression
         : {f} x -> pattern
         : {f} x expression
         : x y expression
         : x y -> pattern *)
}
