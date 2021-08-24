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
%token BAR COLON LARROW COMMA BANG
%token EQ LT GT
%token BOOL
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
| LET LIDENT LPAREN separated_list(COMMA, LIDENT) RPAREN EQ exp { () }

exp:
| LET LIDENT LPAREN separated_list(COMMA, LIDENT) RPAREN EQ exp IN exp { () }
| exp LPAREN separated_list(COMMA, exp) RPAREN { () }
| suspended_exp { () }
| LIDENT { () }
| UNIT { () }

suspended_exp:
| LBRACE exp RBRACE { () }
| LBRACE separated_list(COMMA, LIDENT) LARROW exp RBRACE { () }

typ:
| base_type { () }
| typ LARROW comp_typ { () }

comp_typ:
| typ BANG effect_row { () }

base_type:
| LIDENT
  { if $1 = "unit" then () else raise (Invalid_argument "base_type") }

effect_row:
| LBRACE row RBRACE { () }

row:
| row COMMA row_field { () }
| row_field { () }

row_field:
| UIDENT { () }



