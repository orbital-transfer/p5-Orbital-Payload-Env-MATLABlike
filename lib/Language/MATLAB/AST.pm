package Language::MATLAB::AST;

use strict;
use warnings;

use Marpa::R2;

sub grammar {
my $grammar = Marpa::R2::Scanless::G->new(
    {   #action_object  => 'My_Nodes',
	#default_action => '::first',
	default_action => '::array',
	#default_action => ['name', 'value'],
	source         => \(<<'END_OF_SOURCE'),

:start ::= Top

:default ::= action => [name, values]
lexeme default = action => [ name, value ]

Top ::=
	  Script_file
	| Function_file

Function_file ::=
	  Function_blocks_all_with_end
	| Function_blocks_no_ends

# TODO what's the difference between a nested and local function?
Function_block_with_end ::= Function_block kw_End Opt_delimiter
Function_blocks_all_with_end ::= Function_block_with_end
Function_blocks_all_with_end ::= Function_block_with_end Function_blocks_all_with_end

Function_blocks_no_ends ::= Function_block Opt_delimiter
Function_blocks_no_ends ::= Function_block Function_blocks_no_ends

Script_file ::= Statement_block

Statement ::=
	  Expression
	| Assign_lhs Op_assign Expression  # assignment (NOTE: is not an expression)
	| If_block
	| While_block
	| For_block
	| Switch_block
	| Try_block
	| Return
	| Break
	| Continue
	| Global_declaration
	| Persistent_declaration

Statement_block ::=  Statement_delim+
Statement_delim ::= Statement delimiter

delimiter ::= Statement_Sep+
Opt_delimiter ::= # empty
Opt_delimiter ::= delimiter

Break ::= kw_Break
Continue ::= kw_Continue
Return ::= kw_Return

Persistent_declaration ::= kw_Persistent Declaration_list
Global_declaration ::= kw_Global Declaration_list
Declaration_list ::= identifier
Declaration_list ::= identifier Declaration_list

Opt_Statement_block ::= # empty
Opt_Statement_block ::= Statement_block

If_block ::= kw_If Expression Opt_delimiter Opt_Statement_block Opt_else kw_End
Opt_else ::= # empty
Opt_else ::= kw_Else Opt_delimiter Opt_Statement_block
Opt_else ::= kw_Elseif Expression Opt_delimiter Opt_Statement_block Opt_else

While_block ::= kw_While Expression Opt_delimiter Opt_Statement_block kw_End

For_block ::= kw_For identifier Op_assign Expression Opt_delimiter Opt_Statement_block kw_End

Switch_block ::= kw_Switch Expression Opt_delimiter Opt_Cases Opt_Otherwise kw_End
Opt_Cases ::= # empty
Opt_Cases ::= Case_block Opt_Cases
Case_block ::= kw_Case Expression Opt_delimiter Opt_Statement_block
Opt_Otherwise ::= # empty
Opt_Otherwise ::= kw_Otherwise Opt_delimiter Opt_Statement_block

# Function_block can contain nested Function_block's (via Statement_block)
#
# TODO: need to handle the optional end
#
# From <http://www.mathworks.com/help/matlab/ref/function.html>
# > Files can include multiple local functions or nested functions. Use the end
# > keyword to indicate the end of each function in a file if:
# >   - Any function in the file contains a nested function
# >   - Any local function in the file uses the end keyword
# > Otherwise, the end keyword is optional.
Function_block ::= kw_Function Func_Output identifier Func_Arg Opt_delimiter Opt_Statement_block

Assign_lhs ::= Assign_item_no_sq
Assign_lhs ::= Op_lsquare Assign_list_opt_comma Op_rsquare
Assign_lhs ::= Assign_list_req_comma
Assign_item_no_sq ::= identifier
Assign_item_no_sq ::= Struct_Field_Access
Assign_item_in_sq ::=
	  Assign_item_no_sq
	| Op_null_id #  must be in a [ ]
Assign_list_opt_comma ::= Assign_item_in_sq
Assign_list_opt_comma ::= Assign_item_in_sq Op_comma Assign_list_opt_comma
Assign_list_opt_comma ::= Assign_item_in_sq Assign_list_opt_comma
Assign_list_req_comma ::= Assign_item_no_sq
Assign_list_req_comma ::= Assign_item_no_sq Op_comma Assign_list_req_comma

Func_Output ::= # empty
Func_Output ::=  identifier Op_assign
Func_Output ::=  Op_lsquare Func_Output_list Op_rsquare Op_assign
# # empty
# [ a, b, c ] =
# a =
Func_Output_list ::= identifier
Func_Output_list ::= identifier Op_comma Func_Output_list
Func_Output_list ::= identifier Func_Output_list

Func_Arg_item ::= identifier
Func_Arg_item ::= Op_null_id
Func_Arg_list ::= Func_Arg_item
Func_Arg_list ::= Func_Arg_item Op_comma Func_Arg_list
Func_Arg ::= # empty
Func_Arg ::= Op_lparen Op_rparen # ()
Func_Arg ::= Op_lparen Func_Arg_list Op_rparen
# (a)
# (a, b)
# (varargin)

# TODO
# command form for function calls:
# e.g.,
# disp   example output % same as: disp('example', 'output')
#Command ::= identifier Command_Arg_First Command_Args
#Command_Arg_First  ::= [^;,=]+ # TODO probably wrong
#Command_Arg_Rest  ::= [^;,]+   # TODO probably wrong
#Command_Args ::= # empty
#Command_Args ::= Command_Arg_Rest Command_Args

Try_block ::= kw_Try Opt_delimiter Opt_Statement_block kw_Catch Opt_Exception_Object Opt_delimiter Opt_Statement_block kw_End
Opt_Exception_Object ::= # empty
Opt_Exception_Object ::= identifier

## Keywords
kw_For        ~ 'for'
:lexeme ~ <kw_For> priority => 1
kw_End        ~ 'end'
:lexeme ~ <kw_End> priority => 1
kw_If         ~ 'if'
:lexeme ~ <kw_If> priority => 1
kw_While      ~ 'while'
:lexeme ~ <kw_While> priority => 1
kw_Function   ~ 'function'
:lexeme ~ <kw_Function> priority => 1
kw_Return     ~ 'return'
:lexeme ~ <kw_Return> priority => 1
kw_Elseif     ~ 'elseif'
:lexeme ~ <kw_Elseif> priority => 1
kw_Case       ~ 'case'
:lexeme ~ <kw_Case> priority => 1
kw_Otherwise  ~ 'otherwise'
:lexeme ~ <kw_Otherwise> priority => 1
kw_Switch     ~ 'switch'
:lexeme ~ <kw_Switch> priority => 1
kw_Continue   ~ 'continue'
:lexeme ~ <kw_Continue> priority => 1
kw_Else       ~ 'else'
:lexeme ~ <kw_Else> priority => 1
kw_Try        ~ 'try'
:lexeme ~ <kw_Try> priority => 1
kw_Catch      ~ 'catch'
:lexeme ~ <kw_Catch> priority => 1
kw_Global     ~ 'global'
:lexeme ~ <kw_Global> priority => 1
kw_Persistent ~ 'persistent'
:lexeme ~ <kw_Persistent> priority => 1
kw_Break      ~ 'break'
:lexeme ~ <kw_Break> priority => 1

Struct_Field_Access ::= Expression Op_struct_field_access identifier # TODO check this

# precedence from <http://www.mathworks.com/help/matlab/matlab_prog/operator-precedence.html>
Expression ::=
	   Number
	 | identifier
	 | Matrix
	 | Indexing
#	 | Command
	 | String
	 | (Op_lparen) Expression (Op_rparen) assoc => group
	 | Struct_Field_Access
	|| Expression Op_mpower Expression   assoc => left
	 | Expression Op_epower Expression
	 | Expression Op_transpose
	 | Expression Op_ctranspose
	|| Op_not Expression
	 | Unary_Sign Expression
	|| Expression Op_mmult Expression    assoc => left
	 | Expression Op_emult Expression
	 | Expression Op_mdiv Expression
	 | Expression Op_ediv Expression
	 | Expression Op_mldiv Expression
	 | Expression Op_eldiv Expression
	|| Expression Op_plus Expression    assoc => left
	 | Expression Op_minus Expression
	|| Expression Op_colon Expression 
	 | Expression Op_colon Expression Op_colon Expression
	|| Expression Op_lt Expression      assoc => left
	 | Expression Op_le Expression
	 | Expression Op_gt Expression
	 | Expression Op_ge Expression
	 | Expression Op_eq Expression
	 | Expression Op_ne Expression
	|| Expression Op_eand Expression
	|| Expression Op_eor Expression
	|| Expression Op_sand Expression
	|| Expression Op_sor Expression

# TODO this is more complicated
Matrix ::= Op_lsquare Op_rsquare
Matrix ::= Op_lsquare Expression_space Op_rsquare
Expression_space ::= Expression
Expression_space ::= Expression Expression_space

# indexing and function calls are the same at parse-time
Indexing ::=
	identifier Op_lparen Opt_Indexing_Expression_with_comma_sep Op_rparen

Indexing_Expression ::=
	  Expression
	| Op_colon

Opt_Indexing_Expression_with_comma_sep ::= # empty
Opt_Indexing_Expression_with_comma_sep ::= Indexing_Expression_with_comma_sep
Indexing_Expression_with_comma_sep ::=
	  Indexing_Expression
	| Indexing_Expression Op_comma Indexing_Expression_with_comma_sep


#Op_ellipsis ~ '...' # TODO line continuation

Op_lparen ~ [(]
Op_rparen ~ [)]

# Op_starstar ~ [*][*] # Octave supports ** for exponentiation, but MATLAB does not
Op_mpower ~ [\^]
Op_epower ~ [.][\^]
Op_ctranspose ~ [']
Op_transpose ~ [.][']
Op_plus ~ [+]
Op_minus ~ [-]
Op_mmult ~ [*]
Op_emult ~ [.][*]
Op_mdiv ~ [/]
Op_ediv ~ [.][/]
Op_mldiv ~ [\\]
Op_eldiv ~ [.][\\]
Op_colon ~ [:]

Op_lt ~ [<]
Op_le ~ [<][=]
Op_gt ~ [>]
Op_ge ~ [>][=]
Op_eq ~ [=][=]
Op_ne ~ [~][=]

Op_eand ~ [&]
Op_eor ~ [|]
Op_sand ~ [&][&]
Op_sor ~ [|][|]

Op_not ~ [~]
Op_null_id ~ [~]

Op_assign ~ [=]

Op_comma ~ [,]
Op_lsquare ~ '['
Op_rsquare ~ ']'

Op_string_delim ~ [']

Op_struct_field_access ~ [.]

Unary_Sign ~ [+-]

#Optional_Unary_Sign ~ Unary_Sign
#Optional_Unary_Sign ~ # empty

Number ~ RealNumber | ImaginaryNumber

String_Unit ~ [^']
String_Unit ~ [']['] # two single quotes next to each other
String_Units ~ # empty
String_Units ~ String_Unit String_Units
String ~ Op_string_delim String_Units Op_string_delim

RealNumber ~ Integer | Float

Optional_RealNumber ~ RealNumber
Optional_RealNumber ~ # empty

ImaginaryNumber ~ Optional_RealNumber ImaginaryUnit
ImaginaryUnit ~  [ij]

Integer ~ digits

Exponent ~ [DdEe] optional_sign digits

Optional_Exponent ~ Exponent
Optional_Exponent ~ # empty

Mantissa ~ digits decimal | optional_digits decimal digits


Float ~ Mantissa Optional_Exponent
Float ~ Integer Exponent

optional_sign ~ sign
optional_sign ~ # empty
sign ~ [+-]

optional_digits ~ digits
optional_digits ~ # empty
digits ~ [\d]+

decimal ~ [.]

Semicolon ~ [;]
Comma ~ [,]
Newline ~ [\n]

Opt_Newlines ~ Newline*

:lexeme ~ <identifier>   priority => -1
identifier ~ [a-zA-Z] id_rest
id_rest    ~ [_a-zA-Z0-9]*


Statement_Sep ~ Semicolon Opt_Newlines | Comma Opt_Newlines | Newline Opt_Newlines

:discard ~ whitespace
whitespace ~ [ \t]+
END_OF_SOURCE
    }
);
	return $grammar;
}



sub My_Nodes::new { return {}; }

sub My_Nodes::do_add {
    my ( undef, $t1, undef, $t2 ) = @_;
    return $t1 + $t2;
}

sub My_Nodes::do_multiply {
    my ( undef, $t1, undef, $t2 ) = @_;
    return $t1 * $t2;
}

1;
# ABSTRACT: Grammar for the MATLAB language.

=pod

=head1 SYNOPSIS

  use My::Package; # TODO

  print My::Package->new;

=head1 DESCRIPTION

TODO

=cut
