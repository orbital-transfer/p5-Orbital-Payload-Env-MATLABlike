use Test::Most;
use Test::Base;
use Path::Class;
use strict;

BEGIN { use_ok 'MarpaX::MATLAB'; }

delimiters('%==', '%--');
my $spec = file(__FILE__)->dir->subdir('data')->file('00_number.m');
spec_file($spec);

my $grammar = MarpaX::MATLAB->grammar;

run {
	my $block = shift;
	my $input = $block->input;
	my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );
	$recce->read( \$input );
	my $value_ref = $recce->value;
	my $value = $value_ref ? ${$value_ref} : 'No Parse';
	use DDP; p $value;
}


done_testing;
