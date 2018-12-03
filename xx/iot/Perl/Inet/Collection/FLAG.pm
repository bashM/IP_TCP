package Inet::Collection::FLAG;
#================================================================--
# File Name    : FLAG.pm
#
# Purpose      : flags for debugging ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant TRUE => 1;
use constant FALSE => 0;

my $trace = TRUE;
my $warning = TRUE;

sub set_trace {
   my $pkg = shift @_;
   my $t = shift @_;
   
   $trace = $t;

   return;
}

sub get_trace {
   my $pkg = shift @_;

   return $trace;
}

sub set_warning {
   my $pkg = shift @_;
   my $w = shift @_;
   
   $warning = $w;

   return;
}

sub get_warning {
   my $pkg = shift @_;

   return $warning;
}

sub dump {
   my $pkg = shift @_;

   print ("Inet Trace: ", $trace, "\n");
   print ("Inet Warning: ", $warning, "\n");

   return;
}

1;
