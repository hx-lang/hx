/* Parser definition */

%{
(* empty *)
%}

%token EOF
%token DATA EFFECT SIG
%token LET IN
%token IF THEN ELSE
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token BAR COLON LARROW COMMA BANG
%token EQ LT GT
%token UNIT INT BOOL
%token UNDERSCORE
%token <string> LIDENT UIDENT
%token <string> INT FLOAT CHAR STRING

%start file

%type <unit> file

%%

file:
| mod_item* EOF { () }

mod_item:
| SIG LIDENT COLON typ { () }
| LET LIDENT param_list EQ exp { () }

exp:
| LET LIDENT param_list EQ exp IN exp
| exp LPAREN arg_list RPAREN
| suspended_exp

typ:
| base_type { () }
| typ BANG effect_row { () }
| typ LARROW typ { () }

base_type:
| UNIT { () }

effect_row:
| LBRACE row RBRACE { () }

row:
| row COMMA row_field { () }
| row_field { () }

row_field:
| UIDENT { () }


