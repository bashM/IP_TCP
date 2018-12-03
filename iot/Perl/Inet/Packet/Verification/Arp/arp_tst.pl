#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Packet/Verification/Arp/arp_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Packet::Arp;

my $y = Inet::Packet::Arp->new();
$y->set_src_ip("192.168.18.21");
$y->set_opcode("ARP-REQUEST");
my $message = $y->encode();
$y->set_src_ip("garbage");
$y->dump();
$y->decode($message);
$y->dump();

