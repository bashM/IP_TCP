package Inet::Collection::HOST;
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

use AnyEvent;

my $host_name = '';
my $boot_time = 0;
my $version = 'unknown';
my $router_flag = 0; 


sub set_version {
   my $pkg = shift @_;
   my $ver = shift @_;
   
   $version = $ver;

}

sub get_version {
   my $pkg = shift @_;

   return $version;
}

sub set_boot_time {
   my $pkg = shift @_;
   my $tme = shift @_;
   
   $boot_time = $tme;

   return;
}

sub get_boot_time {
   my $pkg = shift @_;

   return $boot_time;
}

sub set_name {
   my $pkg = shift @_;
   my $nme = shift @_;
   
   $host_name= $nme;

   return;
}

sub get_name {
   my $pkg = shift @_;

   return $host_name;
}

sub set_router_flag {
   my $pkg = shift @_;
   my $f = shift @_;

   $router_flag= $f;

   return;
}

sub get_router_flag {
   my $pkg = shift @_;

   return $router_flag;
}

sub dump {
   my $self = shift @_;
   
   print ("HOST NAME: ", $host_name, "\n");
   print ("HOST BOOT TIME: ", $boot_time, "\n");
   print ("Inet Version: ", $version , "\n");
   print ("Router Flag: ", $router_flag , "\n");

   return;
}

1;
