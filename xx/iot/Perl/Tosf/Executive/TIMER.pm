package Tosf::Executive::TIMER;
#================================================================--
# File Name    : Executive/TIMER.pm
#
# Purpose      : timer
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;
#no warnings "experimental::smartmatch";

my $sec = 1.0;

sub set_period {
   my $self = shift @_;
   $sec = shift @_;
}

# signal alarm in 2.5s & every .1s thereafter
#   ualarm(2_500_000, 100_000);

sub start {
   my $self = shift @_;

   my $usec = int($sec * 1000000);
   print("usec $usec \n");

   Time::HiRes::ualarm(1000_000, $usec);
}

#convert seconds to ticks
sub s2t {
   my $self = shift @_;
   my $s = shift @_;

   return int($s / $sec);
}

#convert ticks to seconds
sub t2s {
   my $self = shift @_;
   my $t = shift @_;

   return($t * $sec);
}

1;
