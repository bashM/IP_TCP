#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Packet/Verification/Udp/udp_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';

use Inet::Packet::Udp;
use Inet::Packet::Ip;
use Tosf::Exception::Trap;

my $y = Inet::Packet::Ip->new();
$y->set_src_ip("192.168.18.21");
$y->set_dest_ip("192.168.18.22");

my $z = Inet::Packet::Udp->new();
$z->set_src_port(23);
$z->set_dest_port(24);
$z->set_msg("Hello World");
#$y->set_msg($z->encode());
my $udp_raw = $z->encode();
$y->set_msg($udp_raw);
$y->dump();
my $ip_raw = $y->encode();
print ("IP RAW: $ip_raw \n");
$y->dump();

my $a = Inet::Packet::Ip->new();
$a->decode($ip_raw);
my $xx = $a->get_msg();
$a->dump();
my $b = Inet::Packet::Udp->new();
$b->decode($a->get_msg());
my $src = $b->get_src_port();
my $dest = $b->get_dest_port();
print ("src port: $src dest port: $dest \n");

