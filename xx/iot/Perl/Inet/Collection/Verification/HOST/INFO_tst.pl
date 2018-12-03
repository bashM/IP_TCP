#!/usr/bin/perl
######################################################
# Peter Walsh
# File: INFO_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Collection::INFO;

Inet::Collection::INFO->set_host("Peter");
my $x = Inet::Collection::INFO->get_host();
print("Host $x \n");
Inet::Collection::INFO->set_port("9090");
$x = Inet::Collection::INFO->get_port();
print("Port $x \n");



