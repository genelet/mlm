package MLM::Ledger::Filter;

use strict;
use warnings;
use MLM::Filter;

use parent 'MLM::Filter';

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

  if ($action eq 'topics' && $ARGS->{u}) {
    # Whitelist allowed column names
    my $col = $self->validate_column($ARGS->{u}, [qw(login firstname lastname email)]);
    if ($col && $ARGS->{v}) {
      my $like_sql = $self->build_like_sql($col, $ARGS->{v}, 1);
      if ($ARGS->{status}) {
        my $status_escaped = $self->escape_like_value($ARGS->{status});
        $extra->{"_gsql"} = "$like_sql AND l.status='$status_escaped'";
      } else {
        $extra->{"_gsql"} = $like_sql;
      }
    }
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
