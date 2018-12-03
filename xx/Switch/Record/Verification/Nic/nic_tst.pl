#!/usr/bin/perl
######################################################
# Peter Walsh
# File: nic_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Switch::Record::Nic;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;

my $x = VHub::Record::Nic->new();
$x->set_mac('607');
$x->enqueue_packet("Peter");
$x->dump();

my $y = VHub::Record::Nic->new();
$y->set_mac('608');
$y->set_open('1');
$y->enqueue_packet("paul");
$y->dump();
