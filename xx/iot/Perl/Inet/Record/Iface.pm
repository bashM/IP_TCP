package Inet::Record::Iface;
#================================================================--
# File Name    : Record/Iface.pm
#
# Purpose      : implements device control record 
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
   my %params = @_;
   
   my $self = {
      opened => my $opened = 0,
      type => my $type = "stream",
      ip => my $ip = "noip",
      mac => my $mac = "nomac",
      line => Tosf::Collection::Line->new()
   };
                
   bless ($self, $class);
   return $self;
}

sub set_inLeftFrame {
   my $self = shift @_;
   my $f = shift @_;

   $self->{line}->set_inLeftFrame($f);
}

sub set_inRightFrame {
   my $self = shift @_;
   my $f = shift @_;

   $self->{line}->set_inRightFrame($f);
}

sub set_outRightFrame {
   my $self = shift @_;
   my $f = shift @_;

   $self->{line}->set_outRightFrame($f);
}

sub set_outLeftFrame {
   my $self = shift @_;
   my $f = shift @_;

   $self->{line}->set_outLeftFrame($f);
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

sub get_opened {
   my $self = shift @_;

   return $self->{opened};
}

sub set_opened {
   my $self = shift @_;
   my $o = shift @_;

   $self->{opened} = $o;
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

   $s = $s . "Opened: $self->{opened} ";
   $s = $s . "Type: $self->{type} ";
   $s = $s . "Nic: $self->{nicName} ";

   return $s;
}

sub dump {
   my $self = shift @_;

   print ("Opened: $self->{opened} \n");
   print ("Type: $self->{type} \n");
   print ("Ip: $self->{ip} \n");
   print ("Mac: $self->{mac} \n");
   print ("Line: \n");
   $self->{line}->dump();
}

1;
