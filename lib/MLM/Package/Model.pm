package MLM::Package::Model;

use strict;
use warnings;
use MLM::Model;
our $AUTOLOAD;

use parent 'MLM::Model';

sub update {
  my $self = shift;
  return $self->SUPER::update(@_)
	|| $self->do_sql(
"UPDATE product_package p
INNER JOIN def_type t USING (typeid)
SET p.bv=t.bv
WHERE packageid=?", $self->{ARGS}->{packageid});
}

1;
