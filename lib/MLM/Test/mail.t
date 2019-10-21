#!/usr/bin/perl

use lib qw(/home/eightran/public_html/goto);

package Controller;
use Genelet::Debug;
use Genelet::CGI;
use Genelet::Template;
use Genelet::SMTP;
use Genelet::FCGIController;
our @ISA = qw(Genelet::Debug Genelet::CGI Genelet::Template Genelet::SMTP Genelet::FCGIController);

# program starts ....
package main;
use strict;
use Data::Dumper;
use Goto::Config;

my $smtp = $Goto::Config::controller{mail};
$smtp->{To} = 'peterbi@gmail.com';
$smtp->{Subject} = 'Wavelet request';
$smtp->{Debug} = 1;

my $body = qq~
Scientists estimate that nearly half the living material on our planet is hidden in or beneath the ocean or in rocks, soil, tree roots, mines, oil wells, lakes and aquifers on the continents.
~;

my $c = Controller->new();
my $err = $c->sendMail($smtp, $body);
warn Dumper $err;

exit(0);
