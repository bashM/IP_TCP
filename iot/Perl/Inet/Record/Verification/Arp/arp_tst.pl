#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Record/Verification/Arp/arp_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Record::Arp;
use Tosf::Exception::Trap;

my $x = Inet::Record::Arp->new();
$x->set_mac('23');
$x->dump();
my $y = $x->get_mac();
print ("max addr: $y \n");
