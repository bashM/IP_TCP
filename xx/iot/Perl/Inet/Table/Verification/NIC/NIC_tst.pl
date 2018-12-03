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
use Tosf::Exception::Trap;


Inet::Table::NIC->set_ip('eth0', '192.168.6.0');
Inet::Table::NIC->set_mac('eth0', '77');

Inet::Table::NIC->set_ip('p2p1', '192.168.6.1');
Inet::Table::NIC->set_mac('p2p1', 23);

my $x = Inet::Table::NIC->my_mac(24);
print("Value of x $x \n");
#Inet::Table::NIC->dump();

#print("===============================\n");
#my $str = Inet::Table::NIC->dumps();
#print $str;
 

