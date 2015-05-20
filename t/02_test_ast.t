
use strict;
use warnings;
use Language::MATLAB::AST;
use IO::All;

my $grammar = Language::MATLAB::AST->grammar;

my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );
my ($value, $value_ref);

my $input = do { local $/; <DATA> };

$recce->read( \$input );
$value_ref = $recce->value;
use DDP; p $value_ref;

__DATA__
1 + 2
a = 42 * 2;
2 - a;
