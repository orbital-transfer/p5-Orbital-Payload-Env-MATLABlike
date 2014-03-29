package MarpaX::MATLAB;

use strict;
use warnings;

use Marpa::R2;

sub grammar {
my $grammar = Marpa::R2::Scanless::G->new(
    {   action_object  => 'My_Nodes',
	#default_action => '::first',
	default_action => '::array',
	source         => \(<<'END_OF_SOURCE'),

:start ::= Top

Top ::=
	  Script_file
	| Function_file

Script_file ::= Statement+

Function_file ::= Statement+

Statement ::=
	  Expression Statement_Sep
	| identifier Op_assign Expression Statement_Sep  # assignment
	| Keyword

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


Expression ::=
	   Number
	 | Indexing
	 | Op_lparen Expression Op_rparen assoc => group
	|| Expression Op_caret Expression  assoc => right
	|| Unary_Sign Number
	|| Expression Op_star Expression
	 | Expression Op_slash Expression
	|| Expression Op_plus Expression
	 | Expression Op_minus Expression
	 | Expression Op_colon Expression 
	 | Expression Op_colon Expression Op_colon Expression

Indexing ::=
	identifier Op_lparen Indexing_Expression_with_comma_sep Op_rparen Statement_Sep

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
Op_caret ~ [\^]
Op_plus ~ [+]
Op_minus ~ [-]
Op_star ~ [*]
Op_slash ~ [/]
Op_colon ~ [:]

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
Newline ~ [\n]

identifier ~ [a-zA-Z] id_rest
id_rest    ~ [_a-zA-Z0-9]*


Statement_Sep ~ Semicolon | Comma | Newline
Comma ~ [,]

:discard ~ whitespace
whitespace ~ [\s]+
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
