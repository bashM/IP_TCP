#!/usr/bin/perl
######################################################
# Peter Walsh
# File: FLAG_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Collection::FLAG;

Inet::Collection::FLAG->set_trace(1);
my $x = Inet::Collection::FLAG->get_trace();
print("Trace $x \n");
Inet::Collection::FLAG->set_warning(0);
$x = Inet::Collection::FLAG->get_warning();
print("Warning $x \n");



