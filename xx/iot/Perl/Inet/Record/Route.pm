package Inet::Record::Route;
#================================================================--
# File Name    : Record/Route.pm
#
# Purpose      : implements Route record
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

my $interface = ' ';
my $gateway = ' ';

sub  new {
   my $class = shift @_;

   my $self = {interface => $interface,
      gateway => $gateway
   };
                
   bless ($self, $class);
   return $self;
}

sub get_interface {
   my $self = shift @_;
   
   return $self->{interface};
}

sub set_interface {
   my $self = shift @_;
   my $i = shift @_;
 
   $self->{interface} = $i;
   return;
}

sub get_gateway {
   my $self = shift @_;

   return $self->{gateway};
}

sub set_gateway {
   my $self = shift @_;
   my $g = shift @_;

   $self->{gateway} = $g;
   return;
}

sub dumps {
   my $self = shift @_;

   my $s = '';

   $s = $s . "Interface: $self->{interface} ";
   $s = $s . "Gateway: $self->{gateway} ";

   return $s;
}

sub dump {
   my $self = shift @_;

   print ("Interface: $self->{interface} ");
   print ("Gateway: $self->{gateway} \n");

}

1;
