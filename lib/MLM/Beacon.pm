package MLM::Beacon;

use strict;
use Genelet::Dispatch;
use Genelet::Beacon;

use vars qw(@ISA);
@ISA = qw(Genelet::Beacon);

__PACKAGE__->setup_accessors(
  config => Genelet::Dispatch::get_hash("/var/www/mlm/conf/config.json"),
  lib    => '/var/www/mlm/lib',
  ip     => '10.11.1.184',
  comps  => ["Admin","Affiliate","Signup","Member","Sponsor","Placement","Category","Gallery","Package", "Packagedetail","Packagetype","Sale","Basket","Lineitem","Income","Incomeamount","Ledger","Tt","Ttpost","Week1","Week4","Affiliate"],
  tag    => 'json',
  header => {'Content-Type' => "application/x-www-form-urlencoded", 'Cookie' => "go_probe=1"}
);

1;
