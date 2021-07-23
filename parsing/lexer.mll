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

let column lexbuf =
  let p = lexbuf.lex_curr_p in
  p.pos_cnum - p.pos_bol

let position lexbuf =
  let p = lexbuf.lex_start_p in
  let p' = lexbuf.lex_curr_p in
  let cnum = p.pos_cnum - p.pos_bol in
  let cnum'  = p'.pos_cnum - p'.pos_bol in
  (p.pos_lnum, cnum, cnum' - cnum)

let keywords =
  let keywords = [
      "data", DATA;
      "else", ELSE;
      "let", LET;
      "if", IF;
      "in", IN;
      "then", THEN;
      "sig", SIG;
      "effect", EFFECT
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
let open_com = "/*"
let close_com = "*/"

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

rule read = parse
| whitespace { read lexbuf }
| newline    { next_line lexbuf; read lexbuf }
| '('        { LPAREN }
| ')'        { RPAREN }
| '{'        { LBRACE }
| '}'        { RBRACE }
| '['        { LBRACKET }
| ']'        { RBRACKET }
| '='        { EQ }
| '>'        { GT }
| '<'        { LT }
| ','        { COMMA }
| "()"       { UNIT }
| '_'        { UNDERSCORE }
| '|'        { BAR }
| ':'        { COLON }
| '!'        { BANG }
| "->"       { LARROW }
| integer    { INT (lexeme lexbuf) }
| float      { FLOAT (lexeme lexbuf) }
| char       { let raw = lexeme lexbuf in
               let refined = String.sub raw 1 (String.length raw - 2) in
               CHAR refined }
| '"'        { read_string (Buffer.create 17) lexbuf }
| open_com   { read_comment 0 lexbuf }
| varid      { let raw = lexeme lexbuf in
               try Hashtbl.find keywords raw
               with Not_found -> LIDENT raw }
| conid      { UIDENT (lexeme lexbuf) }
| eof        { EOF }
| _ { raise (Error (lexeme lexbuf)) }

and read_comment nesting = parse
| eof        { raise (Error ("Unterminated comment")) }
| close_com  { if nesting = 0 then read lexbuf else read_comment (nesting - 1) lexbuf }
| open_com   { read_comment (nesting + 1) lexbuf }
| newline    { next_line lexbuf; read_comment nesting lexbuf }
| _          { read_comment nesting lexbuf }

and read_string buf = parse
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
| _                   { raise (Error ("Unexpected character literal")) }


{
  (* Empty *)
}
