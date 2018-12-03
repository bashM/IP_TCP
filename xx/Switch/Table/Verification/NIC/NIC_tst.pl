#!/usr/bin/perl
######################################################
# Peter Walsh
# File: NIC_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Tosf::Exception::Trap;
use Switch::Record::Nic;
use Switch::Table::NIC;
use Tosf::Collection::Line;


Switch::Table::NIC->set_mac('eth0', '77');
Switch::Table::NIC->enqueue_packet('eth0', 'Test Pe');

Switch::Table::NIC->set_mac('eth1', '78');
Switch::Table::NIC->enqueue_packet('eth1', 'Test Pa');
#Switch::Table::NIC->dump();


Switch::Table::NIC->set('peter', 'CLOSED', '33', 10);
Switch::Table::NIC->enqueue_packet('peter', 'Test 123');
#Switch::Table::NIC->remove('peter');


Switch::Table::NIC->dump();

