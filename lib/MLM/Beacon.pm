package MLM::Beacon;

use strict;
use Genelet::Dispatch;
use Genelet::Beacon;

use vars qw(@ISA);
@ISA = qw(Genelet::Beacon);

__PACKAGE__->setup_accessors(
  config => Genelet::Dispatch::get_hash("/home/open/mlm/conf/config.json"),
  lib    => '/home/open/mlm/lib',
  ip     => '192.168.29.29',
  comps  => ["Admin","Affiliate","Signup","Member","Sponsor","Placement","Category","Gallery","Package", "Packagedetail","Packagetype","Sale","Basket","Lineitem","Income","Incomeamount","Ledger","Tt","Ttpost","Week1","Week4","Affiliate"],
  tag    => 'json',
  header => {'Content-Type' => "application/x-www-form-urlencoded", 'Cookie' => "go_probe=1"}
);

1;
