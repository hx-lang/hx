/* Parser definition */

%{
(* empty *)
%}

%token EOF
%token DATA
%token LET IN SIG
%token IF THEN ELSE
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token BAR COLON LARROW COMMA
%token EQ LT GT
%token UNIT
%token UNDERSCORE
%token <string> LIDENT UIDENT
%token <string> INT FLOAT CHAR STRING

%start file

%type <unit> file

%%

file:
| EOF      { () }
