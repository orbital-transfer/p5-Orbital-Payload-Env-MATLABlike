use Oberth::Common::Setup;
package Oberth::Service::GNUOctave::Container;
# ABSTRACT: A container for the GNU Octave service

use Moose;
use Bread::Board::Declare;

has doc_eval => (
	is => 'ro',
	isa => 'Oberth::Service::GNUOctave::Doc::Eval',
	infer => 1,
);

has octave_interpreter => (
	is => 'ro',
	isa => 'Oberth::Service::GNUOctave::Interpreter',
	infer => 1,
);

1;
