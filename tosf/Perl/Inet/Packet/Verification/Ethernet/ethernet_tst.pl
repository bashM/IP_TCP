#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Packet/Verification/Ethernet/ethernet_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Packet::Ethernet;
use Inet::Packet::Ip;
use Inet::Packet::Udp;

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
my $ip_raw = $y->encode();

my $matty = Inet::Packet::Ethernet->new();
$matty->set_msg($ip_raw);
my $matty_raw = $matty->encode();

my $c = Inet::Packet::Ethernet->new();
$c->decode($matty_raw);
$a = Inet::Packet::Ip->new();
$a->decode($c->get_msg());
my $b = Inet::Packet::Udp->new();
$b->decode($a->get_msg());
my $src = $b->get_src_port();
my $dest = $b->get_dest_port();
$b->dump();
print ("src port: $src dest port: $dest \n");

