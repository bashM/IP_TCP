#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Table/Verification/IFACE_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Inet::Table::IFACE;
use Inet::Record::Iface;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;


Inet::Table::IFACE->set_opened('p0', '1');
Inet::Table::IFACE->enqueue_packet('p0', 'Test P0');

Inet::Table::IFACE->set_opened('p1', '0');
Inet::Table::IFACE->enqueue_packet('p1', 'Test P1');
Inet::Table::IFACE->dump();

#Inet::Table::IFACE->flush('peter');
Inet::Table::IFACE->dump();

Inet::Table::IFACE->enqueue_packet('Iface9', 'HelloWorld\n');
Inet::Table::IFACE->set_type('Iface9', 'stream');
my $str = Inet::Table::IFACE->get_streamIface();
print("XXX STREAM $str \n");
Inet::Table::IFACE->dump();

