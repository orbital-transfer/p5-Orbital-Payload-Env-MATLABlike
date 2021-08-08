use Orbital::Transfer::Common::Setup;
package Orbital::Payload::Env::GNUOctave::Doc::Eval;
# ABSTRACT: Retrieves documentation via Octave command line

use Moo;
use Orbital::Transfer::Common::Types qw(InstanceOf Str);

has octave_interpreter => (
	is => 'ro',
	isa => InstanceOf['Orbital::Payload::Env::GNUOctave::Interpreter'],
	required => 1,
);

method retrieve( (Str) $doc) {
	my $doc_escape = $doc =~ s/'/''/r; # double apostrophes to escape
	my ($stdout, $stderr, $exit) = $self->octave_interpreter->_eval( "help '$doc_escape'" );

	if( $stderr =~ /^error: help: .* not found/ ) {
		Orbital::Transfer::Common::Error::Retrieval::NotFound->throw( $stdout );
	}

	return $stdout;
}

with qw(Orbital::Transfer::Service::Role::DocumentRetrievable);

1;
