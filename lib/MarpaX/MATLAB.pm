package MarpaX::MATLAB;


use Marpa::R2;
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

Top ::= Expression+

Expression ::= Term

Expression ::=
	   Number
	 | Op_lparen Expression Op_rparen assoc => group
	|| Expression Op_starstar Expression  assoc => right
	|| Optional_Unary_Sign Number
	|| Expression Op_star Expression
	 | Expression Op_slash Expression
	|| Expression Op_plus Expression
	 | Expression Op_minus Expression



Op_lparen ~ [(]
Op_rparen ~ [)]

Op_starstar ~ [*][*]
Op_plus ~ [+]
Op_minus ~ [-]
Op_star ~ [*]
Op_slash ~ [/]

Unary_Sign ~ [+-]

Optional_Unary_Sign ~ Unary_Sign
Optional_Unary_Sign ~ # empty

Number ~ RealNumber | ImaginaryNumber

RealNumber ~ Integer | Float

Optional_RealNumber ~ RealNumber
Optional_RealNumber ~ # empty

ImaginaryNumber ~ Optional_RealNumber [ij]

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
