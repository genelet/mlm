package MLM::Filter;

use strict;
use Genelet::Utils;
use Genelet::Filter;
use Genelet::Template;

use vars qw(@ISA);

@ISA = qw(Genelet::Filter Genelet::Template);

#__PACKAGE__->setup_accessors(
#    'total_force' => 1,
#);

sub preset {
  my $self = shift;
  my $err  = $self->SUPER::preset(@_);
  return $err if $err;

  my $ARGS = $self->{ARGS};
  my $r    = $self->{R};
  my $who  = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};
  my $obj  = $ARGS->{_gobj};

  if ($action eq 'topics') {
    $ARGS->{rowcount} ||= 100;
    $ARGS->{pageno}   ||= 1;
  }

  if ($who eq 'p') {
    if ($ARGS->{Sponsor}) {
      $ARGS->{slogin} = $ARGS->{Sponsor};
    }
  }

  if ($action eq 'insert' or $action eq 'bulk' or $action eq 'reply' or
	$action eq 'activate' or $action eq 'resetpass') {
    $ARGS->{ip} = get_lb_ip();
    $ARGS->{createdint} = $ARGS->{_gtime};
    $ARGS->{created} ||= Genelet::Utils::now_from_unix($ARGS->{_gtime});
  }

  return;
}

sub before {
  my $self = shift;
  my $err  = $self->SUPER::before(@_);
  return $err if $err;

  my ($form, $extra, $nextextras) = @_;
  my $dbh = $form->{DBH};

  my $ARGS = $self->{ARGS};
  my $r    = $self->{R};
  my $who  = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};
  my $obj  = $ARGS->{_gobj};

  return;
}

sub after {
  my $self = shift;
  my $err  = $self->SUPER::after(@_);
  return $err if $err;

  my ($form) = @_;

  my $ARGS = $self->{ARGS};
  my $r = $self->{R};
  my $who = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};
  my $obj = $ARGS->{_gobj};

  return;
}

sub get_lb_ip {
  if ( ($ENV{REMOTE_ADDR} =~ /^192\.168\./ or $ENV{REMOTE_ADDR} =~ /^10\./)
	and $ENV{HTTP_X_FORWARDED_FOR}
	and ($ENV{HTTP_X_FORWARDED_FOR} =~ /(\d+\.\d+\.\d+\.\d+)$/)) {
    return $1;
  } else {
    $ENV{REMOTE_ADDR} =~ /(\d+\.\d+\.\d+\.\d+)$/;
    return $1;
  }
}

1;
