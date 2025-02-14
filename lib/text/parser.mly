/* Parser definition */

%{
    (* empty *)
%}

%token EOF
%token LET TYPE SIG
%token SEMICOLON COMMA
%token RARROW
%token EQUALS
%token LBRACE RBRACE LPAREN RPAREN
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

separated_nonempty_list_trailing(SEP, P):
| /* empty */
  { [] }
| SEP
  { [] }
| P SEP separated_nonempty_list_trailing(SEP, P)
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
| TYPE x = IDENT LBRACE V_NO_PATTERN RBRACE (* TODO(dhil): add type parameters and data constructors *)
  { ignore x }
| SIG x = IDENT LBRACE V_NO_PATTERN RBRACE (* TODO(dhil) add type parameters and operations *)
  { ignore x }

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
