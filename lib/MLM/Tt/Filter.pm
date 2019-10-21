package MLM::Tt::Filter;

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

  if ($action eq 'reply') {
    $ARGS->{party} = $who;
  } elsif ($action eq 'insert') {
    $ARGS->{party} = $who;
  } elsif ($action eq 'topics') {
    $ARGS->{sortby} = "subjectid";
    $ARGS->{sortreverse} = 1;
  }

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

  my ($form, $extra, $nextextras) = @_;

  if ($who eq 'a' && $action eq 'topics' && $ARGS->{u}) {
    if ($ARGS->{u} eq 'created') {
      return 3005 unless ($ARGS->{d1} && $ARGS->{d2});
      $extra->{"_gsql"} = "created >= '$ARGS->{y1}-$ARGS->{m1}-$ARGS->{d1} 00:00:01' AND created <= '$ARGS->{y2}-$ARGS->{m2}-$ARGS->{d2} 23:59:59'";
    } else {
      return 3006 unless $ARGS->{v};
      $extra->{"_gsql"} = $ARGS->{u} ." LIKE '" .$ARGS->{v} ."\%'";
    }
  }

  if ($action eq 'topics') {
    $extra->{category} = $ARGS->{category} if $ARGS->{category};
    $extra->{memberid} = $ARGS->{memberid} if (($who eq 'a') && $ARGS->{memberid});
    $extra->{status} = $ARGS->{status} if ($ARGS->{status});
  } elsif ($action eq 'reply') {
    $extra->{memberid} = $ARGS->{memberid} if ($who eq 'm');
  }

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
      substr($_->{created},0,5)='';
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
