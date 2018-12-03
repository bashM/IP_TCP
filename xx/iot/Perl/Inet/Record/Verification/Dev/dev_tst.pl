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
use Inet::Record::Dev;
use Tosf::Collection::Line;
use Tosf::Exception::Trap;

my $x = Inet::Record::Dev->new();

$x->set_opened('1');
$x->enqueue_packet("Peter");
$x->set_inRightFrame("FRAME_IN_RIGHT");
$x->set_outRightFrame("FRAME_OUT_RIGHT");
$x->set_outLeftFrame("FRAME_OUT_LEFT");
$x->set_inLeftFrame("FRAME_IN_LEFT");
$x->dump();

my $y = Inet::Record::Dev->new();
$y->set_opened('0');
$y->enqueue_packet("paul");
$y->dump();
