package MLM::Incomeamount::Filter;

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
    $ARGS->{sortby} = 'i.amount_id';
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

  if ($action eq 'topics' && $ARGS->{u}) {
    # Whitelist allowed column names
    my $col = $self->validate_column($ARGS->{u}, [qw(login firstname lastname email)]);
    if ($col && $ARGS->{v}) {
      my $like_sql = $self->build_like_sql($col, $ARGS->{v}, 1);
      if ($ARGS->{bonusType}) {
        my $bonus_escaped = $self->escape_like_value($ARGS->{bonusType});
        $extra->{"_gsql"} = "$like_sql AND i.bonusType='$bonus_escaped'";
      } else {
        $extra->{"_gsql"} = $like_sql;
      }
    }
  } elsif ($action eq 'topics' && $ARGS->{bonusType}) {
    $extra->{"i.bonusType"} = $ARGS->{bonusType};
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
