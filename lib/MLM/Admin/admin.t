package Unit;

use strict;
use Genelet::Test;
use MLM::Admin::Model;
use MLM::Admin::Filter;

use vars qw(@ISA);
@ISA = qw(Genelet::Test);

sub initialize {
  my $self = shift;

  return {
	config=>"/home/open/mlm/conf/config.json",
	data=>"unit.json",
	component=>"component.json"
  };
}

package main;

Unit->runtests;
