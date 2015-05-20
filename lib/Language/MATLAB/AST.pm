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

lexeme default = action => [ name, value ]

Top ::= Statement_block

Statement ::=
	  Expression
	| identifier Op_assign Expression  # assignment (NOTE: is not an expression)
	| If_block
	| While_block
	| For_block
	| Function_block
	| Try_block

Statement_delim ::= Statement delimiter

Statement_block ::=  Statement_delim+

delimiter ::= Statement_Sep+


Keyword ::=
	  kw_For
	| kw_End
	| kw_If
	| kw_While
	| kw_Function
	| kw_Return
	| kw_Elseif
	| kw_Case
	| kw_Otherwise
	| kw_Switch
	| kw_Continue
	| kw_Else
	| kw_Try
	| kw_Catch
	| kw_Global
	| kw_Persistent
	| kw_Break

If_block ::= kw_If Expression delimiter Statement_block kw_End
If_block ::= kw_If Expression delimiter Statement_block Else_block kw_End
If_block ::= kw_If Expression delimiter Statement_block Elseif_block kw_End

Else_block ::= kw_Else Statement_block
Elseif_block ::= kw_Elseif Expression delimiter Statement_block

While_block ::= kw_While Expression delimiter Statement_block kw_End

For_block ::= kw_For Expression Statement_block kw_End

Function_block ::= Func_Return kw_Function Func_Arg Statement_block kw_End

Func_Return ::= # TODO

Func_Arg ::= # TODO

Try_block ::= kw_Try Statement_block kw_Catch Opt_Exception_Object Statement_block kw_End

Opt_Exception_Object ::= # empty
Opt_Exception_Object ::= identifier

kw_For        ~ 'for'
kw_End        ~ 'end'
kw_If         ~ 'if'
kw_While      ~ 'while'
kw_Function   ~ 'function'
kw_Return     ~ 'return'
kw_Elseif     ~ 'elseif'
kw_Case       ~ 'case'
kw_Otherwise  ~ 'otherwise'
kw_Switch     ~ 'switch'
kw_Continue   ~ 'continue'
kw_Else       ~ 'else'
kw_Try        ~ 'try'
kw_Catch      ~ 'catch'
kw_Global     ~ 'global'
kw_Persistent ~ 'persistent'
kw_Break      ~ 'break'


# precedence from <http://www.mathworks.com/help/matlab/matlab_prog/operator-precedence.html>
Expression ::=
	   Number
	 | identifier
	 | Indexing
	 | (Op_lparen) Expression (Op_rparen) assoc => group
	|| Expression Op_mpower Expression   assoc => left
	 | Expression Op_epower Expression
	 | Expression Op_transpose
	 | Expression Op_ctranspose
	|| Op_not Number
	 | Unary_Sign Number
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

# indexing and function calls are the same at parse-time
Indexing ::=
	identifier Op_lparen Indexing_Expression_with_comma_sep Op_rparen

Indexing_Expression ::=
	  Expression
	| Op_colon

Indexing_Expression_with_comma_sep ::=
	  Indexing_Expression
	| Indexing_Expression Op_Comma Indexing_Expression_with_comma_sep

Op_Comma ::= [,]

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

Op_assign ~ [=]

Unary_Sign ~ [+-]

#Optional_Unary_Sign ~ Unary_Sign
#Optional_Unary_Sign ~ # empty

Number ~ RealNumber | ImaginaryNumber

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
