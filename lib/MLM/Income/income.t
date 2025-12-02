#!/usr/bin/perl
# Unit tests for MLM::Income::Model

package IncomeTest;

use strict;
use warnings;
use Test::More;
use base qw(Test::Class);

use lib '../..';
use MLM::Income::Model;
use MLM::Income::Filter;

# Test that module loads correctly
sub test_module_loads : Test(2) {
    my $self = shift;
    use_ok('MLM::Income::Model');
    use_ok('MLM::Income::Filter');
}

# Test inheritance
sub test_inheritance : Test(2) {
    my $self = shift;
    ok(MLM::Income::Model->isa('MLM::Model'), 'Model inherits from MLM::Model');
    ok(MLM::Income::Filter->isa('MLM::Filter'), 'Filter inherits from MLM::Filter');
}

# Test that key compensation methods exist
sub test_model_methods_exist : Test(16) {
    my $self = shift;
    # Core methods
    can_ok('MLM::Income::Model', 'inserts');
    can_ok('MLM::Income::Model', 'run_daily');
    can_ok('MLM::Income::Model', 'run_cron');
    can_ok('MLM::Income::Model', 'run_all_tests');
    can_ok('MLM::Income::Model', 'run_to_yesterday');

    # Affiliate bonus methods
    can_ok('MLM::Income::Model', 'is_week1_affiliate');
    can_ok('MLM::Income::Model', 'week1_affiliate');
    can_ok('MLM::Income::Model', 'done_week1_affiliate');
    can_ok('MLM::Income::Model', 'weekly_affiliate');

    # Binary/Pairing bonus methods
    can_ok('MLM::Income::Model', 'is_week1_binary');
    can_ok('MLM::Income::Model', 'week1_binary');
    can_ok('MLM::Income::Model', 'done_week1_binary');
    can_ok('MLM::Income::Model', 'weekly_binary');

    # Direct/Unilevel bonus methods
    can_ok('MLM::Income::Model', 'is_week4_direct');
    can_ok('MLM::Income::Model', 'week4_direct');
    can_ok('MLM::Income::Model', 'monthly_direct');
}

# Test match bonus methods
sub test_match_methods_exist : Test(4) {
    my $self = shift;
    can_ok('MLM::Income::Model', 'is_week1_match');
    can_ok('MLM::Income::Model', 'week1_match');
    can_ok('MLM::Income::Model', 'done_week1_match');
    can_ok('MLM::Income::Model', 'weekly_match');
}

sub test_filter_methods_exist : Test(3) {
    my $self = shift;
    can_ok('MLM::Income::Filter', 'preset');
    can_ok('MLM::Income::Filter', 'before');
    can_ok('MLM::Income::Filter', 'after');
}

# Test Filter security helper methods inherited from MLM::Filter
sub test_filter_security_helpers : Test(4) {
    my $self = shift;
    can_ok('MLM::Income::Filter', 'escape_like_value');
    can_ok('MLM::Income::Filter', 'validate_column');
    can_ok('MLM::Income::Filter', 'validate_date_part');
    can_ok('MLM::Income::Filter', 'build_like_sql');
}

package main;

Test::Class->runtests;
