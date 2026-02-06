package MLM::Member::Filter;

use strict;
use warnings;
use MLM::Filter;
use MLM::Constants qw(
    ERR_PASSWORD_MISMATCH
    ERR_WRONG_DATE_RANGE
    ERR_EMPTY_SEARCH
);

use parent 'MLM::Filter';

sub preset {
	my $self = shift;
	my $err  = $self->SUPER::preset(@_);
	return $err if $err;

	my $ARGS   = $self->{ARGS};
	my $r      = $self->{R};
	my $who    = $ARGS->{g_role};
	my $action = $ARGS->{g_action};

  if ($who eq 'p' && $action eq 'startnew') {
    $ARGS->{slogin} ||= 'www';
  } elsif ($who eq 'm' && $action eq 'update') {
    foreach my $key (keys %$ARGS) {
      delete $ARGS->{$key} if (grep {$key eq $_} qw(passwd ssn active typeid created ip sid pid top leg milel miler comm defpid defleg countl countr));
    }
  } elsif ($who eq 'm' && $action eq 'changepass') {
    return ERR_PASSWORD_MISMATCH unless ($ARGS->{newpasswd} eq $ARGS->{confirm});
    delete $ARGS->{confirm};
  } elsif ($who eq 'a' && $action eq 'resetpass') {
    if ($ARGS->{newpasswd}) {
      return ERR_PASSWORD_MISMATCH unless ($ARGS->{newpasswd} eq $ARGS->{confirm});
      delete $ARGS->{confirm};
    }
  } elsif ($who eq 'a' && $action eq 'topics') {
    $ARGS->{sortby} = 'm.created';
  }

	return;
}

sub before {
	my $self = shift;
	my $err  = $self->SUPER::before(@_);
	return $err if $err;

	my $ARGS   = $self->{ARGS};
	my $r      = $self->{R};
	my $who    = $ARGS->{g_role};
	my $action = $ARGS->{g_action};

  my ($form, $extra, $nextextras) = @_;

  if ($action eq 'insert') {
    $err = $form->get_signup() || $form->sponsor_top_pid();
    return $err if $err;
	$ARGS->{active} = 'Yes';
    $ARGS->{classify} = 'package';
    $ARGS->{id} = $ARGS->{packageid}; #in baske, id is for package and gallery
    $ARGS->{paystatus} = "Pending"; #for new signup, we take Pending only
    $ARGS->{paystatus} = "Processing" if $ARGS->{paytype};
    $ARGS->{signuptype} = "Yes";
    $ARGS->{inbasket} = "No"; #sales directly, no more in basket
    $ARGS->{remark} = $ARGS->{ip}; #for new signup, we put ip here

    $ARGS->{defpid} = $ARGS->{memberid}; # default_pid is himself
    $ARGS->{defleg} = $ARGS->{leg};      # default_leg is the same as him
  }

  if ($who eq 'a' && $action eq 'topics' && $ARGS->{u}) {
    if ($ARGS->{u} eq 'created') {
      return ERR_WRONG_DATE_RANGE unless ($ARGS->{d1} && $ARGS->{d2});
      my $date_sql = $self->build_date_range_sql('created',
        $ARGS->{y1}, $ARGS->{m1}, $ARGS->{d1},
        $ARGS->{y2}, $ARGS->{m2}, $ARGS->{d2});
      return ERR_WRONG_DATE_RANGE unless $date_sql;
      $extra->{"_gsql"} = $date_sql;
    } else {
      return ERR_EMPTY_SEARCH unless $ARGS->{v};
      if ($ARGS->{u} eq 'loginm') {
        $extra->{"_gsql"} = $self->build_like_sql('m.login', $ARGS->{v}, 1);
      } elsif ($ARGS->{u} eq 'firstname') {
        $extra->{"_gsql"} = '(' . $self->build_like_sql('m.firstname', $ARGS->{v}, 0) . ')';
      } elsif ($ARGS->{u} eq 'lastname') {
        $extra->{"_gsql"} = '(' . $self->build_like_sql('m.lastname', $ARGS->{v}, 0) . ')';
      } else {
        # Whitelist allowed column names
        my $col = $self->validate_column($ARGS->{u}, [qw(login email phone ssn)]);
        return ERR_EMPTY_SEARCH unless $col;
        $extra->{"_gsql"} = $self->build_like_sql("m.$col", $ARGS->{v}, 1);
      }
    }
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

  if ($who eq 'm' && $action eq 'update') {
    if ($ARGS->{relogin}) {
      $r->{"headers_out"}->{"Location"} = "logout";
      return 303;
    }
  } elsif ($who eq 'a' && $action eq 'enter') {
    $err = $self->set_login_cookie_as('m', $ARGS->{login}) and return $err;
    $r->{"headers_out"}->{"Location"} = $self->{SCRIPT}.$self->{CUSTOM}->{ENTER};
    return 303;
  } elsif ($who eq 'a' && $action eq 'topics') {
    $ARGS->{m1} ||= (localtime())[4] + 1;
    $ARGS->{m2} ||= $ARGS->{m1};
  }

	return;
}

1;
