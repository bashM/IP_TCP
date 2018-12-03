package Inet::Record::Nic;
#================================================================--
# File Name    : Record/Nic.pm
#
# Purpose      : implements Nic record
#
# Author       : Peter Walsh, Vancouver Island University
#
# System       : Perl (Linux)
#
#=========================================================

$| = 1;
use strict;
use warnings;

sub  new {
   my $class = shift @_;

   my $self = {
      ip => my $ip = ' ',
      mac => my $mac = ' ',
      devName => my $devName = 'noname'
   };
                
   bless ($self, $class);
   return $self;
}

sub get_ip {
   my $self = shift @_;

   return $self->{ip};
}

sub set_ip {
   my $self = shift @_;
   my $ip = shift @_;

   $self->{ip} = $ip;
   return;
}

sub get_devName {
   my $self = shift @_;

   return $self->{devName};
}

sub set_devName {
   my $self = shift @_;
   my $id = shift @_;

   $self->{devName} = $id;
   return;
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

   $s = $s . "Ip: $self->{ip} ";
   $s = $s . "Mac: $self->{mac} ";
   $s = $s . "Dev: $self->{devName} ";

   return $s;
}

sub dump {
   my $self = shift @_;

   print ("Ip: $self->{ip} \n");
   print ("Mac: $self->{mac} \n");
   print ("Dev: $self->{devName} \n");
}

1;
