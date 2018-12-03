package Inet::Record::Nic;
#================================================================--
# File Name    : Record/Nic.pm
#
# Purpose      : implements NicSC (Socket Client) record
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
      type => my $type = ' ',
      ip => my $ip = ' ',
      mac => my $mac = ' ',
      open => my $open = 0,
      line => Tosf::Collection::Line->new()
   };
                
   bless ($self, $class);
   return $self;
}

sub get_open {
   my $self = shift @_;

   return $self->{open};
}

sub set_open {
   my $self = shift @_;
   my $o = shift @_;

   $self->{open} = $o;
   return;
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

sub get_type {
   my $self = shift @_;
   
   return $self->{type};
}

sub set_type {
   my $self = shift @_;
   my $t = shift @_;
 
   $self->{type} = $t;
   return;
}

sub dequeue_packet {
   my $self = shift @_;

   return $self->{line}->dequeue_packet();
}

sub dequeue_packet_fragment {
   my $self = shift @_;
   my $s = shift @_;

   return ($self->{line})->dequeue_packet_fragment($s);
}

sub flush {
   my $self = shift @_;
 
   $self->{line}->flush();
   return;
}

sub enqueue_packet {
   my $self = shift @_;
   my $p = shift @_;
 
   $self->{line}->enqueue_packet($p);
   return;
}

sub enqueue_packet_fragment {
   my $self = shift @_;
   my $f = shift @_;
 
   $self->{line}->enqueue_packet_fragment($f);
   return;
}

sub dumps {
   my $self = shift @_;

   my $s = '';

   $s = $s . "Type: $self->{type} ";
   $s = $s . "Ip: $self->{ip} ";
   $s = $s . "Mac: $self->{mac} ";

   return $s;
}

sub dump {
   my $self = shift @_;

   print ("Type: $self->{type} \n");
   print ("Ip: $self->{ip} \n");
   print ("Mac: $self->{mac} \n");
   print ("Line: \n");
   $self->{line}->dump();
}

1;
