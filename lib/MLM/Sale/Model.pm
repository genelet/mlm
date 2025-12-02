package MLM::Sale::Model;

use strict;
use warnings;
use MLM::Model;
our $AUTOLOAD;

use parent 'MLM::Model';

sub myInvoice {
  my $self = shift;
  my $ARGS = $self->{ARGS};

  $self->{LISTS} = [];
  return $self->select_sql($self->{LISTS},
"SELECT s.saleid, s.amount, s.credit, s.paytype, s.paystatus,p.title, b.qty
FROM sale s JOIN def_type t ON s.typeid = t.typeid
JOIN sale_lineitem i ON s.saleid = i.saleid
JOIN sale_basket b ON i.basketid = b.basketid
join product_package p on b.id = p.packageid
where b.classify = 'package' AND s.saleid=?
union all
SELECT s.saleid, s.amount, s.credit, s.paytype, s.paystatus,g.title, b.qty
FROM sale s JOIN def_type t ON s.typeid = t.typeid
JOIN sale_lineitem i ON s.saleid = i.saleid
JOIN sale_basket b ON i.basketid = b.basketid
join product_gallery g on b.id = g.galleryid
where b.classify = 'gallery' AND s.saleid=?", $ARGS->{saleid}, $ARGS->{saleid});
}
  
sub buy {
  my $self = shift;
  my $ARGS = $self->{ARGS};
  my $extra = shift;

  my $err = $self->call_once({model=>"basket", action=>"topics"});
  return $err if $err;

  my $need = $ARGS->{amount} + $ARGS->{shipping};
  my $ledger = $self->{OTHER}->{ledger_currentBalance}->[0];
  my $have = $ledger->{balance} + $ledger->{shop_balance};
  my $d1 = 0;
  my $d2 = 0;
  if ($have<$need) {
	return 3201;
  } elsif ($ledger->{shop_balance}<$need) {
    return 3202 unless ($ARGS->{agreebalance} eq 'Yes');
    $d1 = $ledger->{shop_balance};
    $d2 = $need - $d1;
  } else {
    $d1 = $need;
  }

  $err = $self->do_sql(
"INSERT INTO sale (memberid, amount, credit, shipping, paytype, paystatus, typeid, active, created)
VALUES (?, ?, ?, ?, 'Advanced', 'Processing', ".$ARGS->{shop_typeid}.", 'Yes', NOW())", map {$ARGS->{$_}} (qw(memberid amount credit shipping)));
  return $err if $err;

  my $saleid = $self->last_insertid();
  my $str1 = "INSERT INTO sale_lineitem (saleid, basketid, amount, credit) VALUES ";
  my $str2 = "UPDATE sale_basket SET inbasket='No' WHERE basketid IN (";
  for my $item (@{$self->{OTHER}->{basket_topics}}) {
    $str1 .= "($saleid, " . $item->{basketid} . ", " . ($item->{amount}+$item->{shipping}) . ", " . $item->{credit} . "),";
    $str2 .= $item->{basketid} . ",";
  }
  substr($str1,-1,1)="";
  substr($str2,-1,1)=") AND memberid=".$ARGS->{memberid};
  $err = $self->do_sql($str1) || $self->do_sql($str2) || $self->do_sql(
"INSERT INTO income_ledger (memberid, amount, balance, shop_balance, old_ledgerid, weekid, created, status)
VALUES (?,?,?,?,?,?,NOW(),'Shopping')",
$ARGS->{memberid}, -1*$need, $ledger->{balance}-$d2, $ledger->{shop_balance}-$d1, $ledger->{ledgerid}, $ledger->{weekid});
}

1;
