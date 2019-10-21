package MLM::Model;

use strict;
use Genelet::Model;
use Genelet::Mysql;
use Genelet::Crud;

use vars qw(@ISA);
@ISA = qw(Genelet::Model Genelet::Mysql);

__PACKAGE__->setup_accessors(
	'total_force' => 1,
);

1;
