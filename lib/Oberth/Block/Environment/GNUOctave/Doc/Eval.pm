use Oberth::Manoeuvre::Common::Setup;
package Oberth::Block::Environment::GNUOctave::Doc::Eval;
# ABSTRACT: Retrieves documentation via Octave command line

use Moo;
use Oberth::Manoeuvre::Common::Types qw(InstanceOf Str);

has octave_interpreter => (
	is => 'ro',
	isa => InstanceOf['Oberth::Block::Environment::GNUOctave::Interpreter'],
	required => 1,
);

method retrieve( (Str) $doc) {
	my $doc_escape = $doc =~ s/'/''/r; # double apostrophes to escape
	my ($stdout, $stderr, $exit) = $self->octave_interpreter->_eval( "help '$doc_escape'" );

	if( $stderr =~ /^error: help: .* not found/ ) {
		Oberth::Manoeuvre::Common::Error::Retrieval::NotFound->throw( $stdout );
	}

	return $stdout;
}

with qw(Oberth::Manoeuvre::Service::Role::DocumentRetrievable);

1;
