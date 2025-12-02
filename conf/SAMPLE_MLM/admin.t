package Unit;

use strict;
use warnings;
use Genelet::Test;
use MLM::Admin::Model;
use MLM::Admin::Filter;

use parent 'Genelet::Test';

sub initialize {
  my $self = shift;

  return {
	config=>"/SAMPLE_home/mlm/conf/config.json",
	data=>"unit.json",
	component=>"component.json"
  };
}

package main;

Unit->runtests;
