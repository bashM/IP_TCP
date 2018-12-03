#!/usr/bin/perl
######################################################
# Peter Walsh
# File: Record/Verification/Nic/dcb_tst.pl
# Module test driver
######################################################

$| = 1;
use strict;
use warnings;

use lib '../../../../';
use Inet::Record::Dcb;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;

my $x = Inet::Record::Dcb->new(
   maxbuff => 10000,
   inLeftFrame => '',
   inRightFrame => "\n",
   outLeftFrame => '',
   outRightFrame => "\n"
);

$x->set_opened('1');
$x->enqueue_packet("Peter");
$x->dump();

my $y = Inet::Record::Dcb->new();
$y->set_opened('0');
$y->enqueue_packet("paul");
$y->dump();
