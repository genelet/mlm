package MLM::Placement::Model;

use strict;
use Data::Dumper;
use MLM::Model;
use vars qw($AUTOLOAD @ISA);

@ISA=('MLM::Model');

my $name = sub {
	my $item = shift;
	my $admin = shift;
    return ($admin) ? "<a href='placement?action=view_binary&memberid=$item->{memberid}'>".$item->{login}." $item->{leg}/$item->{typeid}<br>$item->{milel} - $item->{memberid} - $item->{miler}</a>" : $item->{login};
};

sub view_binary {
  my $self = shift;
  my $ARGS = $self->{ARGS};

  my $lists = [];
  my $err = $self->select_sql($lists,
"SELECT memberid, login, pid, leg, active, milel, miler, login, sid, typeid, LEFT(signuptime,10) AS signuptime
FROM member");
  return $err if $err;
  
  my $ref = {};
  for my $item (@$lists) {
    $ref->{$item->{memberid}} = $item;
  }
  my $newref = make_parent($ref, $ARGS->{top_memberid});

  #$self->{LISTS} = [];
  my $str = "<ul>\n\t<li>\n\t".$name->($ref->{$ARGS->{memberid}}, $ARGS->{_gadmin})."\n";
  $self->_lower_level($ref, $newref, \$str, 0, $ARGS->{memberid});
  $str .= "\t</li>\n</ul>\n";

  $self->{OTHER}->{tree} = $str;
  return;
}

sub _lower_level {
	my $self = shift;
	my ($ref, $newref, $str, $i, $id) = @_;
	#push @{$self->{LISTS}}, $ref->{$id};
	my $item = $newref->{$id};
	return unless $item;
	$i++;
	return if ($i >= $self->{ARGS}->{max_plevel});
	my $old     = "\t" x $i;
	my $leading = "\t" x ($i+1);
	my $left  = $item->{'L'};
	my $right = $item->{'R'};
	if ($left or $right) {
		$$str .= $old . "<ul>\n"
	}
	if ($left) {
		$$str .= $leading . "<li>\n" . $leading. $name->($ref->{$left}, $self->{ARGS}->{_gadmin})."\n";
		$self->_lower_level($ref, $newref, $str, $i, $left);
		$$str .= $leading . "</li>\n"
	} elsif ($right) {
		$$str .= $leading . "<li></li>\n";
	}
	if ($right) {
		$$str .= $leading . "<li>\n" . $leading. $name->($ref->{$right}, $self->{ARGS}->{_gadmin})."\n";
		$self->_lower_level($ref, $newref, $str, $i, $right);
		$$str .= $leading . "</li>\n";
	} elsif ($left) {
		$$str .= $leading . "<li></li>\n";
	}
	if ($left or $right) {
		$$str .= $old . "</ul>\n";
	}
	return;
}

sub leave_tree {
  my $self = shift;
  my $ARGS = $self->{ARGS};
  my $mid = $ARGS->{memberid};

  my $err = $self->get_args($ARGS,
"SELECT top AS membertop
FROM member
WHERE memberid=?", $mid)
# children have the same top as the member will use member as their top
	|| $self->do_sql(
"UPDATE member m
INNER JOIN family f ON (m.memberid=f.child)
SET m.top=?
WHERE f.parent=? AND m.top=?", $mid, $mid, $ARGS->{membertop})
	|| $self->do_sql(
"UPDATE member SET leg='L', pid=1, top=1
WHERE memberid=?", $mid)
	|| $self->do_sql("CALL proc_leave(?)", $mid)
	|| $self->do_sql(
"UPDATE member m
INNER JOIN temp_leave l ON (m.memberid=l.parent AND m.defpid=l.child)
SET m.defpid=NULL, m.defleg=NULL");
	return $err if $err;

	if ($ARGS->{is_deduct} eq 'Yes') {
		return $self->do_sql(
"UPDATE member m
INNER JOIN temp_leave_total tmp ON (m.memberid=tmp.parent)
SET countl=countl-tmp.cleft, milel=milel-tmp.sleft, countr=countr-tmp.cright, miler=miler-tmp.sright")
	|| $self->do_sql(
"UPDATE leftright lr
INNER JOIN temp_leave_level tmp ON (lr.memberid==tmp.parent AND lr.level=tmp.level)
SET numleft=numleft-tmp.sleft, numright=numright-tmp.sright");
	} 
	return $self->do_sql(
"UPDATE member m
INNER JOIN temp_leave_total tmp ON (m.memberid=tmp.parent)
SET countl=countl-tmp.cleft, countr=countr-tmp.cright");
}

sub join_tree {
	my $self = shift;

# 1) find its new top
# 2) children have the same top as the member will use member as their top
# 3) updaate member's new top, pid and leg
# 4) those using member position as defpid, defleg should be NULL and NULL
# 5) call proc_join to make new temp_family table
# 6) update counts and miles in member
# 7) insert temp_family to family
  my $self = shift;
  my $ARGS = $self->{ARGS};
  my $mid = $ARGS->{memberid};
  my $pid = $ARGS->{pid};
  my $leg = $ARGS->{leg};

  my $err = $self->get_args($ARGS,
"SELECT top AS pidtop, leg AS pidleg
FROM member
WHERE memberid=?", $pid);
  return $err if $err;
  my $top = $pid;
  if ($ARGS->{pidleg}==$leg) {
    $top = $ARGS->{pidtop};
# children have the same top as the member will use pidtop
    $err = $self->do_sql(
"UPDATE member m
INNER JOIN family f ON (m.memberid=f.child)
SET m.top=?
WHERE f.parent=? AND m.top=? AND m.leg=?", $ARGS->{pidtop}, $mid, $mid, $leg);
    return $err if $err;
  }
  $err = $self->do_sql(
"UPDATE member SET pid=?, leg=?, top=?
WHERE memberid=?", $pid, $leg, $top, $mid)
	|| $self->do_sql(
"UPDATE member SET defpid=NULL, defleg=NULL
WHERE defpid=? AND defleg=?", $pid, $leg)
    || $self->do_sql("CALL proc_join(?,?,?)", $mid, $pid, $leg)
	|| $self->do_sql(
"INSERT INTO family (parent, child, leg, level)
SELECT parent, child, leg, level
FROM temp_join");
  return $err if $err;

  if ($ARGS->{is_add} eq 'Yes') {
	return $self->do_sql(
"INSERT INTO leftright (member, level, numleft, numright)
SELECT parent, level, sleft, sright
FROM temp_family_level tmp
ON DUPLICATE KEY UPDATE numleft=numleft+tmp.sleft numright=numright+tmp.sright")
	|| $self->do_sql(
"UPDATE member m
INNER JOIN temp_family_total tmp ON (m.memberid=tmp.parent)
SET m.countl=m.countl+tmp.cleft, m.milel=m.milel+tmp.sleft, m.countr=m.countr+tmp.cright, m.miler=m.miler+tmp.sright");
  }
  return $self->do_sql(
"UPDATE member m
INNER JOIN temp_family_total tmp ON (m.memberid=tmp.parent)
SET m.countl=m.countl+tmp.cleft, m.countr=m.countr+tmp.cright");
}

# ref = {55555=>{pid=>4444,leg=>'L'} is from the member table,
# build new reference with parent as key. value a hash of L and R memberid.
# solar is a special member id which may have many downlines, so we rmove it
sub make_parent {
	my $ref = shift;
	my $solar = shift;
	my $newref = {};
	while (my ($child, $item) = each %$ref) {
		my $parent = $item->{pid};
		next if ($parent == $solar);
		$newref->{$parent}->{$item->{leg}} = $child;
	}
	return $newref;
}

# based on the above parent reference, make family tree as array of hashes;
sub make_family {
	my $ref = shift;
	my $tree = [];
	while (my ($parent, $item) = each %$ref) {
		next_item($ref, $parent, $item, 'L', $tree, 1);
	}
	return $tree;
}
	
sub next_item {
	my ($ref, $parent, $item, $leg, $tree, $level) = @_;
	return unless $item;
	my $L = $item->{L};
	my $R = $item->{R};
	my $newleg = $leg;
	if ($L) {
		$newleg = 'L' if ($level==1);
		push @$tree, {parent=>$parent, level=>$level, leg=>$newleg, child=>$L};
		next_item($ref, $parent, $ref->{$L}, $newleg, $tree, $level+1)
	}
	if ($R) {
		$newleg = 'R' if ($level==1);
		push @$tree, {parent=>$parent, level=>$level, leg=>$newleg, child=>$R};
		next_item($ref, $parent, $ref->{$R}, $newleg, $tree, $level+1)
	}
	return;
}

1;
