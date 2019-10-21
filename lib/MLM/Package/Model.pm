package MLM::Package::Model;

use strict;
use MLM::Model;
use vars qw($AUTOLOAD @ISA);

@ISA=('MLM::Model');

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
