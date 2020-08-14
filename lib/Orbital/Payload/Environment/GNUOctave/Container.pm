use Orbital::Transfer::Common::Setup;
package Orbital::Payload::Environment::GNUOctave::Container;
# ABSTRACT: A container for the GNU Octave service

use Moose;
use Bread::Board::Declare;

has doc_eval => (
	is => 'ro',
	isa => 'Orbital::Payload::Environment::GNUOctave::Doc::Eval',
	infer => 1,
);

has octave_interpreter => (
	is => 'ro',
	isa => 'Orbital::Payload::Environment::GNUOctave::Interpreter',
	infer => 1,
);

1;
