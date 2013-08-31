use Test::Most;
use Test::Base;
use Path::Class;
use Path::Iterator::Rule;
use List::AllUtils qw(sum);
use strict;

use MarpaX::MATLAB;

my $testbase = Test::Base->new;
#my $spec = file(__FILE__)->dir->subdir('data')->file('00_number.m');

my @spec_files = Path::Iterator::Rule->new->file->name(qr/\.m$/)->all(
	file(__FILE__)->dir->subdir('data') );
my @test = map {
	my $test = Test::Base->new();
	$test->delimiters('%==', '%--');
	$test->spec_file($_);
	$test->filters({
	    input  => [qw(chomp)],
	    success  => [qw(chomp)],
	});
	$test;
} @spec_files;


plan tests => ( sum ( map { 1 * $_->blocks } @test ) );

my $grammar = MarpaX::MATLAB->grammar;

for my $t (@test) {
	note "running test on @{[$t->{_spec_file}]}";
	$t->run( sub {
		my $block = shift;
		my $input = $block->input;
		my $success = !! ( $block->success ); # booleanify
		my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );
		my ($value, $value_ref);
		unless( not defined eval { $recce->read( \$input ); 1 } ) {
			# parse successful
			$value_ref = $recce->value;
			$value = $value_ref ? ${$value_ref} : 'No Parse';
			if($success and $value_ref) {
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
	});
}
