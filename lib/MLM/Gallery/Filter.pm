package MLM::Gallery::Filter;

use strict;
use warnings;
use Genelet::Utils;
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

  if ($who eq 'a' && ($action eq 'insert' or $action eq 'update')) {
    $ARGS->{logo} = "/product/".$ARGS->{logo} if $ARGS->{logo};
    $ARGS->{full} = "/product/".$ARGS->{full} if $ARGS->{full};
  } elsif ($action eq 'topics') {
    $ARGS->{"sortreverse"}  = 1;
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

  if ($action eq 'topics')  {
    $extra->{"categoryid"} = $ARGS->{categoryid} if $ARGS->{categoryid};
    $extra->{"status"} = "Yes" unless ($ARGS->{_gadmin});
  }
  if (($who eq 'p' || $who eq 'm') &&
    ($action eq 'topics' || $action eq 'edit'))  {
    $extra->{"categoryid"} = $ARGS->{categoryid} if $ARGS->{categoryid};
    $extra->{"status"}  = "Yes";
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

  if ($who eq 'a' && $action eq 'delete')  {
    unlink $self->{DOCUMENT_ROOT}.$ARGS->{logo} if $ARGS->{logo};
    unlink $self->{DOCUMENT_ROOT}.$ARGS->{full} if $ARGS->{full};
  } elsif ($who eq 'a' && $action eq 'update')  {
    unlink $self->{DOCUMENT_ROOT}.$ARGS->{logoold} if ($ARGS->{logo} && ($ARGS->{logoold} ne $ARGS->{logo}));
    unlink $self->{DOCUMENT_ROOT}.$ARGS->{fullold} if ($ARGS->{full} && ($ARGS->{fullold} ne $ARGS->{full}));
  }

  if ($action eq 'topics') {
    foreach my $item (@$lists) {
      if ($who eq 'p') {
        $item->{d} = substr($item->{description},0,40);
      }
    }
  }

	return;
}

1;
