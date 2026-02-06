package MLM::Admin::Filter;

use strict;
use warnings;
use Digest::SHA qw(sha1_hex);
use MLM::Filter;
use MLM::Constants qw(
    ERR_WRONG_PRIVILEGE
    ERR_WRONG_ADMIN
    ERR_WRONG_LOGIN_FORMAT
    ERR_PASSWORD_LENGTH
);

use parent 'MLM::Filter';

sub preset {
	my $self = shift;
	my $err  = $self->SUPER::preset(@_);
	return $err if $err;

	my $ARGS   = $self->{ARGS};
#	my $r      = $self->{R};
	my $who    = $ARGS->{g_role};
	my $action = $ARGS->{g_action};

	if ($ARGS->{adminid} !~ /ROOT/) {
		return ERR_WRONG_PRIVILEGE,
	}

	if ($action eq 'insert') {
		return ERR_WRONG_ADMIN if ($ARGS->{login} eq $ARGS->{adminlogin});
		$ARGS->{old_adminid} = $ARGS->{adminid};
		if (ref($ARGS->{groups}) eq 'ARRAY') {
			$ARGS->{adminid} = join ",", @{$ARGS->{groups}};
		} else {
			$ARGS->{adminid} = $ARGS->{groups};
		}
		return ERR_WRONG_PRIVILEGE if ($ARGS->{adminid} =~ /ROOT/);
		return ERR_WRONG_LOGIN_FORMAT unless ($ARGS->{login} =~ /^[a-zA-Z0-9]+$/);	
		return ERR_PASSWORD_LENGTH unless (length($ARGS->{passwd}) >= 6);
		$ARGS->{passwd} = sha1_hex($ARGS->{login}.$ARGS->{passwd});
	}

	return;
}

sub before {
	my $self = shift;
	my $err  = $self->SUPER::before(@_);
	return $err if $err;

	my $ARGS   = $self->{ARGS};
#	my $r      = $self->{R};
	my $who    = $ARGS->{g_role};
	my $action = $ARGS->{g_action};

	my ($form, $extra, $nextextras) = @_;

	return;
}

sub after {
	my $self = shift;
	my $err  = $self->SUPER::after(@_);
	return $err if $err;

	my $ARGS   = $self->{ARGS};
#	my $r      = $self->{R};
	my $who    = $ARGS->{g_role};
	my $action = $ARGS->{g_action};

	my ($form) = @_;
	my $lists = $form->{LISTS};

	if ($action eq 'insert') {
        $ARGS->{adminid} = $ARGS->{old_adminid};
        delete $ARGS->{old_adminid};
	}

	return;
}

1;
