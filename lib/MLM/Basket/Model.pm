package MLM::Basket::Model;

use strict;
use MLM::Model;
use vars qw($AUTOLOAD @ISA);

@ISA=('MLM::Model');

sub topics {
  my $self = shift;
  my $ARGS = $self->{ARGS};
  my $extra = shift;

	$self->{LISTS} = [];
	my $err = $self->select_sql($self->{LISTS},
"SELECT basketid, classify, id, title, logo, price, sh, bv, qty,
	(qty*price) AS amount, (qty*bv) AS credit, (qty*sh) AS shipping
FROM sale_basket b
INNER JOIN product_gallery g ON (b.id=g.galleryid AND b.classify='gallery')
WHERE memberid=? AND inbasket='Yes'
UNION
SELECT basketid, classify, id, title, logo, price, sh, bv, qty,
	(qty*price) AS amount, (qty*bv) AS credit, (qty*sh) AS shipping
FROM sale_basket b
INNER JOIN product_package g ON (b.id=g.packageid AND b.classify='package')
WHERE memberid=? AND inbasket='Yes'", $ARGS->{memberid}, $ARGS->{memberid});

	$ARGS->{amount} = 0;
	$ARGS->{credit} = 0;
	$ARGS->{shipping} = 0;
	for (@{$self->{LISTS}}) {
		$ARGS->{amount}   += $_->{amount};
		$ARGS->{credit}   += $_->{credit};
		$ARGS->{shipping} += $_->{shipping};
	}

	return $self->process_after("topics", @_);
}

1;
