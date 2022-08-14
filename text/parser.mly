/* Parser definition */

%{
(* empty *)
%}

%token EOF
%token TYPE SIG
%token LET VAL REC AND OPEN IMPORT
%token IF THEN ELSE
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE
%token VBAR COLON SEMICOLON RARROW BOLDRARROW COMMA DOT
%token EQ LT GT
%token FORALL MU
%token UNDERSCORE AS
%token CAST
%token <string> LIDENT UIDENT OPERATOR
%token <string> INT FLOAT CHAR STRING

%start hx_file
%start hxi_file
%start interactive
%start just_datatype

%type <unit> hx_file
%type <unit> hxi_file
%type <unit> interactive
%type <unit> just_datatype

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
hx_file:
| list(toplevel_binding) EOF
  { () }

hxi_file:
| list(toplevel_declaration) EOF
  { () }

interactive:
| interactive_item EOF
  { () }

interactive_item:
| value_declaration
  { () }
| toplevel_binding
  { () }
| expression
  { () }

just_datatype:
| datatype EOF
   { $1 }

/**
 * Toplevel rules
 */
toplevel_binding:
| type_effect_group
  { () }
| toplevel_let_group
  { () }
| open_module
  { () }
| import_module
  { () }

recursive_group_opt(identifier, opt_suffix):
| identifier REC? opt_suffix?
  { () }
| identifier REC? opt_suffix? AND recursive_group_opt(identifier, opt_suffix)
  { () }

%inline
recursive_group(identifier, suffix):
| identifier REC? suffix
  { () }
| identifier REC? suffix AND separated_list(AND, suffix)
  { () }

/* %inline */
/* effect_group: */
/* | recursive_group_opt(SIG, effect_declaration_suffix) */
/*   { () } */

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

recursive_group_2(identifier1, suffix1, identifier2, suffix2):
| identifier1 REC? suffix1?
  { () }
| identifier1 REC? suffix1? AND recursive_group_2(identifier1, suffix1, identifier2, suffix2)
  { () }
| identifier2 REC? suffix2?
  { () }
| identifier2 REC? suffix2? AND recursive_group_2(identifier1, suffix1, identifier2, suffix2)
  { () }

type_effect_group:
| recursive_group_2(TYPE, type_declaration_suffix, SIG, effect_declaration_suffix)
  { () }

/* %inline */
/* type_group: */
/* | recursive_group_opt(TYPE, type_declaration_suffix) */
/*   { () } */

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
| variable_or_operator COLON datatype EQ body_contents
  { () }

open_module:
| OPEN qualified_uident
  { () }

import_module:
| IMPORT qualified_uident
  { () }
| IMPORT qualified_uident AS constructor
  { () }

/* Interface language */
value_declaration:
| VAL variable COLON datatype
  { () }

toplevel_declaration:
| value_declaration
  { () }
| type_effect_group
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
| parenthesised_datatypes RARROW effect_annotated_datatype
  { () }

effect_annotated_datatype:
| effect_annotation datatype
  { () }
| datatype
  { () }

%inline
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
binding:
| recursive_group(LET, local_let_binding_suffix) SEMICOLON
  { () }
| OPEN qualified_uident SEMICOLON
  { () }
| TYPE arg_list(kinded_variable)
  { () }

bindings:
| nonempty_list(binding)
  { () }

body_contents:
| bindings expression
  { () }
| expression
  { () }

expression:
| primary_expression
  { () }

primary_expression:
| typed_expression
  { () }
| IF primary_expression THEN body_contents ELSE body_contents
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
| unary_expression DOT infix_application_expression
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
/* | postfix_expression DOT label */
/*   { () } */
| parenthesised_expression
  { () }

parenthesised_expression:
/* | parenthesised(body_contents) */
/*   { () } */
| parenthesised(separated_list(COMMA, record_or_tuple_field))
    { (* TODO check whether $1 is a singleton *)
      () }

record_or_tuple_field:
| separated_pair(label, EQ, expression)
  { () }
| expression
  { () }

inject_expression:
| constructor arg_list(expression)
  { () }
| constructor
  { () }

suspended_computation:
| delimited(LBRACE, cases, RBRACE)
  { () }

cases:
| VBAR separated_nonempty_list(VBAR, case)
  { () }
| body_contents
  { () }

case:
| parenthesised(separated_list(COMMA, pattern)) COLON body_contents
  { () }
| parenthesised(separated_list(COMMA, pattern)) BOLDRARROW value_pattern COLON body_contents
  { () }

local_let_binding_suffix:
| value_pattern COLON datatype EQ body_contents
  { () }
| value_pattern EQ body_contents
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
| separated_list(COMMA, record_field_pattern)
   { () }
| separated_list(COMMA, record_field_pattern) VBAR atomic_pattern
   { () }

record_field_pattern:
| separated_pair(label, EQ, value_pattern)
  { () }
| label EQ
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

qualified_uident:
| separated_nonempty_list(DOT, constructor)
  { () }

/* qualified_lident: */
/* | qualified_uident COLONCOLON variable */
/*   { () } */
