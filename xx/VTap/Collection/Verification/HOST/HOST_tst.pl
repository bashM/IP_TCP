#!/usr/bin/perl
######################################################
# Peter Walsh
# File: HOST_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use VTap::Collection::HOST;

VTap::Collection::HOST->set_host("Peter");
my $x = VTap::Collection::HOST->get_host();
print("$x \n");
VTap::Collection::HOST->set_port("9090");
$x = VTap::Collection::HOST->get_port();
print("$x \n");



