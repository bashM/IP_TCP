package VTap::Collection::HOST;
#================================================================--
# File Name    : HOST.pm
#
# Purpose      : implements HOST ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my $host = 'unknown';
my $port = 'unknown';


sub set_host {
   my $pkg = shift @_;
   my $nme = shift @_;
   
   $host = $nme;

   return;
}

sub get_host {
   my $pkg = shift @_;

   return $host;
}

sub set_port {
   my $pkg = shift @_;
   my $p = shift @_;
   
   $port = $p;

   return;
}

sub get_port {
   my $pkg = shift @_;

   return $port;
}

sub dump {
   my $self = shift @_;
   
   print ("Tap HOST: ", $host, "\n");
   print ("Tap PORT: ", $port, "\n");

   return;
}

1;
