package MLM::Income::Filter;

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

    if ($action eq 'run_all_tests' and $ARGS->{adminid} !~ /ROOT/) {
        return 3001,
    }

	$ARGS->{BIN} = $self->{CUSTOM}->{BIN};
	$ARGS->{top_memberid} = $self->{CUSTOM}->{TOP_memberid};
	$ARGS->{rate_affiliate} = $self->{CUSTOM}->{RATE_affiliate};
	$ARGS->{rate_shop} = $self->{CUSTOM}->{RATE_shop};
	$ARGS->{rate_matchdown} = $self->{CUSTOM}->{RATE_matchdown};

  if ($who eq 'a' && $action eq 'topics') {
    $ARGS->{sortby} = 'i.incomeid';
    $ARGS->{sortreverse} = 1;
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

  if ($action eq 'topics' && $ARGS->{u} && $ARGS->{classify}) {
    $extra->{"_gsql"} = $ARGS->{u} ." LIKE '" . $ARGS->{v} . "\%' AND i.classify='" . $ARGS->{classify} . "'";
  } elsif ($action eq 'topics' && $ARGS->{u}) {
    $extra->{"_gsql"} = $ARGS->{u} ." LIKE '" . $ARGS->{v} . "\%'";
  } elsif ($action eq 'topics' && $ARGS->{paystatus}) {
    $extra->{"i.paystatus"} = $ARGS->{paystatus};
  } elsif ($action eq 'topics' && $ARGS->{classify}) {
    $extra->{"i.classify"} = $ARGS->{classify};
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
