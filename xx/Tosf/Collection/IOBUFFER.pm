package Tosf::Collection::IOBUFFER;
#================================================================--
# File Name    : IOBUFFER.pm
#
# Purpose      : maintains a line instance for io buffering
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my $line = Tosf::Collection::Line->new(
   maxbuff => 10000,
   inLeftFrame => '',
   inRightFrame => "\n",
   outLeftFrame => '', 
   outRightFrame => "\n"
);

my @params;

my %methods = (
   "dump" => sub { $line->dump(@params); },
   "enqueue_packet_fragment" => sub { $line->enqueue_packet_fragment(@params); },
   "dequeue_packet_fragment" => sub { $line->dequeue_packet_fragment(@params); },
   "enqueue_packet" => sub { $line->enqueue_packet(@params); },
   "dequeue_packet" => sub { $line->dequeue_packet(@params); }
);


sub send {
   my $self = shift @_;
   my $met = shift @_;
   @params = shift @_;

   $methods{$met}->();

}

1;
