package MLM::Packagedetail::Model;

use strict;
use MLM::Model;
use vars qw($AUTOLOAD @ISA);

@ISA=('MLM::Model');

sub topics {
  my $self = shift;

  my $err = $self->SUPER::topics(@_);
  return $err if $err;

  my $sth;
  if (@{$self->{LISTS}}) {
    my $ids = join(",", map {$_->{galleryid}} @{$self->{LISTS}});
    $sth = $self->{DBH}->prepare(
"SELECT galleryid, title, price, bv
FROM product_gallery
WHERE (galleryid NOT IN ($ids)) AND status='Yes'");
  } else {
    $sth = $self->{DBH}->prepare(
"SELECT galleryid, title, price, bv
FROM product_gallery
WHERE status='Yes'");
  }
  $sth->execute() || die $!;
  my $gs;
  while (my $hash = $sth->fetchrow_hashref()) {
    push @$gs, $hash;
  }
  $sth->finish;
  $self->{ARGS}->{gs} = $gs;

  return $self->get_args($self->{ARGS},
"SELECT description, title, price, bv, sh, sumnum, logo
FROM product_package
WHERE packageid=?", $self->{ARGS}->{packageid});
}

1;
