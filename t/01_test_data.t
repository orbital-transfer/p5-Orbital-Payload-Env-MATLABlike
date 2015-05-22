use Test::Most;
use Test::Base;
use Path::Class;
use Path::Iterator::Rule;
use List::AllUtils qw(sum);
use strict;

use Language::MATLAB::AST;

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
	    success  => [qw(remove_matlab_comments chomp)],
	});
	$test;
} @spec_files;


plan tests => ( sum ( map { 1 * $_->blocks } @test ) );

my $grammar = Language::MATLAB::AST->grammar;

for my $t (@test) {
	note "running test on @{[$t->{_spec_file}]}";
	$t->run( sub {
		my $block = shift;
		my $file = $block->blocks_object->{_spec_file};
		my $name = $block->name;
		my $input = $block->input . "\n"; # ensure a new line at the end
		my $success =  $block->success == 1 ; # booleanify
		my $trace_string;
		open(my $trace_fh, '>', \$trace_string);
		my $recce = Marpa::R2::Scanless::R->new( {
			grammar => $grammar,
			trace_terminals => 1,
			trace_file_handle => $trace_fh } );
		$trace_string = "";
		my ($value, $value_ref);
		unless( not defined eval { $recce->read( \$input ); 1 } ) {
			# parse successful
			$value_ref = $recce->value;
			$value = $value_ref ? ${$value_ref} : 'No Parse';
			#use DDP; p $value;
			if($success) {
				if( defined $value_ref ) {
					pass "< $input > parsed: $name";
				} else {
					fail "< $input > parsed, but did not generate tree: $name; from $file" or diag explain $value;
				}
			} else {
				fail "< $input > should not have parsed: $name; from $file" or do {
					diag explain $value;
					#use DDP; diag p $value;
				}
			}
		} else {
			if($success) {
				fail "< $input > should have parsed: $name; from $file"
					or do {
						diag explain $value;
						diag $trace_string;
						#my $progress_report = $recce->show_progress( 0, -1 );
						#diag explain $progress_report;
					}
			} else {
				pass "< $input > did not parse: $name";
			}
		}
	});
}

sub remove_matlab_comments {
	s/^% //gm;
}
