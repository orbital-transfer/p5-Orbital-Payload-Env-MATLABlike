%{

/*
 * Context-free grammar for the MATCH parser written for
 * bison (GNU Bison version 1.24).
 *
 * Command-line options: --yacc -d -t
 */

#include <stdlib.h>
#include <string.h>

#include "basic.h"
#include "cpp_classes.h"


#define LOOKAHEAD        yychar


statement_t* InputSequence;
int BracketDelimiter = ’\0’;


extern int yylex(void);
extern void yyinsert_comma_in_input(const int);


static void yyerror(const char*);

static const char* FunctionName;


/*
 *   MATLAB’s expression operators fall into three categories:
 *
 *       + Arithmetic operators.
 *       + Relational operators.
 *       + Logical operators.
 *
 *   The precedences documented in the manual appear to be wrong. For
 *   instance, according to the manual, arithmetic operators have the
 *   highest precedence, followed by relational operators, followed by
 *   logical operators. This would mean that the MATLAB interpretor
 *   should consider the token sequence NOT INTEGER ’+’ INTEGER as being
 *   equivalent to NOT ’(’ INTEGER ’+’ INTEGER ’)’, and not as ’(’ NOT
 *   INTEGER ’)’ ’+’ INTEGER. However, the MATLAB interpretor actually
 *   treats the token sequence in the latter manner.
 *
 * The following were the observed precedence levels of operators in
 * the MATLAB 5.0 interpretor, arranged in decreasing order:
 *
 *      1. Power (EPOWER), matrix power (POWER).
 *
 *      2. Transpose (TRANSPOSE),
 *      complex conjugate transpose (CTRANSPOSE).
 *
 *      3. Logical negation (NOT),
 *      unary plus (’+’), unary minus (’-’).
 *
 *      4. Matrix multiplication (’*’), multiplication (EMUL),
 *      matrix division (’/’), division (EDIV),
 *      matrix left division (’\\’), left division (ELEFTDIV).
 *
 *      5. Addition (’+’), subtraction (’-’).
 *
 *      6. Colon operator (’:’).
 *
 *      7. Less than (LTHAN), less than or equal to (LTHANE),
 *      greater than (GTHAN), greater than or equal to (GTHANE),
 *      equal to (EQUAL), not equal to (UNEQUAL).
 *
 *      8. Logical and (AND), logical or (OR).
 *
 * Within each precedence level, operators have left associativity,
 * except for the level 2 and level 3 operators, which are
 * non-associative.
 */

%}


%start input


%token LEXERROR

%token LINE
%token LD RD

%token   FOR
%token   END
%token   IF ELSEIF ELSE
%token   GLOBAL
%token   WHILE

%token FUNCTION
%token RETURN
%union {
           char* text;
           char* symbol;

           int integerQ;
           double doubleQ;
           imaginary_t imaginaryQ;

           struct {
                   int size;
                   char** entries;
                   } variables;

           struct {
                   int size;
                   vector_t** vectors;
                   } rows;

           matrix_t* matrix;

           struct {
                   expr_t* start;
                   expr_t* stride;
                   expr_t* stop;
                   } colon;

           expr_t* expression;

           int delimiter;

           var_expr_t* vexpression;

           struct {
                   int size;
                   expr_t** expressions;
                   } singletons;

           statement_t* statement;

           for_t* forStatement;
           if_t* ifStatement;
           global_t* globalStatement;
           while_t* whileStatement;
           }


%token <text> TEXT
%token <symbol> IDENTIFIER

%token <integerQ> INTEGER
%token <doubleQ> DOUBLE
%token <imaginaryQ> IMAGINARY

%type <statement> input functionMFile scriptMFile

%type <symbol> f_def_line
%type <statement> f_body
%type <vexpression> f_output f_input f_argument_list

%type <statement> delimited_input delimited_list
%type <statement> statement_list
%type <statement> statement

%type   <statement>   command_form
%type   <statement>   for_command for_cmd_list
%type   <statement>   if_command if_cmd_list opt_else
%type   <statement>   global_command
%type   <statement>   while_command while_cmd_list
%type   <statement>   return_command

%type <expression> expr reference identifier
%type <colon> colon_expr
%type <expression> assignment

%type <delimiter> parenthesis boxes1 boxes2

%type <vexpression> argument_list text_list
%type <vexpression> reference_list

%type <variables> global_decl_list

%type <matrix> matrix s_assignee_matrix m_assignee_matrix

%type <rows> rows

%type <singletons> row row_with_commas


%left AND OR
%left LTHAN LTHANE GTHAN GTHANE EQUAL UNEQUAL
%left ’:’
%left ’-’ ’+’
%left ’*’ EMUL ’/’ EDIV ’\\’ ELEFTDIV
%nonassoc NOT UNARYPLUS UNARYMINUS
%nonassoc TRANSPOSE CTRANSPOSE
%left EPOWER POWER


%%


input                      : scriptMFile
                      {
                        $$ = InputSequence = $1;
                        }
                      | functionMFile
                      {
                        $$ = InputSequence = $1;
                        }
                      | parse_error
                      {
                        $$ = InputSequence = NULL;
                        }
                      ;


scriptMFile           : opt_delimiter
                      {
                        FunctionName = "__main__";
                        cpp_function(FunctionName, 0, 0, 0);

                        $$ = 0;
                        }
                      | opt_delimiter statement_list
                      {
                        FunctionName = "__main__";
                        cpp_function(FunctionName, $2, 0, 0);

                          $$ = $2;
                          }
                      ;


opt_delimiter         :
                      | delimiter
                      ;


delimiter             : null_lines
                      | empty_lines
                      | null_lines empty_lines
                      ;


null_lines            : null_line
                      | null_lines null_line
                      ;


null_line             :   ’,’
                      |   ’;’
                      |   empty_lines ’,’
                      |   empty_lines ’;’
                      ;


empty_lines           : LINE
                      | empty_lines LINE
                      ;


statement_list        : statement opt_delimiter
                      {
                        $$ = $1;
                        }
                      | statement delimiter statement_list
                      {
                        STATEMENT_NEXT($1) = $3;
                        STATEMENT_PREV($3) = $1;

                          $$ = $1;
                          }
                      ;


statement             : command_form
                      {
                        $$ = $1;
                        }
                      | expr
                      {
                        statement_t* const statement =
                        alloc_statement_t(EXPRESSIONstatement);

                          STATEMENT_EXPR(statement) = $1;

                          EXPR_PARENT_STATEMENT($1) = statement;

                        $$ = statement;
                        }
                      | assignment
                      {
                        statement_t* const statement =
                        alloc_statement_t(EXPRESSIONstatement);

                          STATEMENT_EXPR(statement) = $1;

                          EXPR_PARENT_STATEMENT($1) = statement;

                        $$ = statement;
                        }
                      | for_command
                      {
                        $$ = $1;
                        }
                      | if_command
                      {
                        $$ = $1;
                        }
                      | global_command
                      {
                        $$ = $1;
                        }
                      | while_command
                      {
                        $$ = $1;
                        }
                      | return_command
                      {
                        $$ = $1;
                        }
                      ;


command_form          : identifier text_list
                      {
                        statement_t* const statement =
                        alloc_statement_t(EXPRESSIONstatement);

                          expr_t* const expr =
                          build_expr_nary_op(FUNCTIONARRAYexpr,
                          $1, $2);

                          STATEMENT_EXPR(statement) = expr;

                          EXPR_PARENT_STATEMENT(expr) = statement;

                          $$ = statement;

                          dealloc_var_expr_t_list($2);
                          }
                      ;


text_list             : TEXT
                      {
                        expr_t* expr;

                          if (strlen((const char*)$1) == 1)
                             expr = build_expr_ATOM(
                             build_atom_CHARACTER(*($1)));
                          else
                             expr = build_expr_ATOM(
                             build_atom_STRING($1));
                        $$ =
                        alloc_var_expr_t(expr);
                        }
                      | text_list TEXT
                      {
                        expr_t* expr;

                          if (strlen((const char*)$2) == 1)
                             expr = build_expr_ATOM(
                             build_atom_CHARACTER(*($2)));
                          else
                             expr = build_expr_ATOM(
                             build_atom_STRING($2));

                          VAR_EXPR_NEXT($1) =
                          alloc_var_expr_t(expr);

                          VAR_EXPR_PREV(VAR_EXPR_NEXT($1)) = $1;

                          $$ = $1;
                          }
                      ;


expr                  : INTEGER
                      {
                        $$ =
                        build_expr_ATOM(build_atom_INTEGER($1));
                        }
                      | DOUBLE
                      {
                        yyinsert_comma_in_input(DOUBLE);

                        $$ =
                        build_expr_ATOM(build_atom_DOUBLE($1));
                        }
                      | IMAGINARY
                      {
                        yyinsert_comma_in_input(IMAGINARY);

                        $$ =
                        build_expr_ATOM(build_atom_IMAGINARY($1));
                        }
                      | TEXT
                      {
                        expr_t* expr;

                          if (strlen((const char*)$1) == 1)
                             expr = build_expr_ATOM(
                             build_atom_CHARACTER(*($1)));
                          else
                          expr = build_expr_ATOM(
                          build_atom_STRING($1));

                       yyinsert_comma_in_input(TEXT);

                        $$ = expr;
                        }
                      | ’(’ parenthesis expr
                      {
                        BracketDelimiter = $2;
                        } ’)’
                      {
                        yyinsert_comma_in_input(’)’);

                        $$ = $3;
                        }
                      | reference
                      {
                        $$ = $1;
                        }
                      | matrix
                      {
                        $$ =
                        build_expr_MATRIX($1);
                        }
                      | expr EPOWER expr
                      {
                        $$ =
                        build_expr_binary_op(EPOWERexpr, $1, $3);
                        }
                      | expr POWER expr
                      {
                        $$ =
                        build_expr_binary_op(BIPOWERexpr, $1, $3);
                        }
                      | expr TRANSPOSE
                      {
                        yyinsert_comma_in_input(TRANSPOSE);

                        $$ =
                        build_expr_unary_op(TRANSPOSEexpr, $1);
                        }
                      | expr CTRANSPOSE
                      {
                        yyinsert_comma_in_input(CTRANSPOSE);

                        $$ =
                        build_expr_unary_op(CTRANSPOSEexpr, $1);
                        }
                      | NOT expr
                      {
                        $$ =
                        build_expr_unary_op(NOTexpr, $2);
                        }
                      | ’+’ expr %prec UNARYPLUS
                      {
                        $$ =
                        build_expr_unary_op(UNARYPLUSexpr, $2);
                        }
                      | ’-’ expr %prec UNARYMINUS
                      {
                        $$ =
                        build_expr_unary_op(UNARYMINUSexpr, $2);
                        }
                      | expr ’*’ expr
                      {
                        $$ =
                        build_expr_binary_op(BIMULexpr, $1, $3);
                        }
                      | expr ’/’ expr
                      {
                        $$ =
                        build_expr_binary_op(BIDIVexpr, $1, $3);
                        }
                      | expr ’\\’ expr
                      {
                        $$ =
                        build_expr_binary_op(BILEFTDIVexpr, $1, $3);
                        }
                      | expr EMUL expr
                      {
                        $$ =
                        build_expr_binary_op(EMULexpr, $1, $3);
                        }
                      | expr EDIV expr
                      {
                        $$ =
                        build_expr_binary_op(EDIVexpr, $1, $3);
                        }
                      | expr ELEFTDIV expr
                      {
                        $$ =
                        build_expr_binary_op(ELEFTDIVexpr, $1, $3);
                        }
                      | expr ’+’ expr
                      {
                        $$ =
                        build_expr_binary_op(BIPLUSexpr, $1, $3);
                        }
                      | expr ’-’ expr
                      {
                        $$ =
                        build_expr_binary_op(BIMINUSexpr, $1, $3);
                        }
                      | colon_expr
                      {
                        $$ =
                        build_expr_ternary_op(COLONexpr,
                        $1.start, $1.stride, $1.stop);
                        }
                      | expr LTHAN expr
                      {
                        $$ =
                        build_expr_binary_op(LTHANexpr, $1, $3);
                        }
                      | expr LTHANE expr
                      {
                        $$ =
                        build_expr_binary_op(LTHANEexpr, $1, $3);
                        }
                      | expr GTHAN expr
                      {
                        $$ =
                        build_expr_binary_op(GTHANexpr, $1, $3);
                        }
                      | expr GTHANE expr
                      {
                        $$ =
                        build_expr_binary_op(GTHANEexpr, $1, $3);
                        }
                      | expr EQUAL expr
                      {
                        $$ =
                        build_expr_binary_op(EQUALexpr, $1, $3);
                        }
                      | expr UNEQUAL expr
                      {
                        $$ =
                        build_expr_binary_op(UNEQUALexpr, $1, $3);
                        }
                      | expr AND expr
                      {
                        $$ =
                        build_expr_binary_op(ANDexpr, $1, $3);
                        }
                      | expr OR expr
                      {
                        $$ =
                        build_expr_binary_op(ORexpr, $1, $3);
                        }
                      ;
parenthesis           :
                      {
                          $$ = BracketDelimiter;

                          BracketDelimiter = ’(’;
                          }
                      ;


reference             : identifier
                      {
                        $$ = $1;
                        }
                      | identifier ’(’ parenthesis argument_list
                      {
                        BracketDelimiter = $3;
                        } ’)’
                      {
                        yyinsert_comma_in_input(’)’);

                          $$ =
                          build_expr_nary_op(FUNCTIONARRAYexpr,
                          $1, $4);

                          dealloc_var_expr_t_list($4);
                          }
                      ;


identifier            : IDENTIFIER
                      {
                        $$ =
                        build_expr_ATOM(build_atom_VARIABLE($1));
                        }
                      ;


argument_list         : ’:’
                      {
                        $$ =
                        alloc_var_expr_t(build_expr_ATOM(
                        build_atom_COLON()));
                        }
                      | expr
                      {
                        $$ =
                        alloc_var_expr_t($1);
                        }
                      | ’:’ ’,’ argument_list
                      {
                        var_expr_t* const varExpr =
                          alloc_var_expr_t(build_expr_ATOM(
                          build_atom_COLON()));

                          VAR_EXPR_NEXT(varExpr) = $3;
                          VAR_EXPR_PREV($3) = varExpr;

                        $$ = varExpr;
                        }
                      | expr ’,’ argument_list
                      {
                        var_expr_t* const varExpr =
                        alloc_var_expr_t($1);

                          VAR_EXPR_NEXT(varExpr) = $3;
                          VAR_EXPR_PREV($3) = varExpr;

                          $$ = varExpr;
                          }
                      ;


matrix                : ’[’ boxes1 rows
                      {
                        BracketDelimiter = $2;
                        } ’]’
                      {
                        yyinsert_comma_in_input(’]’);

                          $$ =
                          build_matrix_t($3.size, $3.vectors);
                          }
                      ;


boxes1                :
                      {
                          $$ = BracketDelimiter;

                          BracketDelimiter = ’[’;
                          }
                      ;


rows                  :
                      {
                          $$.vectors = 0;

                        $$.size = 0;
                        }
                      | row
                      {
                            $$.vectors = (vector_t**)
                            alloc_pointers(1);

                            $$.size = 1;

                          *($$.vectors+$$.size-1) =
                          build_vector_t($1.size, $1.expressions);
                          }
                        | rows ’;’
                        {
                          $$ = $1;
                          }
                        | rows ’;’ row
                        {
                          $$.vectors = (vector_t**)
                          realloc_pointers((void*)$1.vectors,
                          $1.size+1);

                            $$.size = $1.size+1;

                          *($$.vectors+$$.size-1) =
                          build_vector_t($3.size, $3.expressions);
                          }
                        | rows LINE
                        {
                          $$ = $1;
                          }
                        | rows LINE row
                        {
                          $$.vectors = (vector_t**)
                          realloc_pointers((void*)$1.vectors,
                          $1.size+1);

                            $$.size = $1.size+1;

                            *($$.vectors+$$.size-1) =
                            build_vector_t($3.size, $3.expressions);
                            }
                        ;


row                     : expr
                        {
                          $$.expressions = (expr_t**)
                          alloc_pointers(1);

                            $$.size = 1;

                         *($$.expressions+$$.size-1) = $1;
                         }
                        | row_with_commas
                      {
                        $$ = $1;
                        }
                      | row_with_commas expr
                      {
                        $$.expressions = (expr_t**)
                        realloc_pointers((void*)$1.expressions,
                        $1.size+1);

                          $$.size = $1.size+1;

                          *($$.expressions+$$.size-1) = $2;
                          }
                      ;


row_with_commas       : expr ’,’
                      {
                        $$.expressions = (expr_t**)
                        alloc_pointers(1);

                          $$.size = 1;

                        *($$.expressions+$$.size-1) = $1;
                        }
                      | row_with_commas expr ’,’
                      {
                        $$.expressions = (expr_t**)
                        realloc_pointers((void*)$1.expressions,
                        $1.size+1);

                          $$.size = $1.size+1;

                          *($$.expressions+$$.size-1) = $2;
                          }
                      ;


colon_expr            : expr ’:’ expr
                      {
                        $$.start = $1;

                          if (LOOKAHEAD != ’:’)
                             {
                               $$.stride =
                               build_expr_ATOM(build_atom_INTEGER(1));
                               $$.stop = $3;
                               }
                          else
                             {
                               $$.stride = $3;
                              $$.stop = 0;
                              }
                        }
                      | colon_expr ’:’ expr
                      {
                        if ($1.stop)
                           {
                             $$.start =
                             build_expr_ternary_op(COLONexpr,
                             $1.start, $1.stride, $1.stop);

                               if (LOOKAHEAD != ’:’)
                                  {
                                   $$.stride =
                                   build_expr_ATOM(
                                   build_atom_INTEGER(1));
                                   $$.stop = $3;
                                   }
                               else
                                  {
                                   $$.stride = $3;
                                   $$.stop = 0;
                                   }
                               }
                          else
                             {
                               $$.start = $1.start;
                               $$.stride = $1.stride;
                               $$.stop = $3;
                               }
                          }
                      ;


assignment            : reference ’=’ expr
                      {
                        $$ =
                        build_expr_binary_op(ASSIGNMENTexpr, $1, $3);
                        }
                      | s_assignee_matrix ’=’ expr
                      {
                        $$ =
                        build_expr_binary_op(ASSIGNMENTexpr,
                        build_expr_MATRIX($1), $3);
                        }
                      | m_assignee_matrix ’=’ reference
                      {
                        $$ =
                        build_expr_binary_op(ASSIGNMENTexpr,
                        build_expr_MATRIX($1), $3);
                        }
                      ;


s_assignee_matrix     : LD boxes2 reference
                      {
                        BracketDelimiter = $2;
                        } RD
                      {
                        expr_t** const singletons = (expr_t**)
                        alloc_pointers(1);

                          *singletons = $3;

                          vector_t** const vectors = (vector_t**)
                          alloc_pointers(1);

                          vectors[0] =
                          build_vector_t(1, singletons);

                          $$ =
                          build_matrix_t(1, vectors);
                          }
                      ;


m_assignee_matrix     : LD boxes2 reference ’,’ reference_list
                      {
                        BracketDelimiter = $2;
                        } RD
                      {
                        var_expr_t* varExpr;
                        int length;

                          for (length = 1, varExpr = $5;
                          VAR_EXPR_NEXT(varExpr);
                          length++, SET_TO_NEXT(varExpr));

                          expr_t** const singletons = (expr_t**)
                          alloc_pointers(length+1);

                          *singletons = $3;

                          for (length = 1, varExpr = $5;
                          VAR_EXPR_NEXT(varExpr);
                          length++, SET_TO_NEXT(varExpr))
                          *(singletons+length) =
                           VAR_EXPR_DATA(varExpr);

                          *(singletons+length) =
                           VAR_EXPR_DATA(varExpr);
                          vector_t** const vectors = (vector_t**)
                          alloc_pointers(1);

                          *vectors =
                          build_vector_t(length+1, singletons);

                          $$ =
                          build_matrix_t(1, vectors);

                          dealloc_var_expr_t_list($5);
                          }
                      ;


boxes2                :
                      {
                          $$ = BracketDelimiter;

                          BracketDelimiter = LD;
                          }
                      ;


reference_list        : reference
                      {
                        $$ =
                        alloc_var_expr_t($1);
                        }
                      | reference ’,’ reference_list
                      {
                        var_expr_t* const varExpr =
                        alloc_var_expr_t($1);

                          VAR_EXPR_NEXT(varExpr) = $3;
                          VAR_EXPR_PREV($3) = varExpr;

                          $$ = varExpr;
                          }
                      ;


for_command           : FOR for_cmd_list END
                      {
                        $$ = $2;
                        }
                      ;


for_cmd_list          : identifier ’=’ expr delimited_input
                      {
                        statement_t* const statement =
                          alloc_statement_t(FORstatement);

                          for_t* const forSt =
                          alloc_for_t();

                          STATEMENT_FOR(statement) = forSt;

                          FOR_VARIABLE(forSt) = $1;
                          FOR_EXPRESSION(forSt) =
                          build_expr_binary_op(ASSIGNMENTexpr, $1, $3);

                          FOR_PARENT(forSt) = statement;
                          FOR_BODY(forSt) = $4;

                          set_owner_of_list(statement, $4);

                          EXPR_PARENT_STATEMENT(FOR_EXPRESSION(forSt)) =
                          statement;

                          $$ = statement;
                          }
                      ;


if_command            : IF if_cmd_list END
                      {
                        $$ = $2;
                        }
                      ;


if_cmd_list           : expr delimited_input opt_else
                      {
                        statement_t* const statement =
                        alloc_statement_t(IFstatement);

                          if_t* const ifSt =
                          alloc_if_t();

                          STATEMENT_IF(statement) = ifSt;

                          IF_CONDITION(ifSt) = $1;
                          IF_PARENT(ifSt) = statement;
                          IF_BODY(ifSt) = $2;

                          IF_ELSE_BODY(ifSt) = $3;

                          set_owner_of_list(statement, $2);
                          set_owner_of_list(statement, $3);

                          EXPR_PARENT_STATEMENT($1) = statement;


                          $$ = statement;
                          }
                      ;


opt_else              :
                      {
                        $$ = 0;
                        }
                      | ELSE delimited_input
                      {
                        $$ = $2;
                        }
                      | ELSEIF expr delimited_input opt_else
                      {
                        statement_t* const statement =
                        alloc_statement_t(IFstatement);

                          if_t* const ifSt =
                          alloc_if_t();

                          STATEMENT_IF(statement) = ifSt;

                          IF_CONDITION(ifSt) = $2;
                          IF_PARENT(ifSt) = statement;
                          IF_BODY(ifSt) = $3;

                          IF_ELSE_BODY(ifSt) = $4;

                          set_owner_of_list(statement, $3);
                          set_owner_of_list(statement, $4);

                          EXPR_PARENT_STATEMENT($2) = statement;

                          $$ = statement;
                          }
                      ;


global_command        : GLOBAL global_decl_list
                      {
                        global_t* const globalSt =
                        alloc_global_t();

                          GLOBAL_LENGTH(globalSt) = $2.size;
                          GLOBAL_ENTRIES(globalSt) = $2.entries;

                          statement_t* const statement =
                          alloc_statement_t(GLOBALstatement);
                          STATEMENT_GLOBAL(statement) = globalSt;
                          GLOBAL_PARENT(globalSt) = statement;

                          $$ = statement;
                          }
                      ;


global_decl_list      : IDENTIFIER
                      {
                        $$.entries = (char**)
                        alloc_pointers(1);

                          $$.size = 1;

                        *($$.entries+$$.size-1) =
                        strcpy(alloc_string(strlen($1)+1), $1);
                        }
                      | global_decl_list IDENTIFIER
                      {
                        $$.entries = (char**)
                        realloc_pointers((void*)($1.entries),
                        $1.size+1);

                          $$.size = $1.size+1;

                          *($$.entries+$$.size-1) =
                          strcpy(alloc_string(strlen($2)+1), $2);
                          }
                      ;


while_command         : WHILE while_cmd_list END
                      {
                        $$ = $2;
                        }
                      ;


while_cmd_list        : expr delimited_input
                      {
                        statement_t* const statement =
                        alloc_statement_t(WHILEstatement);

                          while_t* const whileSt =
                          alloc_while_t();

                          STATEMENT_WHILE(statement) = whileSt;

                          WHILE_CONDITION(whileSt) = $1;
                          WHILE_PARENT(whileSt) = statement;
                          WHILE_BODY(whileSt) = $2;

                          set_owner_of_list(statement, $2);

                          EXPR_PARENT_STATEMENT($1) = statement;

                          $$ = statement;
                          }
                      ;


return_command        : RETURN
                      {
                        statement_t* const statement =
                        alloc_statement_t(RETURNstatement);

                          return_t* const returnSt =
                          alloc_return_t();

                          STATEMENT_RETURN(statement) = returnSt;

                          $$ = statement;
                          }
                      ;


delimited_input       : opt_delimiter
                      {
                        $$ = 0;
                        }
                      | opt_delimiter delimited_list
                      {
                        $$ = $2;
                        }
                      ;


delimited_list        : statement delimiter
                      {
                        $$ = $1;
                        }
                      | statement delimiter delimited_list
                      {
                        STATEMENT_NEXT($1) = $3;
                        STATEMENT_PREV($3) = $1;

                          $$ = $1;
                          }
                      ;
functionMFile         : empty_lines f_def_line f_body
                      {
                        FunctionName = $2;

                        $$ = $3;
                        }
                      | f_def_line f_body
                      {
                        FunctionName = $1;

                          $$ = $2;
                          }
                      ;


f_def_line            : FUNCTION f_output ’=’ IDENTIFIER f_input
                      {
                        extern file* mfile;

                          cpp_set_file(mfile);
                          cpp_function($4, 0, $2, 0);
                          cpp_set_args($5);

                          $$ = $4;

                        dealloc_var_expr_t_list($5);
                        }
                      | FUNCTION IDENTIFIER f_input
                      {
                        extern file* mfile;

                          cpp_set_file(mfile);
                          cpp_function($2, 0, 0, 0);
                          cpp_set_args($3);

                          $$ = $2;

                          dealloc_var_expr_t_list($3);
                          }
                      ;


f_output              : identifier
                      {
                        $$ =
                        alloc_var_expr_t($1);
                        }
                      | LD f_argument_list RD
                      {
                        $$ = $2;
                        }
                      ;


f_input               :
                      {
                        $$ =   0;
                        }
                      | ’(’    ’)’
                      {
                        $$ =   0;
                        }
                      | ’(’    f_argument_list ’)’
                      {
                        $$ =   $2;
                        }
                      ;


f_argument_list       : identifier ’,’ f_argument_list
                      {
                        var_expr_t* const varExpr =
                        alloc_var_expr_t($1);

                          VAR_EXPR_NEXT(varExpr) = $3;
                          VAR_EXPR_PREV($3) = varExpr;

                        $$ = varExpr;
                        }
                      | identifier
                      {
                        $$ =
                        alloc_var_expr_t($1);
                        }
                      ;


f_body                : delimiter statement_list
                      {
                        cpp_set_stmt_list((const statement_t*)$2);

                        $$ = $2;
                        }
                      | opt_delimiter
                      {
                        cpp_set_stmt_list((const statement_t*)0);

                          $$ = 0;
                          }
                      ;
parse_error            : LEXERROR
                       {
                         yyerror("Lexical error!");
                         }
                       | error
                       ;


%%


static void yyerror(const char* message)
{
  extern unsigned int SourceLine;


 DB0(DB_HPM_yacc, "Entering <yyerror> ...\n");

 if (InputFileName)
    fprintf(stderr, "Error in %s around line %u: %s\n",
    InputFileName, SourceLine, message);
 else
    fprintf(stderr, "Error around line %u: %s\n",
    SourceLine, message);

 exit(1);
 }
