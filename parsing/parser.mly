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
%token BAR COLON SEMICOLON RARROW BOLDRARROW COMMA BANG DOT
%token EQ LT GT
%token BOOL
%token UNDERSCORE AS
%token <string> OPERATOR
%token <string> LIDENT UIDENT
%token <string> INT FLOAT CHAR STRING

%right BOLDRARROW

%start file

%type <unit> file

%%

/**
 * Generic rules
 */
%inline
delimited_list(l,sep,prod,r):
| delimited(l, separated_list(sep, prod), r) { $1 }

param_list:
| delimited_list(LPAREN, COMMA, pattern, RPAREN) { $1 }

deep_param_list:
| param_list { $1 }
| param_list RARROW pattern { $1 }

%inline
arg_list:
| delimited_list(LPAREN, COMMA, exp, RPAREN) { $1 }

%inline
opt_separated_nonempty_list(sep, prod):
| preceded(sep, separated_nonempty_list(sep, prod)) { $1 }
| separated_nonempty_list(sep, prod) { $1 }

%inline
parenthesised(prod):
| delimited(LPAREN, prod, RPAREN) { $1 }

variable:
| LIDENT { () }

constructor:
| UIDENT { () }

/* Main entry */
file:
| mod_item* EOF { () }

/**
 * Structure language
 */
mod_item:
| SIG variable COLON typ { () }
| LET variable deep_param_list EQ exp { () }

/**
 * Expression language
 */
exp:
| SIG variable COLON typ LET variable deep_param_list EQ exp IN exp { () }
| LET pattern EQ exp IN exp { () }
| LET variable deep_param_list EQ exp IN exp { () }
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
| postfix_exp { $1 }

postfix_exp:
| postfix_exp arg_list { () }
| suspended_exp { $1 }

suspended_exp:
| delimited(LBRACE, exp, RBRACE) { $1 }
| delimited(LBRACE, cases, RBRACE) { $1 }
| primary_exp { $1 }

cases:
| preceded(BAR, separated_nonempty_list(BAR, case)) { () }

case:
| separated_pair(deep_param_list, BOLDRARROW, exp) { $1 }

primary_exp:
| atomic_exp { $1 }

atomic_exp:
| parenthesised_exp { $1 }
| variable { () }
| constructor { () }

parenthesised_exp:
| parenthesised(exp) { () }
| record_exp { $1 }

record_exp:
| parenthesised(separated_pair(exp, COMMA, separated_nonempty_list(COMMA, exp))) { () }
| parenthesised(separated_nonempty_list(COMMA, separated_pair(record_label, EQ, exp))) { () }

record_label:
| LIDENT { () }
| num = INT { () }

/**
 * Pattern language
 */
pattern:
| operation_pattern { $1 }
| as_pattern { $1 }

operation_pattern:
| LT label = LIDENT params = param_list RARROW resume = typed_pattern GT { () }
| LT label = LIDENT params = param_list GT { () }

typed_pattern:
| parenthesised(separated_pair(constructor_pattern, COLON, typ)) { () }
| parenthesised(pattern) { $1 }

as_pattern:
| constructor_pattern AS LIDENT { () }
| constructor_pattern { $1 }

constructor_pattern:
| label = constructor args = param_list { () }
| constructor { $1 }
| primary_pattern { $1 }

primary_pattern:
| record_pattern { $1 }
| atomic_pattern { $1 }
| typed_pattern { $1 }

record_pattern:
| parenthesised(separated_pair(pattern, COMMA, separated_nonempty_list(COMMA, pattern))) { () }
| parenthesised(separated_nonempty_list(COMMA, separated_pair(record_label, EQ, pattern))) { () }

atomic_pattern:
| UNDERSCORE { () }
| variable { () }

/**
 * Shared fragment between expression and pattern languages
 */

/**
 * Type language
 */
typ:
| comp_type BOLDRARROW typ { () }
| comp_type { $1 }

comp_type:
| primary_type BANG effect_sig { () }
| primary_type { $1 }

primary_type:
| constructor { $1 }
| constructor parenthesised(separated_list(COMMA, typ)) { $1 }
| base_type { $1 }

base_type:
| UNIT { () }

effect_sig:
| delimited(LBRACE, separated_list(COMMA, effect_field), RBRACE) { $1 }

effect_field:
| variable COLON typ { () }
