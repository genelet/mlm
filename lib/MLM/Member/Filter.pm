package MLM::Member::Filter;

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

  if ($who eq 'p' && $action eq 'startnew') {
    $ARGS->{slogin} ||= 'www';
  } elsif ($who eq 'm' && $action eq 'update') {
    foreach my $key (keys %$ARGS) {
      delete $ARGS->{$key} if (grep {$key eq $_} qw(passwd ssn active typeid created ip sid pid top leg milel miler comm defpid defleg countl countr));
    }
  } elsif ($who eq 'm' && $action eq 'changepass') {
    return 3102 unless ($ARGS->{newpasswd} eq $ARGS->{confirm});
    delete $ARGS->{confirm};
  } elsif ($who eq 'a' && $action eq 'resetpass') {
    if ($ARGS->{newpasswd}) {
      return 3102 unless ($ARGS->{newpasswd} eq $ARGS->{confirm});
      delete $ARGS->{confirm};
    }
  } elsif ($who eq 'a' && $action eq 'topics') {
    $ARGS->{sortby} = 'created';
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
      return 3005 unless ($ARGS->{d1} && $ARGS->{d2});
      $extra->{"_gsql"} = "created >= '$ARGS->{y1}-$ARGS->{m1}-$ARGS->{d1} 00:00:01' AND created <= '$ARGS->{y2}-$ARGS->{m2}-$ARGS->{d2} 23:59:59'";
    } else {
      return 3006 unless $ARGS->{v};
      if ($ARGS->{u} eq 'loginm') {
        $extra->{"_gsql"} = "m.login LIKE '" .$ARGS->{v} ."\%'";
      } elsif ($ARGS->{u} eq 'firstname') {
        $extra->{"_gsql"} = "(m.firstname LIKE '\%" .$ARGS->{v} ."\%')";
      } elsif ($ARGS->{u} eq 'lastname') {
        $extra->{"_gsql"} = "(m.lastname LIKE  '\%" .$ARGS->{v} ."\%')";
      } else {
        $extra->{"_gsql"} = "m.".$ARGS->{u} ." LIKE '" .$ARGS->{v} ."\%'";
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
