#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Table/Verification/DCB_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Inet::Table::DCB;
use Inet::Record::Dcb;
use Inet::Table::ROUTE;
use Inet::Record::Route;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;


Inet::Table::DCB->set_opened('p0', '1');
Inet::Table::DCB->enqueue_packet('p0', 'Test P0');

Inet::Table::DCB->set_opened('p1', '0');
Inet::Table::DCB->enqueue_packet('p1', 'Test P1');
Inet::Table::DCB->dump();

Inet::Table::DCB->set('p2', '1');
#Inet::Table::DCB->flush('peter');
Inet::Table::DCB->dump();

print("===============================\n");
my $str = Inet::Table::DCB->dumps();
print $str;
print("*********************************\n");
 
my %nt = (
   maxbuff => 10000,
   inLeftFrame => '',
   inRightFrame => "\n",
   outLeftFrame => '',
   outRightFrame => "\n"
);

Inet::Table::DCB->enqueue_packet('stdio', 'HelloWorld\n', %nt);
Inet::Table::DCB->dump();

