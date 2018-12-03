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

my $x = Inet::Packet::Ip->new();
my $y = Inet::Packet::Ip->new();
$y->set_src_ip("192.168.18.21");
$y->set_msg("Hello World");
my $message = $y->encode();
print ("message: $message \n");
$y->set_src_ip("hhhhhhh");
$y->dump();
$y->decode($message);
$y->dump();

my $a = Inet::Packet::Icmp->new();
$a->dump();
if ($a->packet_in_error()) {
   print ("packet in err\n");
} else {
   print ("packet OK\n");
}
   
my $h = Inet::Packet::Generic->new();
$h->dump();
