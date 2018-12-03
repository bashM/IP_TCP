package Inet::Collection::NODE;
#================================================================--
# File Name    : NODE.pm
#
# Purpose      : implements NODE ADT
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

my $node = 'Node';
my $ihost = 'unknown';
my $iport = 'unknown';
my $version = 'unknown';

sub set_name {
   my $pkg = shift @_;
   my $nme = shift @_;
   
   $node = $nme;

   return;
}

sub get_name {
   my $pkg = shift @_;

   return $node;
}

sub set_version {
   my $pkg = shift @_;
   my $v = shift @_;
   
   $version = $v;

   return;
}

sub get_version {
   my $pkg = shift @_;

   return $version;
}

sub set_ihost {
   my $pkg = shift @_;
   my $h = shift @_;
   
   $ihost = $h;

   return;
}

sub set_iport {
   my $pkg = shift @_;
   my $p = shift @_;
   
   $iport = $p;

   return;
}

sub get_iport {
   my $pkg = shift @_;

   return $iport;
}

sub get_ihost {
   my $pkg = shift @_;

   return $ihost;
}

sub dump {
   my $self = shift @_;
   
   print ("NODE: ", $node, "\n");
   print ("iHOST: ", $ihost, "\n");
   print ("iPORT: ", $iport, "\n");
   print ("VERSION: ", $version, "\n");

   return;
}

1;
