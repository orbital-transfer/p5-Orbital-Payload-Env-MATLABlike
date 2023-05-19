use Orbital::Transfer::Common::Setup;
package Orbital::Payload::Env::GNUOctave::Container;
# ABSTRACT: A container for the GNU Octave service

use Orbital::Transfer::Common::Setup;
use Moose;
use Bread::Board::Declare;

has doc_eval => (
	is => 'ro',
	isa => 'Orbital::Payload::Env::GNUOctave::Doc::Eval',
	infer => 1,
);

has octave_interpreter => (
	is => 'ro',
	isa => 'Orbital::Payload::Env::GNUOctave::Interpreter',
	infer => 1,
);

1;
