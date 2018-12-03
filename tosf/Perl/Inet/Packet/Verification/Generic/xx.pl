#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Packet/Verification/Generic/generic_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Packet::Ip;
use Inet::Packet::Icmp;
use Inet::Packet::Generic;

my $h = Inet::Packet::Generic->new();
$h->dump();
