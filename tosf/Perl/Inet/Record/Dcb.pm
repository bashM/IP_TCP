package Inet::Record::Dcb;
#================================================================--
# File Name    : Record/Dcb.pm
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
      line => Tosf::Collection::Line->new(
         maxbuff => 10000,
         inLeftFrame => $params{inLeftFrame},
         inRightFrame => $params{inRightFrame},
         outLeftFrame => $params{outLeftFrame},
         outRightFrame => $params{outRightFrame}
      )
   };
                
   bless ($self, $class);
   return $self;
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

   return $s;
}

sub dump {
   my $self = shift @_;

   print ("Opened: $self->{opened} \n");
   print ("Line: \n");
   $self->{line}->dump();
}

1;
