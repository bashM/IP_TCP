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
use Inet::Table::MAC;

Inet::Table::MAC->dump();
Inet::Table::MAC->add(7, "ether0");
Inet::Table::MAC->dump();

