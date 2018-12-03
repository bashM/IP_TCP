#!/usr/bin/perl
######################################################
# Peter Walsh
# File: IOBUFFER.pl
# Module test driver
# Marius' test case
######################################################

use lib '../../../../';
use Tosf::Collection::Line;
use Tosf::Collection::IOBUFFER;

my $x = "INIT";
Tosf::Collection::IOBUFFER->send('enqueue_packet_fragment', "Peter \n");
Tosf::Collection::IOBUFFER->send('dump');
$x = Tosf::Collection::IOBUFFER->send('dequeue_packet');
print("PACKET $x \n");
Tosf::Collection::IOBUFFER->send('dump');
print("====================\n");


Tosf::Collection::IOBUFFER->send('enqueue_packet', "Paul");
Tosf::Collection::IOBUFFER->send('dump');
$x = Tosf::Collection::IOBUFFER->send('dequeue_packet_fragment');
print("PACKET FRAG $x \n");
print("//////////////////////////\n");
Tosf::Collection::IOBUFFER->send('dump');

