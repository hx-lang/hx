/* Parser definition */

%{
(* empty *)
%}

%token EOF
%token TYPE SIG
%token LET IN REC AND OPEN IMPORT
%token IF THEN ELSE
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token VBAR COLON SEMICOLON RARROW BOLDRARROW COMMA DOT
%token EQ LT GT
%token FORALL MU
%token UNDERSCORE AS
%token CAST
%token <string> LIDENT UIDENT OPERATOR
%token <string> INT FLOAT CHAR STRING

%start file
%start parse_datatype

%type <unit> file
%type <unit> parse_datatype

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

/**
 * Start productions
 */
file:
| list(toplevel_binding) EOF
  { () }

parse_datatype:
| datatype EOF
   { $1 }

/**
 * Toplevel rules
 */
toplevel_binding:
| effect_group
  { () }
| toplevel_let_group
  { () }
| type_group
  { () }
| open_module
  { () }
| import_module
  { () }

%inline
recursive_group(identifier, suffix):
| identifier REC? suffix
  { () }
| identifier REC? suffix AND separated_list(AND, suffix)
  { () }

%inline
effect_group:
| recursive_group(SIG, effect_declaration_suffix)
  { () }

effect_declaration_suffix:
| parameterised_constructor_declaration EQ operation_enumeration
  { () }

parameterised_constructor_declaration:
| constructor arg_list(kinded_variable)
  { () }
| constructor
  { () }

operation_enumeration:
| VBAR? separated_list(VBAR, operation_declaration)
  { () }

operation_declaration:
| variable COLON datatype
  { () }

%inline
type_group:
| recursive_group(TYPE, type_declaration_suffix)
  { () }

type_declaration_suffix:
| parameterised_constructor_declaration EQ type_constructor_enumeration
  { () }

type_constructor_enumeration:
| VBAR? separated_list(VBAR, type_constructor_declaration)
  { () }

type_constructor_declaration:
| constructor
  { () }
| constructor arg_list(datatype)
  { () }

toplevel_let_group:
| recursive_group(LET, toplevel_let_binding_suffix)
  { () }

toplevel_let_binding_suffix:
| variable_or_operator COLON datatype EQ expression
  { () }

open_module:
| OPEN qualified_translation_unit_name
  { () }

import_module:
| IMPORT qualified_translation_unit_name
  { () }
| IMPORT qualified_translation_unit_name AS constructor
  { () }

/**
 * Type and effect language
 */

datatype:
| arrow_type
  { () }
| mu_datatype
  { () }

%inline
parenthesised_datatypes:
| parenthesised(separated_list(COMMA, datatype))
  { () }

arrow_type:
| parenthesised_datatypes RARROW effect_annotation datatype
  { () }

effect_annotation:
| delimited(LT, effect_row, GT)
  { () }

effect_row:
| variable VBAR separated_list(COMMA, effect_name)
  { () }
| separated_list(COMMA, effect_name)
  { () }

effect_name:
| type_application_type
  { () }
| constructor
  { () }

mu_datatype:
| MU variable DOT mu_datatype
  { () }
| forall_datatype
  { () }

forall_datatype:
| FORALL separated_nonempty_list(COMMA, kinded_variable) DOT datatype
  { () }
| primary_datatype
  { () }

primary_datatype:
| parenthesised_datatypes
  { (* TODO(dhil): check length to deduce whether to construct a unit, tuple, or singleton. *)
   () }
| type_application_type
  { () }
| record_type
  { () }
| atomic_type
  { () }

%inline
type_application_type:
| constructor_name arg_list(datatype)
  { () }

%inline
record_type:
| parenthesised(separated_nonempty_pair_list(COMMA, label, COLON, arrow_type))
  { () }

atomic_type:
| variable
  { () }
| constructor
  { () }
| UNDERSCORE
  { () }


/**
 * Kind language
 */
kind:
| constructor
  { () }

/**
 * Term language
 */
expression:
| separated_nonempty_list(SEMICOLON, primary_expression)
  { () }

primary_expression:
| TYPE arg_list(kinded_variable) primary_expression
  { () }
| typed_expression
  { () }
| IF primary_expression THEN primary_expression ELSE primary_expression
  { () }
| recursive_group(LET, local_let_binding_suffix) IN primary_expression
  { () }
| LET OPEN qualified_translation_unit_name IN primary_expression
  { () }

typed_expression:
| typed_expression COLON datatype
  { () }
| typed_expression COLON datatype CAST datatype
  { () }
| infix_application_expression
  { () }

infix_application_expression:
| unary_expression
  { () }
| unary_expression OPERATOR
  { () }
| unary_expression OPERATOR infix_application_expression
  { () }

unary_expression:
| OPERATOR unary_expression
  { () }
| postfix_expression
  { () }
| inject_expression
  { () }

postfix_expression:
| atomic_expression
  { () }
| suspended_computation
  { () }
| postfix_expression arg_list(expression)
  { () }
| postfix_expression delimited(LBRACKET, separated_list(COMMA, datatype), RBRACKET)
  { () }
| postfix_expression DOT label
  { () }
| parenthesised(expression)
  { () }

%inline
inject_expression:
| constructor arg_list(expression)
  { () }
| constructor
  { () }

suspended_computation:
| delimited(LBRACE, cases, RBRACE)
  { () }

cases:
| VBAR? separated_list(VBAR, case)
  { () }

case:
| pattern COLON expression
  { () }
| pattern BOLDRARROW value_pattern COLON expression
  { () }

local_let_binding_suffix:
| value_pattern COLON datatype EQ expression
  { () }
| value_pattern EQ expression
  { () }

atomic_expression:
| variable
  { () }
| s = STRING
  { () }
| c = CHAR
  { () }
| f = FLOAT
  { () }
| n = INT
  { () }

/**
 * Pattern language
 */

pattern:
| LPAREN typed_operation_pattern RPAREN
 { () }
| value_pattern
 { () }

typed_operation_pattern:
| operation_pattern COLON datatype
  { () }
| operation_pattern
  { () }

operation_pattern:
| LT constructor arg_list(value_pattern) RARROW value_pattern GT
  { () }
| LT constructor arg_list(value_pattern) BOLDRARROW value_pattern GT
  { () }
| LT constructor arg_list(value_pattern) GT
  { () }
| LT variable GT
  { () }
| LT UNDERSCORE GT
  { () }

value_pattern:
| LPAREN typed_pattern COLON datatype RPAREN
  { () }
| typed_pattern
  { () }

typed_pattern:
| constructor_pattern AS variable
  { () }
| constructor_pattern
  { () }

constructor_pattern:
| constructor
  { () }
| constructor arg_list(value_pattern)
  { () }
| parenthesised_pattern
  { () }
| atomic_pattern
  { () }

parenthesised_pattern:
| parenthesised(record_fields_pattern)
  { (* TODO(dhil): check the length of $1. *)
    () }
| parenthesised(tuple_fields_pattern)
  { () }
| parenthesised(value_pattern)
  { () }

%inline
tuple_fields_pattern:
| separated_pair(value_pattern, COMMA, separated_nonempty_list(COMMA, value_pattern))
  { () }

%inline
record_fields_pattern:
| separated_pair_list(COMMA, label, EQ, value_pattern)
  { () }

atomic_pattern:
| UNDERSCORE
  { () }
| variable
  { () }
| s = STRING
  { () }
| n = INT
  { () }
| f = FLOAT
  { () }
| c = CHAR
  { () }

/**
 * Shared rules
 */
constructor:
| UIDENT
  { () }

constructor_name:
| constructor DOT constructor_name
  { () }
| constructor
  { () }

variable:
| LIDENT { () }

kinded_variable:
| variable COLON kind
  { () }
| variable
  { () }

variable_or_operator:
| variable
  { () }
| op = OPERATOR
  { () }

label:
| n = INT
  { () }
| variable
  { () }

%inline
qualified_translation_unit_name:
| separated_nonempty_list(DOT, constructor)
  { () }
