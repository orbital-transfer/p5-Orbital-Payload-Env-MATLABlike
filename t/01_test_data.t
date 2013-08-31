use Test::Most;
use Test::Base;
use Path::Class;
use Path::Iterator::Rule;
use strict;

use MarpaX::MATLAB;

my $testbase = Test::Base->new;
delimiters('%==', '%--');
my $spec = file(__FILE__)->dir->subdir('data')->file('00_number.m');
spec_file($spec);

filters {
    input  => [qw(chomp)],
    success  => [qw(chomp)],
};

plan tests => ( 1 * blocks );

my $grammar = MarpaX::MATLAB->grammar;

run {
	my $block = shift;
	my $input = $block->input;
	my $success = !! ( $block->success ); # booleanify
	my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );
	my ($value, $value_ref);
	eval {
		$recce->read( \$input );
		$value_ref = $recce->value;
		$value = $value_ref ? ${$value_ref} : 'No Parse';
	};
	unless( $@ ) {
		# parse successful
		if($success) {
			pass "< $input > parsed";
		} else {
			fail '< $input > was not supposed to parse';
		}
	} else {
		if($success) {
			fail "< $input > did not parse";
		} else {
			pass "< $input > should not parse";
		}
	}
}
