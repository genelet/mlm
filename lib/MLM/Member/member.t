#!/usr/bin/perl
# Unit tests for MLM::Member::Model

package MemberTest;

use strict;
use warnings;
use Test::More;
use base qw(Test::Class);

use lib '../..';
use MLM::Member::Model;
use MLM::Member::Filter;

# Test that module loads correctly
sub test_module_loads : Test(2) {
    my $self = shift;
    use_ok('MLM::Member::Model');
    use_ok('MLM::Member::Filter');
}

# Test inheritance
sub test_inheritance : Test(2) {
    my $self = shift;
    ok(MLM::Member::Model->isa('MLM::Model'), 'Model inherits from MLM::Model');
    ok(MLM::Member::Filter->isa('MLM::Filter'), 'Filter inherits from MLM::Filter');
}

# Test that key methods exist
sub test_model_methods_exist : Test(8) {
    my $self = shift;
    can_ok('MLM::Member::Model', 'dashboard');
    can_ok('MLM::Member::Model', 'startnew');
    can_ok('MLM::Member::Model', 'bulk');
    can_ok('MLM::Member::Model', 'get_signup');
    can_ok('MLM::Member::Model', 'sponsor_top_pid');
    can_ok('MLM::Member::Model', 'changedef');
    can_ok('MLM::Member::Model', 'resetpass');
    can_ok('MLM::Member::Model', 'changepass');
}

sub test_filter_methods_exist : Test(3) {
    my $self = shift;
    can_ok('MLM::Member::Filter', 'preset');
    can_ok('MLM::Member::Filter', 'before');
    can_ok('MLM::Member::Filter', 'after');
}

# Test Filter security helper methods inherited from MLM::Filter
sub test_filter_security_helpers : Test(4) {
    my $self = shift;
    can_ok('MLM::Member::Filter', 'escape_like_value');
    can_ok('MLM::Member::Filter', 'validate_column');
    can_ok('MLM::Member::Filter', 'validate_date_part');
    can_ok('MLM::Member::Filter', 'build_like_sql');
}

package main;

Test::Class->runtests;
