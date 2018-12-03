#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Table/Verification/DEV_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Inet::Table::DEV;
use Inet::Record::Dev;
use Inet::Table::ROUTE;
use Inet::Record::Route;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;


Inet::Table::DEV->set_opened('p0', '1');
Inet::Table::DEV->enqueue_packet('p0', 'Test P0');

Inet::Table::DEV->set_opened('p1', '0');
Inet::Table::DEV->enqueue_packet('p1', 'Test P1');
Inet::Table::DEV->dump();

#Inet::Table::DEV->flush('peter');
Inet::Table::DEV->dump();

Inet::Table::DEV->enqueue_packet('Dev9', 'HelloWorld\n');
Inet::Table::DEV->set_type('Dev9', 'stream');
my $str = Inet::Table::DEV->get_streamDev();
print("XXX STREAM $str \n");
Inet::Table::DEV->dump();

