#!/usr/bin/perl
######################################################
# Peter Walsh
# File: NODE_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Collection::NODE;

Inet::Collection::NODE->set_node("Peter");
my $x = Inet::Collection::NODE->get_node();
print("Node $x \n");
Inet::Collection::NODE->set_iport("9090");
$x = Inet::Collection::NODE->get_iport();
print("Port $x \n");



