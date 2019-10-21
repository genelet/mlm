package MLM::Sale::Filter;

use strict;
use MLM::Filter;
use vars qw(@ISA);

@ISA=('MLM::Filter');

sub preset {
  my $self = shift;
  my $err  = $self->SUPER::preset(@_);
  return $err if $err;

  my $ARGS   = $self->{ARGS};
  my $r      = $self->{R};
  my $who    = $ARGS->{g_role};
  my $action = $ARGS->{g_action};

  $ARGS->{shop_typeid} = $self->{CUSTOM}->{SHOP_typeid};

  if ($action eq 'update') {
    $ARGS->{manager} = $ARGS->{adminlogin};
  } elsif ($action eq 'topics') {
    $ARGS->{sortby} ||= 'saleid';
    $ARGS->{sortreverse} ||= 1;
  }

  return;
}

sub before {
	my $self = shift;
	my $err  = $self->SUPER::before(@_);
	return $err if $err;

	my ($form, $extra, $nextextras) = @_;

	my $ARGS   = $self->{ARGS};
	my $r      = $self->{R};
	my $who    = $ARGS->{g_role};
	my $action = $ARGS->{g_action};

	if ($action eq 'topics') {
		$extra->{paytype} = $ARGS->{paytype} if $ARGS->{paytype};
		$extra->{paystatus} = $ARGS->{paystatus} if $ARGS->{paystatus};
		$extra->{"memberid"} = $ARGS->{memberid} if $ARGS->{memberid};
	}

	return;
}

sub after {
	my $self = shift;
	my $err  = $self->SUPER::after(@_);
	return $err if $err;

	my $ARGS   = $self->{ARGS};
	my $r      = $self->{R};
	my $who    = $ARGS->{g_role};
	my $action = $ARGS->{g_action};

    my ($form) = @_;
    my $lists = $form->{LISTS};

	return;
}

1;
