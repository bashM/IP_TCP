#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Record/Verification/Nic/nic_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Record::Nic;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;

my $x = Inet::Record::Nic->new();
$x->set_type('ethernet');
$x->set_ip('192.168.6.23');
$x->set_mac('607');
$x->enqueue_packet("Peter");
$x->dump();

my $y = Inet::Record::Nic->new();
$y->set_type('p2p');
$y->set_ip('192.168.6.24');
$y->set_mac('608');
$y->enqueue_packet("paul");
$y->dump();
