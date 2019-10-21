package MLM::Tt::Model;

use strict;
use MLM::Model;

use vars qw($AUTOLOAD @ISA);

@ISA=('MLM::Model');

sub reply {
  my $self = shift;
  my $extra = shift;

  return $self->update($extra) || $self->process_after("reply", @_);
}

1;
