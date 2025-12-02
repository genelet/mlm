package MLM::Tt::Model;

use strict;
use warnings;
use MLM::Model;

our $AUTOLOAD;

use parent 'MLM::Model';

sub reply {
  my $self = shift;
  my $extra = shift;

  return $self->update($extra) || $self->process_after("reply", @_);
}

1;
