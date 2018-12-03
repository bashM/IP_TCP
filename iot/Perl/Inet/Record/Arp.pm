package Inet::Record::Arp;
#================================================================--
# File Name    : Record/Arp.pm
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

my $mac = ' ';

sub  new {
   my $class = shift @_;

   my $self = {mac => $mac
   };
                
   bless ($self, $class);
   return $self;
}

sub get_mac {
   my $self = shift @_;
   
   return $self->{mac};
}

sub set_mac {
   my $self = shift @_;
   my $m = shift @_;
 
   $self->{mac} = $m;
   return;
}

sub dumps {
   my $self = shift @_;

   my $s = '';

   $s = $s . "Mac: $self->{mac}";

   return $s;
}


sub dump {
   my $self = shift @_;

   print ("Mac: $self->{mac} \n");
   return;
}

1;
