#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Table/Verification/NIC/NIC_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Inet::Table::NIC;
use Inet::Record::Nic;
use Inet::Table::ROUTE;
use Inet::Record::Route;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;


Inet::Table::NIC->set_type('eth0', 'ethernet');
Inet::Table::NIC->set_ip('eth0', '192.168.6.0');
Inet::Table::NIC->set_mac('eth0', '77');
Inet::Table::NIC->enqueue_packet('eth0', 'Test Pe');

Inet::Table::NIC->set_type('p2p1', 'p2p');
Inet::Table::NIC->set_ip('p2p1', '192.168.6.1');
Inet::Table::NIC->set_mac('p2p1', 'dc');
Inet::Table::NIC->enqueue_packet('p2p1', 'Test Pa');
Inet::Table::NIC->dump();

Inet::Table::NIC->set('peter', 'ethernet', '192.168.1.3', '33', 0);
#Inet::Table::NIC->flush('peter');
Inet::Table::NIC->dump();

print("===============================\n");
my $str = Inet::Table::NIC->dumps();
print $str;
 

