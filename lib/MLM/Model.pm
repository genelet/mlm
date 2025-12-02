package MLM::Model;

use strict;
use warnings;
use Genelet::Model;
use Genelet::Mysql;
use Genelet::Crud;

use parent qw(Genelet::Model Genelet::Mysql);

__PACKAGE__->setup_accessors(
	'total_force' => 1,
);

# Validate date string format (YYYY-MM-DD)
sub validate_date {
  my ($self, $date) = @_;
  return unless defined $date;
  return unless $date =~ /^(\d{4})-(\d{2})-(\d{2})$/;
  my ($y, $m, $d) = ($1, $2, $3);
  return unless ($m >= 1 && $m <= 12 && $d >= 1 && $d <= 31);
  return $date;
}

# Validate integer (for IDs like c1_id, c4_id)
sub validate_int {
  my ($self, $value) = @_;
  return unless defined $value;
  return unless $value =~ /^-?\d+$/;
  return $value + 0;  # Convert to numeric
}

# Validate positive number (for rates)
sub validate_rate {
  my ($self, $value) = @_;
  return unless defined $value;
  return unless $value =~ /^[0-9]*\.?[0-9]+$/;
  return $value + 0;  # Convert to numeric
}

1;
