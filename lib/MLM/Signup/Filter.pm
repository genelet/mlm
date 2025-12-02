package MLM::Signup::Filter;

use strict;
use warnings;
use Digest::SHA qw(sha1_hex);
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

	if ($action eq 'insert') {
		return 3102 unless ($ARGS->{passwd} && ($ARGS->{passwd} eq $ARGS->{confirm}));
		delete $ARGS->{confirm};
		return 3122 if ($ARGS->{login} =~ /^\d/);
		return 3123 unless ($ARGS->{passwd} =~ /\d/ && $ARGS->{passwd} =~ /[a-zA-Z]/);
		return 3124 unless ( length($ARGS->{passwd})>=6 );
        $ARGS->{passwd} = sha1_hex($ARGS->{login}.$ARGS->{passwd});
		$ARGS->{signuptime} = $ARGS->{created};
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

    if ($action eq 'topics') {
      $extra->{signupstatus} ||= 'Yes'
    } elsif ($action eq 'insert' and !$ARGS->{memberid}) {
      $err = $form->randomid([800000,900000], 10, "memberid", "member");
      return $err if $err;
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
