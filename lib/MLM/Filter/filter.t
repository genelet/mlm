#!/usr/bin/perl
# Unit tests for MLM::Filter helper methods (SQL injection prevention)

package FilterTest;

use strict;
use warnings;
use Test::More;
use base qw(Test::Class);

# Load the module under test
use lib '../..';
use MLM::Filter;

# Create a mock filter object for testing
sub setup : Test(setup) {
    my $self = shift;
    # Create a minimal filter object
    $self->{filter} = bless {}, 'MLM::Filter';
}

# Tests for escape_like_value
sub test_escape_like_value_basic : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->escape_like_value('test');
    is($result, 'test', 'Basic string unchanged');
}

sub test_escape_like_value_single_quote : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->escape_like_value("test'value");
    is($result, "test\\'value", 'Single quote escaped');
}

sub test_escape_like_value_percent : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->escape_like_value('test%value');
    is($result, 'test\\%value', 'Percent wildcard escaped');
}

sub test_escape_like_value_underscore : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->escape_like_value('test_value');
    is($result, 'test\\_value', 'Underscore wildcard escaped');
}

sub test_escape_like_value_backslash : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->escape_like_value('test\\value');
    is($result, 'test\\\\value', 'Backslash escaped');
}

sub test_escape_like_value_sql_injection : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->escape_like_value("'; DROP TABLE member; --");
    is($result, "\\'; DROP TABLE member; --", 'SQL injection attempt escaped');
}

sub test_escape_like_value_undef : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->escape_like_value(undef);
    is($result, '', 'Undefined returns empty string');
}

# Tests for validate_column
sub test_validate_column_valid : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_column('login', [qw(login email phone)]);
    is($result, 'login', 'Valid column returns column name');
}

sub test_validate_column_invalid : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_column('password', [qw(login email phone)]);
    is($result, undef, 'Invalid column returns undef');
}

sub test_validate_column_injection_attempt : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_column('login; DROP TABLE', [qw(login email)]);
    is($result, undef, 'SQL injection in column name rejected');
}

sub test_validate_column_undef : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_column(undef, [qw(login email)]);
    is($result, undef, 'Undefined column returns undef');
}

# Tests for validate_date_part
sub test_validate_date_part_valid : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_date_part('2024');
    is($result, '2024', 'Valid year returns value');
}

sub test_validate_date_part_month : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_date_part('12');
    is($result, '12', 'Valid month returns value');
}

sub test_validate_date_part_invalid : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_date_part('2024-01');
    is($result, undef, 'Non-numeric rejected');
}

sub test_validate_date_part_injection : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->validate_date_part("1; DROP TABLE");
    is($result, undef, 'SQL injection in date rejected');
}

# Tests for build_like_sql
sub test_build_like_sql_prefix : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->build_like_sql('login', 'john', 1);
    is($result, "login LIKE 'john\%'", 'Prefix match SQL built correctly');
}

sub test_build_like_sql_contains : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->build_like_sql('login', 'john', 0);
    is($result, "login LIKE '\%john\%'", 'Contains match SQL built correctly');
}

sub test_build_like_sql_with_escape : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->build_like_sql('login', "john'smith", 1);
    is($result, "login LIKE 'john\\'smith\%'", 'Special chars escaped in LIKE');
}

# Tests for build_date_range_sql
sub test_build_date_range_sql_valid : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->build_date_range_sql('created',
        '2024', '01', '01', '2024', '12', '31');
    is($result, "created >= '2024-01-01 00:00:01' AND created <= '2024-12-31 23:59:59'",
        'Date range SQL built correctly');
}

sub test_build_date_range_sql_invalid_year : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->build_date_range_sql('created',
        '2024abc', '01', '01', '2024', '12', '31');
    is($result, undef, 'Invalid year rejected');
}

sub test_build_date_range_sql_injection : Test(1) {
    my $self = shift;
    my $result = $self->{filter}->build_date_range_sql('created',
        "2024'; DROP TABLE", '01', '01', '2024', '12', '31');
    is($result, undef, 'SQL injection in date rejected');
}

package main;

# Run tests
Test::Class->runtests;
