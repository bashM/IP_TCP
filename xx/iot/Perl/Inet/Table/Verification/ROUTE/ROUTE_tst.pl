#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Table/Verification/Route/ROUTE_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Try::Tiny;
use Tosf::Exception::Trap;
use Inet::Table::ROUTE;
use Inet::Record::Route;


print("Typical usage \n");
Inet::Table::ROUTE->set_route('192.168.6.3', '0.0.0.0', 'lo');
Inet::Table::ROUTE->set_route('192.168.6.33', '0.0.0.0', 'eth1');
Inet::Table::ROUTE->set_route('192.168.6', '0.0.0.0', 'eth0');
Inet::Table::ROUTE->set_route('0.0.0.0', '10.0.0.1', 'p2p0');

my $i;
my $g;

($i, $g) = Inet::Table::ROUTE->get_route('192.168.6.3');
print("Interface $i Gateway $g \n");
Inet::Table::ROUTE->dump();

