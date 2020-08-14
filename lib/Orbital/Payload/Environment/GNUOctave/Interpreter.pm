use Orbital::Transfer::Common::Setup;
package Orbital::Payload::Environment::GNUOctave::Interpreter;
# ABSTRACT: A representation of an Octave interpreter

use Moo;
use Orbital::Transfer::Common::Types qw(Tuple Str Int);

use File::Which;
use Capture::Tiny qw(capture);

has octave_path => (
	is => 'ro',
	default => method() {
		which('octave')
			or Orbital::Transfer::Common::Error::Service::NotAvailable
				->throw('octave is not in the PATH');
	},
);

method _eval( (Str) $command ) :ReturnType( list => Tuple[Str,Str,Int] ) {
	my ($stdout, $stderr, $exit) = capture {
		delete local $ENV{DISPLAY}; # unset so it doesn't use X11 display
		system( $self->octave_path, qw(-q --eval), $command  );
	};

	return ($stdout, $stderr, $exit);
}

1;
