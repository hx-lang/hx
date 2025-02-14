/* Parser definition */

%{
    (* empty *)
%}

%token EOF
%token LET TYPE SIG
%token SEMICOLON COMMA COLON COLONCOLON
%token RARROW
%token EQUALS LT GT
%token LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET
%token V_NO_PATTERN
%token <string> IDENT

%start hx_file

%type <unit> hx_file

%%

/**
 * Macros
 */
%inline
parenthesised(prod):
| delimited(LPAREN, prod, RPAREN) { $1 }

%inline
arg_list(arg):
| parenthesised(separated_list(COMMA, arg)) { $1 }

%inline
separated_pair_list(list_sep, fst, pair_sep, snd):
| separated_list(list_sep, separated_pair(fst, pair_sep, snd))
  { $1 }

%inline
separated_nonempty_pair_list(list_sep, fst, pair_sep, snd):
| separated_nonempty_list(list_sep, separated_pair(fst, pair_sep, snd))
  { $1 }

separated_nonempty_list_trailing_cont(SEP, P):
| /* empty */
  { [] }
| SEP
  { [] }
| P SEP separated_nonempty_list_trailing_cont(SEP, P)
  { $1 :: $3 }

separated_nonempty_list_trailing(SEP, P):
| P
  { [$1] }
| P SEP separated_nonempty_list_trailing_cont(SEP, P)
  { $1 :: $3 }

separated_list_trailing_cont(SEP, P):
| /* empty */
 { [] }
| SEP
 { [] }
| P SEP separated_nonempty_list_trailing_cont(SEP, P)
  { $1 :: $3 }

separated_list_trailing(SEP, P):
| /* empty */
  { [] }
| P
  { [$1] }
| P SEP separated_nonempty_list_trailing_cont(SEP, P)
  { $1 :: $3 }

/**
 * Start productions
 */
hx_file:
| xs = list(toplevel_binding) EOF
   { ignore xs }

/**
 * Toplevel language
 */
toplevel_binding:
| LET x = IDENT EQUALS e = expression SEMICOLON
  { ignore x; ignore e }
| LET x = IDENT f = lambda
  { ignore x; ignore f }
| TYPE x = IDENT xs = list(type_var) LBRACE RBRACE (* TODO(dhil): data constructors *)
  { ignore x; ignore xs }
| SIG x = IDENT xs = list(type_var) LBRACE separated_list_trailing(COMMA, operation_decl)  RBRACE
  { ignore x; ignore xs }

/**
 * Type language
 */
type_var:
| x = IDENT
  { ignore x }
| x = IDENT COLONCOLON y = IDENT
  { ignore x; ignore y }

type_:
| ft = function_type
  { ignore ft }
| bt = mode_type
  { ignore bt }

function_type:
| dom = mode_type RARROW cod = function_type
  { ignore dom; ignore cod }
| dom = mode_type RARROW cod = mode_type
  { ignore dom; ignore cod }

mode_type:
| LT x = IDENT GT t = parenthesised_type
  { ignore x; ignore t }
| LBRACKET x = IDENT RBRACKET t = parenthesised_type
  { ignore x; ignore t }
| parenthesised_type
  { $1 }

parenthesised_type:
| LPAREN xs = separated_list(COMMA, type_) RPAREN
  { match xs with
    | [] -> ()
    | [_x] -> ()
    | _xs -> () }
| bt = base_type
  { ignore bt }

base_type:
| x = IDENT
  { ignore x }

/**
 * Signature language
 */
operation_decl:
| x = IDENT COLON ft = function_type
  { ignore x; ignore ft }

/**
 * Expression language
 */
lambda:
| LBRACE separated_nonempty_list_trailing(COMMA, case) RBRACE
   { () }
| LBRACE V_NO_PATTERN e = expression RBRACE
   { ignore e}

case:
| xs = nonempty_list(pattern) RARROW e = expression
   { ignore xs; ignore e }

expression:
| e = let_expression
  { ignore e }
| v = value
  { ignore v }

let_expression:
| LET p = pattern EQUALS e0 = expression SEMICOLON e1 = expression
  { ignore p; ignore e0; ignore e1 }

tuple_expression:
| LPAREN es = separated_list(COMMA, expression) RPAREN
  { ignore es }

value:
| e = tuple_expression
  { ignore e }
| f = lambda
  { ignore f }
| x = IDENT
  { ignore x }

/**
 * Pattern language
 */
pattern:
| p = atomic_pattern
   { ignore p }
| p = tuple_pattern
    { ignore p }

atomic_pattern:
| x = IDENT
  { ignore x }

tuple_pattern:
| LPAREN ps = separated_list(COMMA, pattern) RPAREN
  { ignore ps }
