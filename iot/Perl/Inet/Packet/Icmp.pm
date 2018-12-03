package Inet::Packet::Icmp;
#================================================================--
# File Name    : Packet/Icmp.pm
#
# Purpose      : implements Icmp packet ADT
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

use constant PCHAR => '_M_';

my $password = "Meg-ICMP";

sub  new {
   my $class = shift @_;
   my $name = shift @_;

   my $self = {
      type => my $type = ' ',
      err => my $err = ' ',
      msg => my $msg = ' '
   };

   $self->{err} = $password;
   bless ($self, $class);

   return $self;
}

sub get_type {
   my $self = shift @_;
   
   return $self->{type};
}

sub set_type {
   my $self = shift @_;
   my $typ = shift @_;
 
   if (defined($typ)) {
      $self->{type} = $typ;
   }

   return;
}

sub get_err {
   my $self = shift @_;

   return $self->{err};
}

sub set_err {
   my $self = shift @_;
   my $er = shift @_;
 
   if (defined($er)) {
      $self->{err} = $er;
   }

   return;
}

sub packet_in_error {
   my $self = shift @_;
 
   return ($self->{err} ne $password);
}

sub get_msg {
   my $self = shift @_;

   return $self->{msg};
}

sub set_msg {
   my $self = shift @_;
   my $ms = shift @_;

   if (defined($ms)) {
      $self->{msg} = $ms;
   }

   return;
}

sub encode {
   my $self = shift @_;

   my @m;
   $m[0] = $self->{type};
   $m[1] = $self->{err};
   $m[2] = $self->{msg};

   return join(PCHAR, @m);
}

sub decode {
   my $self = shift @_;
   my $pkt = shift @_;

   my @m = split(PCHAR, $pkt);

   $self->{type} = $m[0];
   $self->{err} = $m[1];
   $self->{msg} = $m[2];

   return;
}

sub dump {
   my $self = shift @_;

   print ("TYPE: $self->{type} \n");
   print ("ERR: $self->{err} \n");
   print ("MSG: $self->{msg} \n");

   return;
}

1;
