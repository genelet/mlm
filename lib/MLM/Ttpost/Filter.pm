package MLM::Ttpost::Filter;

use strict;
use MLM::Filter;
use vars qw(@ISA);
@ISA=('MLM::Filter');

sub preset {
  my $self = shift;
  my $err = $self->SUPER::preset(@_);
  return $err if $err;

  my $ARGS = $self->{ARGS};
  my $r = $self->{R};
  my $who = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};

  return;
}

sub before {
  my $self = shift;
  my $err = $self->SUPER::before(@_);
  return $err if $err;

  my $ARGS = $self->{ARGS};
  my $r = $self->{R};
  my $who = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};

  my ($dbh, $form, $extra, $nextextras) = @_;

  return;
}

sub after {
  my $self = shift;
  my $err = $self->SUPER::after(@_);
  return $err if $err;

  my $ARGS = $self->{ARGS};
  my $r = $self->{R};
  my $who = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};

    my ($form) = @_;
    my $lists = $form->{LISTS};

  if ($action eq 'topics') {
    for (@{$lists}) {
      substr($_->{created}, 0,5)='';
      substr($_->{created},-3,3)='';
    }
  }

  if ($who eq 'a' && $action eq 'topics') {
    $ARGS->{m1} ||= (localtime())[4] + 1;
    $ARGS->{m2} ||= $ARGS->{m1};
  }

  return;
}

1;
