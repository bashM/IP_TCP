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
use VHost::Collection::HOST;

VHost::Collection::HOST->set_host("Peter");
my $x = VHost::Collection::HOST->get_host();
print("$x \n");
VHost::Collection::HOST->set_port("9090");
$x = VHost::Collection::HOST->get_port();
print("$x \n");



