package Unit;

use strict;
use warnings;
use Test::More;
use Data::Dumper;
use parent 'Genelet::Test';
use MLM::Placement::Model;
use MLM::Placement::Filter;

sub initialize {
  my $self = shift;

  return {
	config=>"/home/open/mlm/conf/config.json",
	data=>"unit.json",
	component=>"component.json"
  };
}

sub ca_makeparent : Test(no_plan) {
  my $self = shift;
  my $arr = $self->{DATA}->{ca_makeparent};
  return unless ($arr); 

  my $ref = {
    1=>{pid=>   0,leg=>'L'},
   11=>{pid=>   1,leg=>'L'},
  111=>{pid=>  11,leg=>'L'},
 1111=>{pid=> 111,leg=>'L'},
11111=>{pid=>1111,leg=>'L'},
   22=>{pid=>   1,leg=>'R'},
  222=>{pid=>  22,leg=>'R'},
 2222=>{pid=> 222,leg=>'R'},
  333=>{pid=>  22,leg=>'L'},
 3333=>{pid=> 333,leg=>'L'},

 4444=>{pid=>   0,leg=>'L'},
55555=>{pid=>4444,leg=>'L'},
66666=>{pid=>4444,leg=>'R'}};

  my $model = $self->{_model};

  for my $item (@$arr) {
    # make_parent is a class method only
    my $newref = MLM::Placement::Model::make_parent($ref, $item->{input}->{pid});
    while (my ($k, $v) = each %{$item->{output}}) {
      my $expect = $newref->{$k}->{$v->[0]};
      is($expect, $v->[1], "make_parent(): $expect is $v->[1]");
    }
  }

  return;
}

sub cb_makefamily : Test(no_plan) {
  my $self = shift;
  my $arr = $self->{DATA}->{cb_makefamily};
  return unless ($arr); 

  my $ref = {
    1=>{pid=>   0,leg=>'L'},
   11=>{pid=>   1,leg=>'L'},
  111=>{pid=>  11,leg=>'L'},
 1111=>{pid=> 111,leg=>'L'},
11111=>{pid=>1111,leg=>'L'},
   22=>{pid=>   1,leg=>'R'},
  222=>{pid=>  22,leg=>'R'},
 2222=>{pid=> 222,leg=>'R'},
  333=>{pid=>  22,leg=>'L'},
 3333=>{pid=> 333,leg=>'L'},

 4444=>{pid=>   0,leg=>'L'},
55555=>{pid=>4444,leg=>'L'},
66666=>{pid=>4444,leg=>'R'}};

  my $model = $self->{_model};

  my $eq = sub {
     my $obj1 = shift;
     my $obj2 = shift;
     for my $k (keys %$obj1) {
       if ($obj1->{$k} ne $obj2->{$k}) {
         return 0;
       }
     }
     return 1;
  };

  for my $item (@$arr) {
    # class method only
    my $newref = MLM::Placement::Model::make_parent($ref, $item->{input}->{pid});
    my $family = MLM::Placement::Model::make_family($newref);
    my $found = 0;
    for my $obj (@$family) {
      if ($eq->($item->{output}, $obj) ==1) {
        $found = 1;
        last;
      }
    } 
    is($found, $item->{expected}, "make_family() with $found");
  }

  return;
}

package main;

Unit->runtests;
