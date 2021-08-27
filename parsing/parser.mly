/* Parser definition */

%{
(* empty *)
%}

%token EOF
%token DATA EFFECT SIG
%token LET IN
%token IF THEN ELSE
%token UNIT
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token BAR COLON RARROW COMMA BANG
%token EQ LT GT
%token BOOL
%token UNDERSCORE
%token OPERATOR
%token <string> LIDENT UIDENT
%token <string> INT FLOAT CHAR STRING

%start file

%type <unit> file

%%

/**
 * Generic rules
 */
%inline
delimited_list(l,sep,prod,r):
| delimited(l, separated_list(sep, prod), r) { $1 }

%inline
param_list:
| delimited_list(LPAREN, COMMA, typed_pattern, RPAREN) { $1 }

%inline
arg_list:
| delimited_list(LPAREN, COMMA, exp, RPAREN) { $1 }

%inline
opt_separated_nonempty_list(sep, prod):
| sep separated_nonempty_list(sep, prod) { $2 }
| separated_nonempty_list(sep, prod) { $1 }

/* Main entry */
file:
| mod_item* EOF { () }

/**
 * Structure language
 */
mod_item:
| SIG LIDENT COLON typ { () }
| LET LIDENT param_list EQ exp { () }

/**
 * Expression language
 */
exp:
| SIG LIDENT COLON typ { () }
| LET pattern EQ exp IN exp { () }
| LET LIDENT param_list EQ exp IN exp { () }
| IF exp THEN exp ELSE exp { () }
| typed_exp { $1 }

typed_exp:
| infix_exp COLON typ { $1 }
| infix_exp { $1 }

infix_exp:
| unary_exp { $1 }
| unary_exp OPERATOR { $1 }
| unary_exp OPERATOR infix_exp { () }
| unary_exp LT infix_exp { () }
| unary_exp GT infix_exp { () }

unary_exp:
| OPERATOR unary_exp { () }
| postfix_exp | constructor_exp { $1 }

postfix_exp:
| postfix_exp arg_list { () }
| suspended_exp { $1 }

suspended_exp:
| delimited(LBRACE, exp, RBRACE) { $1 }
| delimited(LBRACE, opt_separated_nonempty_list(BAR, separated_pair(param_list, RARROW, exp)), RBRACE) { $1 }
| primary_exp { $1 }

constructor_exp:
| label = UIDENT args = arg_list { () }
/* | label = UIDENT { () } */

primary_exp:
| atomic_exp { $1 }
| record_exp { $1 }

atomic_exp:
/* | parenthesised_exp { $1 } */
| LIDENT { () }

parenthesised_exp:
| delimited(LPAREN, exp, RPAREN) { $1 }
| record_exp { $1 }

record_exp:
| delimited(LPAREN, separated_pair(exp, COMMA, separated_nonempty_list(COMMA, exp)), RPAREN) { $1 }
| delimited(LPAREN, separated_nonempty_list(COMMA, separated_pair(record_label, EQ, exp)), RPAREN) { $1 }

record_label:
| LIDENT { () }
| num = INT { () }

/**
 * Pattern language
 */
pattern:
| operation_pattern { $1 }
| typed_pattern { $1 }

operation_pattern:
| LT label = LIDENT params = param_list RARROW resume = typed_pattern GT { () }
| LT label = LIDENT params = param_list GT { () }

typed_pattern:
| delimited(LPAREN, separated_pair(constructor_pattern, COLON, typ), RPAREN) { () }
| constructor_pattern { $1 }

constructor_pattern:
| label = UIDENT params = param_list { () }
/* | label = UIDENT { () } */
| parenthesised_pattern { $1 }

parenthesised_pattern:
| delimited(LPAREN, pattern, RPAREN) { $1 }
| record_pattern { $1 }
| atomic_pattern { $1 }

record_pattern:
| delimited(LPAREN, separated_pair(pattern, COMMA, separated_nonempty_list(COMMA, pattern)), RPAREN) { $1 }
| delimited(LPAREN, separated_nonempty_list(COMMA, separated_pair(record_label, EQ, pattern)), RPAREN) { $1 }


atomic_pattern:
| UNDERSCORE { () }
| LIDENT { () }

/**
 * Type language
 */
typ:
| UNIT { () }
