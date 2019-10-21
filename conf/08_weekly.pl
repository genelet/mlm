#!/usr/bin/perl

use strict;
use DBI;
use Data::Dumper;
use JSON;

my $usage = "Usage: $0 -c config_file yyyy-mm-dd starting_week_id weeks
Where:
  config_file: system configuation file, default to 'config.json'.
  yyyy-mm-dd: the starting day of the starting week, No default.
  starting_week_id: default to 1 but you may choose an arbitrary number.
  weeks: number of weeks, default to 250.
";

my @args = @ARGV;
if (length(@args) < 1 or $args[0] eq "-h" or $args[0] eq "--help") {
	warn $usage;
	exit(-1);
}

my $file;
if ($args[0] eq "-c" or $args[0] eq "-config" or $args[0] eq "--config") {
	shift @args;
	$file = shift @args;
} elsif ($args[0] =~ /^--config=(\S+)$/) {
	$file = $1;
	shift @args;
}
my $day = shift @args;
unless ($day && $day =~ /^\d\d\d\d-\d\d?-\d\d?$/) {
	warn "The starting day should be written as yyyy-mm-dd.\n";
	exit(-1);
}

my $num = shift @args;
my $total = shift @args;
$file  ||= "./config.json";
$num   ||= 1;
$total ||= 250;

my $config;
{
    local $/;
    open( my $fh, '<', $file) or die "$file: $!";
    my $json_text = <$fh>;
    close($fh);
    $config = decode_json( $json_text );
    die "No configuration." unless $config;
}

my $dbh = DBI->connect(@{$config->{Db}}) || die $!;

printf("Making cron tables starting on %s for %d weeks or about %d years.\n",
	$day, $total, int($total/43));

my $week = 1;
for (my $i=$num; $i<($num+$total); $i++) {
	if ($week==5) {
		$week=1;
	}
	my $j = ($i-$num)*7;
	$dbh->do("INSERT INTO cron_1week (c1_id, weekly, daily)
		VALUES ($i, $week, DATE_ADD('$day', INTERVAL $j DAY))");
	if ($week==1) {
		$dbh->do("INSERT INTO cron_4week (c4_id, daily)
		VALUES ($i, DATE_ADD('$day', INTERVAL $j DAY))");
	}
	$week++;
}
$dbh->disconnect();

printf("...done.\n");

exit;
