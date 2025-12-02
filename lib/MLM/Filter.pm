package MLM::Filter;

use strict;
use warnings;
use Genelet::Utils;
use Genelet::Filter;
use Genelet::Template;


use parent qw(Genelet::Filter Genelet::Template);

#__PACKAGE__->setup_accessors(
#    'total_force' => 1,
#);

sub preset {
  my $self = shift;
  my $err  = $self->SUPER::preset(@_);
  return $err if $err;

  my $ARGS = $self->{ARGS};
  my $r    = $self->{R};
  my $who  = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};
  my $obj  = $ARGS->{_gobj};

  if ($action eq 'topics') {
    $ARGS->{rowcount} ||= 100;
    $ARGS->{pageno}   ||= 1;
  }

  if ($who eq 'p') {
    if ($ARGS->{Sponsor}) {
      $ARGS->{slogin} = $ARGS->{Sponsor};
    }
  }

  if ($action eq 'insert' or $action eq 'bulk' or $action eq 'reply' or
	$action eq 'activate' or $action eq 'resetpass') {
    $ARGS->{ip} = get_lb_ip();
    $ARGS->{createdint} = $ARGS->{_gtime};
    $ARGS->{created} ||= Genelet::Utils::now_from_unix($ARGS->{_gtime});
  }

  return;
}

sub before {
  my $self = shift;
  my $err  = $self->SUPER::before(@_);
  return $err if $err;

  my ($form, $extra, $nextextras) = @_;
  my $dbh = $form->{DBH};

  my $ARGS = $self->{ARGS};
  my $r    = $self->{R};
  my $who  = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};
  my $obj  = $ARGS->{_gobj};

  return;
}

sub after {
  my $self = shift;
  my $err  = $self->SUPER::after(@_);
  return $err if $err;

  my ($form) = @_;

  my $ARGS = $self->{ARGS};
  my $r = $self->{R};
  my $who = $ARGS->{_gwho};
  my $action = $ARGS->{_gaction};
  my $obj = $ARGS->{_gobj};

  return;
}

sub get_lb_ip {
  if ( ($ENV{REMOTE_ADDR} =~ /^192\.168\./ or $ENV{REMOTE_ADDR} =~ /^10\./)
	and $ENV{HTTP_X_FORWARDED_FOR}
	and ($ENV{HTTP_X_FORWARDED_FOR} =~ /(\d+\.\d+\.\d+\.\d+)$/)) {
    return $1;
  } else {
    $ENV{REMOTE_ADDR} =~ /(\d+\.\d+\.\d+\.\d+)$/;
    return $1;
  }
}

# Escape a value for use in SQL LIKE queries to prevent SQL injection
sub escape_like_value {
  my ($self, $value) = @_;
  return '' unless defined $value;
  $value =~ s/\\/\\\\/g;  # escape backslashes first
  $value =~ s/'/\\'/g;    # escape single quotes
  $value =~ s/%/\\%/g;    # escape LIKE wildcards
  $value =~ s/_/\\_/g;    # escape LIKE wildcards
  return $value;
}

# Validate column name against whitelist to prevent SQL injection
sub validate_column {
  my ($self, $column, $allowed) = @_;
  return unless defined $column;
  for my $col (@$allowed) {
    return $column if $column eq $col;
  }
  return;
}

# Validate date component is numeric
sub validate_date_part {
  my ($self, $value) = @_;
  return unless defined $value && $value =~ /^\d+$/;
  return $value;
}

# Build safe LIKE SQL clause
sub build_like_sql {
  my ($self, $column, $value, $prefix_match) = @_;
  my $escaped = $self->escape_like_value($value);
  if ($prefix_match) {
    return "$column LIKE '$escaped\%'";
  }
  return "$column LIKE '\%$escaped\%'";
}

# Build safe date range SQL clause
sub build_date_range_sql {
  my ($self, $column, $y1, $m1, $d1, $y2, $m2, $d2) = @_;
  # Validate all date parts are numeric
  for my $part ($y1, $m1, $d1, $y2, $m2, $d2) {
    return unless $self->validate_date_part($part);
  }
  return "$column >= '$y1-$m1-$d1 00:00:01' AND $column <= '$y2-$m2-$d2 23:59:59'";
}

1;
