package MLM::Ledger::Filter;

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

  if ($who eq 'a' && $action eq 'topics') {
    $ARGS->{sortby} = 'l.ledgerid';
    $ARGS->{sortreverse} = 1;
  } elsif ($who eq 'a' && $action eq 'addShopping') {
    $ARGS->{status} = 'Offline';    
    $ARGS->{manager} = $ARGS->{adminlogin};
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

  if ($action eq 'topics' && $ARGS->{u} && $ARGS->{status}) {
    $extra->{"_gsql"} = $ARGS->{u} ." LIKE '" . $ARGS->{v} . "\%' AND l.status='" . $ARGS->{status} . "'";
  } elsif ($action eq 'topics' && $ARGS->{u}) {
    $extra->{"_gsql"} = $ARGS->{u} ." LIKE '" . $ARGS->{v} . "\%'";
  } elsif ($action eq 'topics' && $ARGS->{status}) {
    $extra->{"status"} = $ARGS->{status};
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

	if ($action eq 'topics') {
		for my $item (@$lists) {
			$item->{amount} = sprintf("%.2f", $item->{amount});
			$item->{balance} = sprintf("%.2f", $item->{balance});
			$item->{shop_balance} = sprintf("%.2f", $item->{shop_balance});
		}
	}
	if ($action eq 'bonus') {
		for my $item (@$lists) {
			$item->{usRealTotal} = sprintf("%.2f", $item->{usRealTotal});
			$item->{realTotal} = sprintf("%.2f", $item->{realTotal});
			$item->{balance} = sprintf("%.2f", $item->{balance});
			$item->{shop_balance} = sprintf("%.2f", $item->{shop_balance});
		}
	}

	return;
}

1;
