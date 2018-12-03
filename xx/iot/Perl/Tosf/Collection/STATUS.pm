package Tosf::Collection::STATUS;
#================================================================--
# File Name    : STATUS.pm
#
# Purpose      : implements tosf status ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my $cycleComplete = 1;
my $currentExecutingTask;

sub set_cycleComplete {
   my $self = shift @_;
   my $v = shift @_;
   
   $cycleComplete =  $v;

   return;
}

sub get_cycleComplete {
   my $self = shift @_;

   return $cycleComplete;
}

sub set_currentExecutingTask {
   my $self = shift @_;
   my $t = shift @_;
   
   $currentExecutingTask =  $t;

   return;
}

sub get_currentExecutingTask {
   my $self = shift @_;

   return $currentExecutingTask;
}

1;
