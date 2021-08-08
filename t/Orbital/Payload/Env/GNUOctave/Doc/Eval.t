#!/usr/bin/env perl

use Orbital::Transfer::Common::Setup;
use Orbital::Payload::Env::GNUOctave::Container;
use Test::Most;

my $doc_eval = try {
	Orbital::Payload::Env::GNUOctave::Container->new->doc_eval
} catch {
	plan skip_all => "$_";
};

plan tests => 2;

subtest 'lookup Octave documentation' => sub {
	my $doc_eval = Orbital::Payload::Env::GNUOctave::Container->new->doc_eval;
	my $doc = $doc_eval->retrieve('sum');
	like $doc,
		qr/Sum of elements along dimension DIM/,
		"sum documentation contains the correct phrase";

	my $doc_apo_escape = $doc_eval->retrieve(".'");
	like $doc_apo_escape,
		qr/Matrix transpose operator.*_not_\s+the\s+complex\s+conjugate.*transpose/s,
		"correct documentation for the .' matrix transpose operator: escaped quote properly";
};


subtest "errors in Octave documentation lookup" => sub {
	my $doc_eval = Orbital::Payload::Env::GNUOctave::Container->new->doc_eval;
	throws_ok
		{ my $doc = $doc_eval->retrieve('not_an_octave_function'); }
		'Orbital::Transfer::Common::Error::Retrieval::NotFound',
		"no doc for 'not_an_octave_function'";
};

done_testing;
